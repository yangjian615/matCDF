%**************************************************************************
% NAME:
%       MrCDF_EpochToDatenum
%
% PURPOSE:
%   Convert any CDF epoch type to a time vector. This function serves as
%   a wrapper for the following functions:
%       spdfbreakdownepoch
%       spdfbreakdownepoch
%       spdfbreakdowntt2000
%
% Calling Sequence:
%   TIMEVEC = MrCDF_Epoch_Breakdown(T_EPOCH);
%       Breakdown a CDF epoch time T_EPOCH into date/time components
%       TIMEVEC.
%
% :Params:
%   EPOCH:          in, required, type=any
%                   CDF Epoch time of unknown epoch type. Valid CDF Epoch
%                       types include::
%                           'CDF_EPOCH'         - Double
%                           'CDF_EPOCH16'       - Double complex
%                           'CDF_TIME_TT2000'   - INT64
%
% :Returns:
%   TIMEVEC:        A 10xN array, where N represents the number of elements
%                       in `EPOCH`. The rows contain::
%                           YEAR
%                           MONTH
%                           DAY
%                           HOUR
%                           MINUTE
%                           SECOND
%                           MILLISECOND
%                           MICROSECOND (zeros for CDF_EPOCH)
%                           NANOSECOND  (zeros for CDF_EPOCH)
%                           PICOSECOND  (zeros for CDF_EPOCH and CDF_TIME_TT2000)
%
% MATLAB Releases:
%    7.14.0.739 (R2012a)
%
% Required Products:
%    CDF MatLab Patch v3.5.1 - http://cdf.gsfc.nasa.gov/html/matlab_cdf_patch.html
%
% History:
%    2014-11-29  -  Written by Matthew Argall
%    2015-03-18  -  Updated to use CDF Patch v3.5.1. Removed TYPE parameter. - MRA
%
%**************************************************************************
function [timevec] = MrCDF_Epoch_Breakdown(t_epoch, epoch_type)
    
	% Determine the epoch type if it was not given
	if nargin == 1
		epoch_type = MrCDF_Epoch_Type(t_epoch);
	end

	% Breakdown the epoch value
	switch epoch_type
		case 'CDF_EPOCH'
			% Convert from Epoch to Datenum to Datestr
			timevec = spdfbreakdownepoch(t_epoch);
			timevec = [timevec; ...
			           zeros(3, length(timevec(1,:)))]; % micro-, nano-, pico-seconds 

		case 'CDF_EPOCH16'
			timevec = spdfbreakdownepoch16(t_epoch);


		case 'CDF_TIME_TT2000'
			timevec = spdfbreakdowntt2000(t_epoch);
			timevec = [timevec; ...
			           zeros(1, length(timevec(1,:)))];	% picoseconds

		otherwise
			error('Input TYPE must be "CDF_EPOCH", "CDF_EPOCH16" or "CDF_TIME_TT2000".')
	end
end