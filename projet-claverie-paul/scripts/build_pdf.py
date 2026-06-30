#!/usr/bin/env python3
"""
build_pdf.py — Génère livrables/RAPPORT_FINAL.pdf (pipeline aligné sur build_rendu_tp3_pdf.py).

- Page de garde + sommaire de conformité au sujet
- 6 parties lues depuis rapport/
- Schémas Mermaid → PNG redimensionnés (blocs .shot)
- Captures inline → blocs .shot avec file:// URI (PIL)
- CSS WeasyPrint identique aux TP du dépôt parent

Usage :
    python3 scripts/build_rapport.py   # optionnel (MD de travail)
    python3 scripts/build_pdf.py
"""
from __future__ import annotations

import html
import re
import sys
from pathlib import Path

try:
    import markdown
    from PIL import Image
    from weasyprint import HTML
except ImportError:
    print("ERREUR : pip install markdown weasyprint pillow", file=sys.stderr)
    sys.exit(1)

ROOT = Path(__file__).resolve().parent.parent
RAPPORT = ROOT / "rapport"
SCHEMAS = ROOT / "schemas"
SCREENSHOTS = ROOT / "screenshots"
OUT_PDF = ROOT / "livrables" / "RAPPORT_FINAL.pdf"
CACHE_DIR = OUT_PDF.parent / ".pdf-shot-cache"

PARTS = [
    RAPPORT / "partie1_architecture.md",
    RAPPORT / "partie2_diagnostic.md",
    RAPPORT / "partie3_terraform.md",
    RAPPORT / "partie4_administration.md",
    RAPPORT / "partie5_monitoring.md",
    RAPPORT / "partie6_theorique.md",
]

MERMAID_PNGS = [
    SCHEMAS / "architecture_cible.png",
    SCHEMAS / "architecture_corrigee.png",
]

PDF_IMG_MAX_WIDTH = 660
PDF_IMG_MAX_HEIGHT = 900
MD_EXTENSIONS = ["tables", "fenced_code", "sane_lists"]

CSS = """
@page {
    size: A4;
    margin: 2cm 1.8cm 2cm 1.8cm;
    @bottom-center {
        content: "Épreuve Cloud Azure — NovaRetail";
        font-size: 8pt; color: #888;
    }
    @bottom-right { content: counter(page) " / " counter(pages); font-size: 8pt; color: #888; }
}
@page :first { margin: 0; }
* { box-sizing: border-box; }
body { font-family: "DejaVu Sans", "Liberation Sans", Arial, sans-serif;
       font-size: 10.5pt; line-height: 1.5; color: #1f2329; }
h1 { font-size: 19pt; color: #0b3d63; border-bottom: 3px solid #0b3d63;
     padding-bottom: 5px; margin-top: 0; page-break-before: always; }
h2 { font-size: 14pt; color: #0b3d63; margin-top: 1.3em; border-bottom: 1px solid #d0d7de; padding-bottom: 3px; }
h3 { font-size: 12pt; color: #144e75; margin-top: 1.1em; }
h4 { font-size: 10.8pt; color: #333; }
p { margin: 0.5em 0; }
a { color: #0969da; text-decoration: none; }
code { font-family: "DejaVu Sans Mono", "Liberation Mono", monospace; font-size: 8.8pt;
       background: #f3f5f7; padding: 1px 4px; border-radius: 3px; }
pre { background: #f6f8fa; border: 1px solid #d0d7de; border-radius: 6px;
      padding: 8px 10px; margin: 0.5em 0;
      white-space: pre-wrap; word-wrap: break-word; overflow-wrap: anywhere;
      page-break-inside: auto; }
pre code { background: none; padding: 0; font-size: 7.6pt; line-height: 1.35;
            white-space: pre-wrap; word-break: break-all; }
table { border-collapse: collapse; width: 100%; max-width: 100%; margin: 0.8em 0;
        font-size: 8.5pt; page-break-inside: auto; table-layout: fixed; }
th, td { border: 1px solid #c8d0d8; padding: 4px 6px; text-align: left; vertical-align: top;
         word-wrap: break-word; overflow-wrap: break-word; hyphens: auto; }
th { background: #0b3d63; color: #fff; font-weight: 600; }
tr:nth-child(even) td { background: #f4f7fa; }
blockquote { border-left: 4px solid #4a90c2; background: #eef5fb; margin: 0.7em 0;
             padding: 6px 12px; color: #2c3e50; }
ul, ol { margin: 0.4em 0 0.6em 1.2em; padding-left: 0.8em; }
li { margin: 0.2em 0; }
hr { border: none; border-top: 1px solid #d0d7de; margin: 1.2em 0; }
.doc-section { page-break-before: always; }
.doc-section:first-of-type { page-break-before: auto; }

.cover { page-break-after: always; height: 100vh; padding: 3.2cm 2.4cm;
         background: linear-gradient(160deg, #0b3d63 0%, #11577f 55%, #1b6fa0 100%); color: #fff; }
.cover .kicker { font-size: 12pt; letter-spacing: 3px; text-transform: uppercase; opacity: 0.85; }
.cover h1 { font-size: 30pt; color: #fff; border: none; margin: 0.5cm 0 0.2cm 0; page-break-before: avoid; }
.cover .sub { font-size: 14pt; opacity: 0.95; margin-bottom: 1.6cm; }
.cover .meta { font-size: 11.5pt; line-height: 2; border-top: 1px solid rgba(255,255,255,0.4);
               padding-top: 0.8cm; margin-top: 1.2cm; }
.cover .meta b { display: inline-block; width: 5.5cm; opacity: 0.85; font-weight: 400; }
.cover .foot { position: absolute; bottom: 2.2cm; font-size: 10pt; opacity: 0.8; }

.shot { margin: 0.8em 0 1.4em 0; page-break-inside: avoid; }
.shot img { display: block; width: 100%; max-width: 100%; height: auto;
            max-height: 24cm; object-fit: contain;
            border: 1px solid #c8d0d8; border-radius: 4px; }
.shot .shot-title { font-size: 9pt; font-weight: 600; color: #144e75; margin-bottom: 6px;
                    page-break-after: avoid; }
.caption { font-size: 8.5pt; color: #667; font-style: italic; margin-top: -0.4em; }
"""

