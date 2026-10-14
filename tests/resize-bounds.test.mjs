#!/usr/bin/env node
// tests/resize-bounds.test.mjs
// Node runner for the BookWindow init-path resize-bounds capability fixture
// (issue #15 / parent #11). Executes tests/ResizeBoundsFixture.lua in BOTH
// capability modes against the REAL UI/BookWindow.lua:
//   modern: Frame:SetResizeBounds(minW, minH, maxW, maxH) present
//   legacy : the native resize-bound family absent (Forever beta shape)
//
// Run from the repository root:  node tests/resize-bounds.test.mjs
// Requires no WoW installation. Uses the system lua5.1/luajit interpreter
// (located on PATH or at LUA_BIN); exits non-zero when any assertion fails.

import { execFileSync } from "node:child_process";
import { accessSync, constants } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
const root = join(here, "..");
const fixture = join("tests", "ResizeBoundsFixture.lua");

const candidates = [
  process.env.LUA_BIN,
  "lua5.1",
  "lua5.1.exe",
  "luajit",
  "lua",
  "/usr/bin/lua5.1",
  "/usr/local/bin/lua5.1",
  "/opt/homebrew/bin/lua5.1",
].filter(Boolean);

function findLua() {
  for (const bin of candidates) {
    try {
      accessSync(bin, constants.X_OK);
      return bin;
    } catch {
      // not directly executable; if it's a bare name, try resolving via PATH
      if (!bin.includes("/")) {
        try {
          execFileSync("command", ["-v", bin], { shell: "/bin/sh", stdio: "ignore" });
          return bin;
        } catch {
          // keep looking
        }
      }
    }
  }
  return null;
}

const lua = findLua();
if (!lua) {
  console.error(
    "resize-bounds test: no lua5.1/luajit/lua interpreter found (set LUA_BIN).\n" +
      "The fixture itself is plain Lua 5.1: tests/ResizeBoundsFixture.lua"
  );
  process.exit(1);
}

let failed = 0;
for (const mode of ["modern", "legacy"]) {
  console.log(`\n=== capability fixture: ${mode} mode (${lua}) ===`);
  try {
    const out = execFileSync(lua, [fixture, mode], {
      cwd: root,
      encoding: "utf8",
      stdio: ["ignore", "pipe", "pipe"],
    });
    process.stdout.write(out);
    if (out.includes("FAIL")) failed++;
  } catch (err) {
    process.stdout.write(err.stdout || "");
    process.stderr.write(err.stderr || String(err));
    failed++;
  }
}

console.log(
  failed === 0
    ? "\nresize-bounds capability fixtures: ALL PASS (modern + legacy)"
    : `\nresize-bounds capability fixtures: ${failed} MODE(S) FAILED`
);
process.exit(failed === 0 ? 0 : 1);
