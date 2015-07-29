%
% Name
%   MrCDF_Read
%
% Purpose
%   Read CDF variable data and its support data from a file.
%
% Calling Sequence:
%   DATA = MrCDF_Read(FILENAME, VARNAME)
%     Open the CDF file FILENAME and read DATA for the variable with
%     name VARNAME.
%
%   DATA = MrCDF_Read(CDF_ID, VARNAME)
%     Read data from an already open CDF file. CDF_ID is the CDF file
%     identifier returned by cdflib.open().
%
%   DATA = MrCDF_Read(___, 'ParamName', ParamValue)
%     Any of the parameter name-value pairs listed below.
%
%   [DATA, DEPEND_0, DEPEND_1, DEPEND_2, DEPEND_3] = MrCDF_Read(__)
%     Return the support data associated with DATA. Note that not all
%     variables have 3 dependencies.
%
% Parameters:
%    FILENAME:                in, required, type = char
%    VARNAME:                 in, required, type = char
%    'sTime':                 in, optional, type = char, default = ''
%                             Start time of the interval to be read,
%                               formatted as an ISO-8601 string.
%    'eTime':                 in, optional, type = char, default = ''
%                             End time of the interval to be read,
%                               formatted as an ISO-8601 string.
%    'ColumnMajor'            in, optional, type = boolean, default = false
%                             spdfcdfread v3.5.0 and greater return data in row-major
%                               format with [recs, DEPEND_0, DEPEND_1, DEPEND_2, DEPEND_3].
%                               Convert to column major order by organizing the data as
%                               [DEPEND_3, DEPEND_2, DEPEND_1, DEPEND_0, recs], with
%                               DEPEND_[123] not present if they do not exist for the
%                               variable. If 'RowMajor' is not set, this is the default.
%    'ConvertEpochToDatenum'  in, optional, type = boolean, default = false
%                             Convert epoch times to MATLAB datenumbers.
%    'RowMajor'               in, optional, type = boolean, default = false
%                             spdfcdfread v3.5.0 and greater return data in row-major
%                               format with [recs, DEPEND_0, DEPEND_1, DEPEND_2, DEPEND_3].
%                               Set this keyword to true to keep output in this format.
%    'Validate'               in, optional, type = boolean, default = false
%                             Validate the CDF file upon opening. This
%                               is slow and does not work if the files
%                               contain CDF_TIME_TT2000 variables.
%
% Returns:
%    DATA:            out, required, type = any
%    DEPEND_0:        out, optional, type = any
%    DEPEND_1:        out, optional, type = any
%    DEPEND_2:        out, optional, type = any
%    DEPEND_3:        out, optional, type = any
%
% Examples
%   Read two data files
%     >> file             = 'mms2_dfg_f128_l1a_20150318_v0.2.0.cdf'
%     >> [data, depend_0] = MrCDF_nRead(file, 'mms2_dfg_123');
%     >> whos data depend_0
%       Name                 Size                Bytes  Class     Attributes
%       data          11059200x3             132710400  single              
%       depend_0      11059200x1              88473600  int64 
%
% MATLAB release(s) MATLAB 7.12 (R2011a), 8.3.0.532 (R2014a)
% Required Products None
%
% History:
%   2014-10-14  -   Written by Matthew Argall
%   2015-03-07  -   Added the "Validate" parameter. - MRA
%   2015-04-07  -   Providing time range no longer causes extra call to 
%                     spdfcdfread. - MRA
%   2015-04-12  -   Accept a CDF file ID number as input. - MRA
%   2015-04-15  -   Check number of records written and time range. - MRA
%   2015-04-18  -   Added ColumnMajor parameter. Corrected typo when reporting
%                     empty variable records. - MRA
%   2015-04-18  -   Added RowMajor parameter. ColumnMajor is now the default. - MRA
%
function [data, depend_0, depend_1, depend_2, depend_3] = MrCDF_Read(filename, varname, varargin)

	% Defaults
	sTime = '';
	eTime = '';
	tf_colmajor      = false;
	tf_epoch2datenum = false;
	tf_rowmajor      = false;
	tf_validate      = false;
	
	% Check for optional inputs
	nvargs = length(varargin);
	for index = 1:2:nvargs
		switch varargin{index}
			case 'sTime'
				sTime = [varargin{index+1} '.000'];
			case 'eTime'
				eTime = [varargin{index+1} '.000'];
			case 'ColumnMajor'
				tf_colmajor = varargin{index+1};
			case 'ConvertEpochToDatenum'
				tf_epoch2datenum = varargin{index+1};
			case 'RowMajor'
				tf_rowmajor = varargin{index+1};
			case 'Validate'
				tf_validate = varargin{index+1};
			otherwise
				error(['Parameter not accepted: "' varargin{index} '".']);
		end
	end
	tf_keepepochasis = ~tf_epoch2datenum;
	
	% Majority
	%   - Set TF_COLMAJOR and only check that.
	assert( ~tf_colmajor || ~tf_rowmajor, 'RowMajor and ColumnMajor are mutually exclusive')
	if ~tf_colmajor && ~tf_rowmajor
		tf_colmajor = true;
	elseif tf_rowmajor
		tf_colmajor = false;
	end
	
	% Get a time range?
	if isempty(sTime) && isempty(eTime)
		tf_trange = false;
	else
		tf_trange = true;
	end
	
	% Number of variables to read
	nVars = nargout();
	if nVars == 1 && tf_trange
		nVars = 2;
	end
	varsout    = cell(1, nVars);
	varsout{1} = varname;

