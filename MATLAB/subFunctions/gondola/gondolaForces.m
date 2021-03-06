function [gondAcceleration, maxArmForce, brakeForce] = ...
    gondolaForces(gondSpecs, pitchAngle, thrustAngle, gondAngle, ...
    aThrust, Tw, spring, brakex, brakez)
%gondolaForces calculates all forces acting on gondola
%   Inputs:
%       -Gondola spec array format specified below in code
%       -Pitch angle of airship [rads] 0 is horizontal
%       -Angle of thrusters     [rads] 0 is straight forward
%       -Angle between gondolas [rads] 
%       -Acceleration due to thrusters [m/s^2]
%       -Friction wheel motor torque [Nm]
%       -Torsion hinge spring force  [N]
%       -Brakex is required holding force [N]
%       -brakez is applied linear actuator force [N]
%           brakex and brakez should never both be non zero
%   Outputs:
%       -gondAcceleration array with acceleration force of gondola
%       -maxArmForce forces on most loaded bearing arm
%       -brakeForce is the forces resulting from the linear actuator 
%
%Format for forces/reactions arrays:[locX locY locZ Fx Fy Fz Mx My Mz]

rFw = 0.0127;       %friction wheel radius
hingeAngle = pi/4;  %angle of torsion hinge [rads] yx 
Hdrive = 0.021125;  %height of friction wheel contact point above face of gond
Ldrivex = 0.05;     %distance in x from drive to gondola axle
Ldrivey = 0.00362;  %distance in y from drive to center of gondola

g = -9.81;           %acceleration due to gravity [m/s^2]

Lbearingx = 0.03682;%distance in x from bearing contact to gondola axle
Lbearingy = 0.00328;%distance in y from bearing contact to center of gondola
Hbearing = 0.03954; %height in z from bearing contact to surface of gondola
muBrake = 0.65;

%%%%%%%%%%%%%%% INPUTS %%%%%%%%%%%%%%%%%%

Lgond = gondSpecs(1);       %length in x of one gondola car
Wgond = gondSpecs(2);       %width in y of gondola 
Hgond = gondSpecs(3);       %height in z of gondola
Lcm1x = gondSpecs(4);       %center of gravity in x or gondola 1
Lcm1y = gondSpecs(5);       %center of gravity in x or gondola 1
Lcm1z = gondSpecs(6);       %center of gravity in x or gondola 1
Lcm2x = gondSpecs(7);       %center of gravity in x or gondola 2
Lcm2y = gondSpecs(8);       %center of gravity in x or gondola 2
Lcm2z = gondSpecs(9);       %center of gravity in x or gondola 2
m1 = gondSpecs(10);         %mass of gondola 1 in kg
m2 = gondSpecs(11);         %mass of gondola 2 in kg
brakePosx = gondSpecs(12);  %position of brake in x 
brakePosz = gondSpecs(13);  %height of brake in z

%%%%%%%%%%%%%%%% Forces %%%%%%%%%%%%%%%%%%%%%%%%%%

Fw = Tw/rFw; %driving force of motor

gondMotorForces = [-Ldrivex -Ldrivey Hdrive Fw 0 spring 0 0 0;  %acting on gond 1
                    Ldrivex Ldrivey Hdrive Fw 0 -spring 0 0 0;];%acting on gond 2
               
%%%%rotating motorForces to account for coordinate system change and gondAngle
gondMotorForces(1,:) = rotate(gondMotorForces(1,:), 0, pi/4, 2, 1);
gondMotorForces = rotate(gondMotorForces, gondAngle, (pi)-hingeAngle, 5, 2);
    
weight = [Lcm1x Lcm1y Lcm1z 0 0 m1*g 0 0 0;      %acting on gond 1 
          Lcm2x Lcm2y Lcm2z 0 0 m2*g 0 0 0;];    %acting on gond 2 
     
%%%%rotating weights to account for pitch angle
weight = rotate(weight, pitchAngle, 0, 2, 2);
weight = rotate(weight, gondAngle, 0, 4, 2);
    
accelerationForce = [Lcm1x Lcm1y Lcm1z m1*aThrust 0 0 0 0 0;    %acting on gond 1 
                     Lcm2x Lcm2y Lcm2z m2*aThrust 0 0 0 0 0;];  %acting on gond 2
               
%%%%rotating accelerationForce to account for thrust angle
accelerationForce = rotate(accelerationForce, thrustAngle, 0, 2, 2);
accelerationForce = rotate(accelerationForce, gondAngle, 0, 4, 2);

if brakex ~= 0 
    brakeForce = [brakePosx 0 brakePosz brakex 0 -abs(brakex)/muBrake 0 0 0];
    gondForces =  [gondMotorForces ;  weight ; accelerationForce; brakeForce];  
elseif brakez ~= 0 
    brakeForce = [brakePosx 0 brakePosz -(weight(1,4)+weight(2,4)+...
        accelerationForce(1,4)+accelerationForce(2,4)) 0 brakez 0 0 0];
    gondForces =  [gondMotorForces ;  weight ; accelerationForce; brakeForce];
else 
    gondForces =  [gondMotorForces ;  weight ; accelerationForce];
    brakeForce = 0;
end 
    
%%%%%%%%%%%%%% reactions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gondReactions = [
    Lbearingx Lbearingy Hbearing 1 1 1 0 0 0;    %Reactions at bearing 4
    Lbearingx -Lbearingy Hbearing 1 1 1 0 0 0;   %Reactions at bearing 3
    -Lbearingx Lbearingy Hbearing 0 2 2 0 0 0;   %Reactions at bearing 2
    -Lbearingx -Lbearingy Hbearing 0 -3 3 0 0 0; %Reactions at bearing 1
    0 0 0 1 0 1 0 0 0;                           %acceleration of gondolas 
    0 0 0 0 0 0 1 0 0;];                         %moment

%rotate reaction position on front gondola
gondReactions(3:4,:) = rotate(gondReactions(3:4,:), gondAngle, 0, 1, 2);

%%%%%%%%%%%%%% Acceleration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gondReactionsSolved = forceSolver(gondForces, gondReactions, [1 gondAngle]);

gondAcceleration = (gondReactionsSolved(5,4))/(abs(gondReactionsSolved(5,4)))...
    *sqrt((gondReactionsSolved(5,4)^2)+(gondReactionsSolved(5,6)^2))/(m1+m2);

%%%%%%%%%finding max arm force%%%%%%%%%
maxArmForce = 0;
for i = 1:4   
    current = gondReactionsSolved(i,6);
    if current > maxArmForce
        maxArmForce = current;
    end 
end

if abs(gondReactionsSolved(1,6)-gondReactionsSolved(2,6)) >  maxArmForce
    maxArmForce = abs(gondReactionsSolved(1,6)-gondReactionsSolved(2,6));
end    
    
if abs(gondReactionsSolved(3,6)-gondReactionsSolved(4,6)) >  maxArmForce
    maxArmForce = abs(gondReactionsSolved(3,6)-gondReactionsSolved(4,6));
end 

end