clear;close all; clc;

G0 = tf(50,[30 1]);
% Fun��o de Transfer�ncia da V�lvula
Gv = tf(0.75*[.13],[3 1]);
% Fun��o de Transfer�ncia do Sensor
Gs = tf(.16,[10 1]);
% Fator de escala do setpoint
Kr = 0.16;

C = [2.6618 0.0919]; % Estes valores iniciais s�o estimados utilizando-se
% os m�todos sintonia de Ziegler-Nichols ou SIMC.
% Neste exemplo s�o utilizados os parametros
% inicialmente sintonizados pelo metodo SIMC.

% Inst�ncia do controlador PI sem otimiza��o
C_I = pid(C(1),C(2));
% O gr�fico do controlador PI sem otimiza��o � plotado
step(Kr * feedback(C_I * G0 * Gv,Gs), '--k');
grid on;
hold on;

it = 200; % N� de itera��es
pop = 10; % Popula��o
[Kp, Ki] = PSO(it,pop);

C_O = pid(Kp,Ki);
% O gr�fico do controlador PI otimizado � plotado
step(Kr*feedback(C_O*G0*Gv,Gs),'-r');
% Legendas do gr�fico
legend({'SIMC','SIMC-PSO'})
hold off