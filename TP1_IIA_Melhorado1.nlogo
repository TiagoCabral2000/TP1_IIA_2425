breed [aspiradores aspirador]
breed [moveObstaculos moveObstaculo]

globals [depositoLixo depositoObstaculos] ;; Coordenadas do depósito de obstáculos e de lixo


turtles-own[
  memoriaBase
  conheceBase

  conheceDeposito
  memoriaDeposito

  conheceBaseObstaculos
  memoriaBaseObstaculos

  energia
  energiaAspiradorObstaculos
  lixoTransportado
  ticksEspera
  ticksEsperaObstaculos

  movimentos

  ticksReproducao
  reproduzido

  carregandoPatch
  localDepositoObstaculos ;; Novo: Local do depósito de obstáculos
]

to setup
  clear-all
  reset-ticks

  setup-patches
  setup-turtles
end

to setup-patches
  set-patch-size 15


    ;DEFINIR ZONA DO DEPOSITO DO LIXO (laranja)
  let corDepositoLixo one-of patches with [pcolor = black] ;Guardar coordenada de uma celula preta aleatoria
  while [ [pxcor] of corDepositoLixo + 1 > max-pxcor  or  [pycor] of corDepositoLixo + 1 > max-pycor ]
    [
      set corDepositoLixo one-of patches with [pcolor = black]
  ]; Previne que a zona verde possa ficar separada quando patch inicial escolhida for uma borda

  ask corDepositoLixo [
    set pcolor green
    ask patch-at 1 0 [set pcolor green]  ;; celula a direita
    ask patch-at 0 1 [set pcolor green]  ;; celula em acima
    ask patch-at 1 1 [set pcolor green]  ;; celula diagonal direita
  ]

  ;DEFINIR ZONA DO DEPOSITO DE OBSTACULOS (azul)
  let corDepositoObstaculos one-of patches with [pcolor = black] ;Guardar coordenada de uma celula preta aleatoria
  while [ [pxcor] of corDepositoObstaculos + 1 > max-pxcor  or  [pycor] of corDepositoObstaculos + 1 > max-pycor ]
    [
      set corDepositoObstaculos one-of patches with [pcolor = black]
  ]; Previne que a zona azul possa ficar separada quando patch inicial escolhida for uma borda

  ask corDepositoObstaculos [
    set pcolor orange
    ask patch-at 1 0 [set pcolor orange]  ;; celula a direita
    ask patch-at 0 1 [set pcolor orange]  ;; celula em cima
    ask patch-at 1 1 [set pcolor orange]  ;; celula diagonal direita
  ]
  ;; Salvar coordenadas do depósito de obstáculos
  set depositoObstaculos [list pxcor pycor] of corDepositoObstaculos

  ;PREENCHER GRELHA COM LIXO (vermelho)
  let patchesTotal count patches
  let lixoTotal round (patchesTotal * nlixo / 100)

  let contador 0
  while [contador < lixoTotal] [
    ask one-of patches with [pcolor = black] [
      set pcolor red
      set contador contador + 1
    ]
  ]
  ;^

  ;COLOCAR CARREGAMENTO DE ASPIRADORES NA GRELHA (azul)
  set contador 0
  while [contador < ncarregadores] [
    ask one-of patches with [pcolor = black] [
      set pcolor blue
      set contador contador + 1
    ]
  ]
  ;^

  ;COLOCAR OBSTACULOS NA GRELHA (branco)
  set contador 0
  while [contador < nobstaculos] [
    ask one-of patches with [pcolor = black] [
      set pcolor white
      set contador contador + 1
    ]
  ]
  ;^
