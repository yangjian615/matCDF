%
% Name
%   MrCDF_epoch2ssm
%
% Purpose
%   Convert CDF epoch data since seconds since midnight on the
%   date of a specified epoch time.
%
% Calling Sequence
%   T_SSM = MrCDF_epoch2sse(T_EPOCH)
%       Convert a CDF epoch time, T_EPOCH, to seconds since epoch, T_SSE,
%       where the new epoch begins at T_EPOCH(1).
%
%   T_SSM = MrCDF_epoch2sse(T_EPOCH, T_REF)
%       Instead of using T_EPOCH(1) as the new base epoch time, use T_REF.
%       T_REF must be the same epoch type as T_EPOCH.
%
%   T_SSM = MrCDF_epoch2sse(__ EPOCH_TYPE)
%       Specify the epoch type, EPOCH_TYPE, of T_EPOCH as a character array.
%       Options are: 'CDF_EPOCH', 'CDF_EPOCH16', or 'CDF_TIME_TT2000'.
%       EPOCH_TYPE can be used with any of the calling sequences above.
%
% :Examples:
%   Create 10 seconds of data, convert epoch type, then to SSE.
%     t0 = datevec( now() );
%     t0 = [t0(1:3) 2 0 0];
% 
%     t_epoch   = spdfcomputeepoch(   [t0, zeros(1, 1)] );
%     t_epoch16 = spdfcomputeepoch16( [t0, zeros(1, 4)] );
%     t_tt2000  = spdfcomputett2000(  [t0, zeros(1, 3)] );
% 
%     t_ssm = MrCDF_epoch2ssm(t_epoch)
%             7200
%     t_ssm = MrCDF_epoch2ssm(t_epoch16)
%             7200
%     t_ssm = MrCDF_epoch2ssm(t_tt2000)
%             7200
%
% Parameters
%   T_EPOCH          in, required, type = 'CDF_EPOCH', 'CDF_EPOCH16', or 'CDF_TIME_TT2000'
%   T_REF            in, optional, type = same as T_EPOCH
%   EPOCH_TYPE       in, optional, type = string, default = check T_EPOCH
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
function t_ssm = MrCDF_epoch2ssm(t_epoch, varargin)

	% Declare variables
	t_ref      = [];
	epoch_type = '';

	% Optional parameters
	if nargin == 3
		% t_sse = MrCDF_epoch2ssm(t_epoch, t_ref, 'epoch_type')
		epoch_type = varargin{2};
		t_ref      = varargin{1};
	elseif nargin == 2
		% t_sse = MrCDF_epoch2ssm(t_epoch, 'epoch_type')
		if ischar(varargin{1})
			epoch_type = varargin{1};
		% t_sse = MrCDF_epoch2ssm(t_epoch, t_ref)
		else
			t_ref = varargin{1};
		end
	end
	
	% Defaults
	if isempty(epoch_type);
		epoch_type = MrCDF_Epoch_Type(t_epoch);
	end
	if isempty(t_ref)
		if strcmp(epoch_type, 'CDF_EPOCH16')
			t_ref = t_epoch(1,:);
		else
			t_ref = t_epoch(1);
		end
	end
	
	% Find midnight, then recompute
	dvec = MrCDF_Epoch_Breakdown( t_ref, epoch_type );
	t0   = MrCDF_Epoch_Compute( dvec(:,1:3), epoch_type );

	% Convert to seconds since epoch
	switch epoch_type
		case 'CDF_EPOCH'
			t_ssm = (t_epoch - t0) .* 1e-3;
			
		case 'CDF_EPOCH16'
			t_ssm = ( t_epoch(:,1) - t0(1,1) ) + ...
			        ( t_epoch(:,2) - t0(1,2) ) .* 1e-12;

		case 'CDF_TIME_TT2000'
			t_ssm = double( t_epoch - t0 ) .* 1e-9;
			
		otherwise
			error( ['Epoch type "' epoch_type '" is not recognized.'] );
	end
end