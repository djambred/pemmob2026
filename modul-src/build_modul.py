"""Bangun PDF modul praktikum dari berkas sumber modul-N.md.

Pemakaian:
    python3 build_modul.py            # bangun semua modul-*.md
    python3 build_modul.py 2 5        # bangun modul 2 dan 5 saja

Hasil ditulis ke ../pertN/modul/modul-praktikum-flutter-pertemuan-N.pdf.

Format sumber (sederhana, mirip Markdown):
    % Judul                      judul modul
    %% Subjudul                  baris "Pertemuan N: ..."
    ## Heading                   heading bagian (biru)
    ### Subheading               sub-bagian
    - item                       daftar berpoin
    1. item                      daftar bernomor
    > teks                       kotak catatan (Checkpoint, Catatan, dll.)
    | a | b |                    tabel; baris pertama = header
    ```  ...  ```                blok kode
    `kode`  **tebal**  *miring*  format dalam teks
"""

import glob
import os
import re
import sys

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (KeepTogether, Paragraph, SimpleDocTemplate,
                                Spacer, Table, TableStyle)

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

BIRU = colors.Color(.082353, .396078, .752941)
ABU_FOOTER = colors.Color(.392157, .454902, .545098)
ABU_SUB = colors.Color(.278431, .333333, .411765)
GARIS = colors.Color(.796078, .835294, .882353)
LATAR_KODE = colors.Color(.945098, .960784, .976471)
LATAR_CATATAN = colors.Color(.909804, .945098, .984314)

# Font TrueType agar karakter seperti → dan – tampil benar.
FONT_DIR = '/System/Library/Fonts/Supplemental'
_fonts = {
    'Sans': 'Arial.ttf',
    'Sans-Bold': 'Arial Bold.ttf',
    'Sans-Italic': 'Arial Italic.ttf',
    'Sans-BoldItalic': 'Arial Bold Italic.ttf',
    'Mono': 'Courier New.ttf',
    'Mono-Bold': 'Courier New Bold.ttf',
}
if all(os.path.exists(os.path.join(FONT_DIR, f)) for f in _fonts.values()):
    for name, f in _fonts.items():
        pdfmetrics.registerFont(TTFont(name, os.path.join(FONT_DIR, f)))
    pdfmetrics.registerFontFamily('Sans', normal='Sans', bold='Sans-Bold',
                                  italic='Sans-Italic', boldItalic='Sans-BoldItalic')
    pdfmetrics.registerFontFamily('Mono', normal='Mono', bold='Mono-Bold',
                                  italic='Mono', boldItalic='Mono-Bold')
    SANS, SANS_B, MONO = 'Sans', 'Sans-Bold', 'Mono'
else:  # cadangan bila font sistem tidak ada
    SANS, SANS_B, MONO = 'Helvetica', 'Helvetica-Bold', 'Courier'

LEBAR = A4[0] - 2 * 2 * cm

st = {
    'title': ParagraphStyle('title', fontName=SANS_B, fontSize=19, leading=23,
                            textColor=BIRU, spaceAfter=2),
    'subtitle': ParagraphStyle('subtitle', fontName=SANS, fontSize=11, leading=14.5,
                               textColor=ABU_SUB, spaceAfter=12),
    'h2': ParagraphStyle('h2', fontName=SANS_B, fontSize=13, leading=16,
                         textColor=BIRU, spaceBefore=14, spaceAfter=6, keepWithNext=1),
    'h3': ParagraphStyle('h3', fontName=SANS_B, fontSize=11, leading=14,
                         spaceBefore=8, spaceAfter=4, keepWithNext=1),
    'p': ParagraphStyle('p', fontName=SANS, fontSize=10, leading=14.5, spaceAfter=6),
    'li': ParagraphStyle('li', fontName=SANS, fontSize=10, leading=14.5,
                         leftIndent=17, bulletIndent=3, spaceAfter=2),
    'cell': ParagraphStyle('cell', fontName=SANS, fontSize=9, leading=12),
    'cellh': ParagraphStyle('cellh', fontName=SANS_B, fontSize=9, leading=12,
                            textColor=colors.white),
    'note': ParagraphStyle('note', fontName=SANS, fontSize=9.5, leading=14.5),
}


def inline(text):
    """Ubah `kode`, **tebal**, *miring* menjadi markup Paragraph ReportLab."""
    parts = re.split(r'(`[^`]+`)', text)
    out = []
    for part in parts:
        if part.startswith('`') and part.endswith('`') and len(part) > 1:
            code = part[1:-1].replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
            out.append(f'<font name="{MONO}">{code}</font>')
        else:
            s = part.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
            s = re.sub(r'\*\*(.+?)\*\*', r'<b>\1</b>', s)
            s = re.sub(r'(?<![\w*])\*(?!\s)(.+?)(?<!\s)\*(?![\w*])', r'<i>\1</i>', s)
            out.append(s)
    return ''.join(out)


def lebar_kolom(rows, ncol):
    """Lebar alami tiap kolom; sisa ruang diberikan ke kolom terlebar."""
    alami = []
    for c in range(ncol):
        w = 0
        for i, r in enumerate(rows):
            if c < len(r):
                teks = re.sub(r'[`*]', '', r[c])
                w = max(w, pdfmetrics.stringWidth(teks, SANS_B if i == 0 else SANS, 9))
        alami.append(w + 14)
    total = sum(alami)
    if total <= LEBAR:
        terlebar = alami.index(max(alami))
        alami[terlebar] += LEBAR - total
        return alami
    # terlalu lebar: kolom yang melebihi jatah rata-rata dipersempit
    batas = LEBAR / ncol
    kecil = [w for w in alami if w <= batas]
    sisa = LEBAR - sum(kecil)
    besar_total = sum(w for w in alami if w > batas)
    return [w if w <= batas else sisa * w / besar_total for w in alami]