end
to setup-turtles
  create-aspiradores naspiradores[
    set energia energiaInicial
    set shape "arrow"
    set color grey
    set heading random 360


    set lixoTransportado 0
    set conheceBase false
    set conheceDeposito false

      ; DISTRIBUIÇÃO DOS AGENTES PELOS 4 QUADRANTES:
  if distribuirQuadrantes = true[
    if naspiradores > 4 [
      let total-agentes naspiradores
      let agentes-por-quadrante total-agentes / 4
      let resto total-agentes mod 4

      ; Distribuir agentes por quadrante
      let quadrante 0 ; Iniciar o quadrante em 0

      ; Loop para cada aspirador
      ask aspiradores [
        set quadrante (who mod 4)  ; Obter o quadrante com base no who

        if quadrante = 0 [
          ;; Quadrante 1
          setxy random ((max-pxcor) * -1) random ((max-pycor) * -1)
        ]
        if quadrante = 1 [
          ;; Quadrante 2
          setxy random (max-pxcor) random ((max-pycor) * -1)
        ]
        if quadrante = 2 [
          ;; Quadrante 3
          setxy random (max-pxcor) random (max-pycor)
        ]
        if quadrante = 3 [
          ;; Quadrante 4
          setxy random ((max-pxcor) * -1) random (max-pycor)
        ]
      ]

      ; Distribuir o resto no primeiro quadrante
      repeat resto [
        let random-aspirador one-of aspiradores with [who mod 4 = 0]
        ask random-aspirador [
          setxy ((max-pxcor / 2) * -1) + random (max-pxcor / 2) ((max-pycor / 2) * -1) + random (max-pycor / 2)
        ]
      ]
    ]
  ]


  ]

  ; Criação do obstáculo
  create-moveObstaculos aspiradoresObstaculos [
    set color green
    set shape "circle"
    set carregandoPatch false
    set conheceBaseObstaculos false
    set energiaAspiradorObstaculos energiaInicial
    set heading random 360
    ;; Nascer no depósito de obstáculos
    move-to one-of patches with [pcolor = orange]
    ;; Guardar a localização do depósito
    set localDepositoObstaculos depositoObstaculos
  ]
end



to go
  move-aspiradores
  move-Obstaculos ;; Nova função chamada aqui

  ;; Condição de extinção dos aspiradores
  if count aspiradores = 0 [

    print (word "Extinção! Em " ticks)
    stop
  ]

  ;; Condição de limpeza completa
  if count patches with [pcolor = red] = 0 [
    print (word "Limpeza! Em " ticks)
    stop
  ]

  ;; Condição de tempo esgotado
  if ticks = 10000 [
    print (word "Esgotou o tempo! Em " ticks)
    stop
  ]

  ask aspiradores [if reproducao? [reproduzir]]

  tick
end


to move-Obstaculos
  ask moveObstaculos [
    ;; Verifica se o agente tem energia suficiente para continuar
    if energiaAspiradorObstaculos <= 0 [
      ask patch-here [set pcolor white]
      die
    ]

    ;; Se o agente estiver em espera, reduzir o tempo de espera
    ifelse ticksEsperaObstaculos > 0 [
      set ticksEsperaObstaculos ticksEsperaObstaculos - 1
      if ticksEsperaObstaculos = 0 [set color green]
    ]
    [
      ;; Se a energia estiver baixa, procurar base de recarga
      ifelse energiaAspiradorObstaculos <= energiaMinima [
        procurar-base-obstaculos
      ]
      [
        ;; Se o agente está carregando um obstáculo, ele retorna ao depósito
        ifelse carregandoPatch = true [
          retornar-deposito-laranja
        ] [
          ;; Se não está carregando, procurar por uma patch branca
          procurar-patch-branca
        ]

        ;; Verifica se o agente está em uma borda e muda de direção
        if pxcor = min-pxcor or pxcor = max-pxcor or pycor = min-pycor or pycor = max-pycor [
          ;; Se está na borda, mudar direção ou se mover ao longo da borda
          right random 90 ;; Aleatoriamente virar 90 graus para mudar direção
          fd 1
        ]
      ]
    ]

  ]
end



to move-aspiradores
  ask aspiradores[
    if energia < 0 [ask patch-here[set pcolor white]   die]

    if MemorizarDeposito = false [set conheceDeposito false]
    if MemorizarBase = false [set conheceBase false]


    ifelse ticksEspera > 0[ ; está em espera (a carregar ou a depositar) => decrementa espera:
      set ticksEspera ticksEspera - 1
      if ticksEspera = 0 [set color grey]
    ]

    [ ; não está em espera => avança no processo de verificação:
      if conheceBase = true[
      let baseConhecida memoriaBase
        ask aspiradores-on neighbors4 [ if conheceBase = false [partilhar-base baseConhecida] ]
      ]

      if conheceDeposito = true[
        let depositoConhecido memoriaDeposito
        let partilhou false
        ask aspiradores-on neighbors4 [ if conheceDeposito = false [partilhar-deposito depositoConhecido] ]
      ]

      ifelse conheceBase = true
      [; conhece a base
        modo-inteligente
      ]
      [; não conhece a base
        modo-normal
      ]
    ]
  ]
