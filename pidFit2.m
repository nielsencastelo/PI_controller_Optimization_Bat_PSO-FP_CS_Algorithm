function z = pidFit2(C,G0,Gv,Gs,Kr)
    P = pid(C(1),C(2));
    pidSys = Kr * feedback(P*G0*Gv,Gs);
    
    [y,~] = step(pidSys);
    stepInfo = stepinfo(pidSys);
    z = abs(1/((1 - exp(-(0.3)))*(stepInfo.Overshoot + 1 - y(end)) + (1 - exp(-(0.3)))*(stepInfo.RiseTime - stepInfo.SettlingTime)));
end