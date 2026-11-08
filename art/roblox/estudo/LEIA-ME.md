# Guerreiro — estudo estático para conferir no mapa

Este pacote leva ao Studio o modelo Blender com os cotovelos corrigidos.
Ele serve para comparar proporções, cores e silhueta dentro do mapa.
Não é um personagem animado e não substitui o guerreiro jogável.

## Importar

1. Extraia o ZIP inteiro para uma pasta (não abra o FBX dentro do ZIP).
2. Salve seu lugar e pare o **Play** no Roblox Studio.
3. Na barra superior, clique em **Importar 3D / Import 3D** e escolha
   `MUBlox_Estudo_Mapa.fbx`.
4. Mantenha a importação das texturas ativada. Não use criação automática de
   avatar/rig. Importe como modelo comum com as sete malhas agrupadas.
   Se houver escolha de unidades, use a escala indicada pelo arquivo.
5. Importe o modelo no **Workspace**. Mantenha `Estudo_Cores.png` junto do FBX
   caso o importador precise localizar a textura externa.
6. Selecione o **Model inteiro** no Explorador, não apenas uma malha.
7. Abra `AJUSTAR_NO_STUDIO.luau` no Bloco de Notas, copie todo o conteúdo e
   execute na **Barra de Comandos** do Studio (não no CMD nem no Rojo).
   O comando confere a seleção, define altura de **5,5 studs**, ancora todas
   as peças e desativa colisões. Pode ser desfeito com Ctrl+Z.
8. Com o modelo selecionado, pressione **F** para enquadrá-lo. Use **Mover**
   para colocá-lo ao lado da área onde o personagem aparece. Ao dar Play,
   o estudo fica parado e você pode caminhar ao redor para comparar.

Se não achar a Barra de Comandos, pode ajustar manualmente: selecione as sete
malhas e ative **Anchored/Ancorado**; desative **CanCollide**; depois selecione
o Model inteiro e use a ferramenta **Escala** para deixá-lo do tamanho desejado.
O comando apenas oferece uma altura consistente e evita repetir o problema
da importação gigante.

Mantenha o nome **MUBloxEstudoMapa** e deixe em **Workspace**. O modelo de
equipamentos `MUBloxWarriorVisual` em ServerStorage continua sendo o avatar
jogável existente. Não é necessário trocar scripts ou conectar o Rojo para
este teste visual.

## Validação

O FBX foi exportado e reimportado no Blender, verificando sete malhas,
textura, UVs, limite de triângulos e ausência de câmera/luzes/pedestal.
A importação no seu Roblox Studio ainda precisa de conferência. A iluminação
do mapa pode fazer as cores parecerem diferentes do render do Blender.
