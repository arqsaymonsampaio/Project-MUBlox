# MUBlox

Protótipo Roblox reconstruído a partir dos códigos da conversa, organizado para **Rojo 7.7.1**. Os arquivos desta pasta são a fonte do código; não é necessário colar instaladores na Barra de Comandos.

## Abrir no Windows

1. Extraia ou clone este repositório em uma pasta nova, por exemplo `Documents\Project-MUBlox`. Preserve qualquer projeto anterior.
2. Abra essa pasta no Explorador, digite `cmd` na barra de endereço e pressione Enter.
3. Execute (ajuste o caminho do executável se necessário):

```bat
"%USERPROFILE%\Downloads\rojo-7.7.1-windows-x86_64\rojo.exe" serve
```

4. Abra uma Baseplate nova no Roblox Studio, abra o plugin Rojo e conecte a `localhost:34872`.
5. A sincronização deve adicionar `MUBloxServerV2`, `MUBloxClientV2` e `MUBloxAction`. Aceite depois de conferir os nomes.
6. Clique em **Play** e escolha uma classe. O mapa é criado durante o jogo, por isso a cidade pode não aparecer antes de Play.

Não execute os instaladores antigos junto com esta versão. Ao usar um lugar existente, faça uma cópia e retire controladores antigos de MUBlox para evitar duplicação; a configuração preserva objetos desconhecidos e não os remove automaticamente.

## Controles

- **I** ou botão à direita: abrir inventário (fora de campos de texto/chat).
- Clique numa peça equipada para retirar; clique na mochila para equipar.
- **W** na mochila: asas cosméticas com flutuação baixa, sem voo livre.
- Clique esquerdo diretamente no golem, de perto: ataque básico.
- Clique direito diretamente no golem: Golpe Giratório do Guerreiro, 20 mana e 3 segundos de recarga.
- A câmera padrão também usa o botão direito ao arrastar.

O golem fica além do portão norte, no sentido oposto ao ponto de nascimento. Revida parado, concede 50 XP ao jogador que dá o último golpe e reaparece após cinco segundos. Cada 100 XP sobe um nível. Os níveis ainda não concedem novos atributos.

## O que está incluído

- Cidade medieval, fonte, casas cenográficas, muralhas e campo de treino.
- Guerreiro, Mago e Elfa com vida e mana diferentes.
- HUD, inventário lateral, peças cosméticas, espada e asas.
- Controlador com suporte a Motor6D e AnimationConstraint, incluindo postura e ataque procedural.
- Batida original das asas preservada; a revisão posterior de articulação das asas não está aplicada.
- Dano, alcance, mana e recarga validados pelo servidor.

## Limitações e validação

A sintaxe dos scripts foi verificada com o compilador oficial Luau. O build foi gerado com Rojo 7.7.1 e os objetos/fontes resultantes foram conferidos. Isso não substitui um teste no Roblox Studio.

A postura com AnimationConstraint e os movimentos da espada ainda precisam de confirmação visual. As armaduras são peças provisórias; acessórios do avatar podem se sobrepor. Só o Guerreiro possui skill; as demais classes usam o ataque básico provisório. Não há salvamento de progresso, PvP, economia, interiores de casas nem controle de combate para celular. A interface redimensiona, mas precisa de validação em dispositivos.

Teste após conectar: escolher classe, vestir/retirar peças, abrir com I, equipar asas, conferir postura lateral, atacar e usar Giro, receber dano, ganhar XP e renascer.

## Arquivos

- `src/server/MUBlox.server.luau`: mapa, classes, equipamentos e combate.
- `src/client/MUBlox.client.luau`: interface, controles e animações.
- `default.project.json`: sincroniza os scripts e o RemoteEvent preservando outros objetos do lugar.

Edite os arquivos locais com um editor de texto; o Rojo sincroniza para o Studio. O Rojo não dá acesso remoto ao computador e não envia alterações ao GitHub. Mudanças feitas no Studio não são automaticamente gravadas nesses arquivos.

Para gerar um lugar sem usar a conexão ao vivo:

```bat
rojo build default.project.json -o MUBlox.rbxlx
```

O GitHub guarda o código enviado por commit/push. O Roblox guarda o lugar quando você o salva/publica pelo Studio. São operações diferentes. Para futuras tarefas na nuvem, use o checkout existente; não crie worktree sem necessidade ou pedido.
