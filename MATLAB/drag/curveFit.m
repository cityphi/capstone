v=[2,4,6,8,10,12,14,16,18,20];
x=transpose(v);
d=[0.4663,1.7320,3.5236,5.9242,9.3913,14.5235,21.3659,28.1595,35.9296,44.1682];
y=transpose(d);
f=fit(x,y,'poly4')

plot(f,'k',v,d,'xk'),xlabel('Velocity (m/s)'), ylabel('Drag Force (N)'), legend('Fitted Curve', 'Raw Data')