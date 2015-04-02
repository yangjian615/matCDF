%**************************************************************************
% Name:
%       MrCDF_AttrValue
%
% Purpose:
%   Return variable or global attribute values.
%
% Calling Sequence:
%   ATTRVALUE = MrCDF_AttrNames(FILENAME, ATTRNAME);
%       Return all attribute values ATTRVALUE of a global attribute named
%       ATTRNAME.
%
%   ATTRVALUE = MrCDF_AttrNames(__, ENTRYNUM);
%       Return a single value located at index ENTRYNUM.
%
%   ATTRVALUE = MrCDF_AttrValue(__, VARNAME);
%       Return a variable attribute value associated with the variable
%       named VARNAME.
%
% :Params:
%   FILENAME:       in, required, type=string
%   ATTRNAME:       in, required, type=string
%   ENTRYNUM:       in, optional, type=number
%   VARNAME:        in, optional, type=char
%
% :Returns:
%   ATTRVALUE:      out, optional, type=depends
%
% MATLAB Releases:
%    7.14.0.739 (R2012a)
%
% Required Products:
%    None.
%
% History:
%    2015-03-16  -  Written by Matthew Argall
%
%**************************************************************************
function attrValue = MrCDF_AttrValue(filename, attrName, arg3)

	% Make sure th file exists
	assert( exist(filename, 'file') == 2, ['File does not exist: ', filename]);

	% Open the file
	cdfID = cdflib.open(filename);

	% Get the attribute number and general information
	attrNum  = cdflib.getAttrNum(cdfID, attrName);
	attrInfo = cdflib.inquireAttr(cdfID, attrNum);

	% All Global attribute entries
	if nargin == 2
		assert( strcmp(attrInfo.scope, 'GLOBAL_SCOPE'), 'Attribute is not global in scope' );
		
		% Number of entries. Allocate memory to output.
		nEntries  = cdflib.getNumAttrgEntries(cdfID, attrNum);
		attrValue = cell(1, nEntries);
		count     = 0;
		
		% Step through each entry
		for ii = 0 : attrInfo.maxgEntry
			value = cdflib.getAttrgEntry(cdfID, attrNum, ii);
			if ~isempty(value)
				count            = count + 1;
				attrValue{count} = value;
			end
		end
	
	% A single global attribute entry
	elseif isnumeric(arg3)
		assert( strcmp(attrInfo.scope, 'GLOBAL_SCOPE'), 'Attribute is not global in scope.' );
		entryNum  = arg3;
		attrValue = cdflib.getAttrgEntry(cdfID, attrNum, entryNum);
	
	% Variable Attribute entry.
	else
		assert( strcmp(attrInfo.scope, 'VARIABLE_SCOPE'), 'Attribute is not variable scope.' );
		varname   = arg3;
		entryNum  = cdflib.getVarNum(cdfID, varname);
		attrValue = cdflib.getAttrEntry(cdfID, attrNum, entryNum);
	end

	% Close the CDF file
	cdflib.close(cdfID);
end