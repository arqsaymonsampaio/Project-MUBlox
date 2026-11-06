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
- Clique esquerdo diretamente em um golem: ataque básico da classe, exigindo arma equipada e alcance.
- Clique direito no mundo (ou no primeiro slot do HUD): skill da classe. Pode ser lançada sem alvo, consumindo mana e iniciando recarga.

| Classe / arma | Ataque básico | Skill | Mana / recarga |
|---|---|---|---|
| Guerreiro / espada | 15 de dano, 10 studs | Giro: 45 de dano nos alvos em 14 studs | 20 / 3 s |
| Mago / staff | Orbe: 18 de dano, 60 studs | Espíritos: 35 de dano por alvo visível na tela, até 65 studs | 30 / 4 s |
| Elfa / arco | Flecha: 16 de dano, 55 studs | Multi-Shot: 32 de dano por alvo no cone frontal de 80°, até 55 studs | 25 / 3 s |

Os espíritos usam candidatos projetados na tela pela câmera; o servidor valida registro do inimigo, alcance, obstáculos e duplicatas. O cone da Elfa segue a direção do corpo, não a câmera. Cada alvo recebe dano uma vez por lançamento. Os projéteis rastreiam o alvo clicado e aplicam dano ao concluir o percurso, se ele continuar elegível. Os valores são iniciais para balanceamento.

- Com inventário aberto, cliques fora do painel continuam controlando o combate; os cliques sobre as peças apenas equipam/retiram.
- Ao flutuar, o som padrão de passos é silenciado e volta ao retirar as asas.
- O dano efetivo aparece sobre o monstro, sobe e desaparece, inclusive no golpe final.
- A câmera padrão também usa o botão direito ao arrastar.

A arena além do portão norte possui três golems, com vida, patrulha e reaparecimento independentes. Cada golem patrulha a arena, detecta jogadores vivos com classe escolhida a até 32 studs e persegue automaticamente sem precisar receber dano. Seu deslocamento fica limitado à arena; alvos além de 42 studs do centro são ignorados. Levanta os braços antes de golpear, permitindo sair do alcance. Concede 50 XP ao jogador que dá o último golpe e reaparece após cinco segundos. Cada 100 XP sobe um nível. Os níveis ainda não concedem novos atributos.

## O que está incluído

- Cidade medieval, fonte, casas cenográficas, muralhas e campo de treino.
- Guerreiro, Mago e Elfa com vida e mana diferentes.
- HUD, inventário lateral com atalho I, peças cosméticas e arma própria de cada classe. O slot interno `Sword` foi preservado por compatibilidade, mas exibe Espada, Staff ou Arco conforme a classe.
- Guerreiro: asas de morcego com membranas e nervuras escuras. Mago: asas de anjo com penas claras. Elfa: asas de borboleta com lóbulos delicados e semitransparentes. Os modelos são geométricos provisórios.
- Barra de HP do golem com redução suave e mudança de cor, mantendo os números flutuantes de dano.
- Movimento e golpes articulados do golem controlados pelo servidor. A navegação atual atende ao piso plano e aberto desta arena; não é um sistema de navegação para obstáculos adicionados posteriormente.
- Controlador com suporte a Motor6D e AnimationConstraint, incluindo postura e ataque procedural.
- O Mago mantém as asas de penas anteriores; as membranas do Guerreiro e da Elfa usam uma estrutura por lado para permanecerem unidas durante a batida.
- Com asas, o tronco fica quase ereto parado e inclina até 20° ao se deslocar, com transição suave baseada na velocidade horizontal.
- Dano, alcance, mana e recarga validados pelo servidor.

## Limitações e validação

Onze cenários de combate passaram usando o bloco real do servidor com serviços simulados: seleção obrigatória para ataques básicos, alcance, obstáculos, projéteis, alvos visíveis sem duplicação, cone frontal, skills vazias, mana, recarga, armas, morte do lançador e múltiplas recompensas/respawns. Rode `python tests/run_combat.py /caminho/para/luau`. Sete cenários da IA verificam patrulha, perseguição, alvos inválidos, golpes, esquiva, morte e independência entre inimigos: `python tests/run_enemy.py /caminho/para/luau`. Os testes não verificam a física ou a renderização do Studio.

Sons, barra de HP, novos modelos de asas, animação/navegação do golem e interação com o painel ainda precisam de teste no Studio.

A sintaxe dos scripts foi verificada com o compilador oficial Luau. O build foi gerado com Rojo 7.7.1 e os objetos/fontes resultantes foram conferidos. Isso não substitui um teste no Roblox Studio.

A postura inclinada com AnimationConstraint foi confirmada pelo usuário no Studio. A transição entre repouso e movimento e os movimentos da espada ainda precisam de confirmação visual. As armaduras são peças provisórias; acessórios do avatar podem se sobrepor. Armas, espíritos, flechas e poses de conjuração/tiro são representações procedurais provisórias que precisam de revisão visual no Studio. Não há salvamento de progresso, PvP, economia, interiores de casas nem controle de combate para celular. A interface redimensiona, mas precisa de validação em dispositivos.

Teste após conectar: escolher classe, vestir/retirar peças, abrir com I, equipar asas, conferir postura lateral, testar as três classes em sessões separadas, usar as skills com vários inimigos (incluindo alvos fora da tela e atrás da Elfa), receber dano, ganhar XP e renascer.

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
