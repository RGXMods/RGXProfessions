#!/usr/bin/env python3
"""Regenerates the WoW Forever guide data from wowsod.pro's profession leveling pages.

Usage: tools/gen-forever-guides.py [--fetch] [--cache DIR]
  --fetch   download the 12 pages first (robots.txt allows it; 1s between requests)
  --cache   directory holding <slug>.html (default: ./.guide-cache)

Writes (all generated, do not edit by hand):
  Data/Forever/ProfessionPaths/<Profession>.lua   crafting routes and gathering brackets
  Data/Forever/Recipes.lua                        per-craft reagents for those routes
  Data/Forever/ProfessionNotes.lua                taglines, what-changed notes, tips, gathering brackets
Source: https://wowsod.pro/wow-forever/professions/leveling (Wowhead Forever data, final pre-launch skill-up colours).
"""
import html, json, os, re, subprocess, sys, time

SLUGS = {
    "alchemy": ("Alchemy", 171, "craft"), "blacksmithing": ("Blacksmithing", 164, "craft"),
    "cooking": ("Cooking", 185, "craft"), "enchanting": ("Enchanting", 333, "craft"),
    "engineering": ("Engineering", 202, "craft"), "first-aid": ("FirstAid", 129, "craft"),
    "leatherworking": ("Leatherworking", 165, "craft"), "tailoring": ("Tailoring", 197, "craft"),
    "fishing": ("Fishing", 356, "gather"), "herbalism": ("Herbalism", 182, "gather"),
    "mining": ("Mining", 186, "gather"), "skinning": ("Skinning", 393, "gather"),
}
BASE = "https://wowsod.pro/wow-forever/professions/"

def clean(t):
    t = re.sub(r"<!--.*?-->", "", t)
    t = re.sub(r"<[^>]+>", "", t)
    return re.sub(r"\s+", " ", html.unescape(t)).strip()

