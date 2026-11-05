#!/usr/bin/env python3
"""Verify an uploaded SQL file, publish it, and retain Beijing calendar days.

Install this script outside the backup account's writable directory, owned by
root. The caller uploads <filename>.partial before invoking this command.
"""

import argparse
import datetime as dt
import hashlib
import json
import os
from pathlib import Path
import re
import stat
import sys
import uuid


BEIJING = dt.timezone(dt.timedelta(hours=8))
BACKUP_NAME = re.compile(r"mth_([0-9]{8}_[0-9]{6})\.sql\Z")
SHA256 = re.compile(r"[0-9a-fA-F]{64}\Z")


class BackupError(Exception):
    """An upload cannot safely be finalized."""


def backup_date(filename):
    match = BACKUP_NAME.fullmatch(filename)
    if not match:
        raise BackupError("Invalid backup filename.")
    try:
        return dt.datetime.strptime(match.group(1), "%Y%m%d_%H%M%S").date()
    except ValueError as exc:
        raise BackupError("Invalid date in backup filename.") from exc


class BackupDirectory:
    """Pin the Linux directory and never follow a backup file's symlink."""

    def __init__(self, directory):
        self.path = Path(directory)
        if not self.path.is_absolute() or ".." in self.path.parts:
            raise BackupError("Backup directory must be an absolute path without '..'.")
        for component in reversed((self.path,) + tuple(self.path.parents)):
            if component.is_symlink():
                raise BackupError("Backup directory must not contain symlinks.")
        if not self.path.is_dir():
            raise BackupError("Backup directory does not exist.")
        self.fd = None

    def __enter__(self):
        if os.name == "posix":
            import fcntl

            self.fd = os.open(self.path, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
            try:
                fcntl.flock(self.fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except OSError:
                os.close(self.fd)
                self.fd = None
                raise BackupError("Another receiver is using this backup directory.")
        return self

    def __exit__(self, *unused):
        if self.fd is not None:
            os.close(self.fd)

    def entry(self, name):
        return name if self.fd is not None else self.path / name

    def info(self, name):
        try:
            return os.stat(self.entry(name), dir_fd=self.fd, follow_symlinks=False)
        except FileNotFoundError:
            return None

    def require_regular(self, name, optional=False):
        info = self.info(name)
        if info is None and optional:
            return None
        if info is None or not stat.S_ISREG(info.st_mode):
            raise BackupError("Expected a regular file: " + name)
        return info

    def open_file(self, name, flags, mode=0o600):
        flags |= getattr(os, "O_NOFOLLOW", 0) | getattr(os, "O_BINARY", 0)
        return os.open(self.entry(name), flags, mode, dir_fd=self.fd)

    def remove(self, name):
        os.unlink(self.entry(name), dir_fd=self.fd)

    def rename(self, source, destination):
        os.replace(self.entry(source), self.entry(destination),
                   src_dir_fd=self.fd, dst_dir_fd=self.fd)

    def sync(self):
        if self.fd is not None:
            os.fsync(self.fd)

    def names(self):
        return os.listdir(self.fd if self.fd is not None else self.path)


def identity(info):
    return info.st_dev, info.st_ino, info.st_size, info.st_mtime_ns


def verify_file(directory, name, expected_hash):
    before = directory.require_regular(name)
    digest = hashlib.sha256()
    with os.fdopen(directory.open_file(name, os.O_RDONLY), "rb") as stream:
        opened = os.fstat(stream.fileno())
        if identity(before) != identity(opened) or not stat.S_ISREG(opened.st_mode):
            raise BackupError("Backup file changed during verification.")
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
        after = os.fstat(stream.fileno())
    current = directory.require_regular(name)
    if identity(before) != identity(after) or identity(before) != identity(current):
        raise BackupError("Backup file changed during verification.")
    if after.st_size == 0:
        raise BackupError("Backup file is empty.")
    if digest.hexdigest() != expected_hash:
        raise BackupError("SHA-256 mismatch: " + name)
    return after.st_size


def write_checksum(directory, filename, expected_hash):
    checksum_name = filename + ".sha256"
    directory.require_regular(checksum_name, optional=True)
    temporary = "." + filename + "." + uuid.uuid4().hex + ".tmp"
    try:
        flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL
        with os.fdopen(directory.open_file(temporary, flags), "wb") as stream:
            stream.write((expected_hash + "  " + filename + "\n").encode("ascii"))
            stream.flush()
            os.fsync(stream.fileno())
        directory.rename(temporary, checksum_name)
        directory.sync()
    finally:
        if directory.info(temporary) is not None:
            directory.remove(temporary)


def prune_expired(directory, cutoff):
    deleted = []
    for name in sorted(directory.names()):
        try:
            expired = backup_date(name) < cutoff
        except BackupError:
            continue
        info = directory.info(name)
        if not expired or info is None or not stat.S_ISREG(info.st_mode):
            continue
        checksum_name = name + ".sha256"
        checksum_info = directory.info(checksum_name)
        # Preserve the pair when its checksum path is unusual, including a link.
        if checksum_info is not None and not stat.S_ISREG(checksum_info.st_mode):
            continue
        directory.remove(name)
        deleted.append(name)
        if checksum_info is not None:
            directory.remove(checksum_name)
            deleted.append(checksum_name)
    directory.sync()
    return deleted


def finalize_backup(directory, filename, expected_hash, keep_days=3, now=None):
    upload_date = backup_date(filename)
    if not SHA256.fullmatch(expected_hash):
        raise BackupError("Invalid SHA-256.")
    if not isinstance(keep_days, int) or keep_days < 1:
        raise BackupError("keep-days must be a positive integer.")
    expected_hash = expected_hash.lower()
    now = now or dt.datetime.now(BEIJING)
    if now.tzinfo is None:
        raise BackupError("Current time must include a timezone.")
    today = now.astimezone(BEIJING).date()
    cutoff = today - dt.timedelta(days=keep_days - 1)
    if not cutoff <= upload_date <= today:
        raise BackupError("Upload date is outside the current retention window.")

    with BackupDirectory(directory) as target:
        partial = filename + ".partial"
        target.require_regular(partial, optional=True)
        target.require_regular(filename + ".sha256", optional=True)
        if target.require_regular(filename, optional=True) is not None:
            size = verify_file(target, filename, expected_hash)
            # A repeated upload is accepted only if both copies have the same hash.
            if target.info(partial) is not None:
                verify_file(target, partial, expected_hash)
                target.remove(partial)
        else:
            size = verify_file(target, partial, expected_hash)
            target.rename(partial, filename)
            target.sync()
        write_checksum(target, filename, expected_hash)
        deleted = prune_expired(target, cutoff)

    return {
        "file": filename, "sha256": expected_hash, "size": size, "deleted": deleted,
        "retention": {
            "timezone": "Asia/Shanghai (UTC+08:00)", "keep_days": keep_days,
            "from_date": cutoff.isoformat(), "to_date": today.isoformat(),
            "rule": "Keep today and the preceding keep_days-1 Beijing calendar days; "
                    "preserve existing future-dated files and unrelated entries.",
        },
    }


class ArgumentParser(argparse.ArgumentParser):
    def error(self, message):
        raise BackupError(message)


def main(argv=None):
    try:
        parser = ArgumentParser(description=__doc__)
        parser.add_argument("--directory", required=True)
        parser.add_argument("--filename", required=True)
        parser.add_argument("--sha256", required=True)
        parser.add_argument("--keep-days", type=int, default=3)
        args = parser.parse_args(argv)
        result = finalize_backup(args.directory, args.filename, args.sha256, args.keep_days)
        print(json.dumps(result, ensure_ascii=True, sort_keys=True))
        return 0
    except (BackupError, OSError, OverflowError) as exc:
        print("Backup receiver failed: " + str(exc), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
