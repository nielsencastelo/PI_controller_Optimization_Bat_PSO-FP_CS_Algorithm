% -----------------------------------------------------------------
% Cuckoo Search (CS) algorithm by Xin-She Yang and Suash Deb      %
% Programmed by Xin-She Yang at Cambridge University              %
% Programming dates: Nov 2008 to June 2009                        %
% Last revised: Dec  2009   (simplified version for demo only)    %
% -----------------------------------------------------------------
% Papers -- Citation Details:
% 1) X.-S. Yang, S. Deb, Cuckoo search via Levy flights,
% in: Proc. of World Congress on Nature & Biologically Inspired
% Computing (NaBIC 2009), December 2009, India,
% IEEE Publications, USA,  pp. 210-214 (2009).
% http://arxiv.org/PS_cache/arxiv/pdf/1003/1003.1594v1.pdf 
% 2) X.-S. Yang, S. Deb, Engineering optimization by cuckoo search,
% Int. J. Mathematical Modelling and Numerical Optimisation, 
% Vol. 1, No. 4, 330-343 (2010). 
% http://arxiv.org/PS_cache/arxiv/pdf/1005/1005.2908v2.pdf
% ----------------------------------------------------------------%
% This demo program only implements a standard version of         %
% Cuckoo Search (CS), as the Levy flights and generation of       %
% new solutions may use slightly different methods.               %
% The pseudo code was given sequentially (select a cuckoo etc),   %
% but the implementation here uses Matlab's vector capability,    %
% which results in neater/better codes and shorter running time.  % 
% This implementation is different and more efficient than the    %
% the demo code provided in the book by 
%    "Yang X. S., Nature-Inspired Metaheuristic Algoirthms,       % 
%     2nd Edition, Luniver Press, (2010).                 "       %
% --------------------------------------------------------------- %

% =============================================================== %
% Notes:                                                          %
% Different implementations may lead to slightly different        %
% behavour and/or results, but there is nothing wrong with it,    %
% as this is the nature of random walks and all metaheuristics.   %
% -----------------------------------------------------------------

% Additional Note: This version uses a fixed number of generation %
% (not a given tolerance) because many readers asked me to add    %
%  or implement this option.                               Thanks.%                          
function [Kp,Ki,ISTSE] = CS(it,pop,C)
    % if nargin<1
    % % Number of nests (or different solutions)
    n = pop;
    % end

    % Discovery rate of alien eggs/solutions
    pa = 0.25;

    %% Change this if you want to get better results
    N_IterTotal = it;
    % Dimension of the search variables
    
    %% Simple bounds of the search domain
    % Lower bounds
    nd = 2; 
    Lb = 0.5*ones(1,nd).*C; 
    % Upper bounds
    Ub = 2*ones(1,nd).*C;

    % Random initial solutions
    for i=1:n,
        nest(i,:)=Lb+(Ub-Lb).*rand(size(Lb));
    end

    % Get the current best
    fitness = 10^10*ones(n,1);
    [fmin,bestnest,nest,fitness] = get_best_nest(nest,nest,fitness);

    N_iter=0;
    %% Starting iterations
    for iter = 1:N_IterTotal,
        % Generate new solutions (but keep the current best)
         new_nest = get_cuckoos(nest,bestnest,Lb,Ub);   
         [fnew,best,nest,fitness] = get_best_nest(nest,new_nest,fitness);
        % Update the counter
          N_iter=N_iter+n; 
        % Discovery and randomization
          new_nest = empty_nests(nest,Lb,Ub,pa) ;

        % Evaluate this set of solutions
          [fnew,best,nest,fitness] = get_best_nest(nest,new_nest,fitness);
        % Update the counter again

        % Find the best objective so far  
        if fnew<fmin,
            fmin=fnew;
            bestnest=best;
        end
        fprintf('IT: %d\n',iter);
        fprintf('ISTSE: %f\n',fmin);
    end %% End of iterations

    Kp = bestnest(1);
    Ki = bestnest(2);
    ISTSE = fmin;
end