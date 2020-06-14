% Author: Nielsen Castelo Damasceno
% Date: 31/05/2015
% Simple example of genetic algorithm to find the function maximum
%


function [] = ag_tuning()
% Função de Transferência do Processo
G0 = tf(50,[30 1]);
% Função de Transferência da Válvula
Gv = tf(0.75*[.13],[3 1]);
% Função de Transferência do Sensor
Gs = tf(.16,[10 1]);
% Fator de escala do setpoint
Kr = 0.16;
% Parametros do Controlador PI [Kp Ki] a Otimizar
C = [2.6618 0.0919]; % Estes valores iniciais são estimados utilizando-se
% os métodos sintonia de Ziegler-Nichols ou SIMC.
% Neste exemplo são utilizados os parametros
% inicialmente sintonizados pelo metodo SIMC.

% Instância do controlador PI sem otimização
C_I = pid(C(1),C(2));
% O gráfico do controlador PI sem otimização é plotado
step(Kr * feedback(C_I * G0 * Gv,Gs), '--k');
grid on
hold on

% Declaration of Variables
tampop = 50;                          % Population size
gene   = 2;
populacao       = abs(randn(tampop,gene)); % initial population
novapopulacao   = zeros(tampop,gene);
melhorpopulacao = zeros(tampop,gene);
fav  = zeros(tampop,1);              % Vector of adaptability functions

prec = 0.8;                          % recombination percentage of 80% of the population
pmut = 0.01;                         % mutation percentage of 1% of the population
cromossomo_aux = zeros(1,gene);      % For exchange of parts of chromosome at the crossover
novosindividuo = zeros(tampop*0.2,gene);
melhor_cromossomo = zeros(1,gene);   % To save and better individual (elitism)
no_geracoes = 10;                   %Inform the number of generations
melhoradp_ant = 0;
estagnacao  = 0;
melhores    = zeros(no_geracoes,1);
epoca       = 1;

while(1)
    % Stop condition is the number of generations
    if (epoca > no_geracoes)
        break;
    end
           
    % Calculation of function adaptability
    % evaluation component of the chromosome
    for i = 1 : tampop
        p = populacao(i,:);
        fav(i) = Fun(p,G0,Gv,Gs,Kr);
    end
    
    % Selects the worst individual of current population
    [pioradp, piorindividuo] = max(fav);

    % Saves the best individual
    if (epoca ~= 1)
        melhoradp_ant = melhoradp;
    end
    
    % Select the best individual of the current population
    [melhoradp, melhorindividuo] = min(fav);
    % It Saves the each time (generation) what was the best individual
    melhores(epoca)   = melhoradp;
    % and which the chromosome associated with it
    melhor_cromossomo = populacao(melhorindividuo,:);
    
    % If the best individuals begin to appear (again) in the generations 
    % future, then there was a stagnation of population
%     if (melhoradp == melhoradp_ant)
%         estagnacao = estagnacao + 1;
%     end

    % Condition of stop to the criterion of stagnation of the population
%     if(estagnacao > 5)
%        break;
%     end
    
    % Sum of all evaluation functions
    % used to calculate the adequacy
    somafav = sum(fav);
    % Vector of adequacy
    adr = zeros(tampop,1);                            

    % Calculation of adequacy relative
    % the sum of adequabilidades is equal to 1
    for i=1:tampop
        adr(i) = fav(i)/somafav;                    
    end
    % To select at random individuals should appear in the next generation
    % it uses the method of roulette
    % anomaru described in the article on AG's
    roleta=zeros(tampop,1);
    roleta(1) = adr(1);
    for i= 2:tampop
        roleta(i) = roleta(i-1)+adr(i);
    end

    % Começando a selecionar os individuos da proxima populacao
    % Operator Selecao - Method Roulette
    % The probability of being "randomly selected" are those with higher
    % adequacy relative
    selecionado = zeros(tampop,1);
    for r=1:tampop
        bola    = rand(1);
        posicao = 1;
        flag    = 0;
        while(1)
            if (bola <= roleta(posicao))
                selecionado(r) = posicao;
                flag = 1;
            end
            posicao = posicao + 1;
            if (flag == 1) 
                break;
            end
        end
    end
       
    qtselecionado  = 0;
    cjselecionado  = [];
    
    % Apply elitism in population
    % Generating new populations 
    % They will be discarded at this stage individuals who were not "selected" any time in roulette 
    cjselecionado = hist(selecionado,tampop);  % In each vector position the number of times the element was selected
    indice = 1;
    for i = 1:tampop
        if (cjselecionado(i) ~= 0)
            nobt = cjselecionado(i);           % Number of copies obtained
            for c = 1:nobt
                novapopulacao(indice,:) = populacao(selecionado(i),:); % Element of the new population eh equal to the selected element of the earlier
                indice = indice + 1;                                   % population
            end
        end
    end

    % Application operator recombination (crossover) in rushes (probability of recombination) of the population
    % Number of times in which the crossover operator will be applied (80% of the population)
    vezes = 0.8 * tampop;                                 
    cromossomo_aux = zeros(1,gene);
    qtd_trocas     = 0;
    for r=1:vezes        % performed on a portion of the population
        prob = rand*1;   % to test whether this probability to recombine within the
        if (prob <= prec)
            qtd_trocas = qtd_trocas + 1;
            % Select the cutoff point (lower and upper limits of the court in chromosome)
            corte1 = ceil((rand*gene - 1)+1);
            corte2 = ceil((rand*gene - 1)+1);
            if (corte1 > corte2)
                aux = corte1;
                corte1 = corte2;
                corte2 = aux;
            end
            % Choice of individuals to undergo recombination (crossover)
            individuo1 = ceil((rand*tampop-1)+1);
            individuo2 = ceil((rand*tampop-1)+1);
            % Genetic material exchange (crossover) between individuals,
            % replacing the cutting region by the average value of the genes of each individual
            % Rather than simply changing the genes of each chromosome,
            % Changed to an average of the values of the two chromosomes
            cromossomo_aux  =  (novapopulacao(individuo1,corte1:corte2)+novapopulacao(individuo2,corte1:corte2))/2;
            novapopulacao(individuo1,corte1:corte2)   = cromossomo_aux;
            novapopulacao(individuo2,corte1:corte2)   = cromossomo_aux;
        end
    end
    
    % Operator Mutation
    % Ensures that all genetic material is represented in future generations,
    % ie that no allele disappear forever from populationo
    prob = rand*1;
    if (prob <= pmut)
        for i= 1:pmut*tampop*gene
            l = ceil(rand*tampop-1)+1;
            c = ceil(rand*gene - 1)+1;
            novapopulacao(l,c) = rand(1); 
            % Would only that enough? or should you use a multiplier?
        end
    end
    
    % Updates the population before starting the new iteration
    populacao = novapopulacao;                  
    epoca     = epoca + 1;
    disp(epoca);
    %save;
end
       
[melhoradp, melhorindividuo]= min(fav);
fprintf('The function maximum is %f\n', melhoradp);

function z = Fun(C,G0,Gv,Gs,Kr)
    P = pid(C(1),C(2));
    [y,t] = step(Kr * feedback(P*G0*Gv,Gs));
    dt = (t(2)-t(1))/2;
    % Estende o tempo de simulação, para garantir a convergência ao degrau
    % ao final do período
    t = 0:dt:t(end)*2;
    e = 1-Kr * step(feedback(P*G0*Gv,Gs),t);
    z = sum(((t.'.^2).*(e.^2)*dt));
end
end