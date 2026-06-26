#!/usr/bin/env python3
"""Assemble l'ensemble des livrables ecrits du TP3, les scripts et le code Python
en un unique PDF de rendu, conforme aux livrables attendus (section 17 du sujet),
puis genere l'archive ZIP de rendu.

Usage :
    .venv-pdf/bin/python scripts/build_rendu_tp3_pdf.py

Sortie :
    dist/tp3/TP3_ShopEasy_Administration_Falahi_Claverie.pdf
    dist/tp3/Rendu_TP3_ShopEasy_Administration_Falahi_Claverie.zip
"""

from __future__ import annotations

import html
import re
import zipfile
from pathlib import Path

import markdown
from PIL import Image
from weasyprint import HTML

ROOT = Path(__file__).resolve().parent.parent
TP3 = ROOT / "tp3"
LIVRABLES = TP3 / "livrables"
SCRIPTS = TP3 / "scripts"
PYTHON = TP3 / "python"
EXPORTS = TP3 / "exports"
SCREENSHOTS = TP3 / "screenshots"
OUT_PDF = ROOT / "dist" / "tp3" / "TP3_ShopEasy_Administration_Falahi_Claverie.pdf"
OUT_ZIP = ROOT / "dist" / "tp3" / "Rendu_TP3_ShopEasy_Administration_Falahi_Claverie.zip"
README_MD = ROOT / "dist" / "tp3" / "README_RENDU_TP3.md"

# Ordre des livrables ecrits dans le PDF.
DOCS = [
    LIVRABLES / "05_note_technique.md",
    LIVRABLES / "01_compte_rendu_ateliers.md",
    LIVRABLES / "03_analyse_finops_securite.md",
    LIVRABLES / "04_rapport_exploitation.md",
    LIVRABLES / "02_quiz_reponses.md",
]

# Fichiers de code integres dans l'annexe B (chemin relatif a tp3/).
CODE_FILES = [
    "variables.sh",
    "scripts/inventory.sh",
    "scripts/vm-power.sh",
    "scripts/healthcheck.sh",
    "python/inventory.py",
    "python/requirements.txt",
]

# Fichiers d'exports inclus dans le ZIP (echantillon lisible).
EXPORT_ZIP = ["resources.tsv", "inventory.csv"]

PDF_IMG_MAX_WIDTH = 660
PDF_IMG_MAX_HEIGHT = 900

MD_EXTENSIONS = ["tables", "fenced_code", "sane_lists", "toc"]

CSS = """
@page {
    size: A4;
    margin: 2cm 1.8cm 2cm 1.8cm;
    @bottom-center {
        content: "TP3 Administration Azure - ShopEasy - Olivier Falahi & Paul Claverie";
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

.cover { page-break-after: always; height: 100vh; padding: 3.2cm 2.4cm;
         background: linear-gradient(160deg, #0b3d63 0%, #11577f 55%, #1b6fa0 100%); color: #fff; }
.cover .kicker { font-size: 12pt; letter-spacing: 3px; text-transform: uppercase; opacity: 0.85; }
.cover h1 { font-size: 33pt; color: #fff; border: none; margin: 0.5cm 0 0.2cm 0; page-break-before: avoid; }
.cover .sub { font-size: 15pt; opacity: 0.95; margin-bottom: 1.6cm; }
.cover .meta { font-size: 11.5pt; line-height: 2; border-top: 1px solid rgba(255,255,255,0.4);
               padding-top: 0.8cm; margin-top: 1.2cm; }
.cover .meta b { display: inline-block; width: 5.5cm; opacity: 0.85; font-weight: 400; }
.cover .foot { position: absolute; bottom: 2.2cm; font-size: 10pt; opacity: 0.8; }

.mermaid-block { background: #fbfcfd; border: 1px dashed #9bb7cd; border-radius: 6px;
                 padding: 10px 12px; font-size: 8.2pt; white-space: pre-wrap; word-wrap: break-word;
                 font-family: "DejaVu Sans Mono", monospace; }
.caption { font-size: 8.5pt; color: #667; font-style: italic; margin-top: -0.4em; }

.shot { margin: 0.8em 0 1.4em 0; page-break-inside: avoid; page-break-before: auto; }
.shot img { display: block; width: 100%; max-width: 100%; height: auto;
            max-height: 24cm; object-fit: contain;
            border: 1px solid #c8d0d8; border-radius: 4px; }
.shot .shot-title { font-size: 9pt; font-weight: 600; color: #144e75; margin-bottom: 6px;
                    page-break-after: avoid; }
"""

