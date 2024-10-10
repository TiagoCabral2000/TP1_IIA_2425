# <div align="center">Trabalho Prático 1 de Introdução à Inteligência Artificial </div>  

## OBJETIVO DO TRABALHO
Garantir a limpeza completa do ambiente (deixarem de existir representações de lixo no espaço), no menor tempo possível.

## AMBIENTE
LIXO: 
- Definido por células vermelhas. A % de lixo no ambiente é definida pelo utilizador ✅
- Quando o lixo é recolhido pelo aspirador, a patch muda de cor preta para vermelha ✅

CARREGADORES:
- Definidos por células azuis. Nº de aspiradores definido pelo utilizador (entre 0 e 5) ✅

OBSTACULOS:
- Definidos por células brancas. Nº de obstáculos definido pelo utilizador (entre 0 e 100) ✅
- Obstáculos devem ser sempre contornados pelos agentes aspirador (_Ficha2 - Parte 2 - passo h_) ✅

DEPOSITO DO LIXO:
- Zona de 4 celulas verdes ✅
- Quando os agentes aspirador tiverem capacidade maxima cheia, devem descarregar la o lixo ❌




## AGENTES
### User Interface
- Nº de agentes definido pelo utilizador ✅
- Energia inicial dos agentes definida pelo utilizador ✅
- Capacidade de carga máxima de lixo dos agentes definida pelo utilizador ✅
- Número de ticks para despejar a totalidade do lixo no depósito ✅
- Número de ticks para carregar o agente ❌

### Funcionalidades
- Agente pode recolher lixo APENAS quando passa em cima dele -> quantidade de elementos de lixo que transporta é incrementada. SE quantidade de lixo que transporta for = à capacidade maxima de transportar lixo, deixa de o poder apanhar. Ao apanhar, mudar a cor da patch de vermelho para preto ✅
- Se houver vários elementos de lixo na vizinhança do agente, este transporta um ao acaso (_Ficha2 - Parte 1 - Ex2 passo a_) ✅
- Quando o agente atingir a capacidade máxima de transporte de lixo, procura depósito do lixo. Quando chega ao depósito, deposita a totalidade do lixo (_Ficha3 - Passo 6_). A operação de despejo de lixo deverá demorar um determinado número de iterações, ou ticks (configurável pelo utilizador) ✅
- Por cada célula que o agente se move perde 1 de energia  (_Ficha3 - Passo 4_) ✅
- Quando a energia do agente atingir o valor mínimo de energia definida pelo utilizador, o agente muda de cor e procura carregador, ignorando o lixo. Memoriza a localização do carregador para lá voltar (_Ficha 3 - passo 7_). Demora um determinado número de iterações, ou ticks (configurável pelo utilizador), para carregar totalmente ❌
- Quando dois agentes se encontram na vizinhança podem trocar informação da posição do carregador, caso a tenha ❌
- Se a energia do agente chegar a 0, este morre e pinta a patch de branco ❌
- Agente não pode sair dos limites do ambiente ❌


### NOTAS
Neste momento, os aspiradores movem-se aleatoriamente pelo espaço, já evitam os obstáculos e também apanham o lixo aleatoriamente da vizinhanca</br>
Quando atinguem a sua capacidade maxima, já procuram o depósito (apesar de demorarem bué às vezes xD) e despejam o lixo. O tempo deste processo tb ja esta de acordo com o enunciado - tempo definido pelo utilizador</br>
Por cada movimento, os agentes ja perdem 1 de energia, mas ainda nada esta implementado nesse sentido. Falta fazer 'die' para quando a energia chega a 0 e todo o processo de carregamento (incluindo memória da localização do carregador - penso que a questao de procurar o carregador e ficar lá um determinado tempo a carregar é igual ao procurar o depósito do lixo)

### PROBLEMAS IDENTIFICADOS
Os agentes saem do ambiente de jogo e voltam a spawnar do outro lado. Pedi ajuda ao chatgpt, deu-me uma solução mas continuava a dar mal, não percebe nada de netlogo o.O

## OPÇÕES PARA O MODELO MELHORADO
- Reprodução de aspiradores (Ficha 3 - Passo 9) -> (_Sugerido no enunciado_)
- Definição de uma estratégia de limpeza (com aspiradores a serem posicio-nados em posições específicas e a operarem de forma idêntica – uma espécie de mimetismo controlado) -> (_Sugerido no enunciado_)
- Melhorar o agente aspirador, de forma que monitorize o nível de energia, regressando à base mais próxima (memorizada), assim que deteta que ape-nas tem energia para efetuar o trajeto de regresso -> (_Sugerido no enunciado_)
- Introdução de falhas na perceção dos aspiradores (aparecimento de um gato – o inimigo – que viaja sobre o aspirador e tapa alguns dos seus sensores -> (_Sugerido no enunciado_)
- Destrutor de obstáculos (ia melhorar o tempo para aspirar tudo)
- Boosters de energia (em vez de perder tempo a carregar, sempre que um aspirador passasse numa célula com este booster era carregado imediatamente)
- Teletransporte para o deposito do lixo após saber a sua localização




