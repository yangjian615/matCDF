%--------------------------------------------------------------------------
% Purpose
%   Find the record numbers associated with a particular time interval.
%
% Calling Sequence:
%    RECRANGE = MrCDF_Time_RecNum(FILENAME, TIMEVAR)
%        Return the 0-based record range RECRANGE for the CDF Epoch
%        variable identified by TIMEVAR. FILENAME is the name of the CDF
%        file.
%
%    RECRANGE = MrCDF_Time_RecNum(..., STIME)
%        Specify the start of the time interval for which the record range
%        is to be returned. It must have format: 'yyyy-mm-ddThh:mm:ss'.
%
%    RECRANGE = MrCDF_Time_RecNum(..., STIME, ETIME)
%        Specify the end of the time interval for which the record range
%        is to be returned. It is not necessary to specify STIME with
%        ETIME. ETIME must have format: 'yyyy-mm-ddThh:mm:ss'.
%
%    [RECRANGE, TIME] = MrCDF_Time_RecNum(__)
%        Return a vector of TIMEs within the given interval.
%
% Parameters:
%    FILENAME:        in, required, type = char
%    TIMEVAR:         in, required, type = char
%    STIME:           in, optional, type = char
%    ETIME:           in, optional, type = char
%
% Returns:
%    RECRANGE:        out, required, type = 1x2 int64
%    TIME:            out, optional, type = A CDF Epoch type
%
% MATLAB Releases:
%    7.14.0.739 (R2012a)
%
% Required Products:
%    CDF MatLab Patch v3.5.1 - http://cdf.gsfc.nasa.gov/html/matlab_cdf_patch.html
%
% History:
%    2014-11-29  -  Written by Matthew Argall
%--------------------------------------------------------------------------
function [recrange, time] = MrCDF_Time_RecNum(file, timevar, sTime, eTime)

	% Read the time variable's data
	time = spdfcdfread(file,                     ...
	                  'Variables',      timevar, ...
	                  'KeepEpochAsIs',  true,    ...
	                  'CombineRecords', true);

	% Identify the epoch time
	epoch_type = MrCDF_Epoch_Type(time(1));

	% Convert input interval to the proper epoch type
	sTime_epoch = MrCDF_Epoch_Parse(sTime, epoch_type);
	eTime_epoch = MrCDF_Epoch_Parse(eTime, epoch_type);

	% Return a subinterval of the data?
	nRecs    = length(time);
	recrange = [1 nRecs];
	if ~isempty(sTime)
		recrange(1) = find(time >= sTime_epoch, 1);
	end
	if ~isempty(eTime)
		recrange(2) = find(time <= eTime_epoch, 1, 'last');
	end

	% Cut out the unwanted times.
	time = time(recrange(1):recrange(2));

	% Convert to 0-based record
	recrange = recrange - 1;
end
    