COVER = """
<div class="cover">
  <div class="kicker">Bloc 4 &middot; Cloud Computing</div>
  <h1>&Eacute;preuve finale &mdash; Cloud Azure</h1>
  <div class="sub">Cas NovaRetail &mdash; Architecture, diagnostic, Terraform, administration, monitoring, FinOps, s&eacute;curit&eacute;</div>
  <div class="meta">
    <div><b>Auteur</b> Paul Claverie</div>
    <div><b>Formation</b> Mast&egrave;re Dev Manager Full Stack &mdash; EFREI</div>
    <div><b>Module</b> Optimisation du SI par l'apport du Cloud</div>
    <div><b>Outils</b> Terraform &middot; Azure CLI &middot; Azure Monitor</div>
    <div><b>Cloud</b> Microsoft Azure (swedencentral, Azure for Students)</div>
    <div><b>Date</b> Juin 2026</div>
  </div>
  <div class="foot">Infrastructure r&eacute;ellement d&eacute;ploy&eacute;e et valid&eacute;e &mdash; 6 parties, 20 questions, captures du portail Azure int&eacute;gr&eacute;es.</div>
</div>
"""

INTRO = """
<h1>Sommaire et conformit&eacute; au rendu</h1>
<p>Ce document unique regroupe l'ensemble du rendu de l'&eacute;preuve NovaRetail.
Il r&eacute;pond aux <b>livrables attendus</b> (sections 1.1 et 10 du sujet), produits sur
l'environnement r&eacute;ellement d&eacute;ploy&eacute; (Resource Group <code>rg-novaretail-prod</code>,
r&eacute;gion <code>swedencentral</code>).</p>
<table>
<thead><tr><th>Livrable attendu (sujet)</th><th>Trait&eacute; dans</th></tr></thead>
<tbody>
<tr><td>Rapport final PDF</td><td>Ce document</td></tr>
<tr><td>Sch&eacute;ma d'architecture (PNG)</td><td>Parties 1 et 2</td></tr>
<tr><td>Dossier Terraform</td><td>Partie 3 + archive de rendu <code>infra/</code></td></tr>
<tr><td>Diagnostic architecture d&eacute;fectueuse</td><td>Partie 2</td></tr>
<tr><td>Captures de validation</td><td>Parties 3 et 5</td></tr>
<tr><td>Inventaire et strat&eacute;gie de tags</td><td>Partie 4</td></tr>
<tr><td>Monitoring, FinOps, s&eacute;curit&eacute;, note DSI</td><td>Partie 5</td></tr>
<tr><td>Questions th&eacute;oriques (Cloud + blockchain)</td><td>Partie 6</td></tr>
</tbody>
</table>
<h2>Contenu</h2>
<ol>
<li>Partie 1 &mdash; Analyse de l'existant et architecture cible</li>
<li>Partie 2 &mdash; Diagnostic d'une architecture d&eacute;fectueuse</li>
<li>Partie 3 &mdash; D&eacute;ploiement Terraform et preuves</li>
<li>Partie 4 &mdash; Administration et gouvernance</li>
<li>Partie 5 &mdash; Monitoring, FinOps, s&eacute;curit&eacute;, note DSI</li>
<li>Partie 6 &mdash; Questions th&eacute;oriques</li>
</ol>
"""


