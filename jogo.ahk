#SingleInstance, Force
#Include telaMenu.ahk
#Include campo1.ahk
#Include funcoesAuxiliares.ahk
FileEncoding, UTF-8

/*
* * * * * * * * * * * * * * * * * *
*       JOGO BATALHA NAVAL        *
*    Desenvolvido por: Luan F.    *
* * * * * * * * * * * * * * * * * *
*/

IMAGENS := {bomba:"imagens/bomba.png",mar:"imagens/quadradoAzul.png",atirou:"imagens/errouTiro.png",acertou:"imagens/hitship.png"}
MUSICAS := {venceu:"audios/we_are.mp3",perdeu:"audios/roronoa.mp3"}

; Constantes:
WIDTH_MENU := 269, HEIGHT_MENU := 270
WIDTH_CAMPO1_UNICA := 340, HEIGHT_CAMPO1_UNICA := 565
WIDTH_CAMPO1_DUPLA := 700, HEIGHT_CAMPO1_DUPLA := 567
WIDTH_CAMPO2_UNICA := 422, HEIGHT_CAMPO2_UNICA := 650
WIDTH_CAMPO2_DUPLA := 865, HEIGHT_CAMPO2_DUPLA := 680

QUAD_SIZE := 40 ; (40x40)

; Variaveis
widthAtual := WIDTH_MENU
heightAtual := HEIGHT_MENU
campoMaxLinha := 8, campoMaxColuna := 12

pontuacaoPlayer := 0
pontuacaoAdv := 0
playerAtingiu := 0
advAtingiu := 0
afundadosJogador := []
afundadosAdv := []
superTiros := 2
clicadoSupertiro := false
partidaIniciada := false
partidaFinalizada := false
startTime := 0

; Exibe o Menu
resizeGUI("menu",WIDTH_MENU,HEIGHT_MENU,true)
guiAtiva := "menu"

Return

JogarCampo1:
    Gui menu:Hide
    GuiControlGet, PlayerNome
    guiAtiva := "campo1"
    iniciarJogo1(campoMaxLinha,campoMaxColuna,WIDTH_CAMPO1_UNICA,HEIGHT_CAMPO1_UNICA)
    Return
JogarCampo2:
    Gui menu:Hide
    GuiControlGet, PlayerNome
    guiAtiva := "campo2"
    campoMaxLinha := 10, campoMaxColuna := 14

    iniciarJogo1(campoMaxLinha,campoMaxColuna,WIDTH_CAMPO2_UNICA,HEIGHT_CAMPO2_UNICA)
    Return
IniciarJogo:
    ; finalizou a insercao de embarcacoes e clicou no botao iniciar jogo
    if(partidaIniciada)
        return

    partidaIniciada := true
    Gui, campo1:Hide
    ToolTip, Iniciando Partida...
    
    Gui, campo1: Add, Text, vTirosCont x5 y5, Tiros: 0000

    scoreIni := "00P    "
    ; Score Player
    xScorePlayer := guiAtiva=="campo1" ? 35 : 65
    Gui, campo1: Font, s12 vBold c002266
    Gui, campo1: Add, Text, x%xScorePlayer% y20 vScoreAdv, Pontuação PC: %scoreIni%

    ; Botao SuperTiro
    xSuperTiro := guiAtiva=="campo1" ? (WIDTH_CAMPO1_DUPLA/2)-80 : (WIDTH_CAMPO1_DUPLA/2)
    Gui, campo1: Font, s12 vBold
    Gui, campo1: Add, Button, x%xSuperTiro% y10 gUsarSuperTiro vSuperTiro, Usar Super Tiro

    ; Contador de SuperTiros
    Gui, campo1: Font, s15 vBold cE63900
    xCountSuperTiros := % xSuperTiro+146
    Gui, campo1: Add, Text, x%xCountSuperTiros% y15 vCountSuperTiro, 2x

    ; Score Máquina
    xCountSuperTiros += 60
    Gui, campo1: Font, s12 vBold c006600
    Gui, campo1: Add, Text, x%xCountSuperTiros% y20 vScorePlayer, Pontuação %playerNome%: %scoreIni%
    Gui, campo1: Font

    ; esconder as embarcações do tabuleiro do jogador
    hideCampo()

    ; esconde os elementos de inserção das embarcacoes
    GuiControl, Hide, EmbarcacaoAtualTexto
    GuiControl, Hide, InsercaoMode
    GuiControl, Hide, IniciarButton

    ; gera o tabuleiro do adversario
    gerarAreaCampo("campo1",campoMaxLinha,campoMaxColuna,((40*(campoMaxLinha+1))+2), 60, true) 
    ; realiza o processo de insercao de embarcacoes aleatorias para o adversario
    inserirEmbarcacoesAdversario("campo1",campoMaxLinha,campoMaxColuna,201)
    
    if(guiAtiva == "campo1"){
        wDupla := WIDTH_CAMPO1_DUPLA
        hDupla := HEIGHT_CAMPO1_DUPLA
    } else {
        wDupla := WIDTH_CAMPO2_DUPLA
        hDupla := HEIGHT_CAMPO2_DUPLA
    }

    resizeGUI("campo1",wDupla,hDupla,true)
    cronometrar() ; inicia o cronometro
    ToolTip
    Return
