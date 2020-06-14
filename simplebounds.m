function s=simplebounds(s,Lb,Ub)
if s(1)<Lb(1)
    s(1)=Lb(1);
end
if s(2)<Lb(2)
    s(2)=Lb(2);
end
if s(1)>Ub(1)
    s(1)=Ub(1);
end
if s(2)>Ub(2)
    s(2)=Ub(2);
end
end