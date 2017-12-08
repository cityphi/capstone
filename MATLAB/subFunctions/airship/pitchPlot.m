function pitches = pitchPlot(fixedMass, gondolaMass, CV, airshipRad)
%PITCHPLOT Finds the pitch angle of the airship and plot the values
%   PITCHPLOT(fixedMass, gondolaMass, CV, airshipRad) returns the pitch
%   data of the airship
%
%   fixedMass - fixed masses form solidworks
%   gondolaMass - mass of the gondola
%   CV - the location of the centre of volume relative to the thruster arms
%   airshipRad - the radius of the airship


points = 100; % number of points for graph
keelDist = 0.0027; % roughly an inch
radius = 0.637; % keel radius
fixedMass(2) = fixedMass(2) - CV;

distanceStep = 3/(points);
data = zeros(points+1, 2);

gondolaReference = gondolaMass(2:4);

for i = 1:(points+1);
    loc = distanceStep*(i-1); % Actual distance on keel
    gondolaMass(2:4) = gondola(loc, keelDist, radius, CV, gondolaReference, airshipRad);
    CG = centreMass([fixedMass; gondolaMass]);

    pitch = atan(CG(2)/CG(4)) * 180/pi; % Use CV and CG to get pitch

    % Fix for if angle greater than -90
    if i > 1
        if (pitch > 0) && (data(i-1, 2) < 0);
            pitch = pitch - 180;
        end
    end

    % Record the results from each pass
    data(i,:) = [loc pitch];
end

pitches = [min(data(:, 2)) max(data(:, 2))];

% Information to output
scatter(data(:,1), data(:,2), 'h');
title('Pitch angle relative to the gondola')
xlabel('Distance along the Keel (m)');
ylabel('Pitch angle (deg)');
end

%----------------------------------------
%   GONDOLA POSITION
%----------------------------------------

function pos = gondola(loc, keelDist, radius, CV, gondolaReference, airshipRad)
%Finds a x-z coordinate based on distance traveled along the keel

% flat section of the keel
if loc <= 2
    x = loc - 1;
    z = -(airshipRad+keelDist);

% curved section of the keel
elseif loc > 2
    x = 1 + radius*sin((loc-2)/radius);
    z = -(radius*cos((loc-2)/radius) + keelDist) + radius - airshipRad;
    
% incase of weird scenario
else
    x = 0; z = 0;
end

x = x - CV + gondolaReference(1);
y = gondolaReference(2);
z = z + gondolaReference(3);
pos = [x, y, z];
end