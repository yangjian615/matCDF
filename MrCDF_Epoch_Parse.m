%--------------------------------------------------------------------------
% Name:
%    MrCDF_Epoch_Parse
%
% Purpose
%    Parse a time string into CDF Epoch values. This is a wrapper for the
%    following functions:
%        spdfparseepoch
%        spdfparseepoch16
%        spdfparsett2000
%
% Calling Sequence:
%    T_EPOCH = MrCDF_Epoch_Encode(TIME, TYPE)
%        Convert time strings TIME to the CDF Epoch type TYPE. See the
%        above functions for acceptable formats for TIME. The recommended
%        format is:
%            CDF_EPOCH        -  'yyyy-mm-ddThh:mm:ss.mmm'
%            CDF_EPOCH16      -  'yyyy-mm-ddThh:mm:ss.mmmuuunnnppp'
%            CDF_TIME_TT2000  -  'yyyy-mm-ddThh:mm:ss.mmmuuunnn'
%
% Parameters:
%    TIME:        in, required, type = char or cell
%    EPOCH_TYPE:  in, optional, type = char
%                 Valid CDF Epoch types are:
%                     CDF_EPOCH
%                     CDF_EPOCH16
%                     CDF_TIME_TT2000
%
% Returns:
%    T_EPOCH:     out, required, type = varies
%                 CDF Epoch times have the following types:
%                     CDF_EPOCH        -  double
%                     CDF_EPOCH16      -  double complex
%                     CDF_TIME_TT2000  -  int64
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
function t_epoch = MrCDF_Epoch_Parse(time, epoch_type)
	
	% Default to converting to CDF_TIME_TT2000 times.
	if isempty(epoch_type)
		epoch_type = 'CDF_TIME_TT2000';
	end
	
	% Parse
	switch upper(epoch_type)
		case 'CDF_EPOCH'
			t_epoch = spdfparseepoch(time);
		case 'CDF_EPOCH16'
			t_epoch = spdfparseepoch16(time);
		case 'CDF_TIME_TT2000'
			t_epoch = spdfparsett2000(time);
		otherwise
			error('TYPE must be {"CDF_EPOCH" | "CDF_EPOCH16" | "CDF_TIME_TT2000"}.');
	end
end