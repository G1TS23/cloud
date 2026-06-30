#!/usr/bin/env python3
"""
build_rapport.py — Assemble livrables/RAPPORT_FINAL.md (MD de travail / relecture).

Le PDF de rendu est produit par build_pdf.py (pipeline WeasyPrint, cf. scripts/build_rendu_tp3_pdf.py
dans le dépôt parent). Ce script reste utile pour une version Markdown concaténée.
"""
import re
import shutil
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent.parent
RAPPORT = ROOT / "rapport"
ASSETS = ROOT / "livrables" / "assets"
OUT = ROOT / "livrables" / "RAPPORT_FINAL.md"

PARTS = [
    "partie1_architecture.md",
    "partie2_diagnostic.md",
    "partie3_terraform.md",
    "partie4_administration.md",
    "partie5_monitoring.md",
    "partie6_theorique.md",
]

MERMAID_IMAGES = [
    "assets/architecture_cible.png",
    "assets/architecture_corrigee.png",
]

PAGE_BREAK = '\n\n<div class="page-break"></div>\n\n'

TITLE = """# Épreuve finale pratique — Cloud Azure

## Cas NovaRetail — Architecture, diagnostic, Terraform, administration, monitoring, FinOps, sécurité

**Auteur :** Paul Claverie — Mastère
**Souscription de déploiement :** Azure for Students — région `swedencentral`
**Date :** Juin 2026

**Infrastructure réellement déployée et validée** via Terraform (captures du portail Azure intégrées).

Ce dossier répond à l'intégralité de l'épreuve : analyse de l'existant et architecture cible (Partie 1),
diagnostic d'une architecture défectueuse (Partie 2), déploiement Infrastructure as Code avec preuves
(Partie 3), administration et automatisation (Partie 4), monitoring / FinOps / sécurité (Partie 5)
et questions théoriques dont la traçabilité blockchain (Partie 6).
"""


def sync_assets() -> int:
    """Copie schemas/*.png et screenshots/*.png vers livrables/assets/."""
    ASSETS.mkdir(parents=True, exist_ok=True)
    count = 0
    for src_dir in (ROOT / "schemas", ROOT / "screenshots"):
        if not src_dir.is_dir():
            continue
        for png in sorted(src_dir.glob("*.png")):
            shutil.copy2(png, ASSETS / png.name)
            count += 1
    return count


def fix_image_paths(text: str) -> str:
    """Réécrit les chemins ../screenshots/ et ../schemas/ vers assets/."""
    text = re.sub(r"\]\(\.\./screenshots/([^)]+)\)", r"](assets/\1)", text)
    text = re.sub(r"\]\(\.\./schemas/([^)]+)\)", r"](assets/\1)", text)
    return text


def replace_mermaid(text: str, images: list[str], counter: dict) -> str:
    pattern = re.compile(r"```mermaid\n.*?\n```", re.DOTALL)

    def _sub(match):
        idx = counter["i"]
        counter["i"] += 1
        if idx < len(images):
            return f"![Schéma d'architecture]({images[idx]})"
        return match.group(0)

    return pattern.sub(_sub, text)


def main() -> None:
    n_assets = sync_assets()
    counter = {"i": 0}
    chunks = [TITLE, PAGE_BREAK]
    for part in PARTS:
        content = (RAPPORT / part).read_text(encoding="utf-8")
        content = replace_mermaid(content, MERMAID_IMAGES, counter)
        content = fix_image_paths(content)
        chunks.append(content)
        chunks.append(PAGE_BREAK)

    OUT.write_text("".join(chunks), encoding="utf-8")
    print(f"Rapport assemblé : {OUT}")
    print(f"Images dans assets/ : {n_assets}")
    print(f"Schémas Mermaid remplacés : {counter['i']}")


if __name__ == "__main__":
    main()