end

to modo-normal; não conhece a base
  ifelse energia <= energiaMinima
  [procurar-base]; tem de carregar!
  [; tem bateria, logo faz função normal (lixo ou depositar)
    ifelse lixoTransportado >= capTransporte
    [procurar-deposito];deposito cheio => depositar
    [procurar-lixo];procurar lixo
  ]
end

to modo-inteligente; conhece a base
  let energiaRetornar 0
  if retornarInteligente = true[
    set energiaRetornar calcular-energia-retorno + 10; energiaRetorno recebe o valor "reportado" (return) da função do tipo to-reporto calcular-energia
  ]
  if retornarInteligente = false[
    set energiaRetornar energiaMinima
  ]

  ifelse energia <= energiaRetornar
  [retornar-base]; tem de carregar!
  [; tem bateria, logo faz função normal (lixo ou depositar)
    ifelse lixoTransportado >= capTransporte
    [procurar-deposito];deposito cheio => depositar
    [procurar-lixo];procurar lixo
  ]
end

to-report calcular-energia-retorno
  let contador 1  ; Contador que vai acumular o nº de movimentos

  ; Criar um agente invisível (uma nova turtle)
  hatch 1 [
    hide-turtle  ; Para o agente ser invisível

    ; Enquanto o turtle invisivel não estiver na base, olha em direção a ela e, se possível, avança
    while [ [pxcor] of memoriaBase != [pxcor] of patch-here   or   [pycor] of memoriaBase != [pycor] of patch-here ] [
      face memoriaBase

      verifica-obstaculo
      fd 1

      set contador  contador + 1
    ]

    ; Destruir o agente depois do cálculo
    die
  ]

  report contador
end

to extras; auxiliar, para não repetir código: Garante as rotações necessárias para evitar sair do mapa ou ir contra obstáculos.

;NOTA: Este verifica-obstaculo é executado sempre que o robô anda, daí os extras serem aqui inseridos

  ;Extra: se, por acaso, mesmo que não estando com a prioridade de encontrar uma base, tal acontecer, então recorda-a.
  let locBase one-of neighbors4 with [pcolor = blue] ; Verifica se existe Base de Carregamento nas células vizinhas
  if conheceBase = false [ if locBase != nobody [set conheceBase true  set memoriaBase locBase] ]
  ;

  ;Extra: se, por acaso, mesmo que não estando com a prioridade de encontrar um deposito, tal acontecer, então recorda-o.
  let locDeposito one-of neighbors4 with [pcolor = green] ; Verifica se existe um depósito nas células vizinhas
  if conheceDeposito = false [ if locDeposito != nobody [set conheceDeposito true  set memoriaDeposito locDeposito] ]
  ;

  ;Extra: ao fim de x movimentos, vira aleatoriamente
  set movimentos movimentos + 1
  if movimentos >= passosMudarDirecao [set heading random 7 * 45  set movimentos 0] ; Adiciona aleatoriedade ao movimento
                                                                    ;^

  verifica-obstaculo
end

to verifica-obstaculo

  ifelse patch-ahead 1 = nobody
  [rt 180]; Se estiver prestes a ir para uma borda, vira para lado oposto
  [ if [pcolor] of patch-ahead 1 = white [rt 90] ]; Se estiver prestes a ir para um obstáculo, vira



  if patch-ahead 1 = nobody  or  patch-ahead 1 = white
  [evitar-obstrucao]
end

to evitar-obstrucao
  let contador 0
  while [ patch-ahead 1 = nobody  or  [pcolor] of patch-ahead 1 = white ] [
    set contador contador + 1

    ifelse patch-ahead 1 = nobody[rt 180  + random 180]
    [ if [pcolor] of patch-ahead 1 = white [rt random 90 + random 90] ]
    if contador = 2 [set heading random 360  stop]
  ]
