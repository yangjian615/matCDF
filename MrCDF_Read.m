%--------------------------------------------------------------------------
% Name
%   MrCDF_Read
%
% Purpose
%   Read CDF variable data and its support data from a file.
%
% Calling Sequence:
%   DATA = MrCDF_Read(FILENAME, VARNAME)
%     Reads CDF variable VARNAME from file FILENAME and returns DATA.
%
%   DATA = MrCDF_Read(..., 'sTime', STIME)
%     Returns data on and after the time STIME, a string formatted as
%     'yyyy-mm-ddThh:mm:ss'
%
%   DATA = MrCDF_Read(..., 'eTime', ETIME)
%     Returns data on and before the time STIME, a string formatted as
%     'yyyy-mm-ddThh:mm:ss'
%
%   DATA = MrCDF_Read(..., 'eTime', ETIME)
%     Returns data on and before the time STIME, a string formatted as
%     'yyyy-mm-ddThh:mm:ss'
%
%   [DATA, DEPEND_0, DEPEND_1, DEPEND_2, DEPEND_3] = MrCDF_Read(__)
%     Return the support data associated with DATA. Note that not all
%     variables have 3 dependencies.
%
% Parameters:
%    FILENAME:                in, required, type = char
%    VARNAME:                 in, required, type = char
%    'sTime':                 in, optional, type = char, default = ''
%    'eTime':                 in, optional, type = char, default = ''
%    'ConvertEpochToDatenum'  in, optional, type = boolean, default = false
%    'Validate'               in, optional, type = boolean, default = false
%
% Returns:
%    DATA:            out, required, type = any
%    DEPEND_0:        out, optional, type = any
%    DEPEND_1:        out, optional, type = any
%    DEPEND_2:        out, optional, type = any
%    DEPEND_3:        out, optional, type = any
%
% MATLAB release(s) MATLAB 7.12 (R2011a), 8.3.0.532 (R2014a)
% Required Products None
%
% History:
%   2014-10-14  -   Written by Matthew Argall
%   2015-03-07  -   Added the "Validate" parameter. - MRA
%   2015-04-07  -   Providing time range no longer causes extra call to 
%                     spdfcdfread. - MRA
%
function [data, depend_0, depend_1, depend_2, depend_3] = MrCDF_Read(filename, varname, varargin)

	% Ensure the file exists
	assert(exist(filename, 'file') == 2, ['File does not exist: "' filename '".']);
	
	% Defaults
	sTime = '';
	eTime = '';
	tf_epoch2datenum = false;
	tf_validate      = false;
	
	% Check for optional inputs
	nvargs = length(varargin);
	for index = 1:2:nvargs
		switch varargin{index}
			case 'sTime'
				sTime = [varargin{index+1} '.000'];
			case 'eTime'
				eTime = [varargin{index+1} '.000'];
			case 'ConvertEpochToDatenum'
				tf_epoch2datenum = varargin{index+1};
			case 'Validate'
				tf_validate = varargin{index+1};
			otherwise
				error(['Parameter not accepted: "' varargin{index} '".']);
		end
	end
	tf_keepepochasis = ~tf_epoch2datenum;
	
	% Number of outputs
	nOut       = nargout();
	varsout    = cell(1, nOut);
	varsout{1} = varname;
	
	% Get a time range?
	if isempty(sTime) && isempty(eTime)
		tf_trange = false;
	else
		tf_trange = true;
	end

%-----------------------------------------------------%
% Open the File \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	
	% Validate file?
	if ~tf_validate
		cdflib.setValidate('VALIDATEFILEoff')
	end
	
	% Open the file and get the variable number
	cdf_id = cdflib.open(filename);
	varnum = cdflib.getVarNum(cdf_id, varname);

%-----------------------------------------------------%
% Dependent Variable Names and Numbers \\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	% DEPEND_0
	if nOut > 1 || tf_trange
		vnum_dep0  = cdflib.getAttrNum(cdf_id, 'DEPEND_0');
		vname_dep0 = cdflib.getAttrEntry(cdf_id, vnum_dep0, varnum);
		
		if nOut > 1
			varsout{2} = vname_dep0;
		end
	end
	
	% DEPEND_1
	if nOut > 2
		vnum_dep1  = cdflib.getAttrNum(cdf_id, 'DEPEND_1');
		vname_dep1 = cdflib.getAttrEntry(cdf_id, vnum_dep1, varnum);
		varsout{3} = vname_dep1;
	end
	
	% DEPEND_2
	if nOut > 3
		vnum_dep2  = cdflib.getAttrNum(cdf_id, 'DEPEND_2');
		vname_dep2 = cdflib.getAttrEntry(cdf_id, vnum_dep2, varnum);
		varsout{4} = vname_dep2;
	end
	
	% DEPEND_3
	if nOut > 4
		vnum_dep3  = cdflib.getAttrNum(cdf_id, 'DEPEND_3');
		vname_dep3 = cdflib.getAttrEntry(cdf_id, vnum_dep3, varnum);
		varsout{5} = vname_dep3;
	end
	
	% Close the CDF file
	cdflib.close(cdf_id);

%-----------------------------------------------------%
% Read the Data \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%

	% Read the data
	%   - It is much faster to read all of the data, then prune, than it is
	%     to read the fixed number of records.
	temp = spdfcdfread(filename,                                  ...
	                   'ConvertEpochToDatenum', tf_epoch2datenum, ...
	                   'CombineRecords',        true,             ...
	                   'Variables',             varsout,          ...
	                   'KeepEpochAsIs',         tf_keepepochasis);
	
	% File validation back on
	if tf_validate == false
		cdflib.setValidate('VALIDATEFILEon')
	end
	

%-----------------------------------------------------%
% Extract Data \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	% Cell or data?
	if length(varsout) == 1
		data = temp;
	else
		data = temp{1};
	end
	
	% DEPEND_0
	if nOut > 1
		depend_0 = temp{2};
	end
	
	% DEPEND_1
	if nOut > 2
		depend_1 = temp{3};
	end
	
	% DEPEND_2
	if nOut > 3
		depend_2 = temp{4};
	end
	
	% DEPEND_3
	if nOut > 4
		depend_3 = temp{5};
	end
	
	% Clear the temporary array
	clear temp

%-----------------------------------------------------%
% Record Range \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	if tf_trange
		% Determine epoch type
		epoch_type = MrCDF_Epoch_Type( depend_0(1) );
		
		% Complete record range
		recrange = (1, length( data(:,1) ));

	%-----------------------------------------------------%
	% Start Time \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%-----------------------------------------------------%
		if ~isempty(sTime)
			% Convert to epoch
			sTime_epoch = MrCDF_Epoch_Parse( sTime, epoch_type );
			
			% Find record start
			recrange(1) = find( depend_0 >= sTime_epoch, 1, 'first');
		end

	%-----------------------------------------------------%
	% End Time \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%-----------------------------------------------------%
		if ~isempty(eTime)
			% Convert to epoch
			eTime_epoch = MrCDF_Epoch_Parse( eTime, epoch_type );
			
			% Find last record
			recrange(2) = find( depend_0 <= eTime_epoch, 1, 'last');
		end

	%-----------------------------------------------------%
	% Prune Data \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%-----------------------------------------------------%
		data     = data(recrange(1):recrange(2), :);
		depend_0 = depend_0(recrange(1):recrange(2));
	end
end