function [ n ] = cauchy( s, material )
%CAUCHY uses cauchy tensor to get a safety factor
%   n = cauchy(s, M) takes the cauchy tensor s and material information 
%   to calculate the safety factor.
%
%   For Brittle:
%   Use the the Mohr-Coulomb failure model adapted for brittle materials. 
%   It uses the cauchy tensor to get the three principal stresses then uses
%   them to find the safety factor. (uses Sut, Suc)
% 
%   For Ductile:
%   Use von Mises with the three primary stresses found to get a safety
%   factor for the part. (uses Sy)
%
%   s - tensor of form:
%   | Sx  txy txz |
%   | txy Sy  tyz |
%   | txz tyz Sz  |
%   material [density Sut Suc Sy E brittle] - of the material information

% convert material to easy to read
Sut = material(2);
Suc = material(3);
Sy  = material(4);
brittle = material(end);

% coefficients of the charateristic equation
I1 = trace(s);
I3 = det(s);
I2 = s(1, 1)*s(2, 2) + s(2, 2)*s(3, 3) + s(1, 1)*s(3, 3) - s(1, 2)^2 - ...
    s(2, 3)^2 - s(3, 1)^2;

% characteristic equation
char = [-1 I1 -I2 I3];

% get the roots and find the sigmas
charRoots = roots(char);
s1 = max(charRoots);
s3 = min(charRoots);
s2 = I1 - s1 - s3;

switch brittle
    % brittle-mohr-coulomb (Shigley, 227)
    case 1
        if s1 >= 0 && s3 >= 0
            n = Sut/s1;

        elseif s1 >= 0 && s3 <= 0
            n = Sut*Suc/(Suc*s1-Sut*s3);

        else
            n = -Suc/s3;
        end
        
    % von Mises (Shigley, 216)
    case 0
        sPrime = sqrt(((s1 - s2)^2 + (s2 - s3)^2 + (s3 - s1)^2)/2);
        n = Sy/sPrime;
end
end