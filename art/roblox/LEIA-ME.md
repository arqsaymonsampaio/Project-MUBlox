# Guerreiro inicial — primeiro teste no Roblox Studio

Este pacote instala um **visual experimental R15** do Guerreiro sobre o personagem
que já movimenta no MUBlox. A malha vem do protótipo Blender, com roupa inicial,
rosto e cabelo. É um teste jogável de integração; ainda precisa de conferência no
Studio para avaliar encaixes, juntas, escala e cores. Não é um avatar pronto para
publicar no catálogo Roblox.

## Instalação

1. Salve seu lugar atual e pare o **Play**.
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
   Leve o modelo completo: 15 malhas `Visual_*`, 15 blocos `Bind_*` e os
   marcadores `AxisOrigin`, `AxisUp`, `AxisFront`. Os blocos são referências;
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

As roupas e o corpo continuam separados no arquivo-fonte Blender. Neste FBX,
as superfícies foram agrupadas por região R15 para acompanhar o movimento;
não se trata de uma malha orgânica com pesos de deformação. Podem aparecer
emendas nos joelhos/cotovelos, especialmente com poses fortes. As proporções
finais também dependem das dimensões do avatar R15 do jogador. Precisaremos
avaliar isso no Studio antes de fixar um corpo padrão para todos os jogadores.

Os sets geométricos antigos continuam provisórios e ainda não foram ajustados
para este novo corpo. O foco deste pacote é o personagem inicial. Rosto, cabelo,
mãos, costuras e acabamento ainda são de protótipo; a renderização conceitual
não é uma promessa de acabamento idêntico no jogo.

## Validação realizada

- Exportação real de FBX com 15 malhas, marcadores e textura atlas de 128 × 128.
- Reimportação real no Blender: UVs, textura, nomes, limites espaciais dos
  segmentos e menos de 10 mil triângulos em cada malha.
- Validação automatizada do contrato de importação: modelos incompletos,
  nomes duplicados, rig incompatível e eixos inválidos são rejeitados.
- Testes existentes de combate e IA, compilação Luau e build Rojo.
- Ainda **não testado no Roblox Studio** neste ambiente.

Fontes: `art/blender/criar_corpo_base.py` e
`art/blender/exportar_corpo_roblox.py` no repositório.
