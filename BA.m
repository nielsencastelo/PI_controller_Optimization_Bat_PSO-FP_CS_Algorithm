function [Kp,Ki,ISTSE] = BA(it,pop,C)
    % -------------- INÍCIO DO CÓDIGO --------------

    % ======================================================= %
    % Os parâmetros internos do Bat Algorithm encontram-se    %
    % definidos nesta seção, esses podem ser modificados para %
    % garantir o melhor desempenho.                           %
    % ======================================================= %
    % População inicial de morcegos
    n = pop;
    % Número de gerações
    N_gen = it;
    % Valores iniciais de amplitude(A) e Frequencia(r)
    A = 0.5;
    r = 0.5;

    % Esta é a faixa de frequência, ela determina as escalas
    % Os valores podem ser alterados conforme necessário
    Qmin = 0;         % Frequência mínima
    Qmax = 2;         % Frequência máxima
    % ======================================================= %
    % Fim dos parametros internos do Bat Algorithm            %
    % ======================================================= %

    % ======================================================= %
    % Os parâmetros do sistema de controle do trocador de     %
    % calor encontram-se definidos nesta seção, para maiores  %
    % informações consultar (De Paula; Damasceno, 2014).      %
    % ======================================================= %
    % Função de Transferência do Processo
    G0 = tf(50,[30 1]);
    % Função de Transferência da Válvula
    Gv = tf(0.75*[.13],[3 1]);
    % Função de Transferência do Sensor
    Gs = tf(.16,[10 1]);
    % Fator de escala do setpoint
    Kr = 0.16;
    % ======================================================= %
    % Fim dos parametros do sistema de controle               %
    % ======================================================= %
    
    % ======================================================= %
    % Início das iterações do Bat Algorithm                   %
    % ======================================================= %
    % Dimensões do problema de otimização
%     C = [2.6618 0.0919]; % Estes valores iniciais são estimados utilizando-se
%     C = [10.71 0.437]; %Z-N
    % os métodos sintonia de Ziegler-Nichols ou SIMC.
    % Neste exemplo são utilizados os parametros
    % inicialmente sintonizados pelo metodo SIMC.
    ctype = length(C);
    dim = ctype;         % Controlador proporcional+integral, dim=2
    % Limite Mínimo de Busca
    Lb = 0.5*ones(1,dim).*C;
    % Limite Máximo de Busca
    Ub = 2*ones(1,dim).*C;
    % Inicializando vetores
    Q = zeros(n,1);   % Frequencia
    v = zeros(n,dim); % Velocidade
    Fitness = zeros(1,n);
    Sol = zeros(n,dim);
    % Inicializando a população de morcegos
    for i = 1:n
        Sol(i,:)= Lb+(Ub-Lb)*rand(dim,dim);
        Fitness(i) = pidFit(Sol(i,:),G0,Gv,Gs,Kr);
    end
    % Encontra a melhor solução inicial
    [fmin,I] = min(Fitness);
    best = Sol(I,:);
    % Início do Laço Principal
    for t1 = 1 : N_gen,
        % Laço de iteração sobre todos os vetores (soluções candidatas)
        for i = 1:n,

            % Atualiza posição do morcego
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
            % Avalia nova solução
            Fnew = pidFit(S(i,:),G0,Gv,Gs,Kr);

            if (Fnew<=Fitness(i)) & (rand<A)
                Sol(i,:) = S(i,:);
                Fitness(i)=Fnew;
            end
            % Atualiza a melhor solução atual
            if Fnew <= fmin
                best = S(i,:);
                fmin = Fnew;
            end
        end
        %N_iter = N_iter + n;
        fprintf('IT: %d\n',t1);
        fprintf('ISTSE: %f\n',fmin);
    end % Fim do Laço Principal

    Kp = best(1);
    Ki = best(2);
    ISTSE = fmin;
end