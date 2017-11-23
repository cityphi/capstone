v=[0,2,4,6,8,10,12,14,16,18,20];
x=transpose(v);
d=[0,0.4663,1.7320,3.5236,5.9242,9.3913,14.5235,21.3659,28.1595,35.9296,44.1682];
y=transpose(d);
f=fit(x,y,'poly4');

cvalues = coeffvalues(f);
cnames = coeffnames(f);
output = formula(f);

for ii=1:1:numel(cvalues)
    cname = cnames{ii};
    cvalue = num2str(cvalues(ii));
    output = strrep(output, cname , cvalue);
end

disp(output)

plot(f,'k',v,d,'xk'),xlabel('Velocity (m/s)'), ylabel('Drag Force (N)'),...
    legend('Fitted Curve', 'Raw Data')