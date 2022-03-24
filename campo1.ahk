#SingleInstance, Force
/* GUI Tela Campo 1 (Menor - 8x12)
*/

;embarcacoesTotaisAdv := [["PortaAviao",5,1],["NavioTanque",4,2],["Contratorpedeiro",3,3],["Submarino",2,4]]
idList := []
idListAdv := []
tentadosJogador := []
tentadosAdv := []
tiros3Jogador := []
tiros3Adv := []
acertosJogador := []
acertosAdv := []
jogadas := 0

;contIndex = 1

embarcacoesTotais := [["PortaAviao",5,1],["NavioTanque",4,2],["Contratorpedeiro",3,3],["Submarino",2,4]]
embarcacoesByEspaco := {2:"Submarino",3:"Contratorpedeiro",4:"NavioTanque",5:"PortaAviao"}
;embarcacoesTotaisAdv := embarcacoesTotais.copy() ; copia o array com as informacoes das embarcacoes
embarcacoesTotaisAdv := [["PortaAviao",5,1],["NavioTanque",4,2],["Contratorpedeiro",3,3],["Submarino",2,4]]

embarcacaoAtual := "PortaAviao"
embarcacaoAtualEspaco := 5
embarcacaoAtualQuant := 1

modoHorizontal := true
insercaoFinalizada := false ; verificador de se o jogador terminou de inserir as embarcacoes
embarcacoesSetadas := []
embarcacoesSetadasMatriz := []
embarcacoesAdv := []
embarcacoesAdvClicados := []
embarcacoesPlayer := []


iniciarJogo1(campoMaxLinha,campoMaxColuna,width_tela,height_tela){
    global
    ToolTip, Carregando Jogo...

    ; Inserir Embarcações
    wInserir := height_tela==HEIGHT_CAMPO1_UNICA ? 60 : 105
    Gui, campo1: Font, vBold s12 cE63900
    Gui, campo1: Add, Text, x%wInserir% w300 y5 vEmbarcacaoAtualTexto, Inserir PortaAviao (1x)         
    
    ; Modo Horizontal e Vertical
    Gui, campo1: Font, s10
    Gui, campo1: Add, Button, x%wInserir% w200 h25 y28 cE63900 vInsercaoMode gSetarModo, Ativar Modo Vertical
    
    ; Botao de iniciar jogo
    wBotaoJogar := height_tela==HEIGHT_CAMPO1_UNICA ? 90 : 135
    hBotaoJogar := % height_tela+4
    Gui, campo1: Font, s13 vBold
    Gui, campo1: Add, Button, x%wBotaoJogar% y%hBotaoJogar% gIniciarJogo vIniciarButton, INICIAR JOGO
    Gui, campo1: Font

    ; Gerar Primeiro Tabuleiro (Inserir Embarcações do Usuário)
    gerarAreaCampo("campo1",campoMaxLinha,campoMaxColuna,2,60)

    ; exibe o campo1 de inserir embarcacoes
    resizeGUI("campo1",width_tela,height_tela,true)
    ToolTip

    Return
}

gerarAreaCampo(campo,quantX,quantY,xIni=0,yIni=0,adversario=false){
    global
    totalAreas := % quantX*quantY
    areaSize := % QUAD_SIZE ; 40x40

    xAtual := xIni
    yAtual := yIni

    contLinha := quantX
    idInicial := adversario ? 201 : 1
    contIndex := idInicial

    Loop %totalAreas% { ; cria cada area/quadrado
        ;areaID = %campo%_%A_Index%
        areaID = %contLinha%_%contIndex%
        
        if(adversario){
            idListAdv.Push(areaID)
            writeFile("idListAdv.txt",areaID)
        } else {
            idList.Push(areaID)
            ;funcaoClick = inserirEmbarcacoes
        }

        contIndex += 1
        Gui, %campo%:Add, Picture, x%xAtual% y%yAtual% w%areaSize% h%areaSize% gInserirEmbarcacoes v%areaID%, imagens/quadradoAzul.png

        xAtual += % areaSize+2

        if(Mod(A_Index,quantX)=0){ ; proxima linha do tabuleiro
            xAtual := xIni
            yAtual += % areaSize+2
            contLinha += quantX
        }
    }
}

