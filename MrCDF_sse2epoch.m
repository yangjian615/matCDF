%
% Name:
%   MrCDF_sse2epoch
%
% Purpose:
%   Convert time in seconds since a specified epoch time to CDF epoch
%   values.
%
% Calling Sequence:
%   T_EPOCH = MrCDF_epoch2sse(T_SSE, T_REF)
%       Convert a time in seconds since some epoch, T_SSE, where "some
%       epoch" is a CDF epoch time given by T_REF, to CDF epoch times,
%       T_EPOCH. T_EPOCH will be the same CDF type as T_REF.
%
%   T_SSE = MrCDF_epoch2sse(T_EPOCH, T_REF, EPOCH_TYPE)
%       Specify the epoch type of T_REF. If EPOCH_TYPE is not give, it will
%       be determined from the class and size of T_REF. Options for
%       EPOCH_TYPE are 'CDF_EPOCH', 'CDF_EPOCH16', or 'CDF_TIME_TT2000'.
%
% Examples:
%   Create CDF epoch times, convert to SSE, then convert back to epoch.
%     datetime = repmat( [2015 03 18 0 0], 10, 1 );
%     second   = (1:1:10)';
%     datetime = [datetime second];
% 
%     t_epoch   = spdfcomputeepoch(   [datetime, zeros(10, 1)] );
%     t_epoch16 = spdfcomputeepoch16( [datetime, zeros(10, 4)] );
%     t_tt2000  = spdfcomputett2000(  [datetime, zeros(10, 3)] );
% 
%     t_sse_epoch   = MrCDF_epoch2sse(t_epoch);
%     t_sse_epoch16 = MrCDF_epoch2sse(t_epoch16);
%     t_sse_tt2000  = MrCDF_epoch2sse(t_tt2000);
% 
%     t_ep = MrCDF_sse2epoch(t_sse_epoch,   t_epoch(1));
%     t_16 = MrCDF_sse2epoch(t_sse_epoch16, t_epoch16(1,:));
%     t_tt = MrCDF_sse2epoch(t_sse_tt2000,  t_tt2000(1));
%
%     t_epoch' == t_ep'
%     ans =
%            1     1     1     1     1     1     1     1     1     1
%     t_epoch16' == t_16'
%     ans =
%            1     1     1     1     1     1     1     1     1     1
%            1     1     1     1     1     1     1     1     1     1
%     t_tt2000' == t_tt'
%     ans =
%            1     1     1     1     1     1     1     1     1     1
%
% :Parameters:
%   T_EPOCH          in, required, type = 'CDF_EPOCH', 'CDF_EPOCH16', or 'CDF_TIME_TT2000'
%   T_REF            in, required, type = same as T_EPOCH
%   EPOCH_TYPE       in, optional, type = string
%
% Required Products:
%    CDF MatLab Patch v3.5.1 - http://cdf.gsfc.nasa.gov/html/matlab_cdf_patch.html
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-07      Written by Matthew Argall
%
function t_epoch = MrCDF_sse2epoch(t_sse, t_ref, epoch_type)

	% Epoch type
	if nargin < 3
		epoch_type = MrCDF_Epoch_Type(t_ref);
	end
	
	% Convert to seconds since epoch
	switch epoch_type
		case 'CDF_EPOCH'
			t_epoch = (t_sse * 1e3) + t_ref;
			
		case 'CDF_EPOCH16'
			pico    = fix( mod(t_sse, 1) * 1e12 ) + t_ref(1,2);
			seconds = fix(t_sse) + t_ref(1,1);
			t_epoch = [seconds pico];

		case 'CDF_TIME_TT2000'
			t_epoch = int64( t_sse * 1e9 ) + t_ref;
	end
end