def prepare_shot_image(shot: Path, cache_dir: Path) -> Path:
    """Redimensionne une capture pour l'impression PDF (même logique que les TP)."""
    cache_dir.mkdir(parents=True, exist_ok=True)
    out = cache_dir / shot.name
    img = Image.open(shot)
    w, h = img.size
    scale = min(PDF_IMG_MAX_WIDTH / w, PDF_IMG_MAX_HEIGHT / h, 1.0)
    if scale < 1.0:
        img = img.resize((int(w * scale), int(h * scale)), Image.Resampling.LANCZOS)
    if img.mode in ("RGBA", "P"):
        img = img.convert("RGB")
    img.save(out, optimize=True)
    return out


def resolve_image_path(src: str) -> Path:
    src = src.strip()
    if src.startswith("../"):
        return (ROOT / src[3:]).resolve()
    if src.startswith("assets/"):
        return (ROOT / "livrables" / src).resolve()
    return (ROOT / src).resolve()


def shot_html(img_path: Path, title: str, cache_dir: Path) -> str:
    if not img_path.is_file():
        return f"<p><em>[Image introuvable : {html.escape(str(img_path))}]</em></p>"
    prepared = prepare_shot_image(img_path, cache_dir)
    uri = prepared.resolve().as_uri()
    return (
        f'<div class="shot"><div class="shot-title">{html.escape(title)}</div>'
        f'<img src="{uri}" alt="{html.escape(title)}" /></div>\n'
    )


def replace_mermaid_with_png(md_text: str, cache_dir: Path, counter: dict) -> str:
    pattern = re.compile(r"```mermaid\n.*?\n```", re.DOTALL)

    def repl(_: re.Match) -> str:
        idx = counter["i"]
        counter["i"] += 1
        if idx < len(MERMAID_PNGS) and MERMAID_PNGS[idx].is_file():
            return shot_html(MERMAID_PNGS[idx], "Schéma d'architecture", cache_dir)
        return ""

    return pattern.sub(repl, md_text)


def replace_md_images(md_text: str, cache_dir: Path) -> str:
    pattern = re.compile(r"!\[([^\]]*)\]\(([^)]+)\)")

    def repl(m: re.Match) -> str:
        alt, src = m.group(1).strip(), m.group(2).strip()
        img_path = resolve_image_path(src)
        title = alt or img_path.name
        return shot_html(img_path, title, cache_dir)

    return pattern.sub(repl, md_text)


def preprocess_md(md_text: str, cache_dir: Path, mermaid_counter: dict) -> str:
    md_text = replace_mermaid_with_png(md_text, cache_dir, mermaid_counter)
    md_text = replace_md_images(md_text, cache_dir)
    md_text = md_text.replace('<div class="page-break"></div>', "")
    md_text = md_text.replace('<div style="page-break-after: always;"></div>', "")
    return md_text


def md_to_html(path: Path, cache_dir: Path, mermaid_counter: dict) -> str:
    text = path.read_text(encoding="utf-8")
    text = preprocess_md(text, cache_dir, mermaid_counter)
    md = markdown.Markdown(extensions=MD_EXTENSIONS)
    return f'<div class="doc-section">{md.convert(text)}</div>'


def main() -> None:
    missing = [p for p in PARTS if not p.is_file()]
    if missing:
        print("ERREUR : fichiers manquants :", ", ".join(str(p) for p in missing), file=sys.stderr)
        sys.exit(1)

    mermaid_counter = {"i": 0}
    body = [COVER, f'<div class="doc-section">{INTRO}</div>']
    for part in PARTS:
        body.append(md_to_html(part, CACHE_DIR, mermaid_counter))

    full_html = (
        "<!DOCTYPE html><html lang='fr'><head><meta charset='utf-8'>"
        f"<style>{CSS}</style></head><body>{''.join(body)}</body></html>"
    )

    OUT_PDF.parent.mkdir(parents=True, exist_ok=True)
    HTML(string=full_html, base_url=str(ROOT)).write_pdf(str(OUT_PDF))

    size_kb = OUT_PDF.stat().st_size / 1024
    shots = sorted(SCREENSHOTS.glob("*.png")) if SCREENSHOTS.is_dir() else []
    print(f"PDF généré : {OUT_PDF} ({size_kb:.0f} Ko)")
    print(f"Schémas Mermaid → PNG : {mermaid_counter['i']}")
    print(f"Captures disponibles : {len(shots)}")


if __name__ == "__main__":
    main()