def tabel(rows):
    data = []
    for i, r in enumerate(rows):
        style = st['cellh'] if i == 0 else st['cell']
        data.append([Paragraph(inline(c), style) for c in r])
    ncol = max(len(r) for r in rows)
    for r in data:
        while len(r) < ncol:
            r.append('')
    widths = lebar_kolom(rows, ncol)
    t = Table(data, colWidths=widths, repeatRows=1)
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), BIRU),
        ('GRID', (0, 0), (-1, -1), 0.4, GARIS),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('RIGHTPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ]))
    return t


def kode(lines):
    while lines and not lines[-1].strip():
        lines.pop()
    data = [[ln if ln else ' '] for ln in lines]
    n = len(data)
    tinggi = [9.8] * n
    tinggi[0] += 3
    tinggi[-1] += 3
    t = Table(data, colWidths=[LEBAR - 12], rowHeights=tinggi)
    t.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (-1, -1), MONO),
        ('FONTSIZE', (0, 0), (-1, -1), 7.8),
        ('LEADING', (0, 0), (-1, -1), 9.8),
        ('BACKGROUND', (0, 0), (-1, -1), LATAR_KODE),
        ('BOX', (0, 0), (-1, -1), 0.4, GARIS),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 0),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2.2),
        ('BOTTOMPADDING', (0, n - 1), (-1, n - 1), 5.2),
    ]))
    t.hAlign = 'RIGHT'
    return t


def catatan(text):
    t = Table([[Paragraph(inline(text), st['note'])]], colWidths=[LEBAR - 12])
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, -1), LATAR_CATATAN),
        ('LEFTPADDING', (0, 0), (-1, -1), 7),
        ('RIGHTPADDING', (0, 0), (-1, -1), 7),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
    ]))
    t.hAlign = 'RIGHT'
    return t


def parse(src):
    story = []
    lines = src.split('\n')
    i = 0
    meta = {}
    while i < len(lines):
        ln = lines[i]
        if ln.startswith('```'):
            j = i + 1
            buf = []
            while j < len(lines) and not lines[j].startswith('```'):
                buf.append(lines[j])
                j += 1
            story += [Spacer(1, 2), kode(buf), Spacer(1, 8)]
            i = j + 1
            continue
        if ln.startswith('%% '):
            meta['subtitle'] = ln[3:]
            story.append(Paragraph(inline(ln[3:]), st['subtitle']))
        elif ln.startswith('% '):
            meta['title'] = ln[2:]
            story.append(Paragraph(inline(ln[2:]), st['title']))
        elif ln.startswith('### '):
            story.append(Paragraph(inline(ln[4:]), st['h3']))
        elif ln.startswith('## '):
            story.append(Paragraph(inline(ln[3:]), st['h2']))
        elif ln.startswith('|'):
            rows = []
            while i < len(lines) and lines[i].startswith('|'):
                cells = re.split(r'(?<!\\)\|', lines[i].strip())[1:-1]
                rows.append([c.strip().replace('\\|', '|') for c in cells])
                i += 1
            story += [tabel(rows), Spacer(1, 8)]
            continue
        elif ln.startswith('> '):
            story += [catatan(ln[2:]), Spacer(1, 8)]
        elif ln.startswith('- '):
            story.append(Paragraph(inline(ln[2:]), st['li'], bulletText='•'))
            if i + 1 >= len(lines) or not lines[i + 1].startswith('- '):
                story.append(Spacer(1, 4))
        elif re.match(r'^\d+\. ', ln):
            num, rest = ln.split(' ', 1)
            story.append(Paragraph(inline(rest), st['li'], bulletText=num))
            if i + 1 >= len(lines) or not re.match(r'^\d+\. ', lines[i + 1]):
                story.append(Spacer(1, 4))
        elif ln.strip():
            story.append(Paragraph(inline(ln), st['p']))
        i += 1
    return story, meta


def build(path):
    n = re.search(r'modul-(\d+)\.md$', path).group(1)
    story, meta = parse(open(path, encoding='utf-8').read())
    footer = f"{meta.get('title', 'Modul')} - Pertemuan {n}"
    out = os.path.join(ROOT, f'pert{n}', 'modul', f'modul-praktikum-flutter-pertemuan-{n}.pdf')

    def on_page(canvas, doc):
        canvas.saveState()
        canvas.setFont(SANS, 8)
        canvas.setFillColor(ABU_FOOTER)
        canvas.drawString(2 * cm, 1.2 * cm, footer)
        canvas.drawRightString(A4[0] - 2 * cm, 1.2 * cm, f'Halaman {doc.page}')
        canvas.restoreState()

    doc = SimpleDocTemplate(out, pagesize=A4, leftMargin=2 * cm, rightMargin=2 * cm,
                            topMargin=1.8 * cm, bottomMargin=2 * cm,
                            title=f"{meta.get('title', '')} - {meta.get('subtitle', '')}",
                            author='Pemrograman Mobile')
    doc.build(story, onFirstPage=on_page, onLaterPages=on_page)
    print('OK', out)


if __name__ == '__main__':
    wanted = sys.argv[1:]
    for f in sorted(glob.glob(os.path.join(HERE, 'modul-*.md'))):
        n = re.search(r'modul-(\d+)\.md$', f).group(1)
        if not wanted or n in wanted:
            build(f)
