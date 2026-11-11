"""Create reproducible CMM2 game/source archives and separately downloadable BASIC.

No third-party Python packages are needed. This script never changes the working
tree's Git index, branch or commits. Original media and map bytes are verified
against the upstream base before packaging.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import zipfile


ROOT = Path(__file__).resolve().parents[1]
BASE = "dc76eab5620afd6efc3511e7880d2316918dfdc9"
INCLUDES = {
    "ENEMIES.INC", "PRINT.INC", "LOAD_MAP.INC", "SOUND.INC",
    "COLLISION.INC", "EXIT.INC", "INIT_TEXT.INC", "INTRO.INC",
    "OPTIONS.INC", "PLAYER_SELECT.INC",
}
ASSET_EXTENSIONS = {
    "FONTS": {".png"}, "IMAGES": {".png"}, "MAPS": {".map", ".md"},
    "MOD": {".mod"}, "SOUND": {".wav"},
}
DOCS = {"README.md", "CHANGELOG-CMM2.md", "TESTING-CMM2.md"}
ZIP_DATE = (2026, 11, 11, 0, 0, 0)


def git(*arguments: str, env: dict | None = None) -> bytes:
    result = subprocess.run(["git", *arguments], cwd=ROOT, env=env,
                            capture_output=True, check=False)
    if result.returncode:
        raise RuntimeError(result.stderr.decode("utf-8", errors="replace"))
    return result.stdout


def safe_file(path: Path) -> Path:
    if path.is_symlink() or not path.is_file() or not path.resolve().is_relative_to(ROOT):
        raise ValueError(f"Package input must be a normal file inside this repository: {path}")
    # Reject junctions/reparse points in input directories as well as file links.
    for component in (path, *path.parents):
        if component == ROOT.parent:
            break
        if getattr(component.lstat(), "st_file_attributes", 0) & 0x400:
            raise ValueError(f"Package input must not use a directory link: {component}")
    return path


def read(path: Path) -> bytes:
    return safe_file(path).read_bytes()


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def manifest(files: dict[str, bytes]) -> bytes:
    return "".join(f"{digest(files[name])}  {name}\n" for name in sorted(files)).encode("utf-8")


def archive(path: Path, prefix: str, files: dict[str, bytes]) -> None:
    with zipfile.ZipFile(path, "w", compression=zipfile.ZIP_DEFLATED, compresslevel=9) as output:
        for name in sorted(files):
            entry = zipfile.ZipInfo(f"{prefix}/{name}", ZIP_DATE)
            entry.create_system = 3
            entry.external_attr = 0o100644 << 16
            entry.compress_type = zipfile.ZIP_DEFLATED
            output.writestr(entry, files[name], compresslevel=9)


def original_assets_unchanged() -> None:
    records = git("ls-tree", "-r", "-z", BASE, "--", *ASSET_EXTENSIONS).split(b"\0")
    for record in records:
        if not record:
            continue
        metadata, encoded_name = record.split(b"\t", 1)
        name = encoded_name.decode("utf-8")
        expected = metadata.split()[2].decode("ascii")
        data = read(ROOT / name)
        actual = hashlib.sha1(f"blob {len(data)}\0".encode("ascii") + data).hexdigest()
        if actual != expected:
            raise ValueError(f"Original asset differs from upstream bytes: {name}")


def patch(paths: list[str], directory: Path) -> bytes:
    with tempfile.TemporaryDirectory(prefix="patch-index-", dir=directory) as temporary:
        temp = Path(temporary)
        objects = temp / "objects"
        objects.mkdir()
        env = dict(os.environ)
        env["GIT_INDEX_FILE"] = str(temp / "index")
        env["GIT_OBJECT_DIRECTORY"] = str(objects)
        env["GIT_ALTERNATE_OBJECT_DIRECTORIES"] = git(
            "rev-parse", "--path-format=absolute", "--git-path", "objects").decode().strip()
        git("read-tree", BASE, env=env)
        git("add", "--all", "--", *paths, env=env)
        return git("diff", "--cached", "--binary", "--full-index", "--no-ext-diff",
                   "--no-textconv", BASE, "--", env=env)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", default="dist/cmm2", help="Output folder below this repository's dist folder")
    parser.add_argument("--test-results", type=Path, help="Captured output from the final unittest run; hardware status is stated separately")
    args = parser.parse_args()
    output = (ROOT / args.output).resolve()
    dist = (ROOT / "dist").resolve()
    if not output.is_relative_to(dist) or not dist.is_relative_to(ROOT):
        parser.error("--output must resolve below this repository's dist folder")
    for component in (ROOT / "dist", output):
        if component.exists() and getattr(component.lstat(), "st_file_attributes", 0) & 0x400:
            parser.error("The output folder must not be a directory link")
    output.mkdir(parents=True, exist_ok=True)

    expansion = (ROOT / "CAMPAIGN.INC").is_file()
    rooms = 39 if expansion else 9
    label = "Gauntlet-CMM2-Campaign" if expansion else "Gauntlet-CMM2-Fixes"
    branch = "cmm2-campaign-expansion" if expansion else "cmm2-gameplay-fixes"
    includes = INCLUDES | ({"CAMPAIGN.INC"} if expansion else set())
    actual_includes = {path.name for path in ROOT.glob("*.INC")}
    if actual_includes != includes:
        raise ValueError(f"Unexpected include set: missing={includes - actual_includes}, extra={actual_includes - includes}")
    files = {name: read(ROOT / name) for name in sorted(includes | DOCS | {"GAUNTLET.BAS"})}
    for name, data in files.items():
        if Path(name).suffix.upper() in {".BAS", ".INC"}:
            # Transform release text only; never rewrite source or binary maps.
            data = data.replace(b"\r\n", b"\n").replace(b"\n", b"\r\n")
            files[name] = data
            for target in re.findall(rb'(?im)^\s*#INCLUDE\s+"([^"]+)"', data):
                if target.decode("ascii") not in includes:
                    raise ValueError(f"Unexpected include in {name}: {target!r}")
    original_assets_unchanged()
    for directory, extensions in ASSET_EXTENSIONS.items():
        for path in sorted((ROOT / directory).rglob("*")):
            if path.is_file():
                if path.suffix.lower() not in extensions:
                    raise ValueError(f"Unexpected file in CMM2 asset folder: {path}")
                files[path.relative_to(ROOT).as_posix()] = read(path)
    actual_rooms = {Path(name).name for name in files if re.fullmatch(r"MAPS/ROOM\d+\.MAP", name)}
    expected_rooms = {f"ROOM{room:02d}.MAP" for room in range(1, rooms + 1)}
    if actual_rooms != expected_rooms:
        raise ValueError(f"Expected exactly rooms 1-{rooms}: {actual_rooms ^ expected_rooms}")

    result_bytes = (args.test_results.read_bytes() if args.test_results else
                    b"Automated results were not supplied to this package run.\n"
                    b"Run python -m unittest discover -s tests -v and package again with --test-results PATH.\n")
    result_bytes += (b"\nHardware validation: PENDING. Python checks do not validate CMM2 framebuffer, "
                     b"Wii controllers, audio playback, frame rate or campaign balance.\n")
    files["TEST-RESULTS.txt"] = result_bytes
    files["SHA256SUMS.txt"] = manifest(files)

    source = {name: data for name, data in files.items() if name != "SHA256SUMS.txt"}
    for name in (".gitattributes", ".gitignore"):
        source[name] = read(ROOT / name)
    for directory in ("tests", "tools"):
        for path in sorted((ROOT / directory).rglob("*.py")):
            source[path.relative_to(ROOT).as_posix()] = read(path)
    source["SHA256SUMS.txt"] = manifest(source)

    archive(output / f"{label}.zip", "Gauntlet", files)
    archive(output / f"{label}-source.zip", "Gauntlet-CMM2-source", source)
    (output / "GAUNTLET.BAS").write_bytes(files["GAUNTLET.BAS"])
    (output / "RELEASE-NOTES.txt").write_bytes(files["CHANGELOG-CMM2.md"])
    (output / "TEST-RESULTS.txt").write_bytes(result_bytes)
    paths = sorted(name for name in source if name not in {"SHA256SUMS.txt", "TEST-RESULTS.txt"})
    (output / f"{label}.patch").write_bytes(patch(paths, output))
    info = (f"Gauntlet for Colour Maximite 2\nVariant: {branch}\nRooms: {rooms}\n"
            f"Upstream base: {BASE}\nPublication date: 2026-11-11\n"
            f"GAUNTLET.BAS SHA256: {digest(files['GAUNTLET.BAS'])}\n"
            f"Source payload SHA256: {digest(manifest(source))}\n"
            "Original media and original map bytes verified against upstream.\n"
            "Hardware validation remains pending; see TESTING-CMM2.md.\n")
    (output / "BUILD-INFO.txt").write_text(info, encoding="utf-8", newline="\n")
    names = ["GAUNTLET.BAS", f"{label}.zip", f"{label}-source.zip", f"{label}.patch",
             "RELEASE-NOTES.txt", "TEST-RESULTS.txt", "BUILD-INFO.txt"]
    artifacts = {name: (output / name).read_bytes() for name in names}
    (output / "SHA256SUMS.txt").write_bytes(manifest(artifacts))
    print(json.dumps({"variant": branch, "rooms": rooms, "output": str(output),
                      "files": {name: {"bytes": len(data), "sha256": digest(data)}
                                for name, data in artifacts.items()}}, indent=2))


if __name__ == "__main__":
    main()
