# Teste do guerreiro articulado V5

Abra **MUBlox_Teste_Articulado_V5.rbxlx** pelo Roblox Studio (Arquivo → Abrir).
É uma cópia de teste construída a partir do lugar com escala ajustada enviado
pelo usuário. O arquivo original não foi alterado.

## Primeiro teste

1. Salve e feche o lugar atual. Abra o novo `.rbxlx`.
2. Deixe o Rojo desconectado neste primeiro teste, para não sincronizar scripts
   antigos por cima dos scripts novos incluídos no lugar.
3. Dê Play e escolha **Guerreiro**. O novo corpo deve substituir o visual antigo
   do jogador, mantendo movimento, câmera, vida, inventário e combate existentes.
4. A Saída deve mostrar **MUBlox visual: V5 articulado, 15 ossos e 7 malhas**.
5. Confira andar, pular, ataque esquerdo, giro direito, equipar/retirar asas e
   cada peça do set. Pare o teste se algum encaixe estiver errado e registre
   o que aconteceu. A armadura continua usando as formas provisórias do jogo.

Não renomeie manualmente os ossos nem mova o modelo antigo. O novo template já
está em **ServerStorage → MUBloxWarriorSkinned**. A versão antiga
**MUBloxWarriorVisual** foi mantida como alternativa.

## Como funciona

- O R15 original fica invisível e continua responsável pelo Humanoid, física,
  controle e poses de caminhada, voo e ataque.
- O módulo **ReplicatedStorage → SkinnedWarrior** transfere as rotações para os
  15 ossos preservando os comprimentos do corpo novo. A escala `.035` aprovada
  no lugar enviado permanece intacta; não há redimensionamento de malhas isoladas.
- O template preserva o HumanoidRigDescription e as referências do mapeamento
  enviado. Na cópia em execução, a ponte usa os ossos anatômicos diretamente;
  não usa o mapeamento `HeadBase → Skin_FaceMotor6D` para mover a cabeça.
  O rosto e o cabelo acompanham o osso `Head` através dos pesos existentes.
- Pontos invisíveis de encaixe acompanham os ossos para espada, armadura e asas.
  Os cinco slots de roupa ocultam/restauram suas camadas iniciais separadamente.
- A renderização é atualizada para todos os jogadores vistos por cada cliente.
  Dano, mana, alcance e experiência continuam sendo decididos no servidor.

## Rojo e arquivos

Para continuar editando pelo Rojo, atualize **todos** estes arquivos na mesma
pasta do projeto antes de reconectar:

- `default.project.json`
- `src/server/MUBlox.server.luau`
- `src/client/MUBlox.client.luau`
- `src/shared/SkinnedWarrior.luau`
- `art/roblox/MUBloxWarriorSkinned.rbxmx`

O `default.project.json` já sincroniza o módulo e o novo template. A porta de
conexão continua sendo a utilizada no seu `rojo serve` (por exemplo 34873).
Não use o ZIP antigo de demonstração que foi bloqueado pelo Defender. Este
teste não depende daquele instalador. Os scripts desta integração ficam
visíveis no Studio e no repositório; não houve verificação com Windows Defender
neste ambiente. Se houver novo alerta, mantenha o bloqueio e informe a detecção.

## Validação e limites

Foram executados: compilação Luau, construção Rojo, teste matemático usando os
15 ossos efetivamente salvos, rotação de cotovelo/mão, giro do tronco, deslocamento
do voo, preservação de comprimentos, validação de modelo incompleto, solução de
pose neutra Motor6D/AnimationConstraint e regressões de visual, combate e mobs.

**Ainda não executado dentro do Roblox Studio neste ambiente.** Precisam de
conferência prática: encaixe e orientação da espada, ombreiras, botas, altura dos
pés, comportamento após renascer e visual em uma sessão com dois jogadores.
Os assets MeshId/TextureID continuam pertencendo à conta que os importou;
o acesso a eles deve estar disponível para o lugar em que o teste for aberto.

Para voltar, abra seu `.rbxlx` anterior. No projeto V5 também é possível mover
o template `MUBloxWarriorSkinned` para fora de ServerStorage, parar e iniciar
Play novamente: o servidor volta ao visual rígido anterior.