hideCampo(){
    ; esconde o campo do player tirando as embarcações
    global
    For index,areaID in idList {
        GuiControl,, %areaID%, imagens/quadradoAzul.png
    }
}

jogarAdversario(){
    global
    if(partidaFinalizada) ; partida terminou
        return
    jogadaAdv := 0

    jogadaRandom:
    ;if(jogadaAdv=0){
        Loop { ; faz a primeira jogada (randômica)
            jogadaID := randomFromArray(idList)
            if(not inArray(jogadaID,tentadosAdv)) ; verifica se a posicao ja foi jogada
                break
        }
    ;}

    checarJogada:
    if(jogadaAdv=3){ ; efetuou as 3 jogadas
        jogadaAdv := 0
        return
    }
    jogadaAdv++

    tentadosAdv.push(jogadaID)

    ; insere a bomba pra marcar a jogada da maquina
    GuiControl,, %jogadaID%, % IMAGENS.bomba
    jogadaIDValor := splitStr(jogadaID)[2]

    if(inArray(embarcacoesSetadas,jogadaIDValor)){ ; acertou tiro em uma embarcacoes
        ; insere a imagem da embarcacao atingida
        imgAtingida := embarcacoesPlayer[indexOfArray(embarcacoesSetadas,jogadaIDValor)]
        GuiControl,, %jogadaID%, %imgAtingida%
        afundadosAdv.push(jogadaID)
        atualizarPontuacao(10,true)

        ; procura uma posicao em volta da acertada pra dar o segundo tiro
        aoRedor := get4EmVolta(jogadaID,campoMaxLinha,idList)
        aoRedor := shuffleArray(aoRedor)

        For index,posicoesRedor in aoRedor {
            if(Not inArray(tentadosAdv,posicoesRedor)){
                jogadaID := posicoesRedor
                goto checarJogada
            }
        }
    }
    goto jogadaRandom
}

