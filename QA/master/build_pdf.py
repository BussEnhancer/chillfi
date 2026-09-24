#!/usr/bin/env python3
"""
Renders the ChillFi Master QA checklists (JSON = source of truth) into PDFs.

  python3 QA/master/build_pdf.py            # all three
  python3 QA/master/build_pdf.py app        # one

Data files: QA/master/{app,website,admin}.json
  { "title", "subtitle", "scope", "environment",
    "sections": [ { "id", "name", "location", "notes",
        "cases": [ { "id","element","pre","steps","expected","actual",
                     "status","evidence","defect","retest" } ] } ],
    "defects": [ { "id","title","severity","status","root_cause","fix","retest" } ],
    "blockers": [ { "id","title","why","manual_action","resume" } ] }
Status values: NOT TESTED | PASS | FAIL | BLOCKED | NOT APPLICABLE
"""
import json, sys, os, datetime
from collections import Counter
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib import colors
from reportlab.lib.units import mm
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import (SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
                                PageBreak, KeepTogether)

HERE = os.path.dirname(os.path.abspath(__file__))
STATUSES = ['PASS', 'FAIL', 'BLOCKED', 'NOT TESTED', 'NOT APPLICABLE']
COLORS = {'PASS': '#1e8e3e', 'FAIL': '#d93025', 'BLOCKED': '#e37400', 'NOT TESTED': '#5f6368', 'NOT APPLICABLE': '#80868b'}
ORANGE = colors.HexColor('#FF6B2C')

ss = getSampleStyleSheet()
H1 = ParagraphStyle('h1', parent=ss['Heading1'], fontSize=20, textColor=ORANGE, spaceAfter=6)
H2 = ParagraphStyle('h2', parent=ss['Heading2'], fontSize=13, spaceBefore=8, spaceAfter=3)
BODY = ParagraphStyle('b', parent=ss['BodyText'], fontSize=8.5, leading=11)
CELL = ParagraphStyle('c', parent=ss['BodyText'], fontSize=7, leading=8.6)
CELLB = ParagraphStyle('cb', parent=CELL, fontName='Helvetica-Bold')
SMALL = ParagraphStyle('s', parent=BODY, fontSize=7.5, textColor=colors.HexColor('#555555'))


def esc(t):
    return (str(t or '')).replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;').replace('\n', '<br/>')


def status_par(s):
    s = s or 'NOT TESTED'
    return Paragraph(f'<font color="{COLORS.get(s, "#000")}"><b>{esc(s)}</b></font>', CELL)


def counts(data):
    c = Counter()
    for sec in data['sections']:
        for tc in sec['cases']:
            c[tc.get('status') or 'NOT TESTED'] += 1
    return c


def summary_table(data):
    c = counts(data)
    total = sum(c.values())
    applicable = total - c['NOT APPLICABLE']
    rows = [['Total', *STATUSES, 'Pass rate (applicable)']]
    rate = f"{(100 * c['PASS'] / applicable):.1f}%" if applicable else '-'
    rows.append([str(total), *[str(c[s]) for s in STATUSES], rate])
    t = Table(rows, hAlign='LEFT')
    t.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#F8F7FC')),
                           ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'), ('FONTSIZE', (0, 0), (-1, -1), 8.5),
                           ('GRID', (0, 0), (-1, -1), 0.4, colors.HexColor('#dddddd')),
                           *[('TEXTCOLOR', (i + 1, 1), (i + 1, 1), colors.HexColor(COLORS[s])) for i, s in enumerate(STATUSES)]]))
    return t


def section_summary(data):
    rows = [['#', 'Screen / Page', 'Tests', 'PASS', 'FAIL', 'BLOCKED', 'NOT TESTED', 'N/A']]
    for i, sec in enumerate(data['sections'], 1):
        c = Counter(tc.get('status') or 'NOT TESTED' for tc in sec['cases'])
        rows.append([str(i), Paragraph(esc(sec['name']), CELL), str(len(sec['cases'])), str(c['PASS']), str(c['FAIL']),
                     str(c['BLOCKED']), str(c['NOT TESTED']), str(c['NOT APPLICABLE'])])
    t = Table(rows, colWidths=[8 * mm, 110 * mm, 15 * mm, 15 * mm, 15 * mm, 18 * mm, 22 * mm, 12 * mm], repeatRows=1, hAlign='LEFT')
    t.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#F8F7FC')), ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                           ('FONTSIZE', (0, 0), (-1, -1), 7.5), ('GRID', (0, 0), (-1, -1), 0.3, colors.HexColor('#dddddd')),
                           ('VALIGN', (0, 0), (-1, -1), 'MIDDLE')]))
    return t


