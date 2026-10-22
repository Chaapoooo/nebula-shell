#!/usr/bin/env python3
"""Generate NEBULA's desktop-application index from XDG .desktop files.

The JSON stores icon theme names as-is. Quickshell resolves those names with
Quickshell.iconPath(); absolute icon paths are written as proper file:// URLs.
"""

from __future__ import annotations

import json
import os
import re
import shlex
from pathlib import Path
from typing import Iterable

PROJECT_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_OUTPUT = PROJECT_ROOT / "assets" / "out" / "apps.json"

_FIELD_CODE_RE = re.compile(r"%(?:[fFuUick])")


def _unique_paths(paths: Iterable[Path]) -> list[Path]:
    """Keep path order while removing duplicate directory entries."""
    result: list[Path] = []
    seen: set[str] = set()

    for path in paths:
        expanded = path.expanduser()
        key = os.path.normpath(str(expanded))
        if key not in seen:
            seen.add(key)
            result.append(expanded)

    return result


def get_application_dirs() -> list[Path]:
    """Return XDG application directories, with user entries taking priority."""
    home = Path.home()
    data_home = Path(os.environ.get("XDG_DATA_HOME") or home / ".local/share").expanduser()
    data_dirs_raw = os.environ.get("XDG_DATA_DIRS") or "/usr/local/share:/usr/share"

    dirs: list[Path] = [data_home / "applications"]

    # Flatpak user exports are commonly present in XDG_DATA_DIRS, but include
    # the conventional location explicitly for systems where they are not.
    dirs.append(data_home / "flatpak/exports/share/applications")

    for entry in data_dirs_raw.split(os.pathsep):
        if entry.strip():
            dirs.append(Path(entry.strip()).expanduser() / "applications")

    dirs.append(Path("/var/lib/flatpak/exports/share/applications"))
    return _unique_paths(dirs)


def _unescape_desktop_value(value: str) -> str:
    """Decode the string escapes defined by the Desktop Entry specification."""
    return (
        value.replace(r"\s", " ")
        .replace(r"\n", "\n")
        .replace(r"\t", "\t")
        .replace(r"\r", "\r")
        .replace(r"\\", "\\")
    )


def _read_desktop_entry(path: Path) -> dict[str, str]:
    """Read only the unlocalized keys in the [Desktop Entry] group."""
    values: dict[str, str] = {}
    in_main_section = False

    with path.open("r", encoding="utf-8", errors="replace") as desktop_file:
        for raw_line in desktop_file:
            line = raw_line.strip()

            if not line or line.startswith("#"):
                continue

            if line.startswith("[") and line.endswith("]"):
                in_main_section = line == "[Desktop Entry]"
                continue

            if not in_main_section or "=" not in line:
                continue

            key, value = line.split("=", 1)
            # Ignore localized keys such as Name[fr]. The plain Name is the
            # portable fallback and is all this small index needs.
            if "[" in key or key in values:
                continue

            values[key] = _unescape_desktop_value(value.strip())

    return values


def _exec_name(exec_value: str) -> str:
    """Extract the executable basename from a Desktop Entry Exec value."""
    if not exec_value:
        return ""

    try:
        argv = shlex.split(exec_value, posix=True)
    except ValueError:
        # Malformed quoting should not prevent the rest of the desktop entry
        # (especially its icon) from being indexed.
        argv = exec_value.split()

    cleaned: list[str] = []
    for argument in argv:
        argument = _FIELD_CODE_RE.sub("", argument)
        if argument:
            cleaned.append(argument)

    if not cleaned:
        return ""

    # Handle the common `env VAR=value executable ...` form.
    index = 0
    if Path(cleaned[0]).name == "env":
        index = 1
        while index < len(cleaned):
            token = cleaned[index]
            if token == "--":
                index += 1
                break
            if token.startswith("-") or ("=" in token and not token.startswith("/")):
                index += 1
                continue
            break

    if index >= len(cleaned):
        return ""

    executable = cleaned[index]
    return Path(executable).name.lower()


def _icon_value(raw_icon: str) -> str:
    """Convert absolute icon file paths to file URLs; keep theme names intact."""
    if not raw_icon:
        return ""

    expanded = Path(os.path.expandvars(os.path.expanduser(raw_icon)))
    if expanded.is_absolute():
        # Do not emit a broken file URL for a stale path in a .desktop file.
        if expanded.is_file():
            return expanded.resolve().as_uri()
        return ""

    # This is an icon theme name (e.g. 'firefox' or 'org.gnome.Terminal'),
    # not a URL. Quickshell.iconPath() resolves it in the active icon theme.
    return raw_icon


def parse_desktop_file(path: str | Path, desktop_id: str | None = None) -> dict | None:
    """Parse one .desktop file into NEBULA's compact application record."""
    desktop_path = Path(path)

    try:
        values = _read_desktop_entry(desktop_path)
    except (OSError, UnicodeError):
        return None

    if values.get("Type", "") != "Application":
        return None

    if values.get("Hidden", "false").lower() == "true":
        return None

    if values.get("NoDisplay", "false").lower() == "true":
        return None

    name = values.get("Name", "").strip()
    if not name:
        return None

    raw_exec = values.get("Exec", "").strip()
    raw_icon = values.get("Icon", "").strip()

    return {
        "name": name,
        "icon": _icon_value(raw_icon),
        "exec": raw_exec,
        "exec_name": _exec_name(raw_exec),
        "desktop": desktop_id or desktop_path.name,
        "startup_wm_class": values.get("StartupWMClass", "").strip(),
        "type": "Application",
    }


def scan_applications(app_dirs: Iterable[str | Path] | None = None) -> list[dict]:
    """Scan directories in priority order; user entries override system ones."""
    directories = [Path(path) for path in app_dirs] if app_dirs is not None else get_application_dirs()
    seen_desktop_ids: set[str] = set()
    applications: list[dict] = []

    for directory in directories:
        if not directory.is_dir():
            continue

        try:
            desktop_files = sorted(directory.rglob("*.desktop"), key=lambda item: str(item).lower())
        except OSError:
            continue

        for desktop_file in desktop_files:
            try:
                relative_id = desktop_file.relative_to(directory).as_posix().replace("/", "-")
            except ValueError:
                relative_id = desktop_file.name

            # Mark the ID as seen even if the higher-priority entry is Hidden
            # or NoDisplay: that entry must mask the lower-priority duplicate.
            if relative_id in seen_desktop_ids:
                continue
            seen_desktop_ids.add(relative_id)

            app = parse_desktop_file(desktop_file, relative_id)
            if app is not None:
                applications.append(app)

    applications.sort(key=lambda app: (app["name"].casefold(), app["desktop"].casefold()))
    return applications


def generate_apps_json(
    output_path: str | Path = DEFAULT_OUTPUT,
    app_dirs: Iterable[str | Path] | None = None,
) -> list[dict]:
    """Scan applications and write JSON atomically to the requested path."""
    output = Path(output_path).expanduser()
    output.parent.mkdir(parents=True, exist_ok=True)
    applications = scan_applications(app_dirs)

    temporary_output = output.with_name(output.name + ".tmp")
    temporary_output.write_text(
        json.dumps(applications, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    temporary_output.replace(output)
    return applications


def main() -> None:
    applications = generate_apps_json()
    print(f"Generated {len(applications)} applications -> {DEFAULT_OUTPUT}")


if __name__ == "__main__":
    main()
