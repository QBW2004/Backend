"""Build/verify the clean snapshot on an isolated local MySQL 5.7 instance.

Requires pymysql. Restore the source snapshot to a mth_snapshot_* schema first.
The source defaults to mth_full.sql; --source-sql can rebuild from a prior clean snapshot.
Credentials come from MYSQL_PWD; neither SQL contents nor credentials are logged.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import time
from datetime import datetime, timezone

import pymysql

ROOT = Path(__file__).resolve().parents[2]


def require(condition, message):
    if not condition:
        raise RuntimeError(message)


def scalar(conn, sql, args=None):
    with conn.cursor() as cur:
        cur.execute(sql, args)
        return cur.fetchone()[0]


def execute(conn, sql, args=None):
    with conn.cursor() as cur:
        cur.execute(sql, args)


def tables(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT table_name FROM information_schema.tables WHERE table_schema=DATABASE() AND table_type='BASE TABLE' ORDER BY table_name")
        return [row[0] for row in cur.fetchall()]


def fingerprint(conn, names):
    result = {}
    with conn.cursor() as cur:
        for name in names:
            cur.execute('CHECKSUM TABLE `' + name + '` EXTENDED')
            checksum = cur.fetchone()[1]
            if checksum is None:
                raise RuntimeError('No checksum for ' + name)
            result[name] = {'rows': scalar(conn, 'SELECT COUNT(*) FROM `' + name + '`'), 'checksum': checksum}
    return result


def schema_signature(conn):
    result = {}
    with conn.cursor() as cur:
        for kind, query in {
            'columns': 'SELECT table_name,column_name,column_type,is_nullable,column_default,extra,character_set_name,collation_name FROM information_schema.columns WHERE table_schema=DATABASE() ORDER BY table_name,ordinal_position',
            'indexes': 'SELECT table_name,index_name,non_unique,seq_in_index,column_name,sub_part,index_type FROM information_schema.statistics WHERE table_schema=DATABASE() ORDER BY table_name,index_name,seq_in_index',
            'triggers': 'SELECT trigger_name,event_manipulation,event_object_table,action_statement,action_timing FROM information_schema.triggers WHERE trigger_schema=DATABASE() ORDER BY trigger_name',
            'routines': 'SELECT routine_name,routine_type,data_type,routine_definition FROM information_schema.routines WHERE routine_schema=DATABASE() ORDER BY routine_name',
            'routineParameters': 'SELECT specific_name,ordinal_position,parameter_mode,parameter_name,dtd_identifier,character_set_name,collation_name FROM information_schema.parameters WHERE specific_schema=DATABASE() ORDER BY specific_name,ordinal_position',
            'events': 'SELECT event_name,event_definition,status FROM information_schema.events WHERE event_schema=DATABASE() ORDER BY event_name',
            'views': 'SELECT table_name,view_definition FROM information_schema.views WHERE table_schema=DATABASE() ORDER BY table_name',
        }.items():
            cur.execute(query)
            rows = cur.fetchall()
            # View definitions qualify names with their current schema.
            current = scalar(conn, 'SELECT DATABASE()')
            canonical = json.dumps(rows, ensure_ascii=True, default=str).replace('`' + current + '`.', '`SCHEMA`.')
            result[kind] = {'count': len(rows), 'sha256': hashlib.sha256(canonical.encode()).hexdigest()}
    return result


def run_client(binary, port, user, schema, dump, log):
    started = time.perf_counter()
    with dump.open('rb') as source:
        proc = subprocess.run([str(binary), '--no-defaults', '--host=127.0.0.1', '--port=' + str(port), '--user=' + user, '--default-character-set=utf8mb4', schema], stdin=source, capture_output=True, timeout=300)
    log.write_bytes(proc.stdout + proc.stderr)
    if proc.returncode:
        raise RuntimeError('Import failed; inspect the private local log: ' + str(log))
    return round(time.perf_counter() - started, 3)


def normalize_comments(path):
    # Legacy .frm comments contain GBK bytes despite utf8 metadata. Data rows
    # must already be UTF-8; never guess the encoding of account/config values.
    lines = path.read_bytes().splitlines(keepends=True)
    converted = 0
    for i, line in enumerate(lines):
        try:
            line.decode('utf-8')
        except UnicodeDecodeError:
            if line.lstrip().startswith(b'INSERT') or b'COMMENT' not in line:
                raise RuntimeError('Invalid UTF-8 outside a legacy DDL comment')
            before, marker, after = line.partition(b'COMMENT')
            before.decode('utf-8')
            lines[i] = before + marker + after.decode('gbk').encode('utf-8')
            converted += 1
    path.write_bytes(b''.join(lines))
    return converted


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mysql-bin', required=True, type=Path)
    parser.add_argument('--port', required=True, type=int)
    parser.add_argument('--source-schema', required=True)
    parser.add_argument('--source-sql', type=Path, default=ROOT / 'Database/mth_full.sql')
    parser.add_argument('--admin-account', help='Optional new super-administrator account; omitted keeps the source account')
    parser.add_argument('--user', default='root')
    parser.add_argument('--evidence-dir', required=True, type=Path)
    args = parser.parse_args()
    if args.port in (3306, 3307) or not 1024 <= args.port <= 65535:
        parser.error('Use a dedicated non-default local test port')
    if not re.fullmatch(r'mth_snapshot_[a-z0-9_]+', args.source_schema):
        parser.error('Source schema must start with mth_snapshot_')
    if args.admin_account is not None and not re.fullmatch(r'[A-Za-z0-9_]{3,50}', args.admin_account):
        parser.error('Administrator account must contain 3-50 ASCII letters, digits or underscores')
    source = args.source_sql.resolve(strict=True)
    clean = ROOT / 'Database/mth_clean.sql'
    if clean.exists():
        parser.error('Archive the existing clean snapshot outside the repository first')
    raw = source.read_bytes()
    if re.search(rb'^(CREATE DATABASE|DROP DATABASE|USE )', raw, re.MULTILINE):
        raise RuntimeError('Snapshot must not select or create another database')
    policy = json.loads((ROOT / 'Database/clean-policy.json').read_text())
    args.evidence_dir.mkdir(parents=True, exist_ok=True)
    conn = pymysql.connect(host='127.0.0.1', port=args.port, user=args.user,
                           password=os.environ.get('MYSQL_PWD', ''), database=args.source_schema,
                           charset='utf8mb4', autocommit=True)
    require(scalar(conn, 'SELECT @@port') == args.port, 'Unexpected MySQL port')
    require(scalar(conn, 'SELECT @@lower_case_table_names') == 1, 'Requires lower_case_table_names=1')
    require(str(scalar(conn, 'SELECT @@version')).startswith('5.7.'), 'Requires MySQL 5.7')
    require(scalar(conn, 'SELECT default_collation_name FROM information_schema.schemata WHERE schema_name=DATABASE()') == 'utf8mb4_unicode_ci', 'Restore the source using utf8mb4_unicode_ci; routines inherit the database collation')
    names = tables(conn)
    classified = [name for group in policy.values() for name in group]
    require(len(classified) == len(set(classified)) and set(classified) == set(names), 'Unclassified or duplicate tables')
    require(scalar(conn, 'SELECT COUNT(*) FROM totalkill_table_backup') == 0, 'Restore active total-kill parameter backups before cleaning')
    require(scalar(conn, 'SELECT COUNT(*) FROM admin WHERE PRIV=0 AND RE_ENABLE=1') == 1, 'Exactly one enabled super administrator is required')
    baseline = fingerprint(conn, names)
    shape = schema_signature(conn)
    suffix = datetime.now(timezone.utc).strftime('%Y%m%d_%H%M%S_%f')
    work_schema = 'mth_clean_build_' + suffix
    verify_schema = 'mth_clean_verify_' + suffix
    report = {'capturedAtUtc': datetime.now(timezone.utc).isoformat(), 'sourceSnapshot': str(source), 'sourceRole': 'canonical-full' if source == (ROOT / 'Database/mth_full.sql').resolve() else 'explicit-snapshot', 'sourceSha256': hashlib.sha256(raw).hexdigest(), 'requestedAdminAccount': args.admin_account, 'policy': policy, 'timings': {}, 'schema': shape}
    started = time.perf_counter()
    for schema in (work_schema, verify_schema):
        execute(conn, 'CREATE DATABASE `' + schema + '` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci')
    report['timings']['sourceImportSeconds'] = run_client(args.mysql_bin / 'mysql.exe', args.port, args.user, work_schema, source, args.evidence_dir / 'source-import.log')
    conn.select_db(work_schema)
    require(fingerprint(conn, names) == baseline, 'Source schema differs from the supplied snapshot')
    require(schema_signature(conn) == shape, 'Source restore changed structure')
    keeper = scalar(conn, 'SELECT ID FROM admin WHERE PRIV=0 AND RE_ENABLE=1')
    original_password = scalar(conn, 'SELECT PWD FROM admin WHERE ID=%s', (keeper,))
    for name in policy['empty']:
        execute(conn, 'TRUNCATE TABLE `' + name + '`')
    execute(conn, 'DELETE FROM admin WHERE ID<>%s', (keeper,))
    if args.admin_account is not None:
        execute(conn, 'UPDATE admin SET ID=%s,UpdateTime=UpdateTime WHERE ID=%s', (args.admin_account, keeper))
        report['administratorRenamed'] = args.admin_account != keeper
        keeper = args.admin_account
    execute(conn, "UPDATE admin SET AGENCY='',COINS=0,RECHARGE=0,EXCHANGE=0,COINS_BUY=0,COINS_BACK=0,InviteCode=NULL,CustomerServiceUrl=NULL,PlayableGames=NULL")
    execute(conn, 'UPDATE gameacclaba SET Stock=0,MiniJackpot=0,MidJackpot=0,LargeJackpot=0')
    execute(conn, 'UPDATE games SET Num=0')
    execute(conn, 'UPDATE userrobotnum SET Num=0')
    execute(conn, "UPDATE roomtableowner SET LineAgent='#' WHERE LineAgent<>''")
    execute(conn, "DELETE FROM mjhl_agent_config WHERE LineAgent<>'*'")
    execute(conn, 'UPDATE mjhl_agent_config SET UpdatedBy=%s', (keeper,))
    execute(conn, 'UPDATE activityconfig SET Operator=%s', (keeper,))
    after = fingerprint(conn, names)
    require(all(after[n]['rows'] == 0 for n in policy['empty']), 'Historical data remains')
    require(all(after[n] == baseline[n] for n in policy['preserve']), 'Preserved configuration changed')
    require(scalar(conn, 'SELECT COUNT(*) FROM admin') == 1, 'Unexpected administrator count')
    require(scalar(conn, 'SELECT COUNT(*) FROM admin WHERE ID=%s AND BINARY PWD=BINARY %s', (keeper, original_password)) == 1, 'Administrator credential was not preserved')
    report['administratorPasswordPreserved'] = True
    require(scalar(conn, "SELECT COUNT(*) FROM roomtableowner WHERE LineAgent NOT IN ('','#')") == 0, 'Agent table ownership remains')
    require(scalar(conn, "SELECT COUNT(*) FROM mjhl_agent_config WHERE LineAgent='*' AND JSON_VALID(ConfigJson)") >= 1, 'Missing Mahjong public configuration')
    require(scalar(conn, 'SELECT COUNT(*) FROM clientpackage WHERE Enabled=1') > 0, 'Missing enabled client package')
    require(schema_signature(conn) == shape, 'Cleaning changed structure')
    pending = clean.with_suffix('.sql.pending')
    dumped = time.perf_counter()
    proc = subprocess.run([str(args.mysql_bin / 'mysqldump.exe'), '--no-defaults', '--host=127.0.0.1', '--port=' + str(args.port), '--user=' + args.user, '--default-character-set=utf8mb4', '--single-transaction', '--quick', '--hex-blob', '--routines', '--triggers', '--events', '--set-gtid-purged=OFF', '--skip-lock-tables', '--result-file=' + str(pending), work_schema], capture_output=True, timeout=300)
    (args.evidence_dir / 'clean-export.log').write_bytes(proc.stdout + proc.stderr)
    if proc.returncode:
        raise RuntimeError('Clean export failed; see private local log')
    report['normalizedLegacyCommentLines'] = normalize_comments(pending)
    report['timings']['cleanExportSeconds'] = round(time.perf_counter() - dumped, 3)
    report['timings']['cleanImportSeconds'] = run_client(args.mysql_bin / 'mysql.exe', args.port, args.user, verify_schema, pending, args.evidence_dir / 'clean-import.log')
    conn.select_db(verify_schema)
    require(fingerprint(conn, names) == after, 'Clean roundtrip changed table data')
    require(schema_signature(conn) == shape, 'Clean roundtrip changed structure')
    report['rows'] = {'source': baseline, 'clean': after}
    report['verifiedSchemas'] = [work_schema, verify_schema]
    report['cleanSha256'] = hashlib.sha256(pending.read_bytes()).hexdigest()
    report['timings']['totalSeconds'] = round(time.perf_counter() - started, 3)
    report['result'] = 'PASS'
    (args.evidence_dir / 'verification.json').write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding='utf-8')
    pending.replace(clean)
    print(json.dumps({'result': report['result'], 'tableCount': len(names), 'timings': report['timings'], 'normalizedLegacyCommentLines': report['normalizedLegacyCommentLines']}, indent=2))
    conn.close()


if __name__ == '__main__':
    main()
