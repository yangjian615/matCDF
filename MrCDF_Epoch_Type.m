%**************************************************************************
% NAME:
%       MrCDF_EpochType
%
% PURPOSE:
%   Determine the type of CDF Epoch
%
% CALLING SEQUENCE:
%   epoch_type = MrCDF_Epoch(filename);
%       Return the CDF epoch type.
%
% :Params:
%   EPOCH:          in, required, type=any
%                   CDF Epoch time of unknown epoch type.
%   TYPE:           in, optional, type=string
%                   The CDF epoch type of `EPOCH`. If not given, the epoch
%                       type will be determined automatically. CDF Epoch
%                       types and their corresponding MATLAB datatypes
%                       are::
%                           'CDF_EPOCH'         - Double
%                           'CDF_EPOCH16'       - Double complex
%                           'CDF_TIME_TT2000'   - INT64
%
% :Returns:
%   EPOCH_TYPE:     CDF Epoch type.
%
% MATLAB Releases:
%    7.14.0.739 (R2012a)
%
% Required Products:
%    CDF MatLab Patch v3.5.1 - http://cdf.gsfc.nasa.gov/html/matlab_cdf_patch.html
%
% :History:
%   2015-03-15  -  spdfcomputeepoch returns an Nx1 vector while
%                  spdfcomputeepoch16 returns an Nx2 vector. Use this to
%                  distinguish between the two epoch types. - MRA
%
%**************************************************************************
function [epoch_type] = MrCDF_Epoch_Type(t_epoch)

	% Determine the datatype of the epoch value
	datatype = class(t_epoch);

	% What is the epoch type
	switch datatype

	%-----------------------------------------------------%
	% CDF_EPOCH or CDF_EPOCH16 \\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%-----------------------------------------------------%
		case 'double'
		%-----------------------------------------------------%
		% CDF v3.5.1 or Later \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
		%-----------------------------------------------------%
			% Check dimensions
			dims = size(t_epoch);
		
			% After CDF v3.5.1, CDF_EPOCH16 is an Nx2 array
			if MrCDF_Version_Compare('3.5.1') <= 0
				assert( dims(2) <= 2, 'Cannot determine epoch type. Nx1 or Nx2 array expected.');

				% Check type
				if dims(2) == 2
					epoch_type = 'CDF_EPOCH16';
				else
					epoch_type = 'CDF_EPOCH';
				end

		%-----------------------------------------------------%
		% CDF Before v3.5.1  \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
		%-----------------------------------------------------%
			else
				% Before CDF v3.5.1, CDF_EPOCH16 is a 2xN array.
				assert( dims(1) <= 2, 'Cannot determine epoch type. 1xN or 2xN array expected.');
				
				% Check type
				if dims(1) == 2
					epoch_type = 'CDF_EPOCH16';
				else
					epoch_type = 'CDF_EPOCH';
				end
			end

	%-----------------------------------------------------%
	% CDF_TIME_TT2000 \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%-----------------------------------------------------%
		case 'int64'
			epoch_type = 'CDF_TIME_TT2000';

		otherwise
			error(['Datatype "', datatype, '" is not a valid CDF Epoch type.']);
	end
end