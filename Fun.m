% % Objective function and here we used Rosenbrock's 3D function
function z=Fun(u)
    z=(1-u(1))^2+100*(u(2)-u(1)^2)^2+100*(u(3)-u(2)^2)^2;
end