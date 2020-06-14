function z = pidFit(C,G0,Gv,Gs,Kr)
    P = pid(C(1),C(2));
    [y,t] = step(Kr * feedback(P*G0*Gv,Gs));
    dt = (t(2)-t(1))/2;
    % Estende o tempo de simula��o, para garantir a converg�ncia ao degrau
    % ao final do per�odo
    t = 0:dt:t(end)*2;
    e = 1-Kr * step(feedback(P*G0*Gv,Gs),t);
    z = sum(((t.'.^2).*(e.^2)*dt));
end