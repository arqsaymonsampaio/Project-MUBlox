# Guerreiro inicial — correção de encaixe V4

Este pacote instala um **visual experimental R15** do Guerreiro sobre o personagem
que já movimenta no MUBlox. A malha vem do protótipo Blender, com roupa inicial,
rosto e cabelo. É um teste jogável de integração; ainda precisa de conferência no
Studio para avaliar encaixes, juntas, escala e cores. Não é um avatar pronto para
publicar no catálogo Roblox.

## Atualização para quem já importou o modelo V3

Mantenha o FBX que já está no Studio. Esta correção altera somente o servidor.

1. Pare o Play e substitua `src\server\MUBlox.server.luau` pelo arquivo atual.
   O nome deve ser exatamente esse, sem sufixos como `(1)` ou `(2)`.
2. Mantenha o Rojo conectado à pasta correta do projeto.
3. No Studio, abra `ServerScriptService → MUBloxServerV2`. A primeira linha deve
   começar com `-- MUBLOX_VISUAL_V4`. Isso confirma que o arquivo sincronizou.
4. Inicie Play e escolha Guerreiro. A Saída deve informar
   `MUBlox visual: V4, 29 malhas`.

O marcador do arquivo 3D continua `FormatV3`: não é necessário trocar o asset
para usar o encaixe V4. Se o diagnóstico mostrar `Vnil`, a identificação não foi
aplicada pela rotina atual; confira a primeira linha do script em execução.

## O que mudou nesta versão

- Encaixe usa o vetor completo entre as articulações (X, Y e Z), em vez de
  considerar apenas a distância vertical.
- Orientação do braço e antebraço segue o eixo real de cada osso. Mãos ficam
  alinhadas ao punho mantendo suas proporções.
- Ombreiras e luvas usam o mesmo sistema de orientação das malhas do corpo.
- Regressão testada com as medidas reais fornecidas pelo usuário: os dois lados
  e ambas as extremidades de cada segmento, em três escalas de importação.

Mantido da V3:

- Ombro inteiro acompanha o braço: não há mais uma metade cortada presa ao tórax.
- Palma menor, polegar e quatro dedos definidos; luva inicial em forma de tecido,
  substituindo a esfera que cobria a mão.
- Comprimento dos braços calculado pelas articulações de ombro/cotovelo/punho
  quando disponíveis, com escala de reserva para rigs sem esses attachments.
- Mãos preservam proporções com escala uniforme e são alinhadas ao punho.
- Ao carregar, a Saída do Studio informa `MUBlox visual: V4, 29 malhas`.
  Se não aparecer V4, confira a sincronização do script e o modelo instalado.

Mantido da V2:

- Cinto e fivela inteiros na cintura, sem corte entre dois segmentos.
- 15 regiões do corpo e 14 malhas de roupa/cabelo independentes.
- Equipar uma peça esconde a camada inicial correspondente; retirar restaura.
  Asas não escondem roupa. O elmo esconde o cabelo e mantém o rosto por baixo.
- Eixos dos braços alinhados, escala transversal compartilhada entre segmentos
  e volumes arredondados nas junções para reduzir degraus e aberturas.
- Olhos um pouco mais recuados, conforme o problema visível na foto de perfil.
- Set provisório dimensionado pelas malhas novas, com cintura e grevas.

## Instalação

1. Salve seu lugar atual e pare o **Play**. Se já importou a versão anterior,
   renomeie o modelo antigo em ServerStorage para `MUBloxWarriorVisual_Antigo_V2`.
   Mantenha-o como cópia de segurança até conferir o resultado.
2. Substitua `src\server\MUBlox.server.luau` pelo arquivo deste pacote na pasta
   que o Rojo está servindo. Não cole o código na Barra de Comandos. O script
   do cliente e `default.project.json` continuam os mesmos.
3. No Roblox Studio, use **Importar 3D / Import 3D** e escolha
   `Guerreiro_Visual_R15.fbx`. Mantenha as malhas separadas, os nomes originais,
   a textura e todos os marcadores. Não junte as peças e não solicite criação
   automática de rig: o jogo utiliza o R15 que já existe.
4. Importe para sua conta (ou para o mesmo proprietário da experiência, caso
   use um grupo). O FBX já contém a imagem de cores. A cópia `Guerreiro_Cores.png`
   acompanha o pacote caso o importador peça o arquivo da textura. Se a
   importação mostrar tudo branco, confira a textura antes de continuar.
