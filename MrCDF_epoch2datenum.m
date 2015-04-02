%**************************************************************************
% NAME:
%       MrCDF_epoch2datenum
%
% PURPOSE:
%   Convert any CDF epoch type to MatLab datenum. This function serves as
%   a wrapper for the following functions:
%       epochtodatenum
%       epoch16todatenum
%       tt2000todatenum
%
% CALLING SEQUENCE:
%   datenumber = MrCDF_epoch2datenum(T_EPOCH);
%       Converts CDF epoch times T_EPOCH to MatLab's DATENUMBER.
%
% :Params:
%   EPOCH:          in, required, type=any
%                   CDF Epoch time. CDF Epoch types map to the following
%                   MATLAB types::
%                       'CDF_EPOCH'         - Double
%                       'CDF_EPOCH16'       - Double complex
%                       'CDF_TIME_TT2000'   - int64
%
% :Returns:
%   DATENUM:        out, required, type = double
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
%**************************************************************************
function [datenumber] = MrCDF_epoch2datenum(t_epoch)
    
    % Determine the epoch type
		type = MrCDF_EpochType(t_epoch(1));
    
    % Breakdown the epoch value
    switch type
        case 'CDF_EPOCH'
            datenumber = epochtodatenum(t_epoch);
            
        case 'CDF_EPOCH16'
            datenumber = epoch16todatenum(t_epoch);
            
            
        case 'CDF_TIME_TT2000'
            datenumber = tt2000todatenum(t_epoch);
    end
end