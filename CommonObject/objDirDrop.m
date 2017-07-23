function [newGUI,newObj] = objDirDrop(parent,position,name,filetype,fontsize,style,varargin) 
% create file selection gui element with drop selection view
% This function creates a gui obj for file selection including a directory variable,
% a corresponding folder selection button, and a drop selection of a single file.

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
        log.update = @objLogFallback;
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
            position = [position(1) position(2) 470 80];
        case 3
            position = [position(1) position(2) position(3) 80];
        otherwise
            position = [5 5 470 80];
    end
    position = [position(1) position(2) max(position(3)-50,200) position(4)];
    var_length = position(3)-50;
    drop_hight = 25;
    
    %# gui elements of obj
    newGUI.Panel = gui_panel(parent,position,name,fontsize.general,'');
        newGUI.var = gui_var(newGUI.Panel,[  5 drop_hight+10 var_length 25],'directory','center',fontsize.dir,'',{@setDir});
            set(newGUI.var,'Enable','inactive');
        newGUI.btn  = gui_btn(newGUI.Panel,[var_length+5 drop_hight+10 40 25],'...',fontsize.btn,'Browse Directory','',{@onChange});
        newGUI.drop = gui_drop(newGUI.Panel,[  5 5 var_length+40 drop_hight],'empty','',{@onDrop});
    

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
        newGUI.drop.Enable = con_on_off(state);
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
                [files,nfiles] = getFiles(temp_dir,filetype);
            catch error
                log.update('Error loading files. Ensure "Common" folder is loaded!')
                log.update(error.message)
                status = 0;
                return;
            end
            if ~nfiles
                files = struct();
                files.name = 'empty';
            end
            File2Table(files);
            status = 1;
        end
    end

    function onDrop(varargin)
        if ~strcmp(newGUI.drop.String,'empty')
            file = newGUI.drop.String{newGUI.drop.Value};
        else
            file = '';
        end
    end

    function File2Table(files)
        newGUI.drop.String = cat(1,{files(:).name}');
        newGUI.drop.Value = 1;
        onDrop();
    end

%     function objLogFallback(varargin)
%         temp_var = varargin{1};
%         if ischar(temp_var)
%             helpdlg(temp_var);
%         else
%             disp('Wrong parameter type for logFallback!')
%         end
%     end
end

