%
% Name
%   MrCDF_nRead
%
% Purpose
%   Read CDF variable data and its support data from multiple files.
%
% Calling Sequence:
%   DATA = MrCDF_Read(FILENAMES, VARNAME)
%     Open the CDF files FILENAMES and read DATA for the variable with
%     name VARNAME.
%
%   DATA = MrCDF_Read(___, 'ParamName', ParamValue)
%     Any of the parameter name-value pairs listed below.
%
%   [DATA, DEPEND_0, DEPEND_1, DEPEND_2, DEPEND_3] = MrCDF_Read(__)
%     Return the support data associated with DATA. Note that not all
%     variables have 3 dependencies.
%
% Parameters:
%    FILENAME:                in, required, type = char/cell
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
%                               variable.
%    'ConvertEpochToDatenum'  in, optional, type = boolean, default = false
%                             Convert epoch times to MATLAB datenumbers.
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
%     >> files = {'mms2_dfg_f128_l1a_20150318_v0.2.0.cdf', ...
%                 'mms2_dfg_f128_l1a_20150319_v0.3.0.cdf'}
%     >> [data, depend_0] = MrCDF_nRead(files, 'mms2_dfg_123');
%     >> whos data depend_0
%       Name                 Size                Bytes  Class     Attributes
%       data          22117120x3             265405440  single              
%       depend_0      22117120x1             176936960  int64  
%
% MATLAB release(s) MATLAB 7.12 (R2011a), 8.3.0.532 (R2014a)
% Required Products None
%
% History:
%   2015-04-12  -   Written by Matthew Argall
%   2015-04-15  -   Check number of records written and time range. - MRA
%   2015-04-18  -   Added ColumnMajor parameter. - MRA
%
function [data, depend_0, depend_1, depend_2, depend_3] = MrCDF_nRead(filenames, varname, varargin)
	
	% Defaults
	sTime = '';
	eTime = '';
	tf_epoch2datenum = false;
	tf_validate      = false;
	tf_colmajor      = false;
	
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
			case 'Validate'
				tf_validate = varargin{index+1};
			otherwise
				error(['Parameter not accepted: "' varargin{index} '".']);
		end
	end
	tf_keepepochasis = ~tf_epoch2datenum;
	
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
% Open the Files \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%

	% Number of files
	if ischar(filenames)
		nFiles    = 1;
		filenames = { filenames };
	else
		nFiles = length(filenames);
		warning('MrCDF_nRead:MultipleFiles', ...
		        ['cdflib.inquireVar does not work for CDF_TIME_TT2000 values. ' ...
		         'Assuming record variance for all variables.']);
	end
	
	% Validate file?
	validate_in = cdflib.getValidate();
	if ~tf_validate && strcmp(validate_in, 'VALIDATEFILEon')
		cdflib.setValidate('VALIDATEFILEoff');
	end
	
	% Open the first file. Assume names, numbers, and variance
	% are consistent across files.
	cdf_id = cdflib.open( filenames{1} );

%-----------------------------------------------------%
% Variable Names, Numbers, and Variance \\\\\\\\\\\\\ %
%-----------------------------------------------------%
	% VARIABLE
	%   - cdflib.inquireVar will not work for CDF_TIME_TT2000 variables
	varnum  = cdflib.getVarNum(cdf_id, varname);
	numrecs = cdflib.getVarNumRecsWritten(cdf_id, varnum);
	
	% Make sure there are records written
	%   - This checks only the first file.
	if numrecs == 0
		msg = sprintf( 'Zero records written to variable "%s" in file "%s"', varname, filenames{1} );
		error( msg );
	end
	
	% DEPEND_0
	if nVars > 1 || tf_trange
		% Name & Number
		vnum_dep0  = cdflib.getAttrNum(cdf_id, 'DEPEND_0');
		vname_dep0 = cdflib.getAttrEntry(cdf_id, vnum_dep0, varnum);
		varsout{2} = vname_dep0;
	end
	
	% DEPEND_1
	if nVars > 2
		% Name & Number
		vnum_dep1  = cdflib.getAttrNum(cdf_id, 'DEPEND_1');
		vname_dep1 = cdflib.getAttrEntry(cdf_id, vnum_dep1, vnum_dep1);
		varsout{3} = vname_dep1;
	end
	
	% DEPEND_2
	if nVars > 3
		% Name & Number
		vnum_dep2  = cdflib.getAttrNum(cdf_id, 'DEPEND_2');
		vname_dep2 = cdflib.getAttrEntry(cdf_id, vnum_dep2, vnum_dep2);
		varsout{4} = vname_dep2;
	end
	
	% DEPEND_3
	if nVars > 4
		% Name & Number
		vnum_dep3  = cdflib.getAttrNum(cdf_id, 'DEPEND_3');
		vname_dep3 = cdflib.getAttrEntry(cdf_id, vnum_dep3, vnum_dep3);
		varsout{5} = vname_dep3;
	end
	
%-----------------------------------------------------%
% Close the Files \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	
	% File validation back on
	if ~tf_validate && strcmp(validate_in, 'VALIDATEFILEon')
		cdflib.setValidate('VALIDATEFILEon');
	end
	
	% Close all of the files
	cdflib.close(cdf_id);

%-----------------------------------------------------%
% Define Output Variables \\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	% Define the output variables
	data = [];
	
	if nVars > 1 || tf_trange
		depend_0 = [];
	end
	
	if nVars > 2
		depend_1 = [];
	end
	
	if nVars > 3
		depend_2 = [];
	end
	
	if nVars > 4
		depend_3 = [];
	end

%-----------------------------------------------------%
% Read All Other Files \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	% Step through all files
	for ii = 1 : nFiles

		% One variable per cell
		temp = cell(1, nVars);

		% It is faster to call spdfcdfread 3 times for 3 variables than
		% it is to call it once.
		for jj = 1 : nVars
			% Read the data
			%   - It is much faster to read all records, then prune, than it is
			%     to read the fixed number of records.
			temp{jj} = spdfcdfread(filenames{ii},                             ...
			                       'ConvertEpochToDatenum', tf_epoch2datenum, ...
			                       'CombineRecords',        true,             ...
			                       'Variables',             varsout{jj},      ...
			                       'KeepEpochAsIs',         tf_keepepochasis);
		end

		% VARIABLE
		data = vertcat( data, temp{1} );
		
		% DEPEND_0
		if (nVars > 1 || tf_trange)
			depend_0 = vertcat( depend_0, temp{2} );
		end
		
		% DEPEND_1
		if nVars > 2
			depend_1 = vertcat( depend_1, temp{3} );
		end
		
		% DEPEND_2
		if nVars > 3
			depend_2 = vertcat( depend_2, temp{4} );
		end
		
		% DEPEND_3
		if nVars > 4
			depend_3 = vertcat( depend_3, temp{5} );
		end
	end
	
	% File validation back on
	if ~tf_validate && strcmp(validate_in, 'VALIDATEFILEon')
		cdflib.setValidate('VALIDATEFILEon')
	end

%-----------------------------------------------------%
% Record Range \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\ %
%-----------------------------------------------------%
	if tf_trange

		% Determine epoch type
		epoch_type = MrCDF_Epoch_Type( depend_0(1) );
		
		% Complete record range
		recrange = [1 0];

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
				firstrec = MrCDF_Epoch_Encode(depend_0(1));
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