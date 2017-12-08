function [weight, thrusterDist] = thrusterShaft(thrust, thrustMass, ...
    radius, material)
%THRUSTERSHAFT Thruster arm optimization.
%   [W, D] = ARM(F, W, M) returns the reaction forces at the worst
%   pitch for the connector and the optimized dimensions of the arm. 
%
%   thrust - thrust force
%   weight -  weight of the thruster components chosen
%   radius - distance to thrust and offset from shaft
%   M [ density Sut Suc Sy E brittle ] - information of the material

% hard-coded values
safetyFactor = 3;
aPitch = 90;
a = aPitch*pi()/180; % easier to read deg
bore = 0.0038; % radius needed for screw needed for the screw
bearingOffset = 0.01532; % distance from end of shaft to bearing

% hard coded useful points
thrusterDist = 0.0213 + radius * (1 + 0.025);
shaftEnd = thrusterDist - 0.01979;

% standard thread sizes and pitch (mm)
% https://en.wikipedia.org/wiki/ISO_metric_screw_thread
thread = [ 8 1.25 1; 10 1.5 1.25; 12 1.75 1.5; 14 2 1.5; 16 2 1.5;
    18 2.5 2; 20 2.5 2; 22 2.5 2; 24 3 2];
threadType = 2; % 2 = coarse, 3 = fine

% reference point and location of reactions
bearing = [ 0 0 0 1 1 1 1 1 1 ];

% get the mass data needed for analysis
massData = csvread('weightData.csv', 1);
references = massData(:, 5) == 2 | massData(:, 5) == 3;
massData(~references, :) = [];
massData(:, 2:4) = massData(:, 2:4)/1000;

% relate back to A ( 2 is A )
massData(massData(:, 5) == 3, 3) = massData(massData(:, 5) == 3, 3) + shaftEnd;
massData(massData(:, 5) == 3, 5) = 2;

% add thruster weights
massData(end + 1, :) = [ thrustMass 0 thrusterDist 0 2 ];

% check that array setup correctly
if any(massData(massData(:, 5) ~= 2, :), 1)
    disp('Thruster arm did not relate all weigths to same point');
end

% change it to a weight (N)
weightData = [ massData(:, 1) * 9.81/1000 massData(:, 2:4)];
weights = centreMass(weightData(:, 1:4));
weights(:, 3) = weights(:, 3) - bearingOffset;

% add a row for the weight of the shaft
weights(end+1, :) = [0 0 (shaftEnd - bearingOffset)/2 0];

% build the forces array
forces = zeros(2, 9);
forces(1, :) = [0 thrusterDist-bearingOffset 0 thrust 0 0 0 0 0 ];

for i = 1:size(thread, 1)
    % values for dimensions
    major = thread(i, 1)/1000; % major diameter (m)
    pitch = thread(i, threadType)/1000; % pitch of threads (mm)
    minor = major - 1.082532*pitch; % minor diameter (m)

    % D [ boreRadius minorRadius majorRadius thread(M)]
    dimensions = [bore minor/2 major/2];
    
    % change the weight of the shaft and find new forces each iteration
    weights(end, 1) = pi * dimensions(3)^2 * (shaftEnd - bearingOffset) * ...
        material(1) * 9.81;
    forces(end, :) = centreMass(weights, a);

    % steps to get the safety factor
    reaction = forceSolver(forces, bearing);
    tensor = shaftTensor(reaction, dimensions);
    n = cauchy(tensor, material);
    
    % end when safety factor is reached
    if n > safetyFactor
        break
    end
end

% find the actual total weight and the new CG
weights(end, 1) = pi * dimensions(3)^2 * (shaftEnd) * material(1) * 9.81;
weights(end, 3) = shaftEnd/2;
weights(1, 3) = weights(1, 3) + bearingOffset;

%--OUTPUT
% write to the log file
shaftLog(n, safetyFactor, weights(end, 1)/9.81*1000, thread(i, 1))

% write to solidworks
shaftSW(dimensions(3), shaftEnd)

% back to main
weight = centreMass(weights(end, :));
end

%--------------------------------------------------
%   TENSOR
%--------------------------------------------------

function [tensor] = shaftTensor(forces, dimensions)
%SHAFTTENSOR Cauchy stress tensor of the arm.
%   tensor = SHAFTTENSOR(F, D) returns a 3x3 matrix which is used by
%   the cauchy function to find a safety factor for the shaft.
%
%   F [ locX locY locZ Fx Fy Fz Mx My Mz ] - thrust force
%   D [ bore minor major ] - dimensions of the shaft

