"""Records the source tree's files, or prunes installed copies of build-tree files.

The build runs in-source, so CMake writes Makefiles, object files, and modules into
Contrib/ and Projects/, and upstream installs those directories whole. Recording
their contents before configuring lets the install drop whatever the build added.

Usage:
    source_tree_files.py record <source_root> <manifest> <directory>...
    source_tree_files.py prune <installed_root> <manifest> <directory>...
"""

import sys
from pathlib import Path


def _files(root: Path, directories: list[str]) -> set[str]:
    """Returns the files under ``root/directory`` as posix paths relative to ``root``."""
    found = set()
    for directory in directories:
        base = root / directory
        if base.is_dir():
            found.update(p.relative_to(root).as_posix() for p in base.rglob("*") if p.is_file())
    return found


def main(argv: list[str]) -> None:
    """Runs the ``record`` or ``prune`` command given in ``argv``.

    Args:
        argv: The command, a root directory, the manifest path, and the directories.

    Raises:
        SystemExit: If the command is not ``record`` or ``prune``.
    """
    command, root, manifest, directories = argv[0], Path(argv[1]), Path(argv[2]), argv[3:]
    if command == "record":
        manifest.write_text("".join(f"{p}\n" for p in sorted(_files(root, directories))))
        return
    if command != "prune":
        raise SystemExit(f"unknown command: {command}")
    keep = set(manifest.read_text().splitlines())
    removed = sorted(_files(root, directories) - keep)
    for relative in removed:
        (root / relative).unlink()
    for directory in directories:
        base = root / directory
        if base.is_dir():
            for path in sorted(base.rglob("*"), key=lambda p: len(p.parts), reverse=True):
                if path.is_dir() and not any(path.iterdir()):
                    path.rmdir()
    print(f"Removed {len(removed)} build-tree files from {', '.join(directories)}")


if __name__ == "__main__":
    main(sys.argv[1:])
