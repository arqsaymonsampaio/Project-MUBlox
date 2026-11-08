# Guerreiro articulado — teste de deformação

Este é um novo arquivo com **esqueleto de 15 ossos e pesos nas sete malhas**.
O modelo estático anterior não contém esses ossos: é necessário importar o
novo FBX. Corpo, roupa, cabelo, rosto, luvas e botas acompanham o esqueleto.
Os cotovelos e joelhos dobram por deformação da malha, sem cortar os membros
em peças rígidas. A barra da túnica acompanha parcialmente as coxas.

## No Studio

1. Salve seu lugar e pare o Play. Extraia o ZIP inteiro.
2. Use **Importar 3D** com `MUBlox_Guerreiro_Articulado.fbx`.
3. Importe como modelo com skinning/esqueleto. Preserve a hierarquia de ossos
   do arquivo; não use geração automática de outro rig e não una as malhas.
   Mantenha as texturas ativadas e o PNG ao lado do FBX.
4. Coloque em **Workspace** e selecione o Model inteiro no Explorador.
5. Abra `INSTALAR_TESTE.command.luau` no Bloco de Notas. Copie todo o conteúdo
   e execute na **Barra de Comandos** do Studio, fora do Play.
6. O instalador verifica a presença dos ossos, ancora as malhas, ajusta a
   altura para 5,5 studs e adiciona a demonstração. Se houver problema,
   ele informa o motivo antes de instalar. Ctrl+Z desfaz a instalação.
7. Use **Mover** para colocar o modelo no chão ao lado do personagem.
8. Dê Play: ele deve flexionar os dois cotovelos e um joelho repetidamente,
   enquanto permanece no mesmo lugar. Pare o Play para voltar à edição.

Caso a Barra de Comandos não funcione, envie a mensagem da **Saída/Output**.
Não cole esse instalador no CMD, no chat, nem em um Script comum.
O arquivo `DEMONSTRACAO.client.luau` já está incluído no instalador.

Para remover o teste, pare o Play e apague o modelo `MUBloxTesteArticulado`.
Ele é independente do modelo estático e do personagem jogável.

## No Blender

Abra `MUBlox_Guerreiro_Articulado.blend`. Aperte Espaço sobre a linha do tempo
para ver a ação `Teste_Cotovelos_Joelho` (quadros 1–81). O quadro 1 é a pose
de repouso e o 21 é a pose dobrada. O arquivo FBX contém o esqueleto e os
pesos em repouso; a demonstração no Studio é feita pelo script incluído.

## O que já foi verificado e o que falta

- Geração e render de uma pose dobrada no Blender 4.3.2.
- Reimportação real do FBX: 15 ossos, sete malhas, textura e UVs, até quatro
  pesos normalizados por vértice e menos de 10 mil triângulos por malha.
- Pesos compartilhados nos cotovelos/joelhos, mãos acompanhando os antebraços
  e cabeça permanecendo no lugar durante o teste de flexão.
- Script de demonstração e instalador compilados com Luau.

**A execução no Roblox Studio ainda precisa ser conferida.** Esse teste não
implementa andar, atacar, voar, equipar sets ou controle por Humanoid.
Os ossos usam nomes anatômicos semelhantes ao R15, mas isso não torna o modelo
um avatar R15 compatível automaticamente. A integração com os controles e
equipamentos do MUBlox é uma etapa separada, após conferir a deformação.
Não substitua `MUBloxWarriorVisual` no ServerStorage por este arquivo.

Este é um rig experimental sobre a malha do estudo, ainda sem retopologia
manual final. Podem ser necessários ajustes de pesos em poses extremas.