bore  = dimensions(1); % size needed for the screw
minor = dimensions(2); % bottom of thread

% split the forces array for use in equations
Mz  = forces(9);

% moment of inertia of a hollow circle
Ix = pi/4 * (minor^4 - bore^4);

% assume that max occurs on top surface
Sx  = 0;
Sy  = Mz * minor/Ix; % bending of the shaft
Sz  = 0;
txy = 0;
txz = 0;
tyz = 0;

% cauchy stress tensor
tensor = [ Sx  txy txz;
           txy Sy  tyz;
           txz tyz Sz ];
end

%--------------------------------------------------
%   LOG
%--------------------------------------------------

function shaftLog(n, nReq, weight, thread)
%SHAFTLOG Outputs useful data to the log file
%   SHAFTLOG(n, nReq, weight, thread) returns nothing

logFile = 'groupRE3_LOG.txt';
logFolder = fullfile('../Log');
MATLABFolder = fullfile('../MATLAB');

cd(logFolder)
fid = fopen(logFile, 'a+');

% lines of the file
fprintf(fid, '\r\n***Thruster Shaft***\r\n');
fprintf(fid, ['Safety Factor: ' num2str(n) ]);

% display a message if the safety factor couldn't be acheived
if n < nReq
    fprintf(fid, ' ****This does not meet safety Factor\r\n');
else
    fprintf(fid, '\r\n');
end

fprintf(fid, ['Weight:        ' num2str(weight) ' g\r\n']);
fprintf(fid, ['Thread size:   M' num2str(thread) '\r\n']);

fclose(fid);
cd(MATLABFolder)
end

%--------------------------------------------------
%   SOLIDWORKS
%--------------------------------------------------

function shaftSW(radius, length)
%SHAFTSW Outputs data to solidworks for the arm
%   SHAFTSW(radius) returns nothing

SWBracFile = '2011-MOTOR-BRACKET4-EQUATIONS.txt';
SWShaftFile = '2015-SHAFT.txt';
SWPropFile = '2017-PROPELLER-ENCASEMENT-EQUATIONS.txt';
SWMotFile = '2018-MOTOR-MOUNTING-PLATE-EQUATIONS.txt';
SWIRaceFile = '2023.1-INNER_RACE-EQUATIONS.txt';
SWORaceFile = '2023.2-OUTTER_RACE-EQUATIONS.txt';
SWBallFile = '2023.3-BALL.txt';
SWWashFile = '2024-WASHER2-EQUATIONS.txt';
SWNutFile = '2025-NUT-EQUATIONS.txt';
MATLABFolder = fullfile('../MATLAB');
SWFolder = fullfile('../Solidworks/Equations');

% write to the different solidworks files
cd(SWFolder)
fid = fopen(SWBracFile, 'w+t');
fprintf(fid, ['"rshaft"= ' num2str(radius*1000) 'mm\n']);
fclose(fid);
fid = fopen(SWShaftFile, 'w+t');
fprintf(fid, ['"rshaft"= ' num2str(radius*1000) 'mm\n']);
fprintf(fid, ['"LS1"= ' num2str(length*1000-12.21666771) 'mm\n']);
fclose(fid);
fid = fopen(SWPropFile, 'a+');
fprintf(fid, ['"rshaft"= ' num2str(radius*1000) 'mm\r\n']);
fclose(fid);
fid = fopen(SWMotFile, 'w+t');
fprintf(fid, ['"rshaft"= ' num2str(radius*1000) 'mm\n']);
fclose(fid);
fid = fopen(SWIRaceFile, 'w+t');
fprintf(fid, ['"rshaft"= ' num2str(radius*1000) 'mm\n']);
fclose(fid);
fid = fopen(SWORaceFile, 'w+t');
fprintf(fid, ['"rshaft"= ' num2str(radius*1000) 'mm\n']);
fclose(fid);
fid = fopen(SWBallFile, 'w+t');
fprintf(fid, ['"rshaft"= ' num2str(radius*1000) 'mm\n']);
fclose(fid);
fid = fopen(SWWashFile, 'w+t');
fprintf(fid, ['"rshaft"= ' num2str(radius*1000) 'mm\n']);
fclose(fid);
fid = fopen(SWNutFile, 'w+t');
fprintf(fid, ['"rshaft"= ' num2str(radius*1000) 'mm\n']);
fclose(fid);
cd ..
cd(MATLABFolder)
end