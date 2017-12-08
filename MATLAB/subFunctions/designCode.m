function warningMessage = designCode( requirements, scenario, l, FR, handles )
%DESIGNCODE Runs the analysis of the airship
%   DESIGNCODE(requirements, scenario, l, FR, handles) returns a warning
%   message for the GUI to output if needed.
%
%   requirements [ reqSpeed reqTime reqWeight ] - required from main
%   scenario - dominant parameter
%   l - length (tip to tip) of the airship
%   FR - fineness ratio of the airship
%   handles - GUI parameter

%---SET VALUES
% M [ density Sut Suc Sy E brittle ] - information of the material
carbon       = [1600 600*10^6  570*10^6 0        70*10^9    1]; % ACP
aluminum6061 = [2700 310*10^6  0        276*10^6 68.9*10^9  0]; % matweb
nylon6       = [1130 69*10^6   44*10^6  63*10^6  2.33*10^9  1]; % matweb
steel316     = [8000 550*10^6  0        240*10^6 193*10^9   0]; % matweb
nylon12      = [1130 38.5*10^6 6*10^6   28*10^6  1.138*10^9 1]; % stratasys

% density of air
rhoAir = 1.225; % Engineering Tooblox

%---INPUTS
% split the requirements
reqSpeed = requirements(1); %m/s
reqTime = requirements(2)/60; %h
reqWeight = requirements(3); %g

% files
battCSV = 'batteryData.csv';
propCSV = 'propellerMotorData.csv';
battData = csvread(battCSV, 1, 1);
propData = csvread(propCSV, 1, 1);

% optimization values setup
battMasses = sort(unique(battData(:, 2)), 1);
[uniqueVolts, ~, count] = unique(battData(:, 5));
battMassVolts = zeros(max(count), 2);
battVolts = [battData(:, 2) battData(:, 5)];
for i = 1:max(count)
    massVolts = battVolts(battVolts(:, 2) == uniqueVolts(i), :);
    battMassVolts(i, :) = min(massVolts);
end
motPowers = sort(unique(propData(:, 5)), 1);
massLimitBatt = 0;
powerLimitMot = 0;

%---MAIN
fprintf('\n\n~~~STARTING~~~\n');

% warning message case
warningMessage = 0;