COVER = """
<div class="cover">
  <div class="kicker">Bloc 4 &middot; Cloud Computing</div>
  <h1>TP3 &mdash; Administration &amp; Automatisation Azure</h1>
  <div class="sub">Azure CLI &middot; Bash &middot; Python &middot; Monitor &middot; FinOps &mdash; Cas fil rouge ShopEasy</div>
  <div class="meta">
    <div><b>Auteurs</b> Olivier Falahi &amp; Paul Claverie</div>
    <div><b>Formation</b> Mast&egrave;re Dev Manager Full Stack &mdash; EFREI</div>
    <div><b>Module</b> Optimisation du SI par l'apport du Cloud</div>
    <div><b>Outils</b> Azure CLI &middot; Bash &middot; Python (SDK Azure)</div>
    <div><b>Cloud</b> Microsoft Azure (swedencentral)</div>
    <div><b>Ann&eacute;e</b> 2025 / 2026</div>
  </div>
  <div class="foot">Scripts d'exploitation, inventaires, supervision, analyses FinOps &amp; s&eacute;curit&eacute;, rapport d'exploitation et preuves d'ex&eacute;cution.</div>
</div>
"""

INTRO = """
<h1>Sommaire et conformit&eacute; au rendu</h1>
<p>Ce document unique regroupe l'ensemble du rendu du TP3. Il r&eacute;pond aux
<b>livrables attendus</b> (section 17 du sujet), produits sur l'environnement ShopEasy
r&eacute;ellement d&eacute;ploy&eacute; (Resource Group <code>rg-shopeasy-dev</code>, r&eacute;gion
<code>swedencentral</code>, souscription <i>Azure for Students</i>).</p>
<table>
<thead><tr><th>Livrable attendu</th><th>Format</th><th>Trait&eacute; dans</th></tr></thead>
<tbody>
<tr><td>Variables utilis&eacute;es</td><td><code>variables.sh</code></td><td>Annexe B</td></tr>
<tr><td>Scripts Bash (inventaire, gestion VM, contr&ocirc;le de sant&eacute;)</td><td><code>.sh</code></td><td>Annexe B + Compte rendu (ateliers 5, 6, 9)</td></tr>
<tr><td>Script Python (inventaire via SDK)</td><td><code>.py</code></td><td>Annexe B + Compte rendu (atelier 10)</td></tr>
<tr><td>Exports (JSON, TSV, TXT, CSV)</td><td>dossier <code>exports/</code></td><td>ZIP de rendu</td></tr>
<tr><td>Captures (preuves d'ex&eacute;cution)</td><td>PNG</td><td>Annexe C</td></tr>
<tr><td>Rapport d'exploitation</td><td>Markdown / PDF</td><td>Rapport d'exploitation</td></tr>
<tr><td>Quiz final</td><td>texte</td><td>Quiz (20 r&eacute;ponses)</td></tr>
</tbody>
</table>
<h2>Contenu</h2>
<ol>
<li>Note technique (synth&egrave;se des choix + architecture d'exploitation)</li>
<li>Compte rendu des ateliers (1 &agrave; 12)</li>
<li>Analyse FinOps &amp; s&eacute;curit&eacute; (atelier 11 + corrig&eacute; s&eacute;curit&eacute;)</li>
<li>Rapport d'exploitation ShopEasy (10 sections + tableau de synth&egrave;se)</li>
<li>Quiz de validation (20 questions)</li>
<li>Annexe A &mdash; Arborescence du projet <code>tp3/</code></li>
<li>Annexe B &mdash; Code source (variables, scripts Bash, script Python)</li>
<li>Annexe C &mdash; Preuves d'ex&eacute;cution (captures)</li>
</ol>
"""


