"""Run: python tests/remote-backup-receiver.test.py (no server required)."""

import datetime as dt
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock


SCRIPT = Path(__file__).resolve().parents[1] / "Tools/db/remote-backup-receiver.py"
SPEC = importlib.util.spec_from_file_location("remote_backup_receiver", SCRIPT)
receiver = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(receiver)
NOW = dt.datetime(2026, 11, 5, 4, 0, tzinfo=receiver.BEIJING)
NAME = "mth_20261105_040000.sql"
CONTENT = b"-- isolated backup fixture\nCREATE TABLE backup_check (id int);\n"
HASH = hashlib.sha256(CONTENT).hexdigest()


class ReceiverTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory()
        self.addCleanup(self.temporary.cleanup)
        self.directory = Path(self.temporary.name)

    def write(self, name, content=CONTENT):
        path = self.directory / name
        path.write_bytes(content)
        return path

    def upload(self, name=NAME, content=CONTENT):
        return self.write(name + ".partial", content)

    def finalize(self, name=NAME, expected_hash=HASH, keep_days=3, now=NOW):
        return receiver.finalize_backup(str(self.directory), name, expected_hash, keep_days, now)

    def symlink(self, link, target, directory=False):
        try:
            link.symlink_to(target, target_is_directory=directory)
        except (OSError, NotImplementedError) as exc:
            self.skipTest("Symlink creation is unavailable: " + str(exc))

    def test_success_creates_checksum_and_removes_partial(self):
        partial = self.upload()
        result = self.finalize(expected_hash=HASH.upper())
        self.assertFalse(partial.exists())
        self.assertEqual((self.directory / NAME).read_bytes(), CONTENT)
        self.assertEqual((self.directory / (NAME + ".sha256")).read_text(), HASH + "  " + NAME + "\n")
        self.assertEqual(result["sha256"], HASH)
        self.assertEqual(result["size"], len(CONTENT))
        self.assertEqual(result["deleted"], [])

    def test_hash_mismatch_preserves_old_backup_and_partial(self):
        old = self.write("mth_20261001_040000.sql")
        partial = self.upload(content=b"broken transfer")
        with self.assertRaisesRegex(receiver.BackupError, "mismatch"):
            self.finalize()
        self.assertTrue(old.exists())
        self.assertTrue(partial.exists())
        self.assertFalse((self.directory / NAME).exists())

    def test_cleanup_only_expired_matching_files_and_their_checksums(self):
        expired = "mth_20261102_235959.sql"
        self.write(expired)
        self.write(expired + ".sha256", b"old checksum")
        retained = [
            "mth_20261103_000000.sql", "mth_20261104_040000.sql",
            "mth_20261105_000001.sql", "mth_20261106_040000.sql",
            "mth_20261102_235959.sql.partial", "mth_20261102_235958.sql.sha256",
            "mth_20260230_040000.sql", "mth_20261102_246000.sql",
            "another_20261102_040000.sql", "notes.txt",
        ]
        for name in retained:
            self.write(name)
        nested = self.directory / "mth_20261101_040000.sql"
        nested.mkdir()
        (nested / "do-not-touch.sql").write_bytes(CONTENT)
        self.upload()
        result = self.finalize()
        self.assertEqual(result["deleted"], [expired, expired + ".sha256"])
        self.assertTrue(all((self.directory / name).exists() for name in retained))
        self.assertTrue((nested / "do-not-touch.sql").exists())
        self.assertEqual(result["retention"]["from_date"], "2026-11-03")

    def test_retry_without_upload_is_idempotent(self):
        self.upload()
        first = self.finalize()
        second = self.finalize()
        self.assertEqual(first, second)

    def test_retry_with_same_upload_is_idempotent(self):
        self.upload()
        self.finalize()
        partial = self.upload()
        self.finalize()
        self.assertFalse(partial.exists())

    def test_conflicting_final_file_is_preserved_and_does_not_prune(self):
        self.write(NAME, b"different existing backup")
        old = self.write("mth_20261001_040000.sql")
        partial = self.upload()
        with self.assertRaisesRegex(receiver.BackupError, "mismatch"):
            self.finalize()
        self.assertEqual((self.directory / NAME).read_bytes(), b"different existing backup")
        self.assertTrue(partial.exists())
        self.assertTrue(old.exists())

    def test_conflicting_partial_on_retry_is_preserved(self):
        self.upload()
        self.finalize()
        partial = self.upload(content=b"different new upload")
        old = self.write("mth_20261001_040000.sql")
        with self.assertRaisesRegex(receiver.BackupError, "mismatch"):
            self.finalize()
        self.assertTrue(old.exists())
        self.assertTrue(partial.exists())

    def test_uses_beijing_day_even_when_now_is_utc(self):
        self.upload()
        result = self.finalize(now=dt.datetime(2026, 11, 4, 20, 0, tzinfo=dt.timezone.utc))
        self.assertEqual(result["retention"]["to_date"], "2026-11-05")
        self.assertEqual(result["retention"]["from_date"], "2026-11-03")

    def test_one_day_retention_and_inclusive_oldest_day(self):
        self.upload()
        yesterday = self.write("mth_20261104_235959.sql")
        self.finalize(keep_days=1)
        self.assertFalse(yesterday.exists())
        oldest = "mth_20261103_000000.sql"
        self.upload(oldest)
        self.finalize(oldest)
        self.assertTrue((self.directory / oldest).exists())

    def test_invalid_inputs_never_prune(self):
        old = self.write("mth_20261001_040000.sql")
        for name in ["../" + NAME, "/" + NAME, "mth_20260230_040000.sql",
                     "mth_20261105_240000.sql", "mth_20261105_040000.sql\n",
                     "mth_20261106_040000.sql", "mth_20261102_040000.sql"]:
            with self.subTest(name=name), self.assertRaises(receiver.BackupError):
                self.finalize(name)
        for bad_hash in ["0" * 63, "g" * 64, HASH + "\n"]:
            with self.subTest(hash=bad_hash), self.assertRaises(receiver.BackupError):
                self.finalize(expected_hash=bad_hash)
        with self.assertRaises(receiver.BackupError):
            self.finalize(keep_days=0)
        self.assertTrue(old.exists())

    def test_empty_upload_does_not_prune(self):
        old = self.write("mth_20261001_040000.sql")
        self.upload(content=b"")
        with self.assertRaisesRegex(receiver.BackupError, "empty"):
            self.finalize(expected_hash=hashlib.sha256(b"").hexdigest())
        self.assertTrue(old.exists())

    def test_checksum_failure_preserves_old_backups_and_allows_retry(self):
        old = self.write("mth_20261001_040000.sql")
        self.upload()
        with mock.patch.object(receiver, "write_checksum", side_effect=OSError("disk full")):
            with self.assertRaises(OSError):
                self.finalize()
        self.assertTrue(old.exists())
        self.assertTrue((self.directory / NAME).exists())
        self.finalize()
        self.assertFalse(old.exists())

    def test_partial_symlink_is_rejected(self):
        target = self.write("unrelated.sql")
        self.symlink(self.directory / (NAME + ".partial"), target)
        with self.assertRaises(receiver.BackupError):
            self.finalize()
        self.assertEqual(target.read_bytes(), CONTENT)

    def test_final_or_checksum_symlink_is_rejected(self):
        target = self.write("unrelated.sql")
        for name in [NAME, NAME + ".sha256"]:
            with self.subTest(name=name):
                link = self.directory / name
                self.symlink(link, target)
                self.upload()
                with self.assertRaises(receiver.BackupError):
                    self.finalize()
                self.assertTrue(link.is_symlink())
                link.unlink()
        self.assertEqual(target.read_bytes(), CONTENT)

    def test_cleanup_preserves_symlinks_and_their_targets(self):
        target = self.write("unrelated.sql")
        linked_backup = self.directory / "mth_20261001_040000.sql"
        self.symlink(linked_backup, target)
        regular_backup = self.write("mth_20261002_040000.sql")
        linked_checksum = self.directory / (regular_backup.name + ".sha256")
        self.symlink(linked_checksum, target)
        self.upload()
        result = self.finalize()
        self.assertEqual(result["deleted"], [])
        self.assertTrue(linked_backup.is_symlink())
        self.assertTrue(linked_checksum.is_symlink())
        self.assertTrue(regular_backup.exists())
        self.assertEqual(target.read_bytes(), CONTENT)

    def test_directory_symlink_is_rejected(self):
        actual = self.directory / "actual"
        actual.mkdir()
        link = self.directory / "linked"
        self.symlink(link, actual, directory=True)
        with self.assertRaises(receiver.BackupError):
            receiver.finalize_backup(str(link), NAME, HASH, now=NOW)

    def test_cli_outputs_json_and_failure_exit_one(self):
        current_name = "mth_" + dt.datetime.now(receiver.BEIJING).strftime("%Y%m%d_%H%M%S") + ".sql"
        self.upload(current_name)
        command = [sys.executable, str(SCRIPT), "--directory", str(self.directory),
                   "--filename", current_name, "--sha256", HASH, "--keep-days", "3"]
        success = subprocess.run(command, capture_output=True, text=True)
        self.assertEqual(success.returncode, 0, success.stderr)
        payload = json.loads(success.stdout)
        self.assertEqual(payload["file"], current_name)
        self.assertEqual(payload["sha256"], HASH)
        self.assertNotIn("hash", payload)
        self.assertEqual(success.stderr, "")
        failure = subprocess.run(command + ["--unexpected"], capture_output=True, text=True)
        self.assertEqual(failure.returncode, 1)
        self.assertEqual(failure.stdout, "")
        self.assertNotIn("Traceback", failure.stderr)


if __name__ == "__main__":
    unittest.main(verbosity=2)
