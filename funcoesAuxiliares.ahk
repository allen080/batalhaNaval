#SingleInstance, Force

messageBox(msg,timeout=5){
    MsgBox,, Batalha Naval, %msg%, %timeout%
}

/* Funcões de Strings
*/
concat(str1,str2,delim="_"){
    ; une duas strings por um delimitador
    return str1 . delim . str2
}
cat(str1,str2,delim="_"){
    ; alías da funcao concat
    return concat(str1,str2,delim)
}
strToInt(str){
    ; converte uma string pra inteiro
    num := str,num += 0
    return num
}
splitStr(str,delim="_"){
    ; separa uma string em array de strings
    strVet := []
    Loop, Parse, str, % `delim
        strVet.Push(A_LoopField)
    return strVet
}

/* Funcões de Arrays
*/
inArray(vet, valor){
    ; Checar se um valor esta presente em um array
    for k,i in vet {
        if(i=valor)
            return true
    }
    return false
}
isArray(obj) {
    ; Verifica se um objeto é um array
	return !!obj.MaxIndex()
}
indexOfArray(vet,valor){
    for index,val in vet {
        if(valor=val)
            return index
    }
    return -1
}

getArrayMin(vet){
    ; pega o menor valor de um array
    menor := vet[1]
    For index,elem in vet {
        if(elem in Number and elem<menor)
            menor := elem
    }
    return menor
}

getBiggests(vet,quant){
    ; pega os n maiores indexes de valores de um array
    biggest := []

    Loop %quant% {
        menor := getArrayMin(vet)
        menorIndex := indexOfArray(vet,menor)

        biggest.Push(menorIndex)
        vet.Remove(menorIndex)
    }
    return biggest
}

randomFromArray(vet){
    Random, index, 1, % vet.Length()
    return vet[index]
}

isSubArray(subarray,array){
    ; checa se um subarray esta contido dentro de um array
    For index,elem in subarray {
        if(Not inArray(array,elem))
            return false
    }
    return true
}

inMatriz(matriz,valor){
    ; checa se um valor esta contido em uma matriz
    size := matriz.Length()
    Loop %size% {
        linha := matriz[A_Index]
        if(inArray(linha,valor))
            return true
    }
    return false
}

afundouEmbarcacao(embarcacaoList, atiradas){
    ; checa com uma lista de tiros do jogador se uma embarcacao foi atingida
    size := embarcacaoList.Length()
    Loop %size% {
        embarcacao := embarcacaoList[A_Index]
        if(isSubArray(embarcacao,atiradas))
            return embarcacao ; embarcacao atingida
    }
    return []
}

timerToolTip(msg,timer=3){
    ; ToolTip com timer de duração (em segundos)
    #Persistent
    timer *= 1000
    timer *= -1

    ToolTip, %msg%
    SetTimer, TTEnd, %timer%  

    goto EndFunc
    TTEnd:
        ToolTip
        Return
    EndFunc:
}

getCurrentTime(){
    ; pega a hora e data atual formatados
    FormatTime, currentTime, dd-mm-yyyy
    return currentTime
}

checarOcupado(vet, totalPos, posIni, proximaPos, areaFinal){
    ; Checar se uma area já foi selecionada
    Loop %totalPos% {
        if(inArray(vet, posIni) Or posIni>areaFinal){
            return true
        }
        posIni += proximaPos
    }
    return false
}

checarVetTrue(vet){
    ; checa se todos os elementos de um vetor sao true
    For index,valor in vet {
        if(!valor)
            return false
    }
    return true
}

printMatriz(matriz){
    matrizStr := ""
    For i,vet in matriz {
        For j,elem in vet {
            matrizStr .= elem . ","
        }
        matrizStr .= "`r`r"
    }
    MsgBox, % matrizStr
}

matrizIndexOf(matriz,achar){
    elemIndexes := false

    outLoop:
    For linha,vet in matriz {
        For coluna,elem in vet {
            if(achar=elem){
                elemIndexes := [linha,coluna]
                break outLoop
            }
        }
    }
    return elemIndexes
}

shuffleArray(vet){
    ; Randomiza os elementos de um array
    randomVet := []
    size := vet.Length()

    Loop %size% {
        Random, randomIndex, 1, size--
        randomElem := vet[randomIndex]
        
        randomVet.Push(randomElem)
        vet.Remove(randomIndex)
    }
    return randomVet
}

checarMatrizTrue(matriz){
    ; checa se uma linha inteira de uma matriz de booleans é true e retorna o index dela
    For linha,vet in matriz {
        if(isArray(vet) And checarVetTrue(vet)){
            return linha
        }
    }
    return false
}



sliceArray(vet,ini,fim){
    ; divide um array em um subArray
    sliced := []
    For index,elem in vet {
        if(index>=ini and index<=fim){
            sliced.Push(elem)
            
        }
    }
    return sliced
}

separarID(areaID,pos){
    Loop, Parse, areaID, `_
    {
        if(A_LoopField=pos)
            return strToInt(A_LoopField)
    } 
}



idValidosFilter(idListChecar,idList){
    ; filtra uma lista de ids retornando os válidos
    global
    validos := []
    For index,val in idListChecar {
        if(inArray(idList,val))
            validos.push(val)
    }
    return validos
}

getPosRedor(areaID,maxL,idList){
    areaIDInfo := splitStr(areaID)
    linha := areaIDInfo[1], id := areaIDInfo[2]
    
    aoRedor :=  [cat(linha-maxL,id-maxL-1), cat(linha-maxL,id-maxL), cat(linha-maxL,id-maxL+1)
                ,cat(linha,id-1), cat(linha,id), cat(linha,id+1)
                ,cat(linha+maxL,id+maxL-1), cat(linha+maxL,id+maxL), cat(linha+maxL,id+maxL+1)]

    ; return aoRedor    
    return idValidosFilter(aoRedor,idList) ; filtra os idValidos
}

get4EmVolta(areaID,maxL,idList){
    areaIDInfo := splitStr(areaID)
    linha := areaIDInfo[1], id := areaIDInfo[2]

    redor4 := [cat(linha-maxL,id-maxL),cat(linha+maxL,id+maxL),cat(linha,id-1),cat(linha,id+1)]
    return idValidosFilter(redor4,idList)
}

writeFile(filename,content){
    file := FileOpen(filename,"w")
    file.Write(content . "`r")
    file.Close()
}

join(strArray){
  s := ""
  for i,v in strArray
    s .= ", " . v
  return substr(s, 3)
}

printVet(vet){
    MsgBox, % join(vet)
}
/*getPosRedor(areaID){
    areaIDInfo := splitStr(areaID)
    idValor := areaID[1], idLinhaMax := areaID[2]

    aoRedor := []
    For index,maxLinha in [maxLinha,maxLinha+proxLinha,maxLinha-proxLinha] {
        aoRedor.push(concat(maxLinha,idValor))
        aoRedor.push(concat(maxLinha,idValor-1))
        aoRedor.push(concat(maxLinha,idValor+1))
    }
}
*/