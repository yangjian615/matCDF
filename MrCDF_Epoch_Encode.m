%--------------------------------------------------------------------------
% Name:
%    MrCDF_Epoch_Encode
%
% Purpose
%   Encode a CDF Epoch time value into a string. This serves as a wrapper
%   for::
%        spdfencodeepoch
%        spdfencodeepoch16
%        spdfencodett2000
%
% Calling Sequence:
%    EPOCH_STRING = MrCDF_Epoch_Encode(t_epoch)
%        Convert CDF epoch times T_EPOCH to a cell array of strings
%        EPOCH_STRING formatted in the following manner:
%            CDF_EPOCH        -  'yyyy-mm-ddThh:mm:ss.mmm'
%            CDF_EPOCH16      -  'yyyy-mm-ddThh:mm:ss.mmmuuunnnppp'
%            CDF_TIME_TT2000  -  'yyyy-mm-ddThh:mm:ss.mmmuuunnn'
%
% Parameters:
%    T_EPOCH:         in, required, type = A CDF Epoch type
%
% Returns:
%    EPOCH_STING:     out, required, type = cell
%
% MATLAB Releases:
%    7.14.0.739 (R2012a)
%
% Required Products:
%    CDF MatLab Patch v3.5.1 - http://cdf.gsfc.nasa.gov/html/matlab_cdf_patch.html
%
% History:
%    2014-11-29  -  Written by Matthew Argall
%
%--------------------------------------------------------------------------
function epoch_string = MrCDF_Epoch_Encode(t_epoch)
	
	% Determine the epoch type
	epoch_type = MrCDF_Epoch_Type(t_epoch(1));
	
	% Encode
	%   Return all in format 'yyyy-mm-ddThh:mm:ss.mmm[uuunnn[ppp]]'
	switch epoch_type
		case 'CDF_EPOCH'
			epoch_string = spdfencodeepoch(t_epoch,   'Format', 4);
		case 'CDF_EPOCH16'
			epoch_string = spdfencodeepoch16(t_epoch, 'Format', 4);
		case 'CDF_TIME_TT2000'
			epoch_string = spdfencodett2000(t_epoch,  'Format', 3);
	end
end