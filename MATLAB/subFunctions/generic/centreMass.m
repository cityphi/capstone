function output = centreMass( weights, a )
%CENTREMASS Change masses into a point force
%   F = CENTREMASS(W, a) returns a either a force vector or a centre of
%   mass depending on if a angle is given. This function will not work for 
%   roll.
%
%   W [ weight locX locY locZ ] - weights
%   a [ pitchAngle ] - current pitch angle of the airship RAD
%   
%   Output:
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - point force output
%	OR
%	M [ weight locX locY locZ ] - combined weights of the system

% total weight of the system
M = sum(weights(:, 1));

% location of the centre of mass
CM = transp(weights(:, 1)) * weights(:, 2:4)/M;
output = [M CM];

if nargin == 2
	% build the point force
	output = [ CM M*sin(a) 0 -M*cos(a) 0 0 0];
end
end