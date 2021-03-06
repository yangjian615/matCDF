%
% Name
%   MrCDF_epoch2sse
%
% Purpose
%   Convert CDF epoch data since seconds since a specified epoch time.
%
% Calling Sequence
%   T_SSE = MrCDF_epoch2sse(T_EPOCH)
%       Convert a CDF epoch time, T_EPOCH, to seconds since epoch, T_SSE,
%       where the new epoch begins at T_EPOCH(1).
%
%   T_SSE = MrCDF_epoch2sse(T_EPOCH, T_REF)
%       Instead of using T_EPOCH(1) as the new base epoch time, use T_REF.
%       T_REF must be the same epoch type as T_EPOCH.
%
%   T_SSE = MrCDF_epoch2sse(__ EPOCH_TYPE)
%       Specify the epoch type, EPOCH_TYPE, of T_EPOCH as a character array.
%       Options are: 'CDF_EPOCH', 'CDF_EPOCH16', or 'CDF_TIME_TT2000'.
%       EPOCH_TYPE can be used with any of the calling sequences above.
%
% :Examples:
%   Create 10 seconds of data, convert epoch type, then to SSE.
%     datetime = repmat( [2015 03 18 0 0], 10, 1 );
%     second   = (1:1:10)';
%     datetime = [datetime second]
% 
%     t_epoch   = spdfcomputeepoch(   [datetime, zeros(10, 1)] );
%     t_epoch16 = spdfcomputeepoch16( [datetime, zeros(10, 4)] );
%     t_tt2000  = spdfcomputett2000(  [datetime, zeros(10, 3)] );
% 
%     MrCDF_epoch2sse(t_epoch)'
%     ans =
%         0     1     2     3     4     5     6     7     8     9
%     MrCDF_epoch2sse(t_epoch16)'
%     ans =
%         0     1     2     3     4     5     6     7     8     9
%     MrCDF_epoch2sse(t_tt2000)'
%     ans =
%         0  1  2  3  4  5  6  7  8  9 
%
% Parameters
%   T_EPOCH          in, required, type = 'CDF_EPOCH', 'CDF_EPOCH16', or 'CDF_TIME_TT2000'
%   T_REF            in, optional, type = same as T_EPOCH
%   EPOCH_TYPE       in, required, type = string, default = check T_EPOCH
%
% Required Products:
%    CDF MatLab Patch v3.5.1 - http://cdf.gsfc.nasa.gov/html/matlab_cdf_patch.html
%
% MATLAB release(s) MATLAB 7.14.0.739 (R2012a)
% Required Products None
%
% History:
%   2015-03-07      Written by Matthew Argall
%   2015-08-24      Simplified parameter checks. - MRA
%
function t_sse = MrCDF_epoch2ssm(t_epoch, varargin)

	% Declare variables
	t_ref      = [];
	epoch_type = '';

	% Optional parameters
	if nargin == 3
		% t_sse = MrCDF_epoch2sse(t_epoch, t_ref, 'epoch_type')
		epoch_type = varargin{2};
		t_ref      = varargin{1};
	elseif nargin == 2
		% t_sse = MrCDF_epoch2sse(t_epoch, 'epoch_type')
		if ischar(varargin{1})
			epoch_type = varargin{1};
			t_ref      = t_epoch(1);
		% t_sse = MrCDF_epoch2sse(t_epoch, t_ref)
		else
			epoch_type = MrCDF_Epoch_Type(t_epoch(1));
			t_ref      = varargin{1};
		end
	end
	
	% Defaults
	if isempty(epoch_type)
		epoch_type = MrCDF_Epoch_Type(t_epoch);
	end
	if isempty(t_ref)
		% Epoch16 values are Nx2 doubles, other types are Nx1.
		if strcmp(epoch_type, 'CDF_EPOCH16')
			t_ref = t_epoch(1,:);
		else
			t_ref = t_epoch(1);
		end
	end
	
	% Convert to seconds since epoch
	switch epoch_type
		case 'CDF_EPOCH'
			t_sse = (t_epoch - t_ref) .* 1e-3;
			
		case 'CDF_EPOCH16'
			t_sse = ( t_epoch(:,1) - t_ref(1,1) ) + ...
			        ( t_epoch(:,2) - t_ref(1,2) ) .* 1e-12;

		case 'CDF_TIME_TT2000'
			t_sse = double( t_epoch - t_ref ) .* 1e-9;
			
		otherwise
			error( ['Epoch type "' epoch_type '" is not recognized.'] );
	end
end