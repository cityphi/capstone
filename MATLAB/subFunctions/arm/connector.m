function [ dimensions ] = connector(FT, weight, radius, material)
%CONNECTOR Connecter optimization 
%   D = CONNECTOR(F, W, m) returns the optimized dimensions of the
%   square piece of the connector. The height and length are fixed and the
%   value changing will be the width.
%
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   W [ weight locX locY locZ ] - weight of all components above connector
%   M [ density Sut Suc Sy E brittle ] - information of the material

safetyFactor = 5; % hard coded value for the safety factor
aPitch = 90;
a = aPitch*pi()/180;
thrustForce = [0 0 0 FT*2 0 0 0 0 0 ]; % location and x force
forces = [thrustForce; centreMass(weight, a)];

% [ length width height ] - starting
dimensions = [ 0.04 0.0015 0.033 ];
change = 0.0001;

% location of analysis
reaction = [ 0 0 -radius 1 1 1 1 1 1 ];

reactionForces = forceSolver(forces, reaction);

% loop to find a dimension that gives the desired safety factor
maxIterations = 100; iterations = 0; loop = 1;

while loop && iterations < maxIterations;
    iterations = iterations + 1;  
    
    % safety factor for stresses
    stressTensor = connectorTensor(reactionForces, dimensions);
    n = cauchy(stressTensor, material);
    
    if n < safetyFactor
        if dimensions(2) > 0.0029
            loop = 0;
        else
            dimensions(2) = dimensions(2) + change;
        end
    else
        loop = 0;    
    end
end

%--CHECK other part of the connector
% dimensions of the base connector
l  = 0.06;
a1 = 0.01;
w1 = a1*cos(pi()/4);
h1 = w1/2;
a2 = 0.008;

% l a w h(main) a(smaller)
keelDimensions = [ l a1 w1 h1 a2 ];

keelReactions = [ -l/2 0 -h1 0 0 1 0 0 0;
                   l/2 0  h1 1 0 1 0 0 0];

thrustForce = [0 0 0 FT*2 0 0 0 0 0 ];
forces = [thrustForce; centreMass(weight, pi()/2)];
forces(:, 3) = forces(:, 3) + radius + dimensions(3);
reactionForces = forceSolver(forces, keelReactions);

% build a stress tensor and use cauchy to solve for safety factor
stressTensor = keelTensor(reactionForces(2, :), keelDimensions);
nKeel = cauchy(stressTensor, material);

%--LOG File
connectorLog(n, nKeel, safetyFactor, dimensions(2));

%--Solidworks
connectorSW(dimensions(2), radius);
end

%-------------------------------------
%   TENSOR
%-------------------------------------

function [ tensor ] = connectorTensor(forces, dimensions)
%CONNECTORTENSOR Cauchy stress tensor of the connector
%   tensor = connectorTensor(F, D) returns a 3x3 matrix which is used by
%   the cauchy function to find a safety factor for the connector

% split dimensions array for use in equations
l   = dimensions(1);
w   = dimensions(2);

% split the forces array for use in equations
Fy  = forces(5);
Mx  = forces(7);
My  = forces(8);
Mz  = forces(9);

% area of the x-z cross-section
A   = l*w;
Ix  = l*w^3/12;
Iy  = l^3*w/12;

% for the stress calculations
y = w/2; x = l/2;

% for the torsion calculations
b = l; c = w;

% assume that max occurs at top right corner
%         l          ^
% -->.--------      y|-->
%    |        |w       x
%     --------
Sx  = 0;
Sy  = 0;
Sz  = Mx*y/Ix + My*x/Iy - Fy/A; % two plane stress
txy = Mz/(b*c^2)*(3+1.8*c/b); % torsional sheer
txz = 0;
tyz = 0;

% layout of the cauchy stress tensor
tensor = [ Sx  txy txz;
           txy Sy  tyz;
           txz tyz Sz ];
end

