function [newGUI,newObj] = objDirList(parent,position,name,filetype,fontsize,style,varargin) 
% create file selection gui element with list view
% This function creates a gui obj for file selection including a directory variable,
% a corresponding folder selection button, and a file table for selection of a single file.

% INPUT:
%   parent: handle to parent gui element
%   position: double array with 2, 3 or 4 elements
%       position 1&2: position of file selection gui on parent
%       position 3&4: size of file selection gui
%   name: string for naming the file selection gui element
%   filetype: string with fileextension
%   fontsize: struct containing fields for different fontsizes
%   style: struct containing at least field "color"
%   varargin: additional parameters
%       varargin{1}: handle to Log object (see objLog)
%
% OUTPUT:
%   newGUI: struct containing handles to all matlab gui elements
%   newObj: struct containing links to public values and functions

% Tested: Matlab 2014a, 2014b, 2015a, Win8
% Author: Eugen Zimmermann, Konstanz, (C) 2015 eugen.zimmermann@uni-konstanz.de
% Last Modified on 2015-10-27

    %# check if log is given as parameter
    if nargin<7
        log.update = @logFallback;
    end
    
    %# data elements
    newObj = struct();
        
    %# default values
    newObj.defaultS.dir = 'C:\';
    
    %# values (private) that can change during the run
    dir = '';
    file = '';
        
    %# switch between different postition lengths
    switch length(position)
        case 2
            position = [position(1) position(2) 470 360];
        case 3
            position = [position(1) position(2) position(3) 360];
        case 4
            position = [position(1) position(2) position(3) position(4)];
        otherwise
            position = [5 5 470 360];
    end
    position = [position(1) position(2) max(position(3)-50,300) max(position(4)-50,135)];
    var_length = position(3)-50;
    table_hight = position(4)-60;
    
    %# gui elements of obj
    newGUI.Panel = gui_panel(parent,position,name,fontsize.general,'');
        newGUI.var = gui_var(newGUI.Panel,[  3 table_hight+10 var_length 25],'directory','center',fontsize.dir,'',{@setDir});
            set(newGUI.var,'Enable','inactive');
        newGUI.btn  = gui_btn(newGUI.Panel,[var_length+5 table_hight+10 40 25],'...',fontsize.btn,'Browse Directory','',{@onChange});
        
        Columns      = {'Active', 'File'};
        Format       = {'logical', 'bank'};
        ColumnWidth  = {40         max(var_length,250)-2};
        Editable     = [true       false];
        newGUI.table = gui_table(newGUI.Panel,[3 5 var_length+40 table_hight],Columns,Format,ColumnWidth,Editable,[],'',{@onTableEdit});
                    
    %# obj functions
    newObj.reset = @reset;
    newObj.getDir = @getDir;
    newObj.setDir = @setDir;
    newObj.getFile = @getFile;
    newObj.toggleActive = @toggleActive;
    
    %# initialize default settings
    reset();
    
    function reset()
        dir = newObj.defaultS.dir;
        setDir(dir);
    end

    function d = getDir()
        d = dir;
    end

    function f = getFile()
        f = file;
    end

    function toggleActive(state)
        newGUI.var.Enable = con_a_b(state,'on','inactive');
        newGUI.btn.Enable = con_on_off(state);
        newGUI.table.Enable = con_on_off(state);
    end

    function onChange(~,~,~)  
        temp_dir = uigetdir(dir);

        if ~temp_dir
            newGUI.var.String = dir;
        else
            setDir(temp_dir);
        end
    end

    %# set directory in variable
    function status = setDir(temp_dir)
        %# check if directory exists
        A = exist(temp_dir, 'dir');
        if ~A
            log.update('Directory does not exist.');
            newGUI.var.String = dir;
            status = 0;
        else
            newGUI.var.String = temp_dir;
            dir = temp_dir;
            try
                [files,~] = getFiles(temp_dir,filetype);
            catch error
                log.update('Error loading files. Ensure "Common" folder is loaded!')
                log.update(error.message)
                status = 0;
                return;
            end
            
            files(end+1).name = 'none';
            File2Table(files);
            status = 1;
        end
    end

    function logFallback(varargin)
        temp_var = varargin{1};
        if ischar(temp_var)
            helpdlg(temp_var);
        else
            disp('Wrong parameter type for logFallback!')
        end
    end

    function onTableEdit(~,e)
        temp_data(:,1) = cellfun(@(s) {false},newGUI.table.Data(:,1));
        temp_data(e.Indices(1)) = {true};
        newGUI.table.Data(:,1) = temp_data;
        setFile(e.Indices(1));
    end

    function File2Table(files)
        filelist = cat(1,{files(:).name}');
        checklist = cellfun(@(s) {false},cell(length(filelist),1));
        checklist(1) = {true};
        newGUI.table.Data = [checklist,filelist];
        setFile();
    end

    function setFile(varargin)
        switch nargin
            case 1
                ind = varargin{1};
            otherwise
                ind = 1;
        end
                
        if ~strcmp(newGUI.table.Data{ind,2},'none')
            file = newGUI.table.Data{ind,2};
        else
            file = '';
        end
    end
end

