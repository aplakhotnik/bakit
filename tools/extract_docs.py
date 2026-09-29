#!/usr/bin/env python3
"""Extract text from RFP source documents into Markdown for analysis.

Supports: .pdf (pdftotext), .docx (textutil, macOS), .xlsx (openpyxl), .pptx (python-pptx).
Walks an input tree recursively and writes one Markdown file per source into the
output folder, flattening names (collisions get a numeric suffix).

Usage:
    python tools/extract_docs.py <input_dir> <output_dir>

Run inside the .venv (needs openpyxl + python-pptx).
"""
from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def slugify_name(stem: str) -> str:
    keep = []
    for ch in stem:
        if ch.isalnum() or ch in (" ", "-", "_", "."):
            keep.append(ch)
        else:
            keep.append("-")
    return "-".join("".join(keep).split()).strip("-") or "file"


def unique_out(out_dir: Path, base: str) -> Path:
    candidate = out_dir / f"{base}.md"
    n = 2
    while candidate.exists():
        candidate = out_dir / f"{base}-{n}.md"
        n += 1
    return candidate


def extract_pdf(src: Path) -> str:
    res = subprocess.run(
        ["pdftotext", "-layout", str(src), "-"],
        capture_output=True, text=True,
    )
    if res.returncode != 0:
        raise RuntimeError(res.stderr.strip() or "pdftotext failed")
    return res.stdout


def extract_docx(src: Path) -> str:
    res = subprocess.run(
        ["textutil", "-convert", "txt", "-stdout", str(src)],
        capture_output=True, text=True,
    )
    if res.returncode != 0:
        raise RuntimeError(res.stderr.strip() or "textutil failed")
    return res.stdout


def extract_xlsx(src: Path) -> str:
    from openpyxl import load_workbook

    wb = load_workbook(src, read_only=True, data_only=True)
    parts: list[str] = []
    for ws in wb.worksheets:
        parts.append(f"## Sheet: {ws.title}\n")
        rows = list(ws.iter_rows(values_only=True))
        # Trim fully-empty trailing rows/cols
        rows = [r for r in rows if any(c is not None and str(c).strip() != "" for c in r)]
        if not rows:
            parts.append("_(empty)_\n")
            continue
        width = max(len(r) for r in rows)
        def fmt(r):
            cells = [("" if c is None else str(c)).replace("\n", " ").replace("|", "\\|").strip() for c in r]
            cells += [""] * (width - len(cells))
            return "| " + " | ".join(cells) + " |"
        parts.append(fmt(rows[0]))
        parts.append("| " + " | ".join(["---"] * width) + " |")
        for r in rows[1:]:
            parts.append(fmt(r))
        parts.append("")
    wb.close()
    return "\n".join(parts)


def extract_pptx(src: Path) -> str:
    from pptx import Presentation

    prs = Presentation(str(src))
    parts: list[str] = []
    for i, slide in enumerate(prs.slides, 1):
        parts.append(f"## Slide {i}\n")
        for shape in slide.shapes:
            if shape.has_text_frame:
                for para in shape.text_frame.paragraphs:
                    text = "".join(run.text for run in para.runs).strip()
                    if text:
                        parts.append(text)
            if shape.has_table:
                tbl = shape.table
                for row in tbl.rows:
                    cells = [c.text.replace("\n", " ").replace("|", "\\|").strip() for c in row.cells]
                    parts.append("| " + " | ".join(cells) + " |")
        notes = ""
        if slide.has_notes_slide and slide.notes_slide.notes_text_frame:
            notes = slide.notes_slide.notes_text_frame.text.strip()
        if notes:
            parts.append(f"\n> Speaker notes: {notes}")
        parts.append("")
    return "\n".join(parts)


EXTRACTORS = {
    ".pdf": extract_pdf,
    ".docx": extract_docx,
    ".xlsx": extract_xlsx,
    ".pptx": extract_pptx,
}


def main() -> int:
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    in_dir = Path(sys.argv[1]).resolve()
    out_dir = Path(sys.argv[2]).resolve()
    out_dir.mkdir(parents=True, exist_ok=True)

    files = sorted(
        p for p in in_dir.rglob("*")
        if p.is_file() and p.suffix.lower() in EXTRACTORS and not p.name.startswith("~$")
    )
    if not files:
        print(f"No supported documents found under {in_dir}")
        return 0

    ok, failed = 0, 0
    for src in files:
        rel = src.relative_to(in_dir)
        ext = src.suffix.lower()
        try:
            body = EXTRACTORS[ext](src)
            base = slugify_name(src.stem) + ext.replace(".", "-")
            out = unique_out(out_dir, base)
            header = (
                f"<!-- extracted from: {rel} -->\n"
                f"# {src.stem}\n\n"
                f"_Source: `{rel}` ({ext[1:].upper()})_\n\n"
            )
            out.write_text(header + body, encoding="utf-8")
            ok += 1
            print(f"  OK   {rel}  ->  {out.name}")
        except Exception as exc:  # noqa: BLE001 - report and continue
            failed += 1
            print(f"  FAIL {rel}  ({exc})")
    print(f"\nExtracted {ok} file(s), {failed} failure(s) -> {out_dir}")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