def cases_table(sec):
    head = ['Test ID', 'Element / Feature', 'Preconditions', 'Steps', 'Expected', 'Actual', 'Status', 'Evidence / Notes', 'Defect', 'Re-test']
    rows = [[Paragraph(f'<b>{h}</b>', CELL) for h in head]]
    for tc in sec['cases']:
        rows.append([Paragraph(esc(tc.get('id')), CELLB), Paragraph(esc(tc.get('element')), CELL), Paragraph(esc(tc.get('pre')), CELL),
                     Paragraph(esc(tc.get('steps')), CELL), Paragraph(esc(tc.get('expected')), CELL), Paragraph(esc(tc.get('actual')), CELL),
                     status_par(tc.get('status')), Paragraph(esc(tc.get('evidence')), CELL), Paragraph(esc(tc.get('defect')), CELL),
                     Paragraph(esc(tc.get('retest')), CELL)])
    widths = [17, 30, 24, 38, 38, 36, 17, 38, 14, 15]
    t = Table(rows, colWidths=[w * mm for w in widths], repeatRows=1, hAlign='LEFT')
    t.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#FFF3ED')), ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                           ('GRID', (0, 0), (-1, -1), 0.3, colors.HexColor('#dddddd')),
                           ('ROWBACKGROUNDS', (0, 1), (-1, -1), [colors.white, colors.HexColor('#FAFAFA')]),
                           ('LEFTPADDING', (0, 0), (-1, -1), 2.5), ('RIGHTPADDING', (0, 0), (-1, -1), 2.5)]))
    return t


def simple_table(rows, widths):
    t = Table([[Paragraph(esc(c) if i else f'<b>{esc(c)}</b>', CELL) for c in r] for i, r in enumerate(rows)],
              colWidths=[w * mm for w in widths], repeatRows=1, hAlign='LEFT')
    t.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#F8F7FC')), ('VALIGN', (0, 0), (-1, -1), 'TOP'),
                           ('GRID', (0, 0), (-1, -1), 0.3, colors.HexColor('#dddddd'))]))
    return t


def build(key):
    src = os.path.join(HERE, f'{key}.json')
    data = json.load(open(src))
    out = os.path.join(HERE, data.get('filename', f'{key}.pdf'))
    doc = SimpleDocTemplate(out, pagesize=landscape(A4), leftMargin=10 * mm, rightMargin=10 * mm, topMargin=11 * mm, bottomMargin=11 * mm,
                            title=data['title'], author='ChillFi QA')
    now = datetime.datetime.now().strftime('%d %b %Y, %H:%M')

    def footer(canvas, d):
        canvas.saveState(); canvas.setFont('Helvetica', 7); canvas.setFillColor(colors.HexColor('#888888'))
        canvas.drawString(10 * mm, 6 * mm, f"{data['title']} — generated {now}")
        canvas.drawRightString(landscape(A4)[0] - 10 * mm, 6 * mm, f'Page {d.page}')
        canvas.restoreState()

    story = [Paragraph(esc(data['title']), H1), Paragraph(esc(data.get('subtitle', '')), BODY), Spacer(1, 4),
             Paragraph(f"<b>Generated:</b> {now} &nbsp;&nbsp; <b>Environment:</b> {esc(data.get('environment', ''))}", SMALL),
             Paragraph(f"<b>Scope:</b> {esc(data.get('scope', ''))}", SMALL), Spacer(1, 6),
             Paragraph('Overall status', H2), summary_table(data), Spacer(1, 4),
             Paragraph('Status legend: PASS = verified at runtime with evidence · FAIL = defect found (see Defect ref) · '
                       'BLOCKED = needs manual/external action · NOT TESTED = not yet executed · NOT APPLICABLE = feature not present / not relevant', SMALL),
             Paragraph('Sections', H2), section_summary(data), PageBreak()]
    for i, sec in enumerate(data['sections'], 1):
        story.append(KeepTogether([Paragraph(f"{i}. {esc(sec['name'])}", H2),
                                   Paragraph(f"<b>Location:</b> {esc(sec.get('location', ''))}" + (f" &nbsp; <b>Notes:</b> {esc(sec['notes'])}" if sec.get('notes') else ''), SMALL),
                                   Spacer(1, 3)]))
        story.append(cases_table(sec)); story.append(Spacer(1, 8))
    if data.get('defects'):
        story += [PageBreak(), Paragraph('Defect log', H2),
                  simple_table([['ID', 'Title', 'Severity', 'Status', 'Root cause', 'Fix', 'Re-test']] +
                               [[d.get('id'), d.get('title'), d.get('severity'), d.get('status'), d.get('root_cause'), d.get('fix'), d.get('retest')] for d in data['defects']],
                               [16, 50, 16, 20, 60, 70, 40])]
    if data.get('blockers'):
        story += [Spacer(1, 8), Paragraph('Blocked items / manual actions', H2),
                  simple_table([['ID', 'Blocked item', 'Why', 'Manual action required', 'Resume point']] +
                               [[b.get('id'), b.get('title'), b.get('why'), b.get('manual_action'), b.get('resume')] for b in data['blockers']],
                               [16, 55, 60, 90, 50])]
    doc.build(story, onFirstPage=footer, onLaterPages=footer)
    c = counts(data)
    print(f"{out}: {sum(c.values())} tests — " + ', '.join(f'{s} {c[s]}' for s in STATUSES))


if __name__ == '__main__':
    for k in (sys.argv[1:] or ['app', 'website', 'admin']):
        if os.path.exists(os.path.join(HERE, f'{k}.json')):
            build(k)
