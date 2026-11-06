"""Run the real enemy update callback with minimal Roblox service doubles."""
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
source = (root / 'src/server/MUBlox.server.luau').read_text()
start = source.index('local function clampToArena(position)')
harness = (root / 'tests/enemy-harness.luau').read_text()
script = harness.replace('-- AI_PLACEHOLDER', source[start:])
with tempfile.TemporaryDirectory() as directory:
    path = Path(directory) / 'enemy.luau'
    path.write_text(script)
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', str(path)], check=True)
