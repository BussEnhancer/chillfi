#!/usr/bin/env python3
"""
Update Master QA checklist results (JSON = source of truth), then re-render PDFs with build_pdf.py.

  python3 QA/master/qa.py set <app|website|admin> <ID|ID-prefix*> <STATUS> "<actual>" "<evidence>" [defect] [retest]
  python3 QA/master/qa.py defect <app|website|admin> <DEF-ID> "<title>" <severity> <status> "<root cause>" "<fix>" "<retest>"
  python3 QA/master/qa.py blocker <app|website|admin> <BLK-ID> "<title>" "<why>" "<manual action>" "<resume>"
  python3 QA/master/qa.py stats [key]
  python3 QA/master/qa.py list <key> [STATUS]
"""
import json, os, sys, fnmatch
from collections import Counter

HERE = os.path.dirname(os.path.abspath(__file__))
VALID = {'PASS', 'FAIL', 'BLOCKED', 'NOT TESTED', 'NOT APPLICABLE'}


def load(k): return json.load(open(os.path.join(HERE, f'{k}.json')))
def save(k, d): json.dump(d, open(os.path.join(HERE, f'{k}.json'), 'w'), indent=1, ensure_ascii=False)


def cmd_set(k, pat, status, actual='', evidence='', defect='', retest=''):
    status = status.upper().replace('_', ' ')
    assert status in VALID, status
    d = load(k); n = 0
    for sec in d['sections']:
        for tc in sec['cases']:
            if fnmatch.fnmatch(tc['id'], pat):
                tc['status'] = status
                if actual: tc['actual'] = actual
                if evidence: tc['evidence'] = evidence
                if defect: tc['defect'] = defect
                if retest: tc['retest'] = retest
                n += 1
    save(k, d); print(f'{k}: {n} case(s) {pat} → {status}')
    if not n: sys.exit(1)


def upsert(k, field, item):
    d = load(k); lst = d.setdefault(field, [])
    lst[:] = [x for x in lst if x['id'] != item['id']] + [item]
    save(k, d); print(f'{k}: {field} {item["id"]} saved')


def stats(keys):
    for k in keys:
        d = load(k); c = Counter(tc.get('status', 'NOT TESTED') for s in d['sections'] for tc in s['cases'])
        tot = sum(c.values()); app = tot - c['NOT APPLICABLE']
        print(f"{k:8} total {tot:4}  PASS {c['PASS']:4}  FAIL {c['FAIL']:3}  BLOCKED {c['BLOCKED']:3}  NOT TESTED {c['NOT TESTED']:4}  N/A {c['NOT APPLICABLE']:3}  pass-rate {100*c['PASS']/app if app else 0:.1f}%")


if __name__ == '__main__':
    a = sys.argv[1:]
    if a[0] == 'set': cmd_set(*a[1:])
    elif a[0] == 'defect':
        k, i, t, sev, st, rc, fx, rt = a[1:9]; upsert(k, 'defects', dict(id=i, title=t, severity=sev, status=st, root_cause=rc, fix=fx, retest=rt))
    elif a[0] == 'blocker':
        k, i, t, why, ma, rs = a[1:7]; upsert(k, 'blockers', dict(id=i, title=t, why=why, manual_action=ma, resume=rs))
    elif a[0] == 'stats': stats(a[1:] or ['app', 'website', 'admin'])
    elif a[0] == 'list':
        d = load(a[1]); want = (a[2].upper() if len(a) > 2 else None)
        for s in d['sections']:
            for tc in s['cases']:
                if not want or tc.get('status') == want: print(tc['id'], '|', tc['element'], '|', tc.get('status'))