5. No **Explorador**, renomeie o modelo importado inteiro para exatamente
   **MUBloxWarriorVisual** e arraste-o de Workspace para **ServerStorage**.
   Leve o modelo completo: 15 malhas `Visual_*`, 14 malhas `Wear_*`,
   15 blocos `Bind_*` e os marcadores `AxisOrigin`, `AxisUp`, `AxisFront`,
   `FormatV2`, `FormatV3` (49 objetos). Os blocos são referências;
   não fazem parte do visual que o script coloca no jogador. Não os apague.
6. Com o Rojo conectado, inicie **Play** e escolha **Guerreiro**.
   A roupa inicial será aplicada e as peças do set começarão desequipadas
   nesta sessão. A espada continua disponível. Mago e Elfa mantêm seus visuais.
7. Teste caminhada, salto, inventário, ataque, asas e renascimento. Veja de
   frente, lado e costas. Grave um trecho se encontrar abertura nas juntas,
   peças atravessando o corpo ou escala inadequada.
8. Pare o Play e salve o lugar como `.rbxl`. Esse arquivo guarda a referência
   ao modelo importado. O GitHub e o Rojo, sozinhos, não guardam os IDs dos
   assets que você acabou de importar no Studio.

Para instalações V1/V2, atualize o servidor e importe o FBX atual. Quem já está
com o modelo V3 precisa somente atualizar o servidor para esta correção. Deve existir apenas um modelo com o nome exato
`MUBloxWarriorVisual` dentro de ServerStorage. Não misture partes das versões.

Não precisa tornar o jogo público para testar no Studio. A importação pode
solicitar o envio das malhas/textura para sua conta Roblox.

## Se não aparecer

- Confirme o nome `MUBloxWarriorVisual` e a pasta **ServerStorage**.
- Confira que escolheu Guerreiro e que está usando R15.
- Verifique **Saída / Output** para mensagens começando com
  `MUBlox: visual inicial nao aplicado:`.
- Se o modelo estiver ausente ou incompleto, o código preserva o personagem
  anterior. Isso evita esconder o avatar por uma importação incompleta.
- Para desativar: pare o Play, renomeie o modelo para
  `MUBloxWarriorVisual_Desativado` e teste novamente.

## O que está implementado e o que falta

As malhas são divididas em 15 regiões e presas às partes R15 por soldas. O rig,
Humanoid, animações existentes, câmera, hitboxes e regras de combate continuam
sendo os do jogo. O corpo original e seus acessórios ficam invisíveis quando
há um modelo completo válido. Os marcadores permitem compensar a conversão de
eixos e unidades do FBX. A aparência é reconstruída após carregar o avatar.

As roupas e o corpo estão separados no Blender e no FBX V3. As malhas são
agrupadas por região R15 e por equipamento para acompanhar o movimento;
não se trata de uma malha orgânica com pesos de deformação. Podem aparecer
emendas nos joelhos/cotovelos, especialmente com poses fortes. As proporções
finais também dependem das dimensões do avatar R15 do jogador. Precisaremos
avaliar isso no Studio antes de fixar um corpo padrão para todos os jogadores.

Os sets geométricos antigos continuam provisórios. O encaixe básico agora
considera as dimensões das malhas novas, mas ainda não equivale à armadura
modelada no Blender e precisa de revisão visual com poses diferentes. Rosto, cabelo,
mãos, costuras e acabamento ainda são de protótipo; a renderização conceitual
não é uma promessa de acabamento idêntico no jogo.

## Validação realizada

- Exportação real de FBX com 29 malhas visuais, marcadores e atlas de 128 × 128.
- Reimportação real no Blender: UVs, textura, nomes, limites espaciais dos
  segmentos e menos de 10 mil triângulos em cada malha.
- Validação automatizada do contrato de importação: modelos incompletos,
  nomes duplicados, rig incompatível e eixos inválidos são rejeitados.
- Teste de dedos separados após a exportação/reimportação real do FBX.
- Testes de comprimento por articulação, escala uniforme das mãos, alinhamento
  ao punho e identificação das camadas mesmo sem o marcador V2.
- Testes de camadas obrigatórias, equipar/retirar cada slot, set completo,
  restauração de transparência e independência das asas.
- Testes existentes de combate e IA, compilação Luau e build Rojo.
- A integração da V1 foi confirmada pelo usuário no Studio. Os ajustes da
  **V4 ainda precisa de conferência visual no Studio**. O alinhamento foi testado
  matematicamente com o avatar informado, mas isso não substitui essa conferência.

Fontes: `art/blender/criar_corpo_base.py` e
`art/blender/exportar_corpo_roblox.py` no repositório.
