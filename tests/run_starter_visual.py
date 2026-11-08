from pathlib import Path
import subprocess
import sys
import tempfile
root=Path(__file__).resolve().parents[1]
source=(root/'src/server/MUBlox.server.luau').read_text()
block=source[source.index('local starterParts='):source.index('local function applyStarterVisual(')]
bounds=source[source.index(' local function fitted(body)'):source.index(' local function limb(a,b)')]
harness=(root/'tests/starter-visual-harness.luau').read_text().replace('-- VALIDATOR_PLACEHOLDER',block).replace('-- BOUNDS_PLACEHOLDER',bounds)
with tempfile.TemporaryDirectory() as directory:
    path=Path(directory)/'check.luau'; path.write_text(harness)
    subprocess.run([sys.argv[1] if len(sys.argv)>1 else 'luau',str(path)],check=True)