def render_mermaid_blocks(md_text: str) -> str:
    pattern = re.compile(r"```mermaid\n(.*?)```", re.DOTALL)

    def repl(m: re.Match) -> str:
        code = m.group(1).rstrip()
        return (
            "<div class=\"mermaid-block\">" + html.escape(code) + "</div>"
            "\n<p class=\"caption\">Sch&eacute;ma d'architecture (notation Mermaid).</p>\n"
        )

    return pattern.sub(repl, md_text)


def md_to_html(path: Path) -> str:
    text = path.read_text(encoding="utf-8")
    text = render_mermaid_blocks(text)
    md = markdown.Markdown(extensions=MD_EXTENSIONS)
    return f'<div class="doc-section">{md.convert(text)}</div>'


def build_tree() -> str:
    tree = """cloud/tp3/
&#9500;&#9472;&#9472; variables.sh                (variables d'exploitation - livrable)
&#9500;&#9472;&#9472; scripts/
&#9474;   &#9500;&#9472;&#9472; inventory.sh            (inventaire + compteurs + exports)
&#9474;   &#9500;&#9472;&#9472; vm-power.sh             (start/stop/deallocate/status securise)
&#9474;   &#9492;&#9472;&#9472; healthcheck.sh          (8 controles de sante)
&#9500;&#9472;&#9472; python/
&#9474;   &#9500;&#9472;&#9472; inventory.py            (inventaire via SDK Azure + CSV)
&#9474;   &#9492;&#9472;&#9472; requirements.txt
&#9500;&#9472;&#9472; exports/                    (resources.json/.tsv, inventory.csv, vms-*.txt)
&#9500;&#9472;&#9472; logs/
&#9474;   &#9492;&#9472;&#9472; vm-power.log            (journal des actions VM)
&#9500;&#9472;&#9472; screenshots/                (preuves d'execution - Annexe C)
&#9492;&#9472;&#9472; livrables/
    &#9500;&#9472;&#9472; 01_compte_rendu_ateliers.md
    &#9500;&#9472;&#9472; 02_quiz_reponses.md
    &#9500;&#9472;&#9472; 03_analyse_finops_securite.md
    &#9500;&#9472;&#9472; 04_rapport_exploitation.md
    &#9500;&#9472;&#9472; 05_note_technique.md
    &#9492;&#9472;&#9472; 06_captures_a_faire.md"""
    return (
        '<div class="doc-section"><h1>Annexe A &mdash; Arborescence du projet</h1>'
        f'<pre><code>{tree}</code></pre></div>'
    )


def lang_for(fname: str) -> str:
    if fname.endswith(".sh"):
        return "bash"
    if fname.endswith(".py"):
        return "python"
    return "text"


def build_code_appendix() -> str:
    parts = ['<div class="doc-section"><h1>Annexe B &mdash; Code source</h1>']
    parts.append(
        "<p>Code int&eacute;gral du mini-kit d'exploitation <code>tp3/</code> : variables, "
        "scripts Bash et script Python. Aucun secret n'est cod&eacute; en dur (la souscription "
        "et le groupe de ressources sont des identifiants non sensibles, l'authentification "
        "passe par la session <code>az login</code>).</p>"
    )
    for rel in CODE_FILES:
        fpath = TP3 / rel
        if not fpath.exists():
            continue
        content = html.escape(fpath.read_text(encoding="utf-8").rstrip())
        parts.append(f"<h2>{html.escape(rel)}</h2>")
        parts.append(f'<pre><code class="language-{lang_for(rel)}">{content}</code></pre>')
    parts.append("</div>")
    return "".join(parts)


