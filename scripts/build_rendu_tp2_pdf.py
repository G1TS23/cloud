#!/usr/bin/env python3
"""Assemble l'ensemble des livrables ecrits du TP2 et le code Terraform
en un unique PDF de rendu, conforme aux livrables attendus (section 20 du sujet).

Usage :
    .venv-pdf/bin/python scripts/build_rendu_tp2_pdf.py

Sortie :
    dist/tp2/TP2_ShopEasy_Terraform_Falahi_Claverie.pdf
"""

from __future__ import annotations

import html
import re
from pathlib import Path

import markdown
from weasyprint import HTML

ROOT = Path(__file__).resolve().parent.parent
LIVRABLES = ROOT / "tp2" / "livrables"
TERRAFORM = ROOT / "tp2" / "terraform"
SCREENSHOTS = ROOT / "tp2" / "screenshots"
OUT_PDF = ROOT / "dist" / "tp2" / "TP2_ShopEasy_Terraform_Falahi_Claverie.pdf"

# Ordre des livrables ecrits dans le PDF.
DOCS = [
    LIVRABLES / "05_note_technique.md",
    LIVRABLES / "01_compte_rendu_ateliers.md",
    LIVRABLES / "03_analyse_finops_securite.md",
    LIVRABLES / "04_autonomie_subnet_prive.md",
    LIVRABLES / "02_quiz_reponses.md",
]

# Ordre des fichiers Terraform dans l'annexe code.
TF_FILES = [
    "versions.tf",
    "providers.tf",
    "variables.tf",
    "locals.tf",
    "network.tf",
    "security.tf",
    "compute.tf",
    "loadbalancer.tf",
    "storage.tf",
    "outputs.tf",
    "terraform.tfvars.example",
    "templates/cloud-init.yml",
]

MD_EXTENSIONS = ["tables", "fenced_code", "sane_lists", "toc"]

CSS = """
@page {
    size: A4;
    margin: 2cm 1.8cm 2cm 1.8cm;
    @bottom-center {
        content: "TP2 Terraform Azure - ShopEasy - Olivier Falahi & Paul Claverie";
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
      padding: 10px 12px; overflow-x: auto; page-break-inside: avoid; }
pre code { background: none; padding: 0; font-size: 8.4pt; line-height: 1.4; }
table { border-collapse: collapse; width: 100%; margin: 0.8em 0; font-size: 9pt; page-break-inside: avoid; }
th, td { border: 1px solid #c8d0d8; padding: 5px 7px; text-align: left; vertical-align: top; }
th { background: #0b3d63; color: #fff; font-weight: 600; }
tr:nth-child(even) td { background: #f4f7fa; }
blockquote { border-left: 4px solid #4a90c2; background: #eef5fb; margin: 0.7em 0;
             padding: 6px 12px; color: #2c3e50; }
ul, ol { margin: 0.4em 0 0.6em 1.2em; padding-left: 0.8em; }
li { margin: 0.2em 0; }
hr { border: none; border-top: 1px solid #d0d7de; margin: 1.2em 0; }
.doc-section { page-break-before: always; }

/* Page de garde */
.cover { page-break-after: always; height: 100vh; padding: 3.2cm 2.4cm;
         background: linear-gradient(160deg, #0b3d63 0%, #11577f 55%, #1b6fa0 100%); color: #fff; }
.cover .kicker { font-size: 12pt; letter-spacing: 3px; text-transform: uppercase; opacity: 0.85; }
.cover h1 { font-size: 33pt; color: #fff; border: none; margin: 0.5cm 0 0.2cm 0; page-break-before: avoid; }
.cover .sub { font-size: 15pt; opacity: 0.95; margin-bottom: 1.6cm; }
.cover .meta { font-size: 11.5pt; line-height: 2; border-top: 1px solid rgba(255,255,255,0.4);
               padding-top: 0.8cm; margin-top: 1.2cm; }
.cover .meta b { display: inline-block; width: 5.5cm; opacity: 0.85; font-weight: 400; }
.cover .foot { position: absolute; bottom: 2.2cm; font-size: 10pt; opacity: 0.8; }

/* Mermaid / schema brut conserve en bloc */
.mermaid-block { background: #fbfcfd; border: 1px dashed #9bb7cd; border-radius: 6px;
                 padding: 10px 12px; font-size: 8.2pt; white-space: pre; font-family: "DejaVu Sans Mono", monospace; }
.caption { font-size: 8.5pt; color: #667; font-style: italic; margin-top: -0.4em; }

/* Captures d'ecran (annexe preuves) */
.shot { page-break-inside: avoid; margin: 0.6em 0 1.2em 0; }
.shot img { max-width: 100%; border: 1px solid #c8d0d8; border-radius: 4px; }
.shot .shot-title { font-size: 9.5pt; font-weight: 600; color: #144e75; margin-bottom: 4px; }
"""

