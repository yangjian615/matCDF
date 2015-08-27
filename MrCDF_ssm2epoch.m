%
% Name
%   MrCDF_ssm2epoch
%
% Purpose
%   Convert seconds since midnight the specified epoch type.
%
% Calling Sequence
%   T_EPOCH = MrCDF_epoch2sse(T_SSM, DATE)
%       Convert time T_SSM in seconds since midnight on date DATE
%       to a CDF epoch value of type CDF_TIME_TT2000. EPOCH_TYPE may be:
%       'CDF_EPOCH', 'CDF_EPOCH16', or 'CDF_TIME_TT2000'.
%
%   T_EPOCH = MrCDF_epoch2sse(..., EPOCH_TYPE)
%       Convert to a specific CDF epoch type, EPOCH_TYPE. Options are:
%       'CDF_EPOCH', 'CDF_EPOCH16', or 'CDF_TIME_TT2000'.
%
%
% :Examples:
%   Convert 02:00 on today's date from seconds since midnight to each epoch type.
%     t_ssm = 7200;
%     date  = datestr( now(), 'yyyy-mm-dd' );
% 
%     t_epoch   = MrCDF_ssm2epoch( t_ssm, date, 'CDF_EPOCH' );
%     t_epoch16 = MrCDF_ssm2epoch( t_ssm, date, 'CDF_EPOCH16' );
%     t_tt2000  = MrCDF_ssm2epoch( t_ssm, date, 'CDF_TIME_TT2000' );
% 
%     t_utc = spdfencodeepoch(t_epoch)
%         '24-Aug-2015 02:00:00.000'
%     t_utc = spdfencodeepoch16(t_epoch16)
%         '24-Aug-2015 02:00:00.000.000.000.000'
%     t_utc = spdfencodett2000(t_tt2000)
%         '2015-08-24T02:00:00.000000000'
%
% Parameters
%   T_SSM            in, required, type=double
%   DATE             in, required, type=char
%   EPOCH_TYPE       in, optional, type=char, default='CDF_TIME_TT2000'
%
% Required Products:
%    CDF MatLab Patch v3.5.1 - http://cdf.gsfc.nasa.gov/html/matlab_cdf_patch.html
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-08-24      Written by Matthew Argall
%
function t_epoch = MrCDF_ssm2epoch(t_ssm, date, epoch_type)

	nTimes = length(t_ssm);
	
	% Default epoch type
	if nargin < 3
		epoch_type = 'CDF_TIME_TT2000';
	end

	% Convert the date to a date vector
	if ischar( date )
		dvec = datevec(date, 'yyyy-mm-dd');
	else
		dvec = MrCDF_Epoch_Breakdown(date, epoch_type);
	end
	
	% Length of the date vector
	%   - We will have to add a certain number of zeros, depending
	%     on EPOCH_TYPE, so that we can compute the associated epoch.
	ndvec = length(dvec);
	
	% Append the correct number of zeros
	switch epoch_type
		case 'CDF_EPOCH'
			t0      = spdfcomputeepoch( [dvec zeros(nTimes, 7-ndvec)] );
			t_epoch = (t_ssm * 1e3) + t0;
		case 'CDF_EPOCH16'
			t0      = spdfcomputeepoch16( [dvec zeros(nTimes, 10-ndvec)] );
			pico    = fix( mod(t_ssm, 1) * 1e12 ) + t0(1,2);
			seconds = fix(t_ssm) + t0(1,1);
			t_epoch = [seconds pico];
		case 'CDF_TIME_TT2000'
			t0      = spdfcomputett2000( [dvec zeros(nTimes, 9-ndvec)] );
			t_epoch = int64( t_ssm * 1e9 ) + t0;
		otherwise
			error(['Unknown epoch type: "' epoch_type '".'])'
	end
end