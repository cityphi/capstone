function [propChoice, motChoice, badness] = propeller (reqSpeed, dragValues, maxPower)
%PROPELLER Chooses a propeller motor combinatio based on inputs
%   PROPELLER returns the propeller size and weight, all the parameters
%   about the motor, and the 'badness' of the choice.
%   Badness is a percentage off from the required value
%
%   reqSpeed - the desired speed of the airship
%   dragValues [ CD rho vol ] - values used for drag
%   maxMass - a limit on the mass of the motor and propeller
%   maxPower - a limit of the watts used by the motor

% file
propCSV = 'propellerMotorData.csv';
propData = csvread(propCSV, 1, 1);
propData(:, ~any(propData, 2)) = [];

% remove data points with power that are too large
if maxPower
	powerCondition = propData(:, 5) > maxPower;
	propData(powerCondition, :) = [];
end

% check if there was no data that could match those inputs
if isempty(propData)
    error('MotorData.InvalidInputs')
end

% formatting of command window
needNewLine = 0;

% setup data array unique combinations of pitch and diameter
pitchDiameters = unique(propData(:, 2:3), 'rows');

% data - [P D Vmax Vzero RPM(at start) Power]
data = zeros(size(pitchDiameters, 1), 6);
data(:, 1:2) = sortrows(pitchDiameters,[-1 -2]);

possibleSpeed = reqSpeed;
while 1
	% finding the required parameters for each pitch-diamter combination
	Vzero = possibleSpeed + 5;
    for i = 1:size(data, 1)
	    % since it is sorted reduce the speed by 5 to accelerate the process
	    Vzero = Vzero - 5;
	    
	    % looping variables
	    maxIterations = 100; iterations = 0;
	    
	    % increase the max velocity until it has enough force at desired speed
        while iterations < maxIterations
	        iterations = iterations + 1;
	    
	        % equations use m
	        D = data(i, 1) * 0.0254;
	        P = data(i, 2) * 0.0254;
	        
	        % the max rotations is when thrust is 0
	        nm = Vzero/(0.2*D+0.74*P);
	        
	        % relate it to the test data
	        nStart = 0.9*nm;
	        
	        % max speed based on the thrust line and drag curve
	        Vmax = airshipSpeed(D, P, nStart, dragValues);
	    
	        % check if attained a max speed
            if Vmax < possibleSpeed
	            Vzero = Vzero + 1;
	        else
	            data(i, 3) = nStart * 60; % convert to RPM at start
	            break
            end
        end
    end

	%--MATCH to one of the experimental data sets
	possibleMot = zeros(size(propData, 1), size(propData, 2));

	% check to see if any experimental data meets the calculated requirements
	for i = 1:size(propData, 1)
	    index = find(ismember(data(:, 1:2), propData(i, 2:3), 'rows'), 1);
	    if data(index, 3) < propData(i, 6)
	        possibleMot(i, :) = propData(i, :);
	    end
	end

	% remove any empty rows and sort the possible data
	possibleMot(~any(possibleMot, 2), :) = [];

	% check if any combination was possible
    if ~isempty(possibleMot)
	    break
    else
        needNewLine = 1;
        if possibleSpeed == reqSpeed
			possibleSpeed = possibleSpeed - 0.5;
			fprintf(['Reduced required speed to: ' num2str(possibleSpeed)]);
		else
			possibleSpeed = possibleSpeed - 0.5;
			fprintf([' -- ' num2str(possibleSpeed)]);
        end
    end
end

if needNewLine
    fprintf('\n');
end
% sort the motor based on the watts required to get the best
possibleMot = sortrows(possibleMot, 5);

%--OUTPUTS
% return the choices and the badness
badness = (reqSpeed - possibleSpeed)/reqSpeed;
propChoice = [possibleMot(1, 2:3) possibleMot(1, 9)];
motChoice = possibleMot(1, :);
end