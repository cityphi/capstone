function [rotated] = rotate(in, xz, yz, scenario, n)
%rotate will rotate loactions,forces and moments based on angles inputed
%   inputs:
%       -in - force array with rows formated as specified below 
%       -xz  - angle of rotation about y
%       -yz - angle of rotation about x
%       -scenario - rotation case as specified below 
%       -n - number of forces (row) 
%scenario1 just locations rotated
%scenario2 just forces and moments rotated
%scenario3 rotate entire row 
%scenario4 just locations of second gondola rotated
%scenario5 just forces and moments of second gondola rotated

temp = in;
rotated = temp;
i=1;
if scenario == 1
    if yz ~= 0
        for i = 1:n
            rotated(i,2) = cos(yz)*temp(i,2) + sin(yz)*temp(i,3);
            rotated(i,3) = cos(yz)*temp(i,3) + sin(yz)*temp(i,2);
        end
    end

    if xz ~= 0
        for i = 1:n
            rotated(i,1) = cos(xz)*temp(i,1) + sin(xz)*temp(i,3);
            rotated(i,3) = cos(xz)*temp(i,3) + sin(xz)*temp(i,1);
        end
    end
end

if scenario == 2
    if yz ~= 0
        for i = 1:n
            rotated(i,5) = cos(yz)*temp(i,5) + sin(yz)*temp(i,6);
            rotated(i,6) = cos(yz)*temp(i,6) + sin(yz)*temp(i,5);
            rotated(i,8) = cos(yz)*temp(i,8) + sin(yz)*temp(i,9);
            rotated(i,9) = cos(yz)*temp(i,9) + sin(yz)*temp(i,7);
        end
    end

    if xz ~= 0
        for i = 1:n
            rotated(i,4) = cos(xz)*temp(i,4) + sin(xz)*temp(i,6);
            rotated(i,6) = cos(xz)*temp(i,6) + sin(xz)*temp(i,4);
            rotated(i,7) = cos(xz)*temp(i,7) + sin(xz)*temp(i,9);
            rotated(i,9) = cos(xz)*temp(i,9) + sin(xz)*temp(i,7);
        end
    end
end

if scenario == 3
    if yz ~= 0
        for i = 1:n
            rotated(i,2) = cos(yz)*temp(i,2) + sin(yz)*temp(i,3);
            rotated(i,3) = cos(yz)*temp(i,3) + sin(yz)*temp(i,2);
            rotated(i,5) = cos(yz)*temp(i,5) + sin(yz)*temp(i,6);
            rotated(i,6) = cos(yz)*temp(i,6) + sin(yz)*temp(i,5);
            rotated(i,8) = cos(yz)*temp(i,8) + sin(yz)*temp(i,9);
            rotated(i,9) = cos(yz)*temp(i,9) + sin(yz)*temp(i,8);
        end
    end
 
    if xz ~= 0
        for i = 1:n
            rotated(i,1) = cos(xz)*temp(i,1) + sin(xz)*temp(i,3);
            rotated(i,3) = cos(xz)*temp(i,3) + sin(xz)*temp(i,1);
            rotated(i,4) = cos(xz)*temp(i,4) + sin(xz)*temp(i,5);
            rotated(i,6) = cos(xz)*temp(i,6) + sin(xz)*temp(i,4);
            rotated(i,7) = cos(xz)*temp(i,7) + sin(xz)*temp(i,9);
            rotated(i,9) = cos(xz)*temp(i,9) + sin(xz)*temp(i,7);
        end
    end
end

if scenario == 4 
    if yz ~= 0
        for i = 1:n
            if mod(i,2) == 0
                rotated(i,2) = cos(yz)*temp(i,2) + sin(yz)*temp(i,3);
                rotated(i,3) = cos(yz)*temp(i,3) + sin(yz)*temp(i,2);
            end
        end
    end

    if xz ~= 0
        for i = 1:n
            if mod(i,2) == 0
                rotated(i,1) = cos(xz)*temp(i,1) + sin(xz)*temp(i,3);
                rotated(i,3) = cos(xz)*temp(i,3) + sin(xz)*temp(i,1);
            end
        end
    end
end
if scenario == 5
    if yz ~= 0
        for i = 1:n
            if mod(i,2) == 0
                rotated(i,2) = cos(yz)*temp(i,2) + sin(yz)*temp(i,3);
                rotated(i,3) = cos(yz)*temp(i,3) + sin(yz)*temp(i,2);
                rotated(i,5) = cos(yz)*temp(i,5) + sin(yz)*temp(i,6);
                rotated(i,6) = cos(yz)*temp(i,6) + sin(yz)*temp(i,5);
                rotated(i,8) = cos(yz)*temp(i,8) + sin(yz)*temp(i,9);
                rotated(i,9) = cos(yz)*temp(i,9) + sin(yz)*temp(i,8);
            end
        end
    end

    if xz ~= 0
        for i = 1:n
            if mod(i,2) == 0
                rotated(i,1) = cos(xz)*temp(i,1) + sin(xz)*temp(i,3);
                rotated(i,3) = cos(xz)*temp(i,3) + sin(xz)*temp(i,1);
                rotated(i,4) = cos(xz)*temp(i,4) + sin(xz)*temp(i,6);
                rotated(i,6) = cos(xz)*temp(i,6) + sin(xz)*temp(i,4);
                rotated(i,7) = cos(xz)*temp(i,7) + sin(xz)*temp(i,9);
                rotated(i,9) = cos(xz)*temp(i,9) + sin(xz)*temp(i,7);
            end
        end
    end
end

end