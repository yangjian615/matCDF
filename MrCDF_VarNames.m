%**************************************************************************
% Name:
%       MrCDF_VarNames
%
% Purpose:
%   Return names of variables contained within a CDF file.
%
% Calling Sequence:
%   MrCDF_VarNames(FILENAME);
%       Print variable names contained in the file identified by FILENAME
%       to the command window
%
%   VARNAMES = MrCDF_VarNames(FILENAME);
%       Return a cell array of variable names.
%
% :Params:
%   FILENAME:       in, required, type=string
%
% :Returns:
%   VARNAMES:       out, optional, type = cell
%
% MATLAB Releases:
%    7.14.0.739 (R2012a)
%
% Required Products:
%    None.
%
% History:
%    2014-11-29  -  Written by Matthew Argall
%
%**************************************************************************
function [varnames] = MrCDF_VarNames(filename)

    % Make sure th file exists
    assert( exist(filename, 'file') == 2, ['File does not exist: ', filename]);
    
    % Open the file
    cdfID = cdflib.open(filename);
    
    % Figure out how many variables are in the file
    %   - info.numVars
    info = cdflib.inquire(cdfID);
    
    % Allocate memory
    varnames = cell(1,info.numVars);
    
    % Get all variable names
    for ii = 0 : info.numVars-1
        varinfo        = cdflib.inquireVar(cdfID, ii);
        varnames{ii+1} = varinfo.name;
    end
    
    % Close the CDF file
    cdflib.close(cdfID);
    
    % Print the results if no output is present
    if nargout() == 0
        for ii = 1 : info.numVars
           disp(varnames{ii});
        end
    end
end