VerTop5:
    exibirResultadosVencedores()
    Return
UsarSuperTiro:
    ; Clicou no Botao de usar o super tiro
    if(clicadoSuperTiro) ; super tiro já selecionado!
        return
    if(superTiros = 0){ ; checa se acabou os super tiros
        messageBox("Todos os Super Tiros ja foram utilizados")
        return
    }

    clicadoSuperTiro := true
    superTiros--
    GuiControl,, CountSuperTiro, %superTiros%x
    Return
InserirEmbarcacoes:
    adversario := splitStr(A_GuiControl)[2]>=200 ; checa se a inserção é do adversario
    inserirEmbarcacoes(A_GuiControl,adversario)
    Return
SetarModo:
    modoHorizontal := Not modoHorizontal
    novoModo := modoHorizontal ? "Vertical" : "Horizontal"
    GuiControl,, InsercaoMode, Ativar Modo %novoModo%
    Return
AtivarBotaoJogar:
    ; Exibe o botao de iniciar jogo
    resizeGUI("campo1",0,50)
    Return

; Funcoes Auxiliares
resizeGUI(guiName,increaseWidth,increaseHeight=0,substituir=False){
    ; altera o tamanho de uma GUI
    global
    if(substituir) ; novo tamanho será o passado
        widthAtual := increaseWidth, heightAtual := increaseHeight
    else ; nao substitui, apenas aumenta a altura e largura
        widthAtual += increaseWidth, heightAtual += increaseHeight

    Gui, %guiName%:Show, w%widthAtual% h%heightAtual%, Batalha Naval
}

checarVenceu(adversario=false){
    global
    ; checa se o jogador ou a máquina venceram
    if(partidaFinalizada) ; partida terminou
        return

    if(!adversario){
        if(playerAtingiu >= 30){
            SoundPlay, % MUSICAS.venceu
            MsgBox, %playerNome% Venceu!!!!!
            escreverResultadoVencedores(true)
            partidaFinalizada := true
        }
    } else {
        if(advAtingiu >= 30){
            SoundPlay, % MUSICAS.perdeu
            MsgBox, Você perdeu :(
            escreverResultadoVencedores(false)
        }
    }
    
}

atualizarPontuacao(pontos,adversario=false){
    global
    GuiControl,, TirosCont, Tiros: %playerAtingiu% 

    if(!adversario){
        playerAtingiu++
        pontuacaoPlayer += pontos

        GuiControl,, ScorePlayer, Pontuação %playerNome%: %pontuacaoPlayer%P
        checarVenceu()
    } else {
        pontuacaoAdv += pontos
        advAtingiu++

        x:=%pontuacaoAdv%
        GuiControl,, ScoreAdv, Pontuação PC: %pontuacaoAdv%P
        checarVenceu(true)
    }
}

cronometrar(start=true){
    ; cronometrar o tempo da partida
    global
    if(start){
        startTime := % A_TickCount
    } else {
        endTime := (A_TickCount+120-startTime)/1000
        return Round(endTime,2)
    }
}

escreverResultadoVencedores(jogadorVenceu){
    global
    tempoTotal := cronometrar(false)
    dataAtual := getCurrentTime()
    tempoMsg = %playerNome% (%dataAtual%) - Tempo de Partida: %tempoTotal% segundos

    fileResult := FileOpen("ResultadosPartidas.txt","a")
    fileResult.Write(tempoMsg . "`r")
    fileResult.Close()
    ; Exibe o resultado
    messageBox(tempoMsg,10)
}

exibirResultadosVencedores(){
    ; exibe os 5 melhores jogadores
    file := FileOpen("ResultadosPartidas.txt","r")
    fileContent := splitStr(file.Read(), "`r")
    file.Close()

    ; pega apenas os segundos
    getTimes := []
    For index,line in fileContent {
        if(line != "`r"){
            lineInfo := splitStr(line," ")
            getTimes.Push(lineInfo[lineInfo.Length()-1])
        }
    }

    ; pega os 5 maiores jogadores baseados no tempo
    top5Tempos := getBiggests(getTimes,5)

    temposMsg := "Top 5 Vencedores:`r`r"
    For index,elem in top5Tempos {
        temposMsg .= index . ") "
        temposMsg .= fileContent[elem] . "`r"
    }

    ; exibe o top 5
    messageBox(temposMsg,30)
}

; Fechar GUIs
Campo1GuiClose:
Campo2GuiClose:
    MsgBox, 36, Fechar, Deseja encerrar a partida?
    IfMsgBox, Yes, { ; escolheu encerrar
        ExitApp
    }
    Return
MenuGuiClose:
    ExitApp