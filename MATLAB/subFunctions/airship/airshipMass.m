function [ totalMass, fixedMass, gondolaMass ] = airshipMass( thrusterMass, envMass, radius )
%AIRSHIPMASS Gets the mass of the total mass of the airship
%   AIRSHIPMASS( thrusterMass, envMass, radius ) returns the different
%   masses and the total mass of the airship.
%   
%   thrusterMass [mag locx locy locz] - mass of entire thruster assembly
%   envMass [mag locx locy locz] - mass of plastic and helium
%   radius - radius of the airship

% get the mass from the file of the fixed masses (ref = 5)
fixedData = csvread('weightData.csv', 1);
references = fixedData(:, 5) == 5;
fixedData(~references, :) = [];
fixedData(:) = fixedData(:)/1000;
fixedData(:, 4) = fixedData(:, 4) + radius;
fixedMass = fixedData(:, 1:4);
fixedMass = [fixedMass; thrusterMass; envMass];


% get the mass from the file of the gondola masses (ref = 10)
gondolaMass = csvread('weightData.csv', 1);
references = gondolaMass(:, 5) == 10;
gondolaMass(~references, :) = [];
gondolaMass(:) = gondolaMass(:)/1000;

%---OUPUTS
fixedMass = centreMass(fixedMass);
gondolaMass = centreMass(gondolaMass);
totalMass = fixedMass(1) + gondolaMass(1);
end