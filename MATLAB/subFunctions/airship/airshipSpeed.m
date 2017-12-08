function topSpeed = airshipSpeed(D, P, n, dragValues)
%AIRSHIPSPEED Gives the airships top speed
%   speed = AIRSHIPSPEED(D, P, n) returns the intersect of the
%   thrust curve with the drag curve (top speed)
%
%   D - Diameter (in)
%   P - Pitch (in)
%   n - RPMs
%   dragValues [CD rho vol] - of the airship

CD = dragValues(1);
rho = dragValues(2);
vol = dragValues(3);

% hard-coded drag function
drag = @(V) 2.420294 * CD * rho * vol^(2/3) * V^1.86;

% thrust equation
T = @(V) 0.20477*(pi*D^2)/4*(D/P)^1.5*((P * n)^2 - V*P * n)*2;
    
% max speed based on the thrust line and drag curve
options = optimset('Display','off');
topSpeed = fsolve(@(V) T(V) - drag(V), 2, options);
end