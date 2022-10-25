function flat=flat_parse(File)
%F=FLAT_PARSE(FILE) 
%This function parses a complete FLAT-File specified in "File" and returns 
%its contents in a structure F. 
%If File is not given a file select dialog is shown.
%
%Interesting parts of the structure:
%    datestr(F.timestamp): prints the associated timestamp 
%        F.offset.x or y : position (for single point spectroscopy)
%  F.info.Parameter_List : Experiment parameters used to measure the data
%
%F can be converted to a matrix using the FLAT2MATRIX[nD] functions.
%F can be plotted using FLAT_PLOT for 1D and 2D or FLAT_SLICEPLOT for 3D.
%
%See also FLAT_TOOLBOX, FLAT2MATRIX, FLAT2MATRIX3D, FLAT2MATRIX2D,
%FLAT2MATRIX1D, FLAT_PLOT, FLAT_SLICEPLOT.

% This file is part of FLAT Toolbox
% Copyright (c) 2009, Christopher Siol, Electronic Materials, 
% Institute of Materials Science, Technische Universität Darmstadt 
% All rights reserved.
%
% FLAT Toolbox is free software: you can redistribute it and/or modify it
% under the terms of the GNU Lesser General Public License as published by
% the Free Software Foundation, either version 3 of the License, or (at
% your option) any later version.
% 
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser
% General Public License for more details.
% 
% You should have received a copy of the GNU Lesser General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

    %open a file
    Path='';
	if nargin==0,
        [File,Path]=uigetfile('*flat', 'Get Matrix-Data');
        if File~=0
            [Path File]
        else
            error('No File selected.')
        end
	end
	fid=fopen([Path,File]);
	
    %####Start parsing (see Vernissage 1.1 Documentation)...
    %Check magic string...
    magic=char(fread(fid,8,'int8')');
    if ~strcmp(magic,'FLAT0100'),
        fclose(fid);
        error('File does not have an Flat File Format V1.0 Header! Not reading...')
    end
    
    %Read axis descriptons...
    flat.axis_count=fread(fid,1,'int32');
    for i=1:flat.axis_count,
        flat.axis(i).name=FLATString(fid);
        flat.axis(i).trigger_name=FLATString(fid);
        flat.axis(i).unit_name=FLATString(fid);
        flat.axis(i).clockcount=fread(fid,1,'int32');
        flat.axis(i).raw_start=fread(fid,1,'int32');
        flat.axis(i).raw_inc=fread(fid,1,'int32');
        flat.axis(i).phys_start=fread(fid,1,'double');
        flat.axis(i).phys_inc=fread(fid,1,'double');
        flat.axis(i).mirrored=fread(fid,1,'int32');
        flat.axis(i).tablesetcount=fread(fid,1,'int32');
        %Read table sets of current axis...
        for j=1:flat.axis(i).tablesetcount,
            flat.axis(i).tableset(j).trigger_name=FLATString(fid);
            flat.axis(i).tableset(j).intervalcount=fread(fid,1,'int32');
            for k=1:flat.axis(i).tableset(j).intervalcount,
                flat.axis(i).tableset(j).interval(k).start=fread(fid,1,'int32');
                flat.axis(i).tableset(j).interval(k).stop=fread(fid,1,'int32');
                flat.axis(i).tableset(j).interval(k).step=fread(fid,1,'int32');
            end
        end
    end
    %Read channel name and TransferFunction including parameters
    flat.channel_name=FLATString(fid);
    flat.TF.name=FLATString(fid);
    flat.channel_unit=FLATString(fid);
    flat.TF.parameter_count=fread(fid,1,'int32');
    %Create nice structures for TFF_Linear1D and TFF_Multilinear1D
    %(Dynamic field names would be more elegant but is avoided to maintain syntax compatiblility with older versions)
    if(flat.TF.parameter_count==2) % corresponds to TFF_Linear1D
        flat.TF.parameter=struct( FLATString(fid),fread(fid,1,'double'), FLATString(fid),fread(fid,1,'double') );
    elseif(flat.TF.parameter_count==5) % corresponds top TFF_Multilinear1D
        flat.TF.parameter=struct( FLATString(fid),fread(fid,1,'double'), FLATString(fid),fread(fid,1,'double'), FLATString(fid),fread(fid,1,'double'), FLATString(fid),fread(fid,1,'double'), FLATString(fid),fread(fid,1,'double'));
    else %just read the parameters even if TF is not implemented...
        warning('FLAT:Parse','Unknown TransferFunction parameter count');
        for i=1:flat.TF.parameter_count,
            flat.TF.parameter(i).name=FLATString(fid);
            flat.TF.parameter(i).value=fread(fid,1,'double');
        end
    end
    
    %Read view information
    flat.view_count=fread(fid,1,'int32');
    flat.view_id=fread(fid,flat.view_count,'int32')';
    
    %Read timestamp and comments
    flat.timestamp=datenum([1970 1 1 0 0 fread(fid,1,'int64')]); %convert time format from UNIX/C/time_t to MATLAB (use 'datestr(timestamp)' to display the date)
    flat.comment=FLATString(fid);
    
    
    %***** Read DATA *****
    flat.bricklet_size=fread(fid,1,'int32');
    flat.data_count=fread(fid,1,'int32');
    flat.data=fread(fid,flat.data_count,'int32');
    
    
    %Read Supplementary information...
    
    %Read offset informations
    flat.offset_count=fread(fid,1,'int32');
    %flat.offset=fread(fid,[offset_count,2],'double'); % col 1: X-direction, col 2: Y-direction
    for i=1:flat.offset_count,
        flat.offset(i).x=fread(fid,1,'double');
        flat.offset(i).y=fread(fid,1,'double');
    end
    
    %Read experiment information
    flat.info.Experiment.Name=FLATString(fid);
    flat.info.Experiment.Version=FLATString(fid);
    flat.info.Experiment.Description=FLATString(fid);
    flat.info.Experiment.File_Specification=FLATString(fid);
    flat.info.File_Creator=FLATString(fid);
    flat.info.Result_File_Creator=FLATString(fid);
    flat.info.User=FLATString(fid);
    flat.info.Account=FLATString(fid);
    flat.info.Result_File_Specification=FLATString(fid);
    flat.info.run_cycle=fread(fid,1,'int32');
    flat.info.scan_cycle=fread(fid,1,'int32');
    
    %Read Experiment Element Parameters (into Parameter_List [string] and for convenient access into a structure "Parameter.<Element>.<Parameter>=value" [double])
    Experiment_Element_count=fread(fid,1,'int32');
    flat.info.Parameter_List={};
    Element_name=cell(Experiment_Element_count,1); % preallocate memory...
    Element_Parameter=cell(Experiment_Element_count,1); % preallocate memory...
    for i=1:Experiment_Element_count,
        Element_name{i}=FLATString(fid); %Read element name
        flat.info.Parameter_List=[flat.info.Parameter_List; {Element_name{i}}]; %Add element name to list
        
        %Read each Parameter for current element...
        Element_Parameter_Count=fread(fid,1,'int32');
        %clear variables and allocate memory...
        Par_name=cell(Element_Parameter_Count,1);
        Par_int=cell(Element_Parameter_Count,1);
        Par_unit=cell(Element_Parameter_Count,1);
        Par_val=cell(Element_Parameter_Count,1);
        %fill the variables
        for j=1:Element_Parameter_Count,
            Par_name{j}=FLATString(fid);       %Parameter name
            Par_int{j}=fread(fid,1,'int32');   %Parameter value type
            Par_unit{j}=FLATString(fid);       %Parameter unit
            Par_val{j}=FLATString(fid);        %Parameter value
            %Add to Parameter_List...
            flat.info.Parameter_List=[flat.info.Parameter_List; {[9 Par_name{j} 9 '(' int2str(Par_int{j}) ')' 9 Par_val{j} 9 Par_unit{j}]}];
            %convert the value to corresponding matlab format for later
            %use in the strucutre representation of the parameters...
            switch Par_int{j} %which type?
                case 1 %int
                    Par_val{j}=str2double(Par_val{j});
                case 2 %double
                    Par_val{j}=str2double(Par_val{j});
                case 3 %boolean
                    Par_val{j}=str2num(Par_val{j});
                case 4 %enumeration
                    Par_val{j}=Par_val{j};
                case 5 %string
                    Par_val{j}=Par_val{j};
                otherwise
                    Par_val{j}=Par_val{j};
                    warning('FLAT:Parse',['Parameter "' Par_name{j} '": value type unknown!']);
            end
        end
        %BEGIN TESTING: The following code is not well tested please comment if it is causing trouble
        %Put parameters of current element into a structure...
        if(Element_Parameter_Count~=0),
            Element_Parameter{i}=cell2struct(Par_val',Par_name',2);
        else
            Element_Parameter{i}=[];
        end
        %END TESTING
    end
    
    %BEGIN TESTING: The following code is not well tested please comment if it is causing trouble
    %Put all elements with their parameters into structures...
    if(Experiment_Element_count~=0),
        flat.info.Parameter=cell2struct(Element_Parameter',Element_name',2);
    end
    %END TESTING
    
    %Read Experiemnt Element Deployment Parameter List
    Experiment_Element_count=fread(fid,1,'int32');
    flat.info.Deployment_Parameter_List={};
    Element_name=cell(Experiment_Element_count,1); % preallocate memory...
    Element_Deployment_Parameter=cell(Experiment_Element_count,1); % preallocate memory...
    for i=1:Experiment_Element_count,
        Element_name{i}=FLATString(fid); %Read element name
        flat.info.Deployment_Parameter_List=[flat.info.Deployment_Parameter_List; {Element_name{i}}]; %Add element name to list
        
        %Read each Parameter for current element...
        Element_Deployment_Parameter_Count=fread(fid,1,'int32');
        %clear variables and allocate memory...
        Par_name=cell(Element_Deployment_Parameter_Count,1);
        Par_val=cell(Element_Deployment_Parameter_Count,1);
        %fill the variables
        for j=1:Element_Deployment_Parameter_Count,
            Par_name{j}=FLATString(fid);       %Parameter name
            Par_val{j}=FLATString(fid);        %Parameter value
            %Add to Parameter_List...
            flat.info.Deployment_Parameter_List=[flat.info.Deployment_Parameter_List; {[9 Par_name{j} 9 Par_val{j}]}];
        end
        %Put parameters of current element into a structure...
        if(Element_Deployment_Parameter_Count~=0),
            Element_Deployment_Parameter{i}=cell2struct(Par_val',Par_name',2);
        else
            Element_Deployment_Parameter{i}=[];
        end
    end
    
    %Put all elements with their deployment parameters into structures...
    if(Experiment_Element_count~=0),
        flat.info.Deployment_Parameter=cell2struct(Element_Deployment_Parameter',Element_name',2);
    end
    
    %#### Parsing complete (We should be at EOF).
    fclose(fid);
    
    
    %#### Transporm data into nicer format...
    %Apply TransferFunctions...
    if(strcmp(flat.TF.name,'TFF_Linear1D'))
        flat.phys_data=(flat.data-flat.TF.parameter.Offset)/flat.TF.parameter.Factor;
    elseif(strcmp(flat.TF.name,'TFF_MultiLinear1D'))
        flat.phys_data=(flat.TF.parameter.Raw_1-flat.TF.parameter.PreOffset)*(flat.data-flat.TF.parameter.Offset)/(flat.TF.parameter.NeutralFactor*flat.TF.parameter.PreFactor);
    else
        warning('FLAT:Parse','Unknown TransferFunction! Providing raw data only...');
    end
    
    %get the index of corresponding trigger axes in order to ease axis processing...
    for i=1:flat.axis_count,
        flat.axis(i).trigger_index=AxisIndex(flat,flat.axis(i).trigger_name);
        for j=1:flat.axis(i).tablesetcount,
            flat.axis(i).tableset(j).trigger_index=AxisIndex(flat,flat.axis(i).tableset(j).trigger_name);
        end
    end
    
    
    %#### END OF PARSING FUNCTION
	
	%####Helperfunctions
	%Read FLAT-Strings
    function s=FLATString(fid)
        char_count=fread(fid,1,'int32');
        s=char(fread(fid,char_count,'int16')');
            
    %get axis index
    function index=AxisIndex(flat,name)
        index=0;
        for i=1:flat.axis_count,
            if (strcmp(flat.axis(i).name,name))
                if index~=0, 
                    warning('FLAT:Parse',['Duplicate axis "' name '"! Cannot determine the triger axis! Please adjust triger_index values manually!']);
                end
                index=i;
            end
        end
        
        
