% Comparativo entre as metaeuristicas
clear;close all; clc;
% Parametro dos sistemas
G0 = tf(50,[30 1]);
% Função de Transferência da Válvula
Gv = tf(0.75*[.13],[3 1]);
% Função de Transferência do Sensor
Gs = tf(.16,[10 1]);
Kr = 0.16;

% C = [2.6618 0.0919]; % SIMC
C = [10.71 0.437]; % Z-N

% Parâmetro dos algoritmos
it = 60;
pop = 10;

% Roda Bat Algoritm
tic;
[Kpb,Kib,ISTSE_B] = BA(it,pop,C);
tempoB = toc;

grid on;
hold on;

Cb = pid(Kpb,Kib);
step(Kr*feedback(Cb*G0*Gv,Gs));

% Roda PSO
tic;
[Kpp, Kip,ISTSE_P] = PSO(it,pop,C);
tempoP = toc;

CP = pid(Kpp,Kip);
step(Kr*feedback(CP*G0*Gv,Gs));

% Roda Flower Pollination
tic;
[Kpf, Kif,ISTSE_F] = FPA(it,pop,C);
tempof = toc;

CF = pid(Kpf,Kif);
step(Kr*feedback(CF*G0*Gv,Gs));

% Roda CS
tic;
[Kpcs, Kics,ISTSE_CS] = CS(it,pop,C);
tempocs = toc;

CCS = pid(Kpcs,Kics);
step(Kr*feedback(CCS*G0*Gv,Gs));

% Roda Z-N
Kpzn = 10.71;
Kizn = 0.437;
CZN = pid(Kpzn,Kizn);
step(Kr*feedback(CZN*G0*Gv,Gs))

% Roda SMIC
Kpsimic = 2.6618; 
Kisimic = 0.0919;
CSIMIC = pid(Kpsimic,Kisimic);
step(Kr*feedback(CSIMIC*G0*Gv,Gs))

% Legendas do gráfico
legend({'BA','PSO','FPA','CS','Z-N','SIMIC'})
hold off;

% Imprime resultados
fprintf('ISTSE BA: %f\n',ISTSE_B);
fprintf('    Tempo BA: %f\n',tempoB);

fprintf('ISTSE PSO: %f\n',ISTSE_P);
fprintf('    Tempo BA: %f\n',tempoP);

fprintf('ISTSE FPA: %f\n',ISTSE_F);
fprintf('    Tempo FPA: %f\n',tempof);

fprintf('ISTSE CS: %f\n',ISTSE_CS);
fprintf('    Tempo CS: %f\n',tempocs);

