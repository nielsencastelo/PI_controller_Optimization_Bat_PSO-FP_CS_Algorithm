function [Kp,Ki,ISTSE] = BA(it,pop,C)
    % -------------- IN�CIO DO C�DIGO --------------

    % ======================================================= %
    % Os par�metros internos do Bat Algorithm encontram-se    %
    % definidos nesta se��o, esses podem ser modificados para %
    % garantir o melhor desempenho.                           %
    % ======================================================= %
    % Popula��o inicial de morcegos
    n = pop;
    % N�mero de gera��es
    N_gen = it;
    % Valores iniciais de amplitude(A) e Frequencia(r)
    A = 0.5;
    r = 0.5;

    % Esta � a faixa de frequ�ncia, ela determina as escalas
    % Os valores podem ser alterados conforme necess�rio
    Qmin = 0;         % Frequ�ncia m�nima
    Qmax = 2;         % Frequ�ncia m�xima
    % ======================================================= %
    % Fim dos parametros internos do Bat Algorithm            %
    % ======================================================= %

    % ======================================================= %
    % Os par�metros do sistema de controle do trocador de     %
    % calor encontram-se definidos nesta se��o, para maiores  %
    % informa��es consultar (De Paula; Damasceno, 2014).      %
    % ======================================================= %
    % Fun��o de Transfer�ncia do Processo
    G0 = tf(50,[30 1]);
    % Fun��o de Transfer�ncia da V�lvula
    Gv = tf(0.75*[.13],[3 1]);
    % Fun��o de Transfer�ncia do Sensor
    Gs = tf(.16,[10 1]);
    % Fator de escala do setpoint
    Kr = 0.16;
    % ======================================================= %
    % Fim dos parametros do sistema de controle               %
    % ======================================================= %
    
    % ======================================================= %
    % In�cio das itera��es do Bat Algorithm                   %
    % ======================================================= %
    % Dimens�es do problema de otimiza��o
%     C = [2.6618 0.0919]; % Estes valores iniciais s�o estimados utilizando-se
%     C = [10.71 0.437]; %Z-N
    % os m�todos sintonia de Ziegler-Nichols ou SIMC.
    % Neste exemplo s�o utilizados os parametros
    % inicialmente sintonizados pelo metodo SIMC.
    ctype = length(C);
    dim = ctype;         % Controlador proporcional+integral, dim=2
    % Limite M�nimo de Busca
    Lb = 0.5*ones(1,dim).*C;
    % Limite M�ximo de Busca
    Ub = 2*ones(1,dim).*C;
    % Inicializando vetores
    Q = zeros(n,1);   % Frequencia
    v = zeros(n,dim); % Velocidade
    Fitness = zeros(1,n);
    Sol = zeros(n,dim);
    % Inicializando a popula��o de morcegos
    for i = 1:n
        Sol(i,:)= Lb+(Ub-Lb)*rand(dim,dim);
        Fitness(i) = pidFit(Sol(i,:),G0,Gv,Gs,Kr);
    end
    % Encontra a melhor solu��o inicial
    [fmin,I] = min(Fitness);
    best = Sol(I,:);
    % In�cio do La�o Principal
    for t1 = 1 : N_gen,
        % La�o de itera��o sobre todos os vetores (solu��es candidatas)
        for i = 1:n,

            % Atualiza posi��o do morcego
            Q(i) = Qmin + (Qmin - Qmax)*rand;
            v(i,:) = v(i,:)+(Sol(i,:)- best)*Q(i);
            S(i,:) = Sol(i,:)+v(i,:);

            % Aplica limites
            S(i,:) = simplebounds(S(i,:),Lb,Ub);

            % Taxa de Pulsos
            if rand > r
                % O fator 0.1 limita o tamanho do passo nos voos aleatorios
                S(i,:) = best + 0.1*randn(1,dim);
            end
            % Avalia nova solu��o
            Fnew = pidFit(S(i,:),G0,Gv,Gs,Kr);

            if (Fnew<=Fitness(i)) & (rand<A)
                Sol(i,:) = S(i,:);
                Fitness(i)=Fnew;
            end
            % Atualiza a melhor solu��o atual
            if Fnew <= fmin
                best = S(i,:);
                fmin = Fnew;
            end
        end
        %N_iter = N_iter + n;
        fprintf('IT: %d\n',t1);
        fprintf('ISTSE: %f\n',fmin);
    end % Fim do La�o Principal

    Kp = best(1);
    Ki = best(2);
    ISTSE = fmin;
end