COVER = """
<div class="cover">
  <div class="kicker">Bloc 4 &middot; Cloud Computing</div>
  <h1>TP2 &mdash; Terraform sur Azure</h1>
  <div class="sub">Infrastructure as Code &mdash; Cas fil rouge ShopEasy</div>
  <div class="meta">
    <div><b>Auteurs</b> Olivier Falahi &amp; Paul Claverie</div>
    <div><b>Formation</b> Mast&egrave;re Dev Manager Full Stack &mdash; EFREI</div>
    <div><b>Module</b> Optimisation du SI par l'apport du Cloud</div>
    <div><b>Outil</b> Terraform &middot; Provider azurerm</div>
    <div><b>Cloud</b> Microsoft Azure (swedencentral)</div>
    <div><b>Ann&eacute;e</b> 2025 / 2026</div>
  </div>
  <div class="foot">Projet Terraform, r&eacute;ponses aux ateliers, analyses FinOps &amp; s&eacute;curit&eacute;, note technique et code source.</div>
</div>
"""

def build_intro(has_shots: bool) -> str:
    if has_shots:
        captures_cell = "Annexe C &mdash; Preuves d'ex&eacute;cution"
        captures_note = (
            "<blockquote>Les captures d'&eacute;cran sont regroup&eacute;es en "
            "<b>Annexe C</b> et r&eacute;f&eacute;renc&eacute;es par nom de fichier dans la checklist "
            "technique du compte rendu.</blockquote>"
        )
        annexe_c = "<li>Annexe C &mdash; Preuves d'ex&eacute;cution (captures)</li>"
    else:
        captures_cell = (
            "Compte rendu &sect;9 (checklist) &mdash; captures &agrave; produire (voir guide)"
        )
        captures_note = (
            "<blockquote>Les captures d'&eacute;cran (points 3, 4, 5) n&eacute;cessitent un "
            "d&eacute;ploiement r&eacute;el sur une souscription <b>de formation</b>. Le code, les "
            "analyses et les r&eacute;ponses sont complets ; la proc&eacute;dure exacte de capture "
            "est d&eacute;crite dans <code>tp2/livrables/06_captures_a_faire.md</code> et les "
            "emplacements sont r&eacute;f&eacute;renc&eacute;s dans la checklist technique. "
            "D&egrave;s que les images sont d&eacute;pos&eacute;es dans <code>tp2/screenshots/</code>, "
            "elles sont int&eacute;gr&eacute;es automatiquement en Annexe C.</blockquote>"
        )
        annexe_c = ""
    return f"""
<h1>Sommaire et conformit&eacute; au rendu</h1>
<p>Ce document unique regroupe l'ensemble du rendu du TP2. Il r&eacute;pond aux
<b>livrables attendus</b> (section 20 du sujet).</p>
<table>
<thead><tr><th>Livrable attendu</th><th>Trait&eacute; dans</th></tr></thead>
<tbody>
<tr><td>1. Arborescence compl&egrave;te du projet Terraform</td><td>Annexe A</td></tr>
<tr><td>2. Les fichiers .tf</td><td>Annexe B (code source int&eacute;gral)</td></tr>
<tr><td>3. Captures init / validate / plan / apply / output</td><td>{captures_cell}</td></tr>
<tr><td>4. Capture du portail Azure (ressources)</td><td>{captures_cell}</td></tr>
<tr><td>5. Capture de la page web via le Load Balancer</td><td>{captures_cell}</td></tr>
<tr><td>6. Analyse de d&eacute;rive (drift)</td><td>Compte rendu &mdash; Atelier 11</td></tr>
<tr><td>7. Tableaux FinOps et s&eacute;curit&eacute; compl&eacute;t&eacute;s</td><td>Analyse FinOps &amp; s&eacute;curit&eacute;</td></tr>
<tr><td>8. Note technique courte</td><td>Note technique (en t&ecirc;te de ce document)</td></tr>
</tbody>
</table>
{captures_note}
<h2>Contenu</h2>
<ol>
<li>Note technique (synth&egrave;se des choix + architecture)</li>
<li>Compte rendu des ateliers (1 &agrave; 14) + checklist + analyse de d&eacute;rive</li>
<li>Analyse co&ucirc;t (FinOps), s&eacute;curit&eacute; et maintenabilit&eacute;</li>
<li>Mise en autonomie &mdash; Option A : subnet priv&eacute; pour les donn&eacute;es</li>
<li>Quiz de validation (20 questions)</li>
<li>Annexe A &mdash; Arborescence du projet</li>
<li>Annexe B &mdash; Code source Terraform</li>
{annexe_c}
</ol>
"""