end

to verifica-obstaculo-antigo
  ;Extra: ao fim de x movimentos, vira aleatoriamente
  set movimentos movimentos + 1
  if movimentos >= passosMudarDirecao [set heading (heading + random 90) mod 360  set movimentos 0] ; Adiciona aleatoriedade ao movimento
  ;^

  ifelse patch-ahead 1 = nobody
  [rt 180]; Se estiver prestes a ir para uma borda, vira para lado oposto
  [ if [pcolor] of patch-ahead 1 = white [rt 90] ]; Se estiver prestes a ir para um obstáculo, vira

end

to procurar-lixo
  let lixoProximo one-of neighbors4 with [pcolor = red] ; Verifica se existe lixo nas células vizinhas


  ifelse lixoProximo = nobody
  [; Não há lixo próximo => avança, evitando obstáculos e gastando 1 energia
    ifelse MovimentoOtimizado = true[extras][verifica-obstaculo-antigo]
    fd 1

    set energia  energia - 1
  ]

  [; Há lixo próximo -> move-se para ele, limpando (patch fica preta), +1 lixo transportado e -1 energia
    move-to lixoProximo
    set energia  energia - 1
    ask lixoProximo [set pcolor black]
    set lixoTransportado  lixoTransportado + 1
  ]
end



to procurar-deposito
  let locDeposito one-of neighbors4 with [pcolor = green] ; Verifica se existe depósito nas células vizinhas


  ifelse locDeposito = nobody
  [; Não há depósito próximo -> avança
    ifelse MovimentoOtimizado = true[extras][verifica-obstaculo-antigo]
    fd 1
    set energia  energia - 1
  ]

  [; Há depósito perto
    if conheceDeposito = false [set conheceDeposito true  set memoriaDeposito locDeposito]
    move-to locDeposito
    set energia  energia - 1
    set depositoLixo  depositoLixo + lixoTransportado
    set lixoTransportado 0
    set ticksEspera ticksDespejoLixo
  ]
end

to procurar-base; procurar a base aleatoriamente (pq n conhece nenhuma), memorizando a sua localização
  set color yellow
  let locBase one-of neighbors4 with [pcolor = blue] ; Verifica se existe Base de Carregamento nas células vizinhas

  ifelse locBase = nobody
  [; Não há base próxima -> avança
    ifelse MovimentoOtimizado = true[extras][verifica-obstaculo-antigo]
    fd 1
    ;set heading (heading + random 90) mod 360 ; Adiciona aleatoriedade ao movimento
    set energia  energia - 1
  ]

  [; Há base perto
    if conheceBase = false [set conheceBase true  set memoriaBase locBase]
    move-to locBase
    set energia  energia - 1
    set energia 100
    set ticksEspera ticksCarregamento
  ]
end

to retornar-base
  set color yellow

  ; Se o robô não estiver na base, olha em direção a ela e, se possível, avança
  if [pxcor] of memoriaBase != [pxcor] of patch-here   or   [pycor] of memoriaBase != [pycor] of patch-here [
    face memoriaBase

    ifelse MovimentoOtimizado = true[verifica-obstaculo][verifica-obstaculo-antigo]
    fd 1

    set energia  energia - 1
  ]

  ; Se o robô estiver na base, ele carrega a energia e entra em modo de espera
  if [pxcor] of memoriaBase = [pxcor] of patch-here   and   [pycor] of memoriaBase = [pycor] of patch-here [
    set energia 100
    set ticksEspera ticksCarregamento
  ]
end



to reproduzir
  if ticksReproducao <= 0 and random 101 <= 5 ;Probabilidade de tentar reproduzir é de 5%
  [
    if energia > 50
    [
      set energia energia / 2

      if random 101 <= 50 ;probabilidade de 50% do filho nascer
      [
        hatch 1
        [
          setxy random-xcor random-ycor
          set ticksReproducao 200 ;Novo agente também terá que esperar antes de se reproduzir
        ]
      ]

      set ticksReproducao 200 ;O agente atual terá que esperar 200 ticks antes de tentar se reproduzir de novo
    ]
  ]
  set ticksReproducao ticksReproducao - 1