def list_screenshots() -> list[Path]:
    if not SCREENSHOTS.exists():
        return []
    exts = {".png", ".jpg", ".jpeg"}
    return sorted(p for p in SCREENSHOTS.iterdir() if p.suffix.lower() in exts)


def prepare_shot_image(shot: Path, cache_dir: Path) -> Path:
    cache_dir.mkdir(parents=True, exist_ok=True)
    out = cache_dir / shot.name
    img = Image.open(shot)
    w, h = img.size
    scale = min(PDF_IMG_MAX_WIDTH / w, PDF_IMG_MAX_HEIGHT / h, 1.0)
    if scale < 1.0:
        img = img.resize((int(w * scale), int(h * scale)), Image.Resampling.LANCZOS)
    img.save(out, optimize=True)
    return out


def build_screenshots_appendix(shots: list[Path]) -> str:
    cache_dir = OUT_PDF.parent / ".pdf-shot-cache"
    parts = ['<div class="doc-section"><h1>Annexe C &mdash; Preuves d\'ex&eacute;cution</h1>']
    parts.append(
        "<p>Captures des commandes Azure CLI, des scripts Bash, de la supervision et du "
        "script Python, ex&eacute;cut&eacute;s sur l'environnement r&eacute;el. La correspondance "
        "capture &rarr; atelier est d&eacute;taill&eacute;e dans "
        "<code>tp3/livrables/06_captures_a_faire.md</code>.</p>"
    )
    for shot in shots:
        prepared = prepare_shot_image(shot, cache_dir)
        uri = prepared.resolve().as_uri()
        parts.append(
            f'<div class="shot"><div class="shot-title">{html.escape(shot.name)}</div>'
            f'<img src="{uri}" alt="{html.escape(shot.name)}" /></div>'
        )
    parts.append("</div>")
    return "".join(parts)


def build_zip() -> None:
    """Archive ZIP de rendu : PDF + README + variables + scripts + python + exports."""
    if not README_MD.exists():
        raise FileNotFoundError(f"README manquant : {README_MD}")
    if OUT_ZIP.exists():
        OUT_ZIP.unlink()

    with zipfile.ZipFile(OUT_ZIP, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.write(README_MD, README_MD.name)
        zf.write(OUT_PDF, OUT_PDF.name)
        zf.write(TP3 / "variables.sh", "variables.sh")
        for rel in ("inventory.sh", "vm-power.sh", "healthcheck.sh"):
            zf.write(SCRIPTS / rel, f"scripts/{rel}")
        zf.write(PYTHON / "inventory.py", "python/inventory.py")
        zf.write(PYTHON / "requirements.txt", "python/requirements.txt")
        for rel in EXPORT_ZIP:
            fpath = EXPORTS / rel
            if fpath.exists():
                zf.write(fpath, f"exports/{rel}")

    size_kb = OUT_ZIP.stat().st_size / 1024
    print(f"ZIP genere : {OUT_ZIP} ({size_kb:.0f} Ko)")


def main() -> None:
    shots = list_screenshots()
    body = [COVER, INTRO]
    for doc in DOCS:
        body.append(md_to_html(doc))
    body.append(build_tree())
    body.append(build_code_appendix())
    if shots:
        body.append(build_screenshots_appendix(shots))
        print(f"{len(shots)} capture(s) integree(s) en Annexe C.")
    else:
        print("Aucune capture dans tp3/screenshots/ : Annexe C omise.")

    full_html = (
        "<!DOCTYPE html><html lang='fr'><head><meta charset='utf-8'>"
        f"<style>{CSS}</style></head><body>{''.join(body)}</body></html>"
    )

    OUT_PDF.parent.mkdir(parents=True, exist_ok=True)
    HTML(string=full_html, base_url=str(ROOT)).write_pdf(str(OUT_PDF))
    size_kb = OUT_PDF.stat().st_size / 1024
    print(f"PDF genere : {OUT_PDF} ({size_kb:.0f} Ko)")
    build_zip()


if __name__ == "__main__":
    main()
