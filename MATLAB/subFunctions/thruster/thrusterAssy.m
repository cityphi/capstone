function [ weight ] = thrusterAssy( thrusterWeight, battMass, radius )
%THRUSTERASSY Get total weight of thruster assy
%   THRUSTERASSY returns the CG of the thruster assembly
%   
%   thrusterWeight - is the weight of thruster
%   battMass - mass of the battery
%   radius - radius of the propeller

% get the mass dat from the file
massData = csvread('weightData.csv', 1);
references = massData(:, 5) == 1;
massData(~references, :) = [];
massData(:, 2:4) = massData(:, 2:4)/1000;

% add the weight of the chosen battery
massData(massData(:, 1) == -1) = battMass;

% get the weight from mass
weight = [massData(:, 1)*9.81/1000 massData(:, 2:4)];  

% add thruster CG and find total CG
weight(end+1, :) = thrusterWeight;
weight = centreMass(weight);
weight(3) = weight(3) + radius;

% LOG file
thrusterAssyLog(round(weight(1)*2*1000/9.81, 1));
end

%--------------------------------------------------
%   LOG
%--------------------------------------------------

function thrusterAssyLog(mass)
%THRUSTERASSYLOG Outputs useful data to the log file
%   THRUSTERASSYLOG(mass) returns nothing

logFile = 'groupRE3_LOG.txt';
logFolder = fullfile('../Log');
MATLABFolder = fullfile('../MATLAB');

% append to the file
cd(logFolder)
fid = fopen(logFile, 'a+');
fprintf(fid, '\r\n***Thruster Assembly***\r\n');
fprintf(fid, ['Total Mass: ' num2str(mass) ' g\r\n']);
fclose(fid);
cd(MATLABFolder)
end