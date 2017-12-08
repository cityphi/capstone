function [battChoice, badness] = battery( reqTime, minAmps, minVolts, maxMass )
%BATTERY Chooses a battery based on the inputs
%   BATTERY( reqTime, minAmps, minVolts, maxMass ) returns a parameterises
%   battery to be used in the analysis
%
%   reqTime - required flying time
%   minAmps - minimum discharge amps of the battery
%   minVolts - minimum voltage of the battery
%   maxMass - maximum mass of the battery

% file
battCSV = 'batteryData.csv';
battData = csvread(battCSV, 1, 1);
battData(:, ~any(battData, 1)) = [];

% command window
needNewLine = 0;

%--DATA LOADING
% AMPS
% remove batteries which can't output enough amps
ampsCondition = battData(:, 4) < minAmps;
battData(ampsCondition, :) = [];

% MASS
% only load in batteries that are under the mass limit

if maxMass
    massCondition = battData(:, 2) > maxMass;
    battData(massCondition, :) = [];
end

% VOLTS
% remove batteries without enough cells
if minVolts
	voltsCondition = battData(:, 5) < minVolts;
	battData(voltsCondition, :) = [];
end

% end the function if battery data didn't meet inputs
if isempty(battData)
    error('BatteryData.InvalidInputs');
end
    
%--LIFE
possibleTime = reqTime;
while 1
    battLife = minAmps * possibleTime * 1000;
    possibleBatt = battData;
    
	% remove any batteries with life that doesn't meet requirement
	possibleBatt(possibleBatt(:, 3) < battLife, :) = [];

	% check if a battery met the specification
    if ~isempty(possibleBatt)
	    break
    else
        needNewLine = 1;
        if possibleTime == reqTime;
            possibleTime = possibleTime - 2/60;
            if possibleTime <= 0
                possibleTime = 0.1/60;
            end
            fprintf(['Reduced life to: ' num2str(possibleTime*60)]);
        else
            possibleTime = possibleTime - 2/60;
            if possibleTime <= 0
                possibleTime = 0.1/60;
            end
            fprintf([' -- ' num2str(possibleTime*60)]);
        end
    end
end
if needNewLine
    fprintf('\n');
end

%--OUTPUT
% sort and return the best battery and the badness
badness = (reqTime - possibleTime)/reqTime;
possibleBatt = sortrows(possibleBatt, 2);
battChoice = possibleBatt(1, :);
end