%-----------------------------------------------------%
% Open the File \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	
	% Validate file?
	validate_in = cdflib.getValidate();
	if ~tf_validate && strcmp(validate_in, 'VALIDATEFILEon')
		cdflib.setValidate('VALIDATEFILEoff');
	end
	
	% File name or CDF ID number?
	if ischar(filename)
		assert(exist(filename, 'file') == 2, ['File does not exist: "' filename '".']);
		cdf_id  = cdflib.open(filename);
		tf_open = true;
	elseif isa(filename, 'uint64')
		cdf_id  = filename;
		tf_open = false;
	else
		error( ['FILENAME must be a string or uint64. Type is ' class(filename) '".'] )
	end

%-----------------------------------------------------%
% Variable Names and Numbers \\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	% VARIABLE
	varnum  = cdflib.getVarNum(cdf_id, varname);
	numrecs = cdflib.getVarNumRecsWritten(cdf_id, varnum);

	if numrecs == 0
		msg = sprintf( 'No records found for variable %s.', varname );
		warning('MrCDF_Read:Records', msg);
	end
	
	% DEPEND_0
	if nVars > 1 || tf_trange
		vnum_dep0  = cdflib.getAttrNum(cdf_id, 'DEPEND_0');
		vname_dep0 = cdflib.getAttrEntry(cdf_id, vnum_dep0, varnum);
		varsout{2} = vname_dep0;
	end
	
	% DEPEND_1
	if nVars > 2
		vnum_dep1  = cdflib.getAttrNum(cdf_id, 'DEPEND_1');
		vname_dep1 = cdflib.getAttrEntry(cdf_id, vnum_dep1, varnum);
		varsout{3} = vname_dep1;
	end
	
	% DEPEND_2
	if nVars > 3
		vnum_dep2  = cdflib.getAttrNum(cdf_id, 'DEPEND_2');
		vname_dep2 = cdflib.getAttrEntry(cdf_id, vnum_dep2, varnum);
		varsout{4} = vname_dep2;
	end
	
	% DEPEND_3
	if nVars > 4
		vnum_dep3  = cdflib.getAttrNum(cdf_id, 'DEPEND_3');
		vname_dep3 = cdflib.getAttrEntry(cdf_id, vnum_dep3, varnum);
		varsout{5} = vname_dep3;
	end
	
	% Close the CDF file
	if tf_open
		cdflib.close(cdf_id);
	end

