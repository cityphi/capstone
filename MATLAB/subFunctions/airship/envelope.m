function [ volume, mass, radius, CD, CV ] = envelope( l, FR )
%ENVELOPE Calculates the dimensions of the envelope
%   [V, m, r, CD] = envelope( l, FR ) returns properties of the envelope
%   based on set restrictions and the parameters given as the input.
%   
%   l - length of the airship
%   FR - fineness ratio

% engineeringtoolbox - STP
rhoH = 0.1664;

% angle of the cone at back of blimp
alpha = 10*pi()/180;

% Diameter and radius of front
D = l/FR;
rf = D/2;

% get the dimensions
L = @(a) rf - (-(rf - a*sin(alpha))^2/(sin(alpha)^2 - 1))^(1/2) ...
    *(sin(alpha) - 1) + a*(cos(alpha) + 1); % used matlab to simplify
a = fzero(@(a) L(a) - l, 0);
re = rf - a*sin(alpha);
r = sqrt((re/tan(pi()/2-alpha))^2+re^2);
h = r*(1 - cos(pi()/2-alpha));

% volume of the system
vol(1, 1) = 2*pi()*rf^3 / 3;
vol(2, 1) = rf^2*pi()*a;
vol(3, 1) = pi()*a*cos(alpha)*(rf^2 + rf*re + re^2) / 3;
vol(4, 1) = pi()*h*(3*re^2 + h^2) / 6;

% CGs ref at centre of cylinder
x(1, 1) = a/2 + 4*rf/(3*pi());
x(2, 1) = 0; % reference point
x(3, 1) = -(a/2 + a*cos(alpha)/4 * (rf^2 + 2*rf*re + 3*rf^2)/(rf^2 + rf*re + rf^2));
x(4, 1) = -(a/2 + a*cos(alpha) + 3/4*(2*r - h)^2/(3*r - h) + h - r);

% SA to estiamte mass
SA(1, 1) = 2*pi()*rf^2;
SA(2, 1) = 2*pi()*rf*a;
SA(3, 1) = pi()*(rf + re)*sqrt((rf - re)^2 + a*cos(alpha));
SA(4, 1) = pi()*(re^2 + h^2);

% original approximation of envelope
SAOrig = 4*pi()*0.637 + 2*2*pi()*0.637;
areaMass = 0.525/SAOrig;

massHelium = vol(:)*rhoH;
massPlastic = SA(:)*areaMass;

mass = [ (massHelium + massPlastic) x zeros(4, 1) zeros(4, 1)];

%---FINS
densityFoam = 36;
xFin = -(a/2 + a*cos(alpha)*2/3);
massFin = 2*a^2*cos(alpha)*sin(alpha)*0.003*densityFoam;

%--OUTPUTS
CD = 0.00092642*FR^2 - 0.010134*FR + 0.040569;

volume = sum(vol);
mass = centreMass(mass);
CV = mass(2) + 1 - a/2;
mass(end+1,:) = [massFin xFin 0 0];

% relate the CM to the thrusters
mass = centreMass(mass);
mass(2) = mass(2) + 1 - a/2;
radius = rf;

%--LOG
envelopeLog(l, FR, D, CD, volume, sum(massHelium), sum(massPlastic), mass(2))

%--SOLIDWORKS
envelopeSW(radius, a)
end

%----------------------------------------
%   LOG
%----------------------------------------

function envelopeLog(L, FR, D, CD, vol, massHelium, massPlastic, CM)
%ENVELOPELOG Outputs useful data to the log file
%   ENVELOPELOG(n, nReq, mass, thread) returns nothing

logFile = 'groupRE3_LOG.txt';
logFolder = fullfile('../Log');
MATLABFolder = fullfile('../MATLAB');

cd(logFolder)
fid = fopen(logFile, 'w+t');

% lines of the file
fprintf(fid, '***Envelope***\n');
fprintf(fid, ['Using a FR of ' num2str(FR) ' and L of ' num2str(L) 'm gives a D of ' num2str(D) 'm.\n']);
fprintf(fid, ['This corresponds to a CD of ' num2str(CD) '.\n']);
fprintf(fid, ['With a volume of ' num2str(vol) 'm^3 which is ' num2str(round(massHelium*1000, 1)) 'g of helium.\n']);
fprintf(fid, ['Approximately ' num2str(round(massPlastic*1000, 1)) 'g of plastic.\n']);
fprintf(fid, ['Centre of mass at ' num2str(round(CM*1000, 1)) 'mm (in x) from the centre of the thrusters\n']);

fclose(fid);
cd(MATLABFolder)
end

%----------------------------------------
%   SOLIDWORKS
%----------------------------------------

function envelopeSW(radius, length)
%ENVELOPESW Outputs data to solidworks for the envelope
%   ENVELOPESW(radius, length) returns nothing

SWEnvFile = '1001-ENVELOPE-EQUATIONS.txt';
MATLABFolder = fullfile('../MATLAB');
SWFolder = fullfile('../Solidworks/Equations');

% write to the different solidworks files
cd(SWFolder)
fid = fopen(SWEnvFile, 'w+t');
fprintf(fid, ['"rblimp" = ' num2str(radius*1000) 'mm\n']);
fprintf(fid, ['"lblimpcylinder"= ' num2str(length*1000) 'mm\n']);
fclose(fid);
cd ..
cd(MATLABFolder)
end