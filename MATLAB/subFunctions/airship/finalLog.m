function finalLog(speed, time, mass, pitches)
%FINALLOG Outputs useful data to the log file
%   FINALLOG(speed, time) returns nothing

logFile = 'groupRE3_LOG.txt';
logFolder = fullfile('../Log');
MATLABFolder = fullfile('../MATLAB');

cd(logFolder)
fid = fopen(logFile, 'a+');

% lines of the file
fprintf(fid, '\r\n***Achieved Parameters***\r\n');
fprintf(fid, ['Max Speed = ' num2str(round(speed, 1)) 'm/s\r\n']);
fprintf(fid, ['Flight Time = ' num2str(round(time, 1)) 'mins\r\n']);
fprintf(fid, ['Carrying Capacity = ' num2str(round(mass*1000, 1)) 'g\r\n']);
fprintf(fid, ['Max pitch up: ' num2str(pitches(2)) ', max pitch down: ' num2str(pitches(1))]);

fclose(fid);
cd(MATLABFolder)
end