def lua_str(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n") + '"'

def parse_crafting(page):
    route = re.search(r'<ol class="pl-route">(.*?)</ol>', page, re.S).group(1)
    steps = []
    for part in re.split(r'(?=<li class="is-[a-z]+">)', route):
        if not part.startswith('<li class="is-'):
            continue
        kind = re.match(r'<li class="is-([a-z]+)"', part).group(1)
        sk = re.search(r'<div class="pl-skill"><b>(\d+)(?:<!-- -->)?-(?:<!-- -->)?(\d+)</b>', part)
        sp = re.search(r'pl-recipe-link"[^>]*data-wowhead="spell=(\d+)[^"]*"[^>]*>.*?<span>(.*?)</span></a>', part, re.S)
        learn = re.search(r"learn at (?:<!-- -->)?(\d+)", part)
        col = re.search(r'aria-label="Yellow at (\d+), green at (\d+), grey at (\d+)"', part)
        crafts = re.search(r'<div class="pl-crafts"><b>([\d,]+)</b>', part)
        matblock = part.split("pl-step-mats")[1] if "pl-step-mats" in part else ""
        mats = re.findall(r'<li><span>([\d,]+)</span><a [^>]*data-wowhead="item=(\d+)[^"]*"[^>]*>.*?<span>(.*?)</span></a></li>', matblock, re.S)
        steps.append({
            "kind": kind, "minSkill": int(sk.group(1)), "maxSkill": int(sk.group(2)),
            "spellID": int(sp.group(1)), "name": html.unescape(sp.group(2)),
            "learnAt": int(learn.group(1)) if learn else None,
            "colors": {"y": int(col.group(1)), "g": int(col.group(2)), "r": int(col.group(3))} if col else None,
            "crafts": int(crafts.group(1).replace(",", "")) if crafts else 0,
            "mats": [(int(i), int(c.replace(",", "")), html.unescape(n)) for c, i, n in mats],
        })
    return steps

def parse_gathering(page):
    out = []
    block = re.search(r'<ol class="pl-gather">(.*?)</ol>', page, re.S).group(1)
    for li in re.split(r"(?=<li><div class=\"pl-skill\">)", block):
        sk = re.search(r'<div class="pl-skill"><b>(\d+)(?:<!-- -->)?-(?:<!-- -->)?(\d+)</b>', li)
        if not sk:
            continue
        what = re.search(r"<h3>(.*?)</h3>", li, re.S)
        items = re.findall(r'data-wowhead="item=(\d+)[^"]*"[^>]*>.*?<span>(.*?)</span></a>', li, re.S)
        note = re.search(r"</div><p>(.*?)</p></div>", li, re.S)
        ally = re.search(r'is-alliance"><small>Alliance</small>(.*?)</div>', li, re.S)
        horde = re.search(r'is-horde"><small>Horde</small>(.*?)</div>', li, re.S)
        out.append({
            "minSkill": int(sk.group(1)), "maxSkill": int(sk.group(2)),
            "what": clean(what.group(1)) if what else "",
            "items": [(int(i), html.unescape(n)) for i, n in items],
            "note": clean(note.group(1)) if note else "",
            "alliance": clean(ally.group(1)) if ally else "", "horde": clean(horde.group(1)) if horde else "",
        })
    return out

def parse_notes(page):
    h1 = re.search(r'<h1 class="pl-title">.*?<em>(.*?)</em>', page, re.S)
    summary = re.search(r"</h1><p>(.*?)</p></header>", page, re.S)
    changes = []
    cm = re.search(r'<ul class="fp-rules pl-changes">(.*?)</ul>', page, re.S)
    if cm:
        for li in re.findall(r"<li>(.*?)</li>", cm.group(1), re.S):
            src = re.search(r'fp-src is-([a-z\-]+)">(.*?)</span>', li)
            text = clean(re.sub(r'<span class="fp-src.*?</span>', "", li))
            changes.append((text, src.group(2) if src else ""))
    tips, ranks = [], []
    tm = re.search(r'id="tips".*?</section>', page, re.S)
    if tm:
        uls = re.findall(r'<ul class="fp-rules">(.*?)</ul>', tm.group(0), re.S)
        if uls:
            tips = [clean(re.sub(r'<span class="fp-src.*?</span>', "", li)) for li in re.findall(r"<li>(.*?)</li>", uls[0], re.S)]
        if len(uls) > 1:
            ranks = [clean(re.sub(r'<span class="fp-src.*?</span>', "", li)) for li in re.findall(r"<li>(.*?)</li>", uls[1], re.S)]
    tools = []
    tl = re.search(r'<ul class="pl-mats pl-tools">(.*?)</ul>', page, re.S)
    if tl:
        for li in re.findall(r"<li>(.*?)</li>", tl.group(1), re.S):
            it = re.search(r'data-wowhead="item=(\d+)[^"]*"[^>]*>.*?<span>(.*?)</span></a><small>(.*?)</small>', li, re.S)
            if it:
                tools.append((int(it.group(1)), html.unescape(it.group(2)), clean(it.group(3))))
    return {"tagline": clean(h1.group(1)) if h1 else "", "summary": clean(summary.group(1)) if summary else "",
            "changes": changes, "tips": tips, "ranks": ranks, "tools": tools}

def main():
    args = sys.argv[1:]
    cache = args[args.index("--cache") + 1] if "--cache" in args else ".guide-cache"
    os.makedirs(cache, exist_ok=True)
    if "--fetch" in args:
        for slug in SLUGS:
            subprocess.run(["curl", "-sL", "-A", "RGXProfessions-guide-generator", "-o", f"{cache}/{slug}.html", BASE + slug], check=True)
            time.sleep(1)
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    header = "-- GENERATED by tools/gen-forever-guides.py from wowsod.pro (Wowhead Forever data, 2026-11-02).\n-- Do not edit by hand; re-run the generator.\n"
    recipes, notes = {}, {}
    for slug, (pname, profID, kind) in SLUGS.items():
        page = open(f"{cache}/{slug}.html", errors="ignore").read()
        n = parse_notes(page)
        if kind == "craft":
            steps = parse_crafting(page)
            assert steps and steps[0]["minSkill"] == 1 and steps[-1]["maxSkill"] == 300, slug
            lines = ["RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}", "", header.strip(), f"RGXProf.ForeverPaths.{pname} = {{"]
            for st in steps:
                f = [f"keep = 0, minSkill = {st['minSkill']}, maxSkill = {st['maxSkill']}", f"spellID = {st['spellID']}", f"name = {lua_str(st['name'])}"]
                if st["colors"]:
                    c = st["colors"]; f.append(f"colors = {{ y = {c['y']}, g = {c['g']}, r = {c['r']} }}")
                if st["learnAt"] is not None:
                    f.append(f"learnAt = {st['learnAt']}")
                f.append(f"source = {lua_str(st['kind'])}")
                if st["crafts"]:
                    f.append(f"crafts = {st['crafts']}")
                lines.append("  { " + ", ".join(f) + " },")
                if st["crafts"]:
                    per = {}
                    for item, total, _ in st["mats"]:
                        per[item] = max(1, round(total / st["crafts"]))
                    recipes[st["spellID"]] = per
            lines.append("}")
            open(f"{root}/Data/Forever/ProfessionPaths/{pname}.lua", "w").write("\n".join(lines) + "\n")
            n["steps"] = len(steps)
        else:
            n["brackets"] = parse_gathering(page)
            assert n["brackets"], slug
            lines = ["RGXProf.ForeverPaths = RGXProf.ForeverPaths or {}", "", header.strip(), f"RGXProf.ForeverPaths.{pname} = {{"]
            for br in n["brackets"]:
                f = [f"keep = 0, minSkill = {br['minSkill']}, maxSkill = {br['maxSkill']}", f"name = {lua_str(br['what'])}"]
                if br["items"]:
                    f.append(f"itemID = {br['items'][0][0]}")
                f.append('source = "gather"')
                if br["note"]:
                    f.append(f"note = {lua_str(br['note'])}")
                f.append(f"zones = {{ alliance = {lua_str(br['alliance'])}, horde = {lua_str(br['horde'])} }}")
                lines.append("  { " + ", ".join(f) + " },")
            lines.append("}")
            open(f"{root}/Data/Forever/ProfessionPaths/{pname}.lua", "w").write("\n".join(lines) + "\n")
        notes[pname] = (profID, n)
    rl = ["RGXProf.Data = RGXProf.Data or {}", "RGXProf.Data.Recipes = RGXProf.Data.Recipes or {}", "", header.strip(),
          "-- Per-craft reagents for the Forever routes (total shopping amount / crafts). Overrides the Classic table.",
          "for spellID, reagents in pairs({"]
    for spell in sorted(recipes):
        rl.append(f"  [{spell}] = {{" + ", ".join(f"[{i}] = {c}" for i, c in sorted(recipes[spell].items())) + "},")
    rl += ["}) do", "  RGXProf.Data.Recipes[spellID] = reagents", "end"]
    open(f"{root}/Data/Forever/Recipes.lua", "w").write("\n".join(rl) + "\n")
    nl = ["RGXProf.ForeverNotes = RGXProf.ForeverNotes or {}", "", header.strip()]
    for pname, (profID, n) in notes.items():
        nl.append(f"RGXProf.ForeverNotes[{profID}] = {{ -- {pname}")
        nl.append(f"  tagline = {lua_str(n['tagline'])},")
        nl.append(f"  summary = {lua_str(n['summary'])},")
        nl.append("  changes = {")
        for text, src in n["changes"]:
            nl.append(f"    {{ text = {lua_str(text)}, source = {lua_str(src)} }},")
        nl.append("  },")
        nl.append("  tips = {")
        for t in n["tips"]:
            nl.append(f"    {lua_str(t)},")
        nl.append("  },")
        nl.append("  ranks = {")
        for t in n["ranks"]:
            nl.append(f"    {lua_str(t)},")
        nl.append("  },")
        if n["tools"]:
            nl.append("  tools = {")
            for item, name, desc in n["tools"]:
                nl.append(f"    {{ itemID = {item}, name = {lua_str(name)}, note = {lua_str(desc)} }},")
            nl.append("  },")
        if "brackets" in n:
            nl.append("  brackets = {")
            for b in n["brackets"]:
                items = ", ".join(f"{{ itemID = {i}, name = {lua_str(nm)} }}" for i, nm in b["items"])
                nl.append(f"    {{ minSkill = {b['minSkill']}, maxSkill = {b['maxSkill']}, what = {lua_str(b['what'])}, note = {lua_str(b['note'])},")
                nl.append(f"      alliance = {lua_str(b['alliance'])}, horde = {lua_str(b['horde'])}, items = {{ {items} }} }},")
            nl.append("  },")
        nl.append("}")
    open(f"{root}/Data/Forever/ProfessionNotes.lua", "w").write("\n".join(nl) + "\n")
    print("generated:", ", ".join(notes))

if __name__ == "__main__":
    main()
