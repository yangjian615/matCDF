%**************************************************************************
% Name:
%       MrCDF_AttrNames
%
% Purpose:
%   Return names of variables contained within a CDF file.
%
% Calling Sequence:
%   MrCDF_AttrNames(FILENAME);
%       Print attribute names and their scope from a CDF file named
%       FILENAME.
%
%   ATTRNAMES = MrCDF_VarNames(__);
%       Return a cell array of attribute names.
%
%   [ATTRNAMES, SCOPE] = MrCDF_VarNames(__);
%       Return the attribute scope, which can be "VARIABLE_SCOPE" or
%       "GLOBAL_SCOPE".
%
% :Params:
%   FILENAME:       in, required, type=string
%
% :Returns:
%   ATTRNAMES:      out, optional, type = cell
%   SCOPE:          out, optional, type = cell
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
function [attrnames, scope] = MrCDF_AttrNames(filename)

    % Make sure th file exists
    assert( exist(filename, 'file') == 2, ['File does not exist: ', filename]);
    
    % Open the file
    cdfID = cdflib.open(filename);
    
    % Figure out how many variables are in the file
    %   - info.numVars
    info = cdflib.inquire(cdfID);
    
    % Allocate memory
		nAttrs    = info.numgAttrs + info.numvAttrs;
    attrnames = cell(1, nAttrs);
		scope     = cell(1, nAttrs);
    
		% Get global attribute names
		for ii = 0 : nAttrs - 1
			attrInfo        = cdflib.inquireAttr(cdfID, ii);
			attrnames{ii+1} = attrInfo.name;
			scope{ii+1}     = attrInfo.scope;
		end
    
    % Close the CDF file
    cdflib.close(cdfID);
    
    % Print the results if no output is present
    if nargout() == 0
			maxlen = num2str(max(cellfun('length', attrnames)));
			
			for ii = 1 : nAttrs
				fprintf(['%-' maxlen 's   %s\n'], attrnames{ii}, scope{ii});
			end
    end
end