"""Execute o callback real de combate com dependências Roblox simuladas.
Uso: python tests/run_combat.py /caminho/para/luau
Não substitui validação visual ou de rede no Studio.
"""
from pathlib import Path
import subprocess
import sys
import tempfile

root = Path(__file__).resolve().parents[1]
source = (root / 'src/server/MUBlox.server.luau').read_text()
start = source.index('R.OnServerEvent:Connect(function(player,action,value)')
end = source.index('Players.PlayerRemoving:Connect', start)
harness = (root / 'tests/combat-harness.luau').read_text()
script = harness.replace('-- CALLBACK_PLACEHOLDER', source[start:end])
with tempfile.TemporaryDirectory() as directory:
    target = Path(directory) / 'combat.luau'
    target.write_text(script)
    subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'luau', str(target)], check=True)