def render_mermaid_blocks(md_text: str) -> str:
    """Remplace les blocs ```mermaid par un placeholder HTML lisible (WeasyPrint ne rend pas Mermaid)."""
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
    tree = """cloud/tp2/
&#9500;&#9472;&#9472; terraform/
&#9474;   &#9500;&#9472;&#9472; versions.tf
&#9474;   &#9500;&#9472;&#9472; providers.tf
&#9474;   &#9500;&#9472;&#9472; variables.tf
&#9474;   &#9500;&#9472;&#9472; locals.tf
&#9474;   &#9500;&#9472;&#9472; network.tf          (RG + VNet + snet-web + snet-data)
&#9474;   &#9500;&#9472;&#9472; security.tf         (NSG web + NSG data + associations)
&#9474;   &#9500;&#9472;&#9472; compute.tf          (2 VM Linux + NIC + IP publiques)
&#9474;   &#9500;&#9472;&#9472; loadbalancer.tf     (LB + backend pool + probe + regle)
&#9474;   &#9500;&#9472;&#9472; storage.tf          (Storage Account prive + container + versioning)
&#9474;   &#9500;&#9472;&#9472; outputs.tf
&#9474;   &#9500;&#9472;&#9472; terraform.tfvars.example
&#9474;   &#9500;&#9472;&#9472; .gitignore
&#9474;   &#9492;&#9472;&#9472; templates/
&#9474;       &#9492;&#9472;&#9472; cloud-init.yml
&#9500;&#9472;&#9472; livrables/
&#9474;   &#9500;&#9472;&#9472; 01_compte_rendu_ateliers.md
&#9474;   &#9500;&#9472;&#9472; 02_quiz_reponses.md
&#9474;   &#9500;&#9472;&#9472; 03_analyse_finops_securite.md
&#9474;   &#9500;&#9472;&#9472; 04_autonomie_subnet_prive.md
&#9474;   &#9500;&#9472;&#9472; 05_note_technique.md
&#9474;   &#9492;&#9472;&#9472; 06_captures_a_faire.md
&#9492;&#9472;&#9472; screenshots/            (preuves d'execution &mdash; Annexe C)"""
    return (
        '<div class="doc-section"><h1>Annexe A &mdash; Arborescence du projet Terraform</h1>'
        f'<pre><code>{tree}</code></pre></div>'
    )


def lang_for(fname: str) -> str:
    if fname.endswith(".tf") or fname.endswith(".tfvars.example"):
        return "hcl"
    if fname.endswith(".yml") or fname.endswith(".yaml"):
        return "yaml"
    return "text"


def build_code_appendix() -> str:
    parts = ['<div class="doc-section"><h1>Annexe B &mdash; Code source Terraform</h1>']
    parts.append(
        "<p>Code int&eacute;gral du projet <code>tp2/terraform/</code>. "
        "Les secrets ne figurent jamais dans le code : seule la cl&eacute; SSH publique est "
        "r&eacute;f&eacute;renc&eacute;e par chemin, et <code>terraform.tfvars</code> est ignor&eacute; par Git.</p>"
    )
    for rel in TF_FILES:
        fpath = TERRAFORM / rel
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


def build_screenshots_appendix(shots: list[Path]) -> str:
    parts = ['<div class="doc-section"><h1>Annexe C &mdash; Preuves d\'ex&eacute;cution</h1>']
    parts.append(
        "<p>Captures du workflow Terraform, du portail Azure et de la page web servie "
        "par le Load Balancer. La correspondance capture &rarr; atelier est d&eacute;taill&eacute;e "
        "dans <code>tp2/livrables/06_captures_a_faire.md</code>.</p>"
    )
    for shot in shots:
        uri = shot.resolve().as_uri()
        parts.append(
            f'<div class="shot"><div class="shot-title">{html.escape(shot.name)}</div>'
            f'<img src="{uri}" alt="{html.escape(shot.name)}" /></div>'
        )
    parts.append("</div>")
    return "".join(parts)


def main() -> None:
    shots = list_screenshots()
    body = [COVER, build_intro(bool(shots))]
    for doc in DOCS:
        body.append(md_to_html(doc))
    body.append(build_tree())
    body.append(build_code_appendix())
    if shots:
        body.append(build_screenshots_appendix(shots))
        print(f"{len(shots)} capture(s) integree(s) en Annexe C.")
    else:
        print("Aucune capture dans tp2/screenshots/ : Annexe C omise (PDF en etat pre-deploiement).")

    full_html = (
        "<!DOCTYPE html><html lang='fr'><head><meta charset='utf-8'>"
        f"<style>{CSS}</style></head><body>{''.join(body)}</body></html>"
    )

    OUT_PDF.parent.mkdir(parents=True, exist_ok=True)
    HTML(string=full_html, base_url=str(ROOT)).write_pdf(str(OUT_PDF))
    size_kb = OUT_PDF.stat().st_size / 1024
    print(f"PDF genere : {OUT_PDF} ({size_kb:.0f} Ko)")


if __name__ == "__main__":
    main()
