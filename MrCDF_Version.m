%**************************************************************************
% NAME:
%   MrCDF_version
%
% PURPOSE:
%   Return the current installed CDF version. This will first check to see
%   if the spdfcdf patch has been installed. If it is not, the current
%   version of cdflib is returned.
%
% Calling Sequence:
%   VERSION = MrCDF_version();
%     Return the current CDF version installed.
%
% :Examples:
%   >> version = MrCDF_version()
% 			version =
% 			3.5.1.2
%
% :Returns:
%   VERSION:        out, required, type=char
%
% MATLAB Releases:
%    7.14.0.739 (R2012a)
%
% History:
%    2015-03-18  -  Written by Matthew Argall
%
%**************************************************************************
function [version] = MrCDF_Version()
	
	% Check if SDPFCDF* Patch is installed
	try
		info    = spdfcdfinfo();
		version = info.PatchVersion;
	
	% Use cdflib
	catch exception
		% Recommend the CDF patch.
		patch_url = 'http://cdf.gsfc.nasa.gov/html/matlab_cdf_patch.html';
		fprintf(['I recommended that you update your CDF library by \n' ...
			       'downloading the patch available at \n    pjojoij %s'], patch_url);
		
		% Get the CDF library version.
		[version, release, increment] = cdflib.getLibraryVersion();
		version = [num2str(version) '.' num2str(release) '.' num2str(increment)];
	end
end