end


to procurar-patch-branca

  let patchBranca one-of patches in-radius 1 with [pcolor = white]

  ifelse patchBranca != nobody [
    move-to patchBranca
    set energiaAspiradorObstaculos energiaAspiradorObstaculos - 1
    set pcolor black ; A patch branca é "carregada" e fica preta
    set carregandoPatch true
  ] [
    fd 1 ;; Caso não encontre uma patch branca próxima, move-se aleatoriamente
    set energiaAspiradorObstaculos energiaAspiradorObstaculos - 1
  ]

end

to retornar-deposito
  ; Se o robô não estiver no deposito, olha em direção a ele e, se possível, avança
  if [pxcor] of memoriaDeposito != [pxcor] of patch-here   or   [pycor] of memoriaDeposito != [pycor] of patch-here [
    face memoriaDeposito

    ifelse MovimentoOtimizado = true[verifica-obstaculo][verifica-obstaculo-antigo]
    fd 1

    set energia  energia - 1
  ]

  ; Se o robô estiver no deposito, ele descarrega o lixo e entra em modo de espera
  if [pxcor] of memoriaDeposito = [pxcor] of patch-here   and   [pycor] of memoriaDeposito = [pycor] of patch-here [
    set depositoLixo  depositoLixo + lixoTransportado
    set lixoTransportado 0
    set ticksEspera ticksDespejoLixo
    set energia  energia - 1
  ]
end

to retornar-deposito-laranja
  ;; Extrair as coordenadas do depósito
  let xDeposito item 0 localDepositoObstaculos
  let yDeposito item 1 localDepositoObstaculos
  let locDepositoObstaculos patch xDeposito yDeposito

  ifelse distance locDepositoObstaculos < 1 [
    move-to locDepositoObstaculos
    set energiaAspiradorObstaculos energiaAspiradorObstaculos - 1
    set pcolor orange ; A patch branca é depositada no depósito
    set carregandoPatch false ; Reinicia o ciclo
  ] [
    face locDepositoObstaculos
    verifica-obstaculo ;tem capacidade de um apenas
    fd 1
    set energiaAspiradorObstaculos energiaAspiradorObstaculos - 1
  ]
end

to procurar-base-obstaculos
  set color green
  let locBaseObstaculos one-of neighbors4 with [pcolor = blue] ; Verifica se existe Base de Carregamento nas células vizinhas

  ifelse locBaseObstaculos = nobody [
    ; Não há base próxima -> avança
    ifelse MovimentoOtimizado = true[verifica-obstaculo][verifica-obstaculo-antigo]
    fd 1
    set energiaAspiradorObstaculos energiaAspiradorObstaculos - 1
  ] [
    ; Há base perto -> move-se para ela e carrega energia
    if conheceBaseObstaculos = false [set conheceBaseObstaculos true  set memoriaBaseObstaculos locBaseObstaculos]
    move-to locBaseObstaculos
    set color pink
    set energiaAspiradorObstaculos 100 ; Carrega a energia completamente
    set ticksEsperaObstaculos ticksCarregamento ; Entra em modo de espera durante o carregamento
  ]
end

to partilhar-base [novaBase]
  set conheceBase true
  set memoriaBase novaBase
end

to partilhar-deposito [novoDeposito]
  set conheceDeposito true
  set memoriaDeposito novoDeposito
end
@#$#@#$#@
GRAPHICS-WINDOW
430
10
933
514
-1
-1
15.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
260
345
324
378
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
329
345
392
378
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
2
36
158
69
naspiradores
naspiradores
0
100
43.0
1
1
NIL
HORIZONTAL

MONITOR
6
292
84
337
aspiradores
count aspiradores
17
1
11

PLOT
6
386
425
514
Agentes
iterações
n. de agentes
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"aspiradores" 1.0 0 -11053225 true "" "plot count aspiradores"

MONITOR
86
292
167
337
obstaculos
count patches with [pcolor = white]
17
1
11

