function [Kp,Ki,ISTSE] = PSO(it,pop,C)
    % Função de Transferência do Processo
    G0 = tf(50,[30 1]);
    % Função de Transferência da Válvula
    Gv = tf(0.75*[.13],[3 1]);
    % Função de Transferência do Sensor
    Gs = tf(.16,[10 1]);
    % Fator de escala do setpoint
    Kr = 0.16;
    
    best = 0;
    n = pop; %Quantidade de particulas
    m = it; %Quantidade de iteracoes
    dimension = 2; %Dimensoes do problema, uma para cada parametro Kp, Ki 
      
    c1 = 1.2;  %Constante do PSO
    c2 = 0.12; %Constante do PSO
    
    wheight = 0.9; %Peso de Momento de Inercia
%     C = [10.71 0.437]; %Z-N
%     C = [2.6618 0.0919]; %SIMIC
    ctype = dimension;
    Lb = 0.5*ones(1,ctype).*C;
    Ub = 2*ones(1,ctype).*C;
    
    position = 0.5*(rand(n, dimension)-.5); %Particulas Iniciais
    velocity = 0.3*randn(n, dimension);     %Velocidades Iniciais
    
    localBestPosition = position;
    currentFitness = zeros(1,n);
    globalBestPosition = zeros(n,dimension);
    
    for i = 1: n
        position(i,:) = Lb+(Ub-Lb).*rand(1,ctype);
        currentFitness(i) = pidFit(position(i,:),G0,Gv,Gs,Kr);
    end
    localBestFitness = currentFitness;
    [globalBestFitness, x] = min(localBestFitness);
    
    for i = 1:n
        globalBestPosition(i,:) = localBestPosition(x,:);
    end
    
    velocity = wheight*velocity + c1*(randn(n, dimension).*(localBestPosition - position)) + c2*(randn(n, dimension).*(globalBestPosition - position));
    
    position = velocity + position;
    
    for i = 1: m
        for k = 1:n
            currentFitness(k) = pidFit(position(k,:),G0,Gv,Gs,Kr);
        end
        
        for k = 1:n
            if currentFitness(k) < localBestFitness(k)
                localBestFitness(k) = currentFitness(k);
                localBestPosition(k,:) = position(k,:);
            end
        end
        
        [currentBestGlobalFitness, x] = min(localBestFitness);
        
        if currentBestGlobalFitness < globalBestFitness
            globalBestFitness = currentBestGlobalFitness;
            
            for k = 1:n
                globalBestPosition(k,:) = localBestPosition(x,:);
            end            
        end
        
        velocity = wheight*velocity + c1*(rand(n, dimension).*(localBestPosition - position)) + c2*(rand(n, dimension).*(globalBestPosition - position));
        position = position + velocity;
        best = x;
        fprintf('IT: %d\n',i);
        fprintf('ISTSE: %f\n',currentBestGlobalFitness);
    end
    
    parameters = position(best,:);
    
    Kp = parameters(1);
    Ki = parameters(2);
    ISTSE = currentBestGlobalFitness;
end