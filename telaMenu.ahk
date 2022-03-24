#SingleInstance, Force
/* GUI Tela de Menu
*/
Gui menu:Font, s11
; botoes jogar
Gui menu:Add, Button, x52 y109 w160 h40 gJogarCampo1, Jogar no Campo 1 (Menor)
Gui menu:Add, Button, x52 y159 w160 h40 gJogarCampo2, Jogar no Campo 2 (Maior)
; nome do player
Gui menu:Font, Bold
Gui menu:Add, Text, x52 y39 w130 h20, Nome do Player
Gui menu:Font, Normal
Gui menu:Add, Edit, x52 y59 w160 h20 vPlayerNome, Player1
; Botao Checar Top5
Gui menu:Add, Button, x52 y209 w160 h40 gVerTop5, Ver Top 5 Partidas
; tela principal
Gui menu:Font, s9
Gui menu:Color, 99bbff