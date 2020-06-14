clear;close all; clc;

G0 = tf(50,[30 1]);
% Função de Transferência da Válvula
Gv = tf(0.75*[.13],[3 1]);
% Função de Transferência do Sensor
Gs = tf(.16,[10 1]);
% Fator de escala do setpoint
Kr = 0.16;

C = [2.6618 0.0919]; % Estes valores iniciais são estimados utilizando-se
% os métodos sintonia de Ziegler-Nichols ou SIMC.
% Neste exemplo são utilizados os parametros
% inicialmente sintonizados pelo metodo SIMC.

% Instância do controlador PI sem otimização
C_I = pid(C(1),C(2));
% O gráfico do controlador PI sem otimização é plotado
step(Kr * feedback(C_I * G0 * Gv,Gs), '--k');
grid on;
hold on;

it = 200; % Nº de iterações
pop = 10; % População
[Kp, Ki] = PSO(it,pop);

C_O = pid(Kp,Ki);
% O gráfico do controlador PI otimizado é plotado
step(Kr*feedback(C_O*G0*Gv,Gs),'-r');
% Legendas do gráfico
legend({'SIMC','SIMC-PSO'})
hold off