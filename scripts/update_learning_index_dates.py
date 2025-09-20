#!/usr/bin/env python3
"""Update "최신 업데이트" dates in learning note index files."""

from __future__ import annotations

import datetime as dt
import os
import re
from pathlib import Path
from typing import Iterable

REPO_ROOT = Path(__file__).resolve().parents[1]
LEARNING_ROOT = REPO_ROOT / "docs" / "learning_notes"
INDEX_FILENAME = "index.md"
DATE_PATTERN = re.compile(r"(-\s*최신\s*업데이트:\s*)(\d{4}-\d{2}-\d{2})")


def find_index_files(root: Path) -> Iterable[Path]:
    for path in root.rglob(INDEX_FILENAME):
        yield path


def parse_links(markdown: str) -> list[Path]:
    links: list[Path] = []
    for match in re.finditer(r"\[([^\]]+)\]\(([^\)]+)\)", markdown):
        target = match.group(2)
        if target.endswith(".md"):
            links.append(Path(target))
    return links


def latest_date_from_files(base_dir: Path, links: list[Path]) -> dt.date | None:
    latest: dt.date | None = None

    for link in links:
        target_path = (base_dir / link).resolve()
        if not target_path.exists():
            continue

        if target_path.is_dir():
            continue

        try:
            mtime = dt.date.fromtimestamp(target_path.stat().st_mtime)
        except FileNotFoundError:
            continue

        if latest is None or mtime > latest:
            latest = mtime

    return latest


def update_index_file(index_path: Path) -> bool:
    content = index_path.read_text(encoding="utf-8")
    links = parse_links(content)
    latest = latest_date_from_files(index_path.parent, links)

    if latest is None:
        return False

    new_date = latest.strftime("%Y-%m-%d")

    def repl(match: re.Match[str]) -> str:
        prefix, _ = match.groups()
        return f"{prefix}{new_date}"

    updated_content = DATE_PATTERN.sub(repl, content, count=1)

    if updated_content == content:
        return False

    index_path.write_text(updated_content, encoding="utf-8")
    return True


def main() -> None:
    if not LEARNING_ROOT.exists():
        raise SystemExit("Learning notes directory not found")

    updated_files: list[Path] = []

    for index_file in find_index_files(LEARNING_ROOT):
        if update_index_file(index_file):
            updated_files.append(index_file.relative_to(REPO_ROOT))

    if updated_files:
        print("Updated index files:")
        for path in updated_files:
            print(f" - {path}")
    else:
        print("No index files needed updates.")


if __name__ == "__main__":
    main()
