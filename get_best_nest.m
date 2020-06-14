%% Find the current best nest
function [fmin,best,nest,fitness] = get_best_nest(nest,newnest,fitness)
% Evaluating all new solutions
%% ======================================================= %
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
for j=1:size(nest,1),
    fnew = pidFit(newnest(j,:),G0,Gv,Gs,Kr);
    if fnew<=fitness(j),
       fitness(j)=fnew;
       nest(j,:)=newnest(j,:);
    end
end
% Find the current best
[fmin,K]=min(fitness) ;
best=nest(K,:);
end