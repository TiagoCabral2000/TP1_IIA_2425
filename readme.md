# <div align="center">Trabalho Prático 1 de Introdução à Inteligência Artificial </div>  

## OBJETIVO DO TRABALHO
Garantir a limpeza completa do ambiente (deixarem de existir representações de lixo no espaço), no menor tempo possível.

## AMBIENTE
LIXO: 
- Definido por células vermelhas. A % de lixo no ambiente é definida pelo utilizador ✅
- Quando o lixo é recolhido pelo aspirador, a patch muda de cor preta para vermelha ❌

CARREGADORES:
- Definidos por células azuis. Nº de aspiradores definido pelo utilizador (entre 0 e 5) ✅

OBSTACULOS:
- Definidos por células brancas. Nº de obstáculos definido pelo utilizador (entre 0 e 100) ✅
- Obstáculos devem ser sempre contornados pelos agentes aspirador (_Ficha2 - Parte 2 - passo h_)❌

DEPOSITO DO LIXO:
- Zona de 4 celulas verdes ✅
- Quando os agentes aspirador tiverem capacidade maxima cheia, devem descarregar la o lixo ❌




## AGENTES
### User Interface
- Nº de agentes definido pelo utilizador ✅
- Energia inicial dos agentes definida pelo utilizador ✅
- Capacidade de carga máxima de lixo dos agentes definida pelo utilizador ✅
- Número de ticks para despejar a totalidade do lixo no depósito ❌
- Número de ticks para carregar o agente ❌

### Funcionalidades
- Agente pode recolher lixo APENAS quando passa em cima dele (_Ficha2 - Parte 2 - passo i_) -> quantidade de elementos de lixo que transporta é incrementada. SE quantidade de lixo que transporta for = à capacidade maxima de transportar lixo, deixa de o poder apanhar. Ao apanhar, mudar a cor da patch de vermelho para preto ❌
- Se houver vários elementos de lixo na vizinhança do agente, este transporta um ao acaso (_Ficha2 - Parte 1 - Ex2 passo a_)❌
- Quando o agente atingir a capacidade máxima de transporte de lixo, procura depósito do lixo. Quando chega ao depósito, deposita a totalidade do lixo (_Ficha3 - Passo 6_). A operação de despejo de lixo deverá demorar um determinado número de iterações, ou ticks (configurável pelo utilizador) ❌
- Por cada célula que o agente se move perde 1 de energia  (_Ficha3 - Passo 4_) ❌
- Quando a energia do agente atingir o valor mínimo de energia definida pelo utilizador, o agente muda de cor e procura carregador, ignorando o lixo. Memoriza a localização do carregador para lá voltar (_Ficha 3 - passo 7_). Demora um determinado número de iterações, ou ticks (configurável pelo utilizador), para carregar totalmente ❌
- Quando dois agentes se encontram na vizinhança podem trocar informação da posição do carregador, caso a tenha ❌
- Se a energia do agente chegar a 0, este morre e pinta a patch de branco ❌


