#!/usr/bin/env python3
"""Rend une sortie de commande en PNG facon terminal (fond sombre, monospace).

Usage :
    render_terminal_png.py <sortie.txt> <sortie.png> "<commande affichee>" ["<prompt>"]

Sert a produire les captures du workflow Terraform pour le rendu TP2.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

MONO = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf"
MONO_BOLD = "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf"

# Palette type terminal sombre.
BG = (30, 32, 40)
HEADER = (45, 48, 58)
FG = (220, 223, 228)
PROMPT_USER = (94, 200, 122)
PROMPT_PATH = (98, 174, 239)
CMD = (236, 236, 236)
DIM = (140, 145, 155)
GREEN = (94, 200, 122)
DOT_RED = (237, 106, 94)
DOT_YEL = (245, 191, 79)
DOT_GRN = (98, 197, 84)

FONT_SIZE = 22
LINE_H = 30
PAD = 26
HEADER_H = 44
MAX_COLS = 110


def colorize(line: str):
    """Choisit une couleur selon le contenu de la ligne (heuristique simple)."""
    low = line.lower()
    if any(k in line for k in ("Apply complete!", "Success!", "Destroy complete!",
                               "successfully initialized", "Plan:")):
        return GREEN
    if line.lstrip().startswith("+") or " will be created" in line:
        return PROMPT_USER
    if line.lstrip().startswith("-") or " will be destroyed" in line:
        return DOT_RED
    if line.lstrip().startswith("~") or " will be updated" in line:
        return DOT_YEL
    if low.startswith("error") or "error:" in low:
        return DOT_RED
    return FG


def wrap(text: str):
    out = []
    for raw in text.splitlines():
        if len(raw) <= MAX_COLS:
            out.append(raw)
        else:
            while len(raw) > MAX_COLS:
                out.append(raw[:MAX_COLS])
                raw = raw[MAX_COLS:]
            out.append(raw)
    return out


def main():
    if len(sys.argv) < 4:
        print(__doc__)
        sys.exit(1)
    src, dst, command = sys.argv[1], sys.argv[2], sys.argv[3]
    prompt = sys.argv[4] if len(sys.argv) > 4 else "paul@efrei:~/efrei-project/cloud/tp2/terraform$"
    title_prefix = sys.argv[5] if len(sys.argv) > 5 else "Terraform"

    body = Path(src).read_text(encoding="utf-8", errors="replace").rstrip("\n")
    lines = wrap(body)

    # Lignes affichees : prompt+commande, puis le corps.
    total_lines = 1 + len(lines)
    width = PAD * 2 + int(MAX_COLS * FONT_SIZE * 0.601)
    height = HEADER_H + PAD * 2 + total_lines * LINE_H

    img = Image.new("RGB", (width, height), BG)
    d = ImageDraw.Draw(img)
    font = ImageFont.truetype(MONO, FONT_SIZE)
    font_b = ImageFont.truetype(MONO_BOLD, FONT_SIZE)

    # Barre de titre facon fenetre terminal.
    d.rectangle([0, 0, width, HEADER_H], fill=HEADER)
    for i, col in enumerate((DOT_RED, DOT_YEL, DOT_GRN)):
        cx = PAD + i * 26
        d.ellipse([cx, HEADER_H // 2 - 8, cx + 16, HEADER_H // 2 + 8], fill=col)
    title = f"{title_prefix}  -  {command}"
    tb = d.textbbox((0, 0), title, font=font)
    d.text(((width - (tb[2] - tb[0])) / 2, (HEADER_H - FONT_SIZE) / 2 - 2),
           title, font=font, fill=DIM)

    y = HEADER_H + PAD
    # Ligne prompt + commande.
    x = PAD
    d.text((x, y), prompt, font=font_b, fill=PROMPT_PATH)
    x += int(len(prompt) * FONT_SIZE * 0.601) + int(FONT_SIZE * 0.601)
    d.text((x, y), command, font=font_b, fill=CMD)
    y += LINE_H

    for ln in lines:
        d.text((PAD, y), ln, font=font, fill=colorize(ln))
        y += LINE_H

    img.save(dst)
    print(f"OK {dst} ({width}x{height})")


if __name__ == "__main__":
    main()
