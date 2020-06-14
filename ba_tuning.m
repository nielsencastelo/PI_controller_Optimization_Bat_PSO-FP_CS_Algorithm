%ba_tuning - Otimiza os parametros Proporcional e Integral de um
%controlador PI utilizando a metaheuristica Bat Algorithm
%
%
% Testado no MATLAB (R2015a)
%
% Autor:  Paulo Cesar O. de Paula - <paulocesar.eng@live.com>
% Data:   29/01/2015
% Vers�o: 1.1
%
%
% Copyright (c) <2015> <Paulo Cesar O. de Paula>
%
% A permiss�o � concedida, a t�tulo gratuito, a qualquer pessoa que
% obtenha uma c�pia deste software e arquivos de documenta��o associados
% (o "Software"), para utilizar o Software sem restri��o, incluindo, sem
% limita��o, os direitos de usar, copiar, modificar, mesclar, publicar,
% distribuir, sublicenciar, e/ou vender c�pias deste Software, e para
% permitir que pessoas �s quais o Software � fornecido tamb�m o fa�am,
% desde que o(s) aviso(s) de copyright acima e este aviso de permiss�o
% apare�am em todas as c�pias do Software e que tanto o(s) aviso(s) de
% copyright quanto este aviso de permiss�o apare�am na documenta��o de
% apoio.
%
% O SOFTWARE � FORNECIDO "COMO EST�", SEM GARANTIA DE QUALQUER TIPO,
% EXPRESSA OU IMPL�CITA, INCLUINDO, SEM LIMITA��O, AS GARANTIAS DE
% COMERCIALIZA��O, ADEQUA��O A UM DETERMINADO PROP�SITO E N�O VIOLA��O DOS
% DIREITOS DE TERCEIROS. EM NENHUM CASO O DETENTOR OU OS DETENTORES DOS
% DIREITOS AUTORAIS INCLU�DOS NESTE AVISO SER�O RESPONSABILIZADOS POR
% QUALQUER A��O JUDICIAL OU QUAISQUER PREJU�ZOS ESPECIAIS, INDIRETOS OU
% EMERGENTES RESULTANTES DE PRIVA��O DE USO, DADOS OU LUCROS, SEJA EM A��O
% CONTRATUAL, NEGLIG�NCIA OU OUTRA A��O DOLOSA, DECORRENTES DE OU EM
% LIGA��O COM O USO OU DESEMPENHO DESTE SOFTWARE.
%
%
% Fun��o de Transfer�ncia do Processo
G0 = tf(50,[30 1]);
% Fun��o de Transfer�ncia da V�lvula
Gv = tf(0.75*[.13],[3 1]);
% Fun��o de Transfer�ncia do Sensor
Gs = tf(.16,[10 1]);
% Fator de escala do setpoint
Kr = 0.16;
% Parametros do Controlador PI [Kp Ki] a Otimizar
C = [2.6618 0.0919]; % Estes valores iniciais s�o estimados utilizando-se
% os m�todos sintonia de Ziegler-Nichols ou SIMC.
% Neste exemplo s�o utilizados os parametros
% inicialmente sintonizados pelo metodo SIMC.

% Inst�ncia do controlador PI sem otimiza��o
C_I = pid(C(1),C(2));
% O gr�fico do controlador PI sem otimiza��o � plotado
step(Kr * feedback(C_I * G0 * Gv,Gs), '--k');
grid on
hold on
it = 50;
pop = 10;
[Kp,Ki] = BA(it,pop);

% Inst�ncia do controlador PI Otimizado
C_O = pid(Kp,Ki);
% O gr�fico do controlador PI otimizado � plotado
step(Kr*feedback(C_O*G0*Gv,Gs),'-r');
% Legendas do gr�fico
legend({'SIMC','SIMC-BA'})
hold off