MONITOR
6
338
218
383
depositoLixo
depositoLixo
17
1
11

SLIDER
3
216
175
249
nobstaculos
nobstaculos
0
100
45.0
1
1
NIL
HORIZONTAL

SLIDER
2
251
174
284
ncarregadores
ncarregadores
0
5
5.0
1
1
NIL
HORIZONTAL

MONITOR
169
293
256
338
carregadores
count patches with [pcolor = blue]
17
1
11

SLIDER
5
182
177
215
nlixo
nlixo
0
60
34.0
1
1
%
HORIZONTAL

SLIDER
3
72
175
105
capTransporte
capTransporte
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
3
107
175
140
energiaInicial
energiaInicial
0
100
100.0
1
1
%
HORIZONTAL

SLIDER
3
143
175
176
energiaMinima
energiaMinima
0
100
67.0
1
1
%
HORIZONTAL

SLIDER
209
36
381
69
ticksDespejoLixo
ticksDespejoLixo
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
209
75
381
108
ticksCarregamento
ticksCarregamento
0
100
50.0
1
1
NIL
HORIZONTAL

SWITCH
937
92
1062
125
reproducao?
reproducao?
1
1
-1000

SLIDER
1090
135
1262
168
aspiradoresObstaculos
aspiradoresObstaculos
0
20
0.0
1
1
NIL
HORIZONTAL

SWITCH
937
280
1089
313
retornarInteligente
retornarInteligente
1
1
-1000

SWITCH
939
50
1100
83
distribuirQuadrantes
distribuirQuadrantes
0
1
-1000

SWITCH
178
145
312
178
MemorizarBase
MemorizarBase
0
1
-1000

SWITCH
936
231
1091
264
MemorizarDeposito
MemorizarDeposito
1
1
-1000

SWITCH
938
134
1081
167
MoverObstaculos
MoverObstaculos
1
1
-1000

SLIDER
1110
184
1306
217
passosMudarDirecao
passosMudarDirecao
0
100
10.0
1
1
passos
HORIZONTAL

SWITCH
937
184
1100
217
MovimentoOtimizado
MovimentoOtimizado
1
1
-1000

TEXTBOX
63
10
353
60
Configurações Modelo Base
20
0.0
1

TEXTBOX
945
10
1290
41
Configurações Modelo Melhorado
20
0.0
1

TEXTBOX
1238
33
1388
85
No modelo base:\nTudo off\naspiradoresObstaculos = 0\npassosMudarDirecao = 10
10
0.0
1

@#$#@#$#@
## WHAT IS IT?

This section could give a general understanding of what the model is trying to show or explain.

## HOW IT WORKS

This section could explain what rules the agents use to create the overall behavior of the model.

## HOW TO USE IT

This section could explain how to use the model, including a description of each of the items in the interface tab.

## THINGS TO NOTICE

This section could give some ideas of things for the user to notice while running the model.

## THINGS TO TRY

This section could give some ideas of things for the user to try to do (move sliders, switches, etc.) with the model.

## EXTENDING THE MODEL

This section could give some ideas of things to add or change in the procedures tab to make the model more complicated, detailed, accurate, etc.

## NETLOGO FEATURES

This section could point out any especially interesting or unusual features of NetLogo that the model makes use of, particularly in the Procedures tab.  It might also point out places where workarounds were needed because of missing features.

## RELATED MODELS

This section could give the names of models in the NetLogo Models Library or elsewhere which are of related interest.

## CREDITS AND REFERENCES

This section could contain a reference to the model's URL on the web if it has one, as well as any other necessary credits or references.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
0
Rectangle -7500403 true true 151 225 180 285
Rectangle -7500403 true true 47 225 75 285
Rectangle -7500403 true true 15 75 210 225
Circle -7500403 true true 135 75 150
Circle -16777216 true false 165 76 116

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="10" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <metric>count turtles</metric>
    <enumeratedValueSet variable="energiaMinima">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticksDespejoLixo">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="reproducao?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nlixo">
      <value value="60"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticksCarregamento">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="energiaInicial">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nobstaculos">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="aspiradoresObstaculos">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ncarregadores">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capTransporte">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="naspiradores">
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
