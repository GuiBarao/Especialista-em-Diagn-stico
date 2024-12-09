:- dynamic sintoma_usuario/1.
:- discontiguous sintoma/2.
:- discontiguous sintoma_unico/2.

%Sintomas Covid.
sintoma(covid, febre).
sintoma(covid, tosse).
sintoma_unico(covid, dispneia).
sintoma(covid, mialgia).
sintoma(covid, fadiga).
sintoma_unico(covid, anosmia).
sintoma_unico(covid, ageusia).
sintoma(covid, diarreia).
sintoma(covid, vomitos).

%Sintomas Dengue.
sintoma(dengue, febre).
sintoma(dengue, mialgia).
sintoma(dengue, dorOcular).
sintoma_unico(dengue, malEstar).
sintoma_unico(dengue, faltaApetite).
sintoma(dengue, dorDeCabeca).
sintoma_unico(dengue, manchasVermelhas).

%Sintomas influenza.
sintoma(influenza, febre).
sintoma(influenza, mialgia).
sintoma(influenza, dorDeCabeca).
sintoma(influenza, tosse).
sintoma(influenza, fadiga).
sintoma(influenza, diarreia).
sintoma(influenza, vomitos).
sintoma_unico(influenza, dorDeGarganta).
sintoma_unico(influenza, congestaoNasal).
sintoma(influenza, dorOcular).
sintoma_unico(influenza, sensibilidadeLuz).
sintoma_unico(influenza, fraqueza).

/*Realiza a pergunta ao usuário, captura a resposta. 
Se a resposta dor 's' ou 'sim', então o sistema registra o sintoma do usuário.
Se for qualquer outra coisa o sistema ignora o sintoma.*/
pergunta(Sintoma, Texto) :- 
                        format('~w', [Texto]),
                        read(Resposta),
                        ((Resposta = s ; Resposta = sim) -> assert(sintoma_usuario(Sintoma)) ; true),
                        nl, nl.


%Devolve em Quant a quantidade de elementos que representam um percentual de uma lista.
percentual(Lista, Porcentagem, Quant) :- length(Lista, Tam), Quant is floor(Tam * (Porcentagem / 100)).


%Faz a contagem de quantos elementos da Lista1 tem na Lista2.
quant_membros([], _, 0).
quant_membros([Head | Tail], Lista2, Cont) :-   quant_membros(Tail, Lista2, ContTail), 
                                                (member(Head, Lista2) -> Cont is ContTail + 1 ; Cont = ContTail).

%Se o usuário possui 70% dos sintomas, o sistema considera a doença como uma possível diagnóstico.

diagnostico(Lista, covid) :-    lista_sintomas(covid, Stm_Covid), %Stm_Covid recebe os sintomas de Covid.
                                percentual(Stm_Covid, 70, Min_sintomas), %Min_sintomas representa a quantidade minima de sintomas para a doença ser considerada.
                                quant_membros(Lista, Stm_Covid, Nsintomas), %Calcula a quantidade de sintomas do usuários que também são sintomas de covid.
                                Nsintomas >= Min_sintomas.


diagnostico(Lista, dengue) :-   lista_sintomas(dengue, Stm_Dengue),
                                percentual(Stm_Dengue, 70, Min_sintomas),
                                quant_membros(Lista, Stm_Dengue, Nsintomas),
                                Nsintomas >= Min_sintomas.


diagnostico(Lista, influenza) :-        lista_sintomas(influenza, Stm_Influenza),
                                        percentual(Stm_Influenza, 70, Min_sintomas),
                                        quant_membros(Lista, Stm_Influenza, Nsintomas),
                                        Nsintomas >= Min_sintomas.


/*Lista todos o sintomas de uma doenca.*/
lista_sintomas(Doenca, Sintomas) :-     findall(S, sintoma(Doenca, S), Sintomas_compartilhados),
                                        findall(S, sintoma_unico(Doenca, S), Sintomas_unicos),
                                        append(Sintomas_compartilhados, Sintomas_unicos, Sintomas).