%-----------------------------------------------------%
% Read the Data \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%

	% One variable per cell
	temp = cell(1, nVars);

	% It is faster to call spdfcdfread 3 times for 3 variables than
	% it is to call it once.
	for ii = 1 : nVars
		% Read the data
		%   - It is much faster to read all records, then prune, than it is
		%     to read the fixed number of records.
		temp{ii} = spdfcdfread(filename,                                  ...
		                       'ConvertEpochToDatenum', tf_epoch2datenum, ...
		                       'CombineRecords',        true,             ...
		                       'Variables',             varsout{ii},      ...
		                       'KeepEpochAsIs',         tf_keepepochasis);
	end
	
	% File validation back on
	if ~tf_validate && strcmp(validate_in, 'VALIDATEFILEon')
		cdflib.setValidate('VALIDATEFILEon');
	end
	

%-----------------------------------------------------%
% Extract Data \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	% Cell or data?
	data = temp{1};
	
	% DEPEND_0
	if nVars > 1
		depend_0 = temp{2};
	end
	
	% DEPEND_1
	if nVars > 2
		depend_1 = temp{3};
	end
	
	% DEPEND_2
	if nVars > 3
		depend_2 = temp{4};
	end
	
	% DEPEND_3
	if nVars > 4
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
		%   - Define it initially to return an empty array if not altered.
		recrange = [1, 0];

	%-----------------------------------------------------%
	% Start Time \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%-----------------------------------------------------%
		if ~isempty(sTime)
			% Convert to epoch
			sTime_epoch = MrCDF_Epoch_Parse( sTime, epoch_type );
			
			% Find record start
			istart = find( depend_0 >= sTime_epoch, 1, 'first');
			
			% Records in time interval?
			if isempty(istart)
				lastrec = MrCDF_Epoch_Encode(depend_0(end));
				msg     = sprintf( 'No records found after sTime. Last record is %s', ...
				                   lastrec{1});
				warning('MrCDF_Read:TimeRange', msg);
			else
				recrange(1) = istart;
			end
		end

	%-----------------------------------------------------%
	% End Time \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%-----------------------------------------------------%
		if ~isempty(eTime)
			% Convert to epoch
			eTime_epoch = MrCDF_Epoch_Parse( eTime, epoch_type );

			% Find last record
			iend = find( depend_0 <= eTime_epoch, 1, 'last');
			
			% Records in time interval?
			if isempty(iend)
				firstrec = MrCDF_Epoch_Encode(depend_0(end));
				msg      = sprintf( 'No records found before eTime. First record is %s', ...
				                    firstrec{1} );
				warning('MrCDF_Read:TimeRange', msg );
			else
				recrange(2) = iend;
			end
		else
			recrange(2) = length(depend_0);
		end

	%-----------------------------------------------------%
	% Prune Data \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
	%-----------------------------------------------------%
		data     = data(recrange(1):recrange(2), :);
		depend_0 = depend_0(recrange(1):recrange(2));
	end

%-----------------------------------------------------%
% Column Major \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	%
	% spdfcdfread v3.5.0 and greater return data in row-major
	% format with [recs, DEPEND_0, DEPEND_1, DEPEND_2, DEPEND_3].
	% Convert to column major order by organizing the data as
	% [DEPEND_3, DEPEND_2, DEPEND_1, DEPEND_0, recs], with
	% DEPEND_[123] not present if they do not exist for the variable.
	%
	if tf_colmajor
		nDims = ndims(data);
		data  = permute(data, nDims:-1:1);
		
		if nargout > 1
			nDims    = ndims(depend_0);
			depend_0 = permute(depend_0, nDims:-1:1);
		end
		
		if nargout > 2
			nDims    = ndims(depend_1);
			depend_1 = permute(depend_1, nDims:-1:1);
		end
		
		if nargout > 3
			nDims    = ndims(depend_2);
			depend_2 = permute(depend_2, nDims:-1:1);
		end
		
		if nargout > 4
			nDims    = ndims(depend_3);
			depend_3 = permute(depend_3, nDims:-1:1);
		end
	end
end