inserirEmbarcacoes(areaID, adversario=false){
    ; Inserir Embarcacoes (Jogador e Máquina)
    global
    if(partidaFinalizada) ; partida terminou
        return

    ; Separar a String do ID nos valores da linha e do elemento atual
    areaID_Info := splitStr(areaID)
    linhaMax := areaID_Info[1]
    idValor := areaID_Info[2]

    if(insercaoFinalizada and !adversario){
        messageBox("Insercao Finalizada! Clique em Iniciar Jogo para comecar")
        return
    }

    embarcacaoAtual := embarcacoesTotais[1][1]
    embarcacaoAtualEspaco := embarcacoesTotais[1][2]
    ultimoEspaco := campoMaxLinha*campoMaxColuna

    if(adversario){ ; atirou no campo adversário

        ultimoEspaco += 200
        if(inArray(tentadosJogador,areaID)){
            timerToolTip("[ ! ] Ja Atirou Aqui",2)
            return
        }
        
        areaIDs := []
        if(clicadoSupertiro){ ; utilizou 1 supertiro
            superTiroIDs := getPosRedor(areaID,campoMaxLinha,idListAdv)
            For index,tiroID in superTiroIDs { ; marca as areas atingidas
                tentadosJogador.Push(tiroID)
                areaIDs.Push(tiroID)
            }

            jogadas := 9
            clicadoSupertiro := false
        } else { ; tiro unico
            ; coloca a imagem laranja pra indicar que foi atirado ali
            GuiControl,, %areaID%, % IMAGENS.atirou
            tentadosJogador.Push(areaID)
            areaIDs.Push(areaID)
            jogadas++
        }
        
        if(jogadas=3 or jogadas=9){ ; player executou os 3x tiros
            For index,atingido3 in sliceArray(tentadosJogador, tentadosJogador.Length()-jogadas-1, tentadosJogador.Length()){
                if(Not inArray(afundadosJogador,atingido3)){
                    if(inMatriz(embarcacoesAdv,atingido3)){
                        img := IMAGENS.acertou 
                        atualizarPontuacao(10)
                        checarVenceu()
                    } else {
                        img := IMAGENS.bomba
                    }
                    GuiControl,, %atingido3%, %img%
                }
            }
        }
        
        for i,areaID in areaIDs {
            indexesEmbarcacaoClicada := matrizIndexOf(embarcacoesAdv,areaID)
            
            if(indexesEmbarcacaoClicada){ ; area clicada contem parte de embarcacao
                embarcacoesAdvClicados[indexesEmbarcacaoClicada[1]][indexesEmbarcacaoClicada[2]] := true

                destruiuEmbarcacao := checarMatrizTrue(embarcacoesAdvClicados)
                if(destruiuEmbarcacao){ ; destruiu uma embarcacao completa
                    ; ids da embarcacao destruida
                    destruida := embarcacoesAdv[destruiuEmbarcacao]
                    ; tamanho da embarcacao destruida (2,3,4 ou 5)
                    destruidaEspacos := destruida.Length()
                    
                    atualizarPontuacao(10)

                    Loop %destruidaEspacos% { ; [18_202,18_203]
                        destruidaID := destruida[A_Index]
                        afundadosJogador.push(destruidaID)

                        atingida := embarcacoesByEspaco[destruida.Length()]

                        linhaID1 := splitStr(destruida[1])[1]
                        linhaID2 := splitStr(destruida[2])[1]
                        if(linhaID1 != linhaID2) ; checar se a embarcacao destruida está na horizontal ou vertical
                            atingida := % "v_"+atingida
                        
                        ; insere as imagens da embarcacao
                        GuiControl,, %destruidaID%, imagens/embarcacoes/%atingida%%A_Index%.png
                    }
                    checarVenceu()

                    embarcacoesAdvClicados[destruiuEmbarcacao] := "Completou"
                    ;printMatriz(embarcacoesAdvClicados)
                }
            }
        }

        if(jogadas=3 or jogadas=9){
            jogadas := 0
            jogarAdversario()
        }
        Return
    }
    
    ; faz a conta de qual vai ser a proxima posição (area) para se colocar a embarcacao
    proximaPosEmbarcacao := 1
    if(Not modoHorizontal){
        embarcacaoAtual := % "v_"+embarcacaoAtual
        proximaPosEmbarcacao := campoMaxLinha
    }

    if(checarOcupado(embarcacoesSetadas, embarcacaoAtualEspaco, idValor, proximaPosEmbarcacao, ultimoEspaco)){
        MsgBox, [!] Invalido: Ja selecionado
        Return
    }

    ; checa se foi inserido uma embarcacao em um espaço que não cabe
    if(modoHorizontal and linhaMax - (idValor+embarcacaoAtualEspaco-1) < 0){
        MsgBox, Posicao Horizontal Invalida!
        Return
    } else if(Not modoHorizontal and idValor + (proximaPosEmbarcacao*(embarcacaoAtualEspaco-1)) > ultimoEspaco){
        MsgBox, Posicao Vertical Invalida!
        Return
    }
    embarcacoesSetadasMatriz.Push([])

    Loop %embarcacaoAtualEspaco% {
        embarcacoesSetadas.Push(idValor)
        ids := concat(linhaMax,idValor)
        embarcacoesSetadasMatriz[embarcacoesSetadasMatriz.Length()].Push(ids)
        
        img = imagens/embarcacoes/%embarcacaoAtual%%A_Index%.png
        embarcacoesPlayer.push(img)
        
        GuiControl,, %linhaMax%_%idValor%, imagens/embarcacoes/%embarcacaoAtual%%A_Index%.png
        idValor += proximaPosEmbarcacao

        if(Not modoHorizontal)
            linhaMax += campoMaxLinha
    }
    embarcacoesTotais[1][3] -= 1

    if(embarcacoesTotais[1][3]=0){
        embarcacoesTotais.Remove(0)
    }

    ; pega os dados da proxima embarcacao (se a antiga tiver sido removida)
    novaEmbar := embarcacoesTotais[1][1], novaEmbarQuant := embarcacoesTotais[1][3]
    GuiControl,, EmbarcacaoAtualTexto, Inserir %novaEmbar% (%novaEmbarQuant%x)
    
    ; Checa se todas as embarcações foram inseridas
    if(embarcacoesTotais.Length() = 0){ 
        GuiControl,, EmbarcacaoAtualTexto, Todas Embarcacoes Inseridas!
        insercaoFinalizada := true
        gosub AtivarBotaoJogar
    }
}

