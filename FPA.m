function [Kp,Ki,ISTSE] = FPA(it,pop,C)
% --------------------------------------------------------------------% 
% Flower pollenation algorithm (FPA), or flower algorithm             %
% Programmed by Xin-She Yang @ May 2012                               % 
% --------------------------------------------------------------------%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Notes: This demo program contains the very basic components of      %
% the flower pollination algorithm (FPA), or flower algorithm (FA),   % 
% for single objective optimization.    It usually works well for     %
% unconstrained functions only. For functions/problems with           % 
% limits/bounds and constraints, constraint-handling techniques       %
% should be implemented to deal with constrained problems properly.   %
%                                                                     %   
% Citation details:                                                   % 
%1)Xin-She Yang, Flower pollination algorithm for global optimization,%
% Unconventional Computation and Natural Computation,                 %
% Lecture Notes in Computer Science, Vol. 7445, pp. 240-249 (2012).   %
%2)X. S. Yang, M. Karamanoglu, X. S. He, Multi-objective flower       %
% algorithm for optimization, Procedia in Computer Science,           %
% vol. 18, pp. 861-868 (2013).                                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    n = pop; % % Population size, typically 10 to 25
    p = 0.8;           % probabibility switch
    % Iteration parameters
    N_iter = it;       % Total number of iterations

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

    % Dimension of the search variables
%     C = [2.6618 0.0919]; % Estes valores iniciais são estimados utilizando-se
%     C = [10.71 0.437]; % Z-N
    % os métodos sintonia de Ziegler-Nichols ou SIMC.
    % Neste exemplo são utilizados os parametros
    % inicialmente sintonizados pelo metodo SIMC
    ctype = length(C);
    d = ctype;         % Controlador proporcional+integral, dim=2
    Lb = 0.5*ones(1,d).*C;
    Ub = 2*ones(1,d).*C;
    Fitness = zeros(1,n);
    Sol = zeros(n,d);
    % Initialize the population/solutions
    for i = 1: n
      Sol(i,:) = Lb+(Ub-Lb).*rand(1,d);
      Fitness(i) = pidFit(Sol(i,:),G0,Gv,Gs,Kr);
    end

    % Find the current best
    [fmin,I] = min(Fitness);
    best = Sol(I,:);
    S = Sol; 

    % Start the iterations -- Flower Algorithm 
    for t = 1:N_iter,
        % Loop over all bats/solutions
        for i = 1:n,
          % Pollens are carried by insects and thus can move in
          % large scale, large distance.
          % This L should replace by Levy flights  
          % Formula: x_i^{t+1}=x_i^t+ L (x_i^t-gbest)
          if rand > p,
          %% L = rand;
          L = Levy(d);
          dS = L.*(Sol(i,:)- best);
          S(i,:) = Sol(i,:)+dS;
          
          % Check if the simple limits/bounds are OK
          S(i,:) = simpleboundsFPA(S(i,:),Lb,Ub);
          
          % If not, then local pollenation of neighbor flowers 
          else
              epsilon = rand;
              % Find random flowers in the neighbourhood
              JK = randperm(n);
              % As they are random, the first two entries also random
              % If the flower are the same or similar species, then
              % they can be pollenated, otherwise, no action.
              % Formula: x_i^{t+1}+epsilon*(x_j^t-x_k^t)
              S(i,:) = S(i,:)+ epsilon*(Sol(JK(1),:) - Sol(JK(2),:));
              % Check if the simple limits/bounds are OK
              S(i,:) = simpleboundsFPA(S(i,:),Lb,Ub);
          end
          
          % Evaluate new solutions
           Fnew = pidFit(S(i,:),G0,Gv,Gs,Kr);
          % If fitness improves (better solutions found), update then
            if (Fnew <= Fitness(i)),
                Sol(i,:) = S(i,:);
                Fitness(i) = Fnew;
           end
           
          % Update the current global best
          if Fnew <= fmin,
                best = S(i,:);
                fmin = Fnew;
          end
        end
        % Display results every 100 iterations
        fprintf('IT: %d\n',t);
        fprintf('ISTSE: %f\n',fmin);
        
    end

    Kp = best(1);
    Ki = best(2);
    ISTSE = fmin;
end