/*Analisa a lista de sintomas do usuário e compara com a lista de sintomas únicos das doenças diagnosticadas, criando uma pontuação
pra cada doença.*/

maior_probabilidade(_, [], none, 0).

/* Parâmetros:
Sintomas do usuario, Lista de diagnosticos, Doenca com maior probabilidade, Quantidade de elementos em comum 
que existem entre a doença de maior probabilidade e a lista de diagnósticos.*/
maior_probabilidade(Lista, [Head | Tail], Doenca, Quant_Membros) :-     /*Pega a doença calculada na Tail e sua quantidade de elementos em comum com os sintomas do usuário.*/
                                                                        maior_probabilidade(Lista, Tail, Doenca_Tail, Quant_Tail), 
                                                                        
                                                                        /*Captura todos os sintomas unicos da doença atual.*/
                                                                        findall(S, sintoma_unico(Head, S), Unicos),

                                                                        /*Compara a lista de sintomas do usuário e a lista de sintomas unicos e calcula a quantidade de sintomas iguais.*/
                                                                        quant_membros(Lista, Unicos, Quant_Head),

                                                                        /*Doenca recebe a doenca com a maior quantidade de sintomas unicos iguais aos sintomas do usuário.*/
                                                                        (Quant_Head > Quant_Tail     -> Doenca = Head, Quant_Membros = Quant_Head 
                                                                                                        ; Doenca = Doenca_Tail, Quant_Membros = Quant_Tail).



 /*Com findall o sistema lista todas as possibilidades de diagnostico.
 Se a lista de possibilidades estiver vazia, então nenhum diagnóstico foi feito.
 Se estiver com tamanho 1, então a Doença mais provavel ja foi encontrada.
 Se mais de um diagnóstico foi feito o sistema calcula e retorna a doença mais provável.*/
diagnosticar(Lista) :- findall(Doenca, diagnostico(Lista, Doenca), Diagnosticos),
                        (Diagnosticos == [] 
                                        -> write('Não foi possivel diagnosticar a doenca apenas com a informacao obtida.') 
                                        ; (length(Diagnosticos, 1) 
                                                                -> format('Doenca mais provavel: ~w', Diagnosticos)
                                                                ;  maior_probabilidade(Lista, Diagnosticos, Doenca, _), 
                                                                        format('Doenca mais provavel: [~w]', Doenca) )).

inicio :-
        write('=== Sistema especialista em diagnosticos (Covid-19, Influenza e Dengue) ==='), 
        nl , nl,

        write('--- Analise de sintomas: Digite (s/sim) caso tenha o sintoma. ---'), nl,

        pergunta(febre,  'Febre? -> '),
        pergunta(tosse,  'Tosse? -> '),
        pergunta(dispneia,  'Falta de ar? -> '),
        pergunta(mialgia,  'Dor muscular? -> '),
        pergunta(fadiga, 'Fadiga? -> '),
        pergunta(anosmia,  'Perda do olfato? -> '),
        pergunta(ageusia,  'Perda do paladar? -> '),
        pergunta(diarreia, 'Diarreia? -> '),
        pergunta(vomitos,  'Vomitos? -> '),
        pergunta(dorOcular, 'Dor ao movimentar os olhos? -> '),
        pergunta(malEstar,  'Mal estar? -> '),
        pergunta(faltaApetite,  'Falta de apetite? -> '),
        pergunta(dorDeCabeca,  'Dor de cabeca? -> '),
        pergunta(manchasVermelhas, 'Manchas vermelhas pelo corpo? -> '),
        pergunta(dorDeGarganta,  'Dor de garganta? -> '),
        pergunta(congestaoNasal, 'Congestao nasal? -> '),
        pergunta(sensibilidadeLuz,  'Sensibilidade a luz? -> '),
        pergunta(fraqueza, 'Fraqueza? -> '),

        /*Lista de sintomas registrados pelo usuário.*/
        findall(Sintoma, sintoma_usuario(Sintoma), Lista),

        /*Realiza o diagnostico.*/
        diagnosticar(Lista).
