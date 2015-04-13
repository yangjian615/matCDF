%**************************************************************************
% NAME:
%   MrCDF_version
%
% PURPOSE:
%   Compare one CDF library version to another. Results are:
%     -1  -  Version1 is older
%      0  -  Version1 is the same
%      1  -  Version1 is newer
%
% Calling Sequence:
%   RESULT = MrCDF_Version_Compare(VERSION1);
%     Compare a CDF version number VERSION1 to the currently installed
%     version of the CDf library. Version numbers are formatted as
%     'Version.Release.Increment.Patch', where "Patch" is optional.
%
%   RESULT = MrCDF_Version_Compare(VERSION1, VERSION2);
%     Compare VERSION1 to VERSION2.
%
% :Parameters:
%   VERSION1:       in, required, type=char
%   VERSION2:       in, optional, type=char, default=current version
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
function result = MrCDF_Version_Compare(version1, version2)
	
	% Compare to the current version?
	if nargin == 1
		version2 = MrCDF_Version();
	end	
		
	% Split the versions into parts
	%   version.release.increment.patch
	v1 = regexp(version1, '\.', 'split');
	v2 = regexp(version2, '\.', 'split');
	
	% Make sure each have 4-elements
	%   cdflib version numbers have 3 values
	%   spdf   version numbers have 4 values
	if length(v1) == 3
		v1{4} = '0';
	end
	
	if length(v2) == 3
		v2{4} = '0';
	end
	
	% Check if version1 is older than version2
	older = ( v1{1} <  v2{1} ) || ...
		      ( v1{1} == v2{1} && v1{2} <  v2{2} ) || ...
		        ( v1{1} == v2{1} && v1{2} == v2{2} && v1{3} <  v2{3} ) || ...
		        ( v1{1} == v2{1} && v1{2} == v2{2} && v1{3} == v2{3} && v1{4} < v2{4} );
	
	% Check if version1 is newer than version2
	if ~older
		newer = ( v1{1} >  v2{1} ) || ...
		        ( v1{1} == v2{1} && v1{2} >  v2{2} ) || ...
		        ( v1{1} == v2{1} && v1{2} == v2{2} && v1{3} >  v2{3} ) || ...
		        ( v1{1} == v2{1} && v1{2} == v2{2} && v1{3} == v2{3} && v1{4} > v2{4} );
	else
		newer = 0;
	end
	
	
	result = -older + newer;
end