while 1;
    % ENVELOPE
    [vol, envMass, airshipRad, CD, CV] = envelope(l, FR);
    
    % THRUSTER
    dragValues = [CD rhoAir vol];
    
    % pick propeller and battery
    [propChoice, motChoice, motBadness] = propeller(...
        reqSpeed, dragValues, powerLimitMot);
    [battChoice, battBadness] = battery(...
        reqTime, motChoice(5)/motChoice(4), motChoice(4), massLimitBatt);

    % returns useful data and writes to files
    [thrusterMass, battMass, FTmax, propRadius, time, speed] = ...
        battMotPropData(propChoice, motChoice, battChoice, dragValues);

    % optimize the shaft
    [thrusterWeight, thrusterDist] = ...
        thrusterShaft(FTmax, thrusterMass, propRadius, nylon6);
    % change reference to centre of the thrusters
    thrustForceLoc = [ 0 thrusterDist+0.04572+airshipRad 0 ];

    % get the total weight of one thruster assy relative to thrusters
    thrusterWeight = thrusterAssy(thrusterWeight, battMass, airshipRad);

    % ARM
    [thrusterWeight, thrusterMass] = ...
        arm(FTmax, thrustForceLoc, thrusterWeight, airshipRad, carbon);
    connector(FTmax, thrusterWeight, airshipRad, aluminum6061);

    % MASS
    [totalMass, fixedMass, gondolaMass] = ...
        airshipMass(thrusterMass, envMass, airshipRad);
    
    carryingMass = vol*rhoAir - totalMass;
    weightBadness = (reqWeight - carryingMass*1000)/reqWeight;
    if weightBadness < 0
        weightBadness = 0;
    end
    
    % set the weight to be attached to the gondola
    if carryingMass < 0
    	carryingMassGondola = 0;
    elseif carryingMass > 0.5;
        carryingMassGondola = 0.5;
    else
        carryingMassGondola = carryingMass;
    end
    
    % GONDOLA
    gondolaAnalysis(FTmax/totalMass, carryingMassGondola, steel316, nylon12);
    
    % OPTIMIZING
    switch scenario
        case 1 % weight
            % break if the weight meets specifications
            if weightBadness == 0
				break
            else
                indexBatt = find(battMasses == battChoice(2));
                indexPower = find(motPowers == motChoice(5));
                
                % change the motor or the battery until mass is achieved
                if motBadness > battBadness
                    if indexBatt ~= 1
                        massLimitBatt = battMasses(indexBatt-1);
                    else
                        % if the battery is as already the smallest
                        if indexPower ~= 1
                            powerLimitMot = motPowers(indexPower-1);
                        else
                            warningMessage = 1;
                            break
                        end
                    end
                else
                    if indexPower ~= 1
                        powerLimitMot = motPowers(indexPower-1);
                    else
                        if indexBatt ~= 1
                            massLimitBatt = battMasses(indexBatt-1);
                        else
                            warningMessage = 1;
                            break
                        end
                    end
                end
            end
        case 2 % speed
        	% need atleast 200g of carrying capacity
            if carryingMass < 0.2
            	% find the weight of the battery currently
                indexBatt = find(battMasses == battChoice(2));

                % only run if the battery is not already the smallest
                if indexBatt ~= 1
                	% set the max mass for the battery choice
                    massLimitBatt = battMasses(indexBatt - 1);
                    possibleBatt = battMassVolts;
                    voltsCondition = battMassVolts(:, 2) < motChoice(4);
                    possibleBatt(voltsCondition, :) = [];
                    if massLimitBatt <= min(possibleBatt(:, 1))
                        warningMessage = 2;
                        break
                    end
                else
                    warningMessage = 2;
                    break
                end
            else
                if motBadness <= 0
                    if weightBadness <= battBadness
                        break
                    else
                        indexBatt = find(battMasses == battChoice(2));
                        if indexBatt ~= 1
                            massLimitBatt = battMasses(indexBatt-1);
                        else
                            break
                        end
                    end
                else
                    warningMessage = 3;
                    break
                end
            end
        case 3 % time
            % if the time is acheived break
            if carryingMass < 0.2
                % reduce the limit of power on the motors
                indexPower = find(motPowers == motChoice(5));
                if indexPower ~= 1
                    powerLimitMot = motPowers(indexPower-1);
                else
                    % if no smaller motors break
                    warningMessage = 3;
                    break
                end
            else
                if battBadness <= 0
                    break
                else
                    % reduce the limit of power on the motors
                    indexPower = find(motPowers == motChoice(5));
                    if indexPower ~= 1
                        powerLimitMot = motPowers(indexPower-1);
                    else
                        % if no smaller motors break
                        warningMessage = 3;
                        break
                    end
                end
            end
            
    end
end
% override message if the carrying capcity is negative
if carryingMass < 0
    warningMessage = 10;
end

%---PLOTS
% drag speed plot
axes(handles.axes1);
D = propChoice(1)*0.0254;
P = propChoice(2)*0.0254;
n = motChoice(6)/60;
Vp = 0:0.1:round(speed+3);
Tp = 0.20477*(pi*D^2)/4*(D/P)^1.5*((P * n)^2 - Vp*P * n)*2;
dragp = 2.420294 * CD * rhoAir * vol^(2/3) * Vp.^1.86;
plot(Vp, Tp, Vp, dragp);
title('Drag and Thrust with changing velocity')
xlabel('Velocity of airship (m/s)');
ylabel('Force (N)');
legend('Thrust','Drag')

% pitches plot
axes(handles.axes2);
gondolaMass(1) = gondolaMass(1) + carryingMassGondola;
pitches = pitchPlot(fixedMass, gondolaMass, CV, airshipRad);

%---LOG
finalLog(speed, time, carryingMass, pitches)

%---DISPLAY
set(handles.textCarryMass, 'String', ...
    ['Carrying Mass: ' num2str(round(carryingMass*1000, 1)) 'g']);
set(handles.textMaxSpeed, 'String', ...
    ['Max Speed: ' num2str(round(speed, 1)) 'm/s']);
set(handles.textFlightTime, 'String', ...
    ['Flight Time: ' num2str(round(time, 1)) 'mins']);
set(handles.textPitchUp, 'String', ...
    ['Max Pitch Up: ' num2str(round(pitches(2), 1)) '°']);
set(handles.textPitchDown , 'String', ...
    ['Max Pitch Down: ' num2str(round(pitches(1), 1)) '°']);
fprintf('\n~~Design code finished. Solidworks and Log files have been updated.\n');

end