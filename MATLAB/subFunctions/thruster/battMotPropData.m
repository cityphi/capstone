function [ thrustMass, battMass, thrust, radius, time, speed ] = battMotPropData( propChoice, motChoice, battChoice, dragValues )
%BATTMOTPROPDATA Gives useful data about the battery, motor, propeller
%   BATTMOTPROPDATA( propChoice, motChoice, battChoice ) takes the data arrays
%   and transforms it into easy to access data for the main function. It also
%   writes to the log and solidworks files.

battCSV = 'batteryData.csv';
propCSV = 'propellerMotorData.csv';

% get the name of the motor chosen
propFile = fopen(propCSV);
motorNames = textscan(propFile, '%s%*[^\n]', 'Delimiter', ',', ...
    'HeaderLines', 1);
fclose(propFile);

% get the name of the battery chosen
battFile = fopen(battCSV);
batteryNames = textscan(battFile, '%s%*[^\n]', 'Delimiter', ',', ...
    'HeaderLines', 1);
fclose(battFile);

% Propeller name; Motor name; Battery name
names = [[int2str(propChoice(1)) 'x' int2str(propChoice(2))];
         motorNames{1, 1}(motChoice(1));
         batteryNames{1, 1}(battChoice(1))];

%--OUTPUT
% LOG file
% setup the values that need to be in the log files
propData = propChoice(3);
motData  = [motChoice(12) motChoice(10) motChoice(5) motChoice(4) motChoice(7)];
battData = [battChoice(2) battChoice(3) battChoice(5) battChoice(6)];

% write to the log file
thrusterLog( names, propData, motData, battData );

% MAIN returns
thrustMass = motData(1) + propData(1);
battMass = battData(1);
thrust = motChoice(7);
radius = propChoice(1) * 0.5 * 0.0254;
amps = motChoice(5)/motChoice(4)*1000;
time = battChoice(3)/amps*60;
% get the top speed with this setup
D = propChoice(1) * 0.0254;
P = propChoice(2) * 0.0254;
speed = airshipSpeed(D, P, motChoice(6)/60, dragValues);

% write to the solidworks file
thrusterSW(propChoice(1), battChoice(end), battChoice(end-2), battChoice(end-1));
end

%--------------------------------------------------
%   LOG
%--------------------------------------------------

function thrusterLog( names, propChoice, motChoice, battChoice )
%THRUSTERLOG writes to the log files of the program
%   THRUSTERLOG(names, mot, prop, batt) does not return anything
%   names - [prop mot batt]
%   propChoice - [weight]
%   motChoice - [weight KV power Volts topSpeed thrust]
%   battChoice - [weight mAh Volts discharge]

logFile = 'groupRE3_LOG.txt';
logFolder = fullfile('../Log');
MATLABFolder = fullfile('../MATLAB');

% convert to char
propName = char(names(1));
motName  = char(names(2));
battName = char(names(3));

cd(logFolder)
fid = fopen(logFile, 'a+');
% lines of the file
fprintf(fid, '\n***Thruster Selection***\r\n');
fprintf(fid, ['Propeller - APC E ' propName '\r\n']);
fprintf(fid, ['\tWeight: ' num2str(propChoice(1)) ' g\r\n']);

fprintf(fid, ['Motor - ' motName '\n']);
fprintf(fid, ['\tWeight: ' num2str(motChoice(1)) ' g\r\n']);
fprintf(fid, ['\tVolts:  ' num2str(motChoice(4)) ' V\r\n']);
fprintf(fid, ['\tKV:     ' num2str(motChoice(2)) ' RPM/V\r\n']);
fprintf(fid, ['\tPower:  ' num2str(motChoice(3)) ' W\r\n']);
fprintf(fid, ['\tThrust: ' num2str(motChoice(5)) ' N\r\n']);


fprintf(fid, ['Battery - ' battName '\r\n']);
fprintf(fid, ['\tWeight:    ' num2str(battChoice(1)) ' g\r\n']);
fprintf(fid, ['\tCapacity:  ' num2str(battChoice(2)) ' mAh\r\n']);
fprintf(fid, ['\tVoltage:   ' num2str(battChoice(3)) ' V\r\n']);
fprintf(fid, ['\tDischarge: ' num2str(battChoice(4)) ' C\r\n']);
fclose(fid);
cd(MATLABFolder)

end

%--------------------------------------------------
%   SOLIDWORKS
%--------------------------------------------------

function thrusterSW(diameter, battH, battL, battW)
%THRUSTERSW Outputs data to solidworks for the arm
%   THRUSTERSW(diameter, battH, battL, battW) returns nothing

diameter = diameter * 0.0254 * 1000;

SWPropFile = '2016-PROPELLER-EQUATIONS.txt';
SWPropCaseFile = '2017-PROPELLER-ENCASEMENT-EQUATIONS.txt';
SWCovFile = '2013-COMPONENT-COVER-EQUATIONS.txt';
SWDoorFile = '2014-COMPONENT-COVER-DOOR-EQUATIONS.txt';
SWBattFile = '5006-BATTERY2-EQUATIONS.txt';
MATLABFolder = fullfile('../MATLAB');
SWFolder = fullfile('../Solidworks/Equations');

% incasse the battery is smaller than the other components in the case
if battW < 24
    battW = 24;
end
if battL < 58;
    battL = 58;
end

% write to the different solidworks files
cd(SWFolder)
fid = fopen(SWPropFile, 'w+t');
fprintf(fid, ['"propdiameter"= ' num2str(diameter) 'mm\n']);
fclose(fid);
fid = fopen(SWPropCaseFile, 'w+t');
fprintf(fid, ['"propdiameter"= ' num2str(diameter) 'mm\n']);
fclose(fid);
fid = fopen(SWCovFile, 'w+t');
fprintf(fid, ['"batteryheighttwo"= ' num2str(battH) 'mm\n']);
fprintf(fid, ['"batterylengthtwo"= ' num2str(battL) 'mm\n']);
fprintf(fid, ['"batterywidthtwo"= ' num2str(battW) 'mm\n']);
fclose(fid);
fid = fopen(SWDoorFile, 'w+t');
fprintf(fid, ['"batteryheighttwo"= ' num2str(battH) 'mm\n']);
fprintf(fid, ['"batterylengthtwo"= ' num2str(battL) 'mm\n']);
fprintf(fid, ['"batterywidthtwo"= ' num2str(battW) 'mm\n']);
fclose(fid);
fid = fopen(SWBattFile, 'w+t');
fprintf(fid, ['"batteryheighttwo"= ' num2str(battH) 'mm\n']);
fprintf(fid, ['"batterylengthtwo"= ' num2str(battL) 'mm\n']);
fprintf(fid, ['"batterywidthtwo"= ' num2str(battW) 'mm\n']);
fclose(fid);
cd ..
cd(MATLABFolder)
end