%-------------------------------------
%   TENSOR
%-------------------------------------

function [ tensor ] = keelTensor(forces, dimensions)
%KEELTENSOR Cauchy stress tensor of the keel section of the connector
%   tensor = connectorTensor(F, D) returns a 3x3 matrix which is used by
%   the cauchy function to find a safety factor for the connector

% split dimensions array for use in equations
a   = dimensions(2);
w   = dimensions(3);
h   = dimensions(4);

% split the forces array for use in equations
Fx  = forces(4);
Fz  = forces(6);

% area of the z-y cross-section
A  = a^2;
I  = a^4/12;

% for shear stress
V = Fz;
Q = (w*h/2)*(h/3);
b = w;

% assume that max occurs in middle
%        ^
%   /\  z|-->
%   \/     y
Sx  = Fx/A;
Sy  = 0;
Sz  = 0;
txy = 0;
txz = -V*Q/(I*b);
tyz = 0;

% layout of the cauchy stress tensor
tensor = [ Sx  txy txz;
           txy Sy  tyz;
           txz tyz Sz ];
end

%-------------------------------------
%   LOG
%-------------------------------------

function connectorLog(n, nKeel, nReq, thickness)
%CONNECTORLOG Outputs useful data to the log file
%   CONNECTORLOG(n, nBuck, nKeel, nReq) returns nothing

logFile = 'groupRE3_LOG.txt';
logFolder = fullfile('../Log');
MATLABFolder = fullfile('../MATLAB');

% append to the file
cd(logFolder)
fid = fopen(logFile, 'a+');
fprintf(fid, '\r\n***Arm Connection to Keel***\r\n');
fprintf(fid, 'Assuming the piece is made from Aluminum 6061\r\n');
fprintf(fid, ['The optimized thickness is ' num2str(thickness*1000) 'mm\r\n']);
fprintf(fid, 'This gives safety factors for the different failures:\r\n');
fprintf(fid, ['\tConnector Stress: ' num2str(n)]);
% display a message if the safety factor couldn't be acheived
if n < nReq
    fprintf(fid, ' ****This does not meet safety Factor\r\n');
else
    fprintf(fid, '\r\n');
end
fprintf(fid, ['\tKeel Piece: ' num2str(nKeel)]);
% display a message if the safety factor couldn't be acheived
if nKeel < nReq
    fprintf(fid, ' ****This does not meet safety Factor\r\n');
else
    fprintf(fid, '\r\n');
end
fclose(fid);
cd(MATLABFolder)
end

%-------------------------------------
%   SOLIDWORKS
%-------------------------------------

function connectorSW(thickness, radius)
%CONNECTORSW Outputs data to solidworks for the connector
%   CONNECTORSW(thickness, radius) returns nothing

SWArmFile = '2005-THRUSTER-ARMS-EQUATIONS.txt';
SWConFile = '2003-CONNECTOR-EQUATIONS.txt';
SWSupFile = '2004-ENVELOPE-SUPPORT-EQUATIONS.txt';
MATLABFolder = fullfile('../MATLAB');
SWFolder = fullfile('../Solidworks/Equations');

% write to the different solidworks files
cd(SWFolder)
fid = fopen(SWArmFile, 'a+');
fprintf(fid, ['"tsupport"= ' num2str(thickness*1000) 'mm\r\n']);
fprintf(fid, ['"rblimp"= ' num2str(radius*1000) 'mm\r\n']);
fclose(fid);
fid = fopen(SWConFile, 'w+t');
fprintf(fid, ['"tsupport"= ' num2str(thickness*1000) 'mm\n']);
fclose(fid);
fid = fopen(SWSupFile, 'a+');
fprintf(fid, ['"tsupport"= ' num2str(thickness*1000) 'mm\r\n']);
fprintf(fid, ['"rblimp"= ' num2str(radius*1000) 'mm']);
fclose(fid);
cd ..
cd(MATLABFolder)
end