inserirEmbarcacoesAdversario(campo,quantX,quantY,idInicial){
    global
    totalAreas := % quantX*quantY

    idFinal := idInicial+totalAreas
    ocupados := []

    Loop 10 { ; todas embarcacoes
        embarcacaoAtual := embarcacoesTotaisAdv[1][1]
        embarcacaoAtualEspaco := embarcacoesTotaisAdv[1][2]
    
        loopAcharEmbarcacoes:
        Loop { ; loop ate uma embarcacao for colocada
            Random, horizontal, 0, 1
            Random, embarcacaoPosIni, idInicial, idFinal

            proximaPosEmbarcacao := horizontal ? 1 : campoMaxLinha

            areaID := idListAdv[embarcacaoPosIni-idInicial+1]
            Loop, Parse, areaID, `_
            {
                if(A_Index=1){
                    linhaMax := % A_LoopField
                }
            }

            if(checarOcupado(ocupados, embarcacaoAtualEspaco, embarcacaoPosIni, proximaPosEmbarcacao, idFinal)){
                continue loopAcharEmbarcacoes
            }

            if(embarcacaoPosIni > idFinal){
                continue loopAcharEmbarcacoes
            } else if(horizontal and linhaMax - (embarcacaoPosIni+embarcacaoAtualEspaco-idInicial) < 0){
                continue loopAcharEmbarcacoes
            } else if(Not horizontal and embarcacaoPosIni + (proximaPosEmbarcacao*(embarcacaoAtualEspaco-idInicial)) > totalAreas+idInicial-1){
                continue loopAcharEmbarcacoes
            }

            embarcacoesAdv.Push([])
            embarcacoesAdvClicados.Push([])

            Loop %embarcacaoAtualEspaco% {
                idOcupados = %linhaMax%_%embarcacaoPosIni%
                ;MsgBox, idOcupados %idOcupados%
                embarcacoesAdv[embarcacoesAdv.Length()].Push(idOcupados)
                embarcacoesAdvClicados[embarcacoesAdvClicados.Length()].Push(false)

                ocupados.Push(embarcacaoPosIni)
                oc .= idOcupados . ","
                ;MsgBox, id = %linhaMax%_%embarcacaoPosIni%
                ;GuiControl,, %linhaMax%_%embarcacaoPosIni%, imagens/errouTiro.png

                embarcacaoPosIni += proximaPosEmbarcacao
                if(Not horizontal)
                    linhaMax += campoMaxLinha
            }
            ocupados.Push("`r")
            oc .= "`r"
            
            embarcacoesTotaisAdv[1][3] -= 1

            if(embarcacoesTotaisAdv[1][3]=0){
                embarcacoesTotaisAdv.Remove(0)
            }

            break
        }
    }
    GuiControl,, %z%, imagens/errouTiro.png
}