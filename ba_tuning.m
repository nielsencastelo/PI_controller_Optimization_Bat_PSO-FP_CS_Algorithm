%ba_tuning - Otimiza os parametros Proporcional e Integral de um
%controlador PI utilizando a metaheuristica Bat Algorithm
%
%
% Testado no MATLAB (R2015a)
%
% Autor:  Paulo Cesar O. de Paula - <paulocesar.eng@live.com>
% Data:   29/01/2015
% Versão: 1.1
%
%
% Copyright (c) <2015> <Paulo Cesar O. de Paula>
%
% A permissão é concedida, a título gratuito, a qualquer pessoa que
% obtenha uma cópia deste software e arquivos de documentação associados
% (o "Software"), para utilizar o Software sem restrição, incluindo, sem
% limitação, os direitos de usar, copiar, modificar, mesclar, publicar,
% distribuir, sublicenciar, e/ou vender cópias deste Software, e para
% permitir que pessoas às quais o Software é fornecido também o façam,
% desde que o(s) aviso(s) de copyright acima e este aviso de permissão
% apareçam em todas as cópias do Software e que tanto o(s) aviso(s) de
% copyright quanto este aviso de permissão apareçam na documentação de
% apoio.
%
% O SOFTWARE É FORNECIDO "COMO ESTÁ", SEM GARANTIA DE QUALQUER TIPO,
% EXPRESSA OU IMPLÍCITA, INCLUINDO, SEM LIMITAÇÃO, AS GARANTIAS DE
% COMERCIALIZAÇÃO, ADEQUAÇÃO A UM DETERMINADO PROPÓSITO E NÃO VIOLAÇÃO DOS
% DIREITOS DE TERCEIROS. EM NENHUM CASO O DETENTOR OU OS DETENTORES DOS
% DIREITOS AUTORAIS INCLUÍDOS NESTE AVISO SERÃO RESPONSABILIZADOS POR
% QUALQUER AÇÃO JUDICIAL OU QUAISQUER PREJUÍZOS ESPECIAIS, INDIRETOS OU
% EMERGENTES RESULTANTES DE PRIVAÇÃO DE USO, DADOS OU LUCROS, SEJA EM AÇÃO
% CONTRATUAL, NEGLIGÊNCIA OU OUTRA AÇÃO DOLOSA, DECORRENTES DE OU EM
% LIGAÇÃO COM O USO OU DESEMPENHO DESTE SOFTWARE.
%
%
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
it = 50;
pop = 10;
[Kp,Ki] = BA(it,pop);

% Instância do controlador PI Otimizado
C_O = pid(Kp,Ki);
% O gráfico do controlador PI otimizado é plotado
step(Kr*feedback(C_O*G0*Gv,Gs),'-r');
% Legendas do gráfico
legend({'SIMC','SIMC-BA'})
hold off