v=[3,3.5,4,4.460,6.070];
x=transpose(v);
d=[0.0184,0.0167,0.0147,0.0138,0.0132];
y=transpose(d);
f=fit(x,y,'poly2');

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