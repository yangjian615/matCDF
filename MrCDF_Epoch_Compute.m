%**************************************************************************
% NAME:
%       MrCDF_Epoch_Compute
%
% PURPOSE:
%   Compute CDF epoch times in CDF_EPOCH, CDF_EPOCH16, and CDF_TIME_TT2000
%   formats. This is a wrapper for the spdfcomputeepoch, spdfcomputeepoch16
%   and spdfcomputett2000 routines. Added features include:
%
%     * The TIMEVEC time vector requires only YEAR, MONTH, and DAY.
%       Additional time descriptors (hour, millisecond, etc.) are optional.
%     * TIMEVEC can be specified out to the pico-second for all CDF types.
%       The result will be truncated for CDF_TIME_TT2000 and CDF_EPOCH.
%
%
% CALLING SEQUENCE:
%   T_EPOCH = MrCDF_Epoch_Compute(timevec);
%       Convert a date/time vector to a vector of CDF_TIME_TT2000 times,
%       T_EPOCH.
%
%   T_EPOCH = MrCDF_Epoch_Compute(TIMEVEC, EPOCH_TYPE);
%       Convert a date/time vector to a vector to the CDF epoch type
%       identified by EPOCH_TYPE.
%
% :Examples:
%   Convert a time vector to CDF_TIME_TT2000:
%     >> MrCDF_Epoch_Compute([2015, 03, 18])
%     ans =
%        479908867184000000
%
%   Convert a time vector to CDF_EPOCH:
%     >> MrCDF_Epoch_Compute([2015, 03, 18], 'CDF_EPOCH')
%     ans =
%                63593856000000
%
%   Convert a time vector to CDF_EPOCH16:
%     >> MrCDF_Epoch_Compute([2015, 03, 18], 'CDF_EPOCH16')
%     ans =
%                63593856000
%
% :Params:
%   TIMEVEC:        in, required, type=any
%                   CDF Epoch time.
%   EPOCH_TYPE:     in, optional, type=string, default='CDF_TIME_TT2000'
%                   The CDF epoch type of `EPOCH`. CDF Epoch types and
%                     their corresponding MATLAB datatypes are::
%                       'CDF_EPOCH'         - Double
%                       'CDF_EPOCH16'       - Double complex
%                       'CDF_TIME_TT2000'   - INT64
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
%    2015-03-18  -  Written by Matthew Argall
%
%**************************************************************************
function t_epoch = MrCDF_Epoch_Compute(timevec, epoch_type)
    
	% Determine the epoch type if it was not given
	if nargin() == 1
		epoch_type = 'CDF_TIME_TT2000';
	end
    
	% Size of each dimension
	dims = size(timevec);
	assert( dims(2) >=  3, 'TIMEVEC must contain at least YEAR, MONTH, DATE.');
	assert( dims(2) <= 10, 'TIMEVEC can have at most 10 columns');


	% Breakdown the epoch value
	switch upper(epoch_type)
	%-----------------------------------------------------%
	% CDF_EPOCH \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%-----------------------------------------------------%
		case 'CDF_EPOCH'
			% Pad the time vector with zeros
			if dims(2) < 7
				nAdd    = 7 - dims(2);
				timevec = [ timevec zeros(dims(1), nAdd) ];
				
			% Remove micro-, nano-, pico-seconds
			elseif dims(2) > 7
				timevec = timevec(:, 1:7);
			end
			
			% Compute epoch
			t_epoch = spdfcomputeepoch(timevec);

	%-----------------------------------------------------%
	% CDF_EPOCH16 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%-----------------------------------------------------%
		case 'CDF_EPOCH16'
			% Pad the time vector with zeros
			if dims(2) < 10
				nAdd    = 10 - dims(2);
				timevec = [ timevec zeros(dims(1), nAdd) ];
			end
			
			% Compute epoch
			t_epoch = spdfcomputeepoch16(timevec);
			
	%-----------------------------------------------------%
	% CDF_TIME_TT2000 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%-----------------------------------------------------%
		case 'CDF_TIME_TT2000'
			% Pad the time vector with zeros
			if dims(2) < 9
				nAdd    = 9 - dims(2);
				timevec = [ timevec zeros(dims(1), nAdd) ];
				
			% Remove pico-seconds
			elseif dims(2) > 9
				timevec = timevec(:, 1:9);
			end
			
			% Compute epoch
			t_epoch = spdfcomputett2000(timevec);

		otherwise
			error('EPOCH_TYPE must be "CDF_EPOCH", "CDF_EPOCH16" or "CDF_TIME_TT2000".')
	end
end