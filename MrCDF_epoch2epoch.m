%
% Name:
%   MrCDF_epoch2epoch
%
% Purpose:
%   Convert one CDF epoch type to another.
%
% Calling Sequence:
%   T_OUT = MrCDF_epoch2sse(T_EPOCH, TYPE_OUT)
%     Convert a CDF epoch time vector T_EPOCH to the CDF epoch type
%     identified by TYPE_OUT. If TYPE_OUT
%
% Parameters:
%   T_EPOCH:      in, required, type=double/int64
%   TYPE_OUT:     in, required, type=char
%
% Returns:
%   T_OUT:        out, required, type=double/int64
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
function t_out = MrCDF_epoch2epoch(t_epoch, type_out)
	
	% Epoch type
	type_in = MrCDF_Epoch_Type(t_epoch);
	
	% No conversion necessary
	if strcmpi(type_in, type_out)
		t_out = t_epoch;

	% Convert
	else
		% Convert to a generalized time vector.
		timevec = MrCDF_Epoch_Breakdown(t_epoch);

		% Convert to the desired ouptut epoch type.
		t_out = MrCDF_Epoch_Compute(timevec, type_out);
	end
end