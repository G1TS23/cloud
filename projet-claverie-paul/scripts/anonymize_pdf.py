#!/usr/bin/env python3
"""Anonymise un PDF de rendu en masquant les données personnelles (texte)."""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

try:
    import fitz  # PyMuPDF
except ImportError:
    print("ERREUR : PyMuPDF requis — pip install pymupdf", file=sys.stderr)
    sys.exit(1)

# Ordre important : chaînes les plus longues en premier.
REPLACEMENTS = [
    ("Paul Claverie — Mastère", "épreuve individuelle — niveau Mastère"),
    ("paul.claverie@efrei.net", "ops@novaretail.example"),
    ("Paul Claverie", "[identité masquée]"),
    ("paul.claverie", "dsi.ops"),
    ("efrei-mastere", "cc-novaretail"),
]


def anonymize_pdf(src: Path, dst: Path) -> int:
    doc = fitz.open(src)
    count = 0
    for page in doc:
        for old, new in REPLACEMENTS:
            for rect in page.search_for(old):
                page.add_redact_annot(rect, fill=(1, 1, 1), text=new, fontsize=10)
                count += 1
        page.apply_redactions()
    dst.parent.mkdir(parents=True, exist_ok=True)
    doc.save(dst)
    doc.close()
    return count


def main() -> None:
    parser = argparse.ArgumentParser(description="Anonymise un PDF de rendu.")
    parser.add_argument("source", type=Path, help="PDF source")
    parser.add_argument("destination", type=Path, help="PDF anonymisé de sortie")
    args = parser.parse_args()

    if not args.source.is_file():
        print(f"ERREUR : fichier introuvable — {args.source}", file=sys.stderr)
        sys.exit(1)

    n = anonymize_pdf(args.source, args.destination)
    print(f"PDF anonymisé : {args.destination} ({n} remplacement(s))")


if __name__ == "__main__":
    main()
