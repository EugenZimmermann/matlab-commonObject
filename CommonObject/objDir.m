function [newGUI,newObj] = objDir(parent,position,fontsize,style,varargin) 
%NEWCALIBSTATUS Summary of this function goes here
%   Detailed explanation goes here

    if nargin<5
        log.update = @logFallback;
    end
    
    % data elements
    newObj = struct();
        
    % default values
    newObj.defaultS.dir = 'C:\';
    
    % values that can change during the run
    dir = '';
        
    % gui elements of device
    switch length(position)
        case 2
            position = [position(1) position(2) 470 50];
        case 3
            position = [position(1) position(2) position(3) 50];
        otherwise
            position = [position(1) position(2) 470 50];
    end
    var_length = position(3)-50;
    
    newGUI.Panel = gui_panel(parent,position,'Directory',fontsize.general,'');
        newGUI.var = gui_var(newGUI.Panel,[  3 5 var_length 25],'directory','center',fontsize.dir,'',{@setDir});
            set(newGUI.var,'Enable','inactive');
        newGUI.btn  = gui_btn(newGUI.Panel,[var_length+5 5 40 25],'...',fontsize.btn,'Browse Directory','',{@onChange});
                    
    % device functions
    newObj.reset = @reset;
    newObj.getDir = @getDir;
    newObj.setDir = @setDir;
    newObj.toggleActive = @toggleActive;
    
    reset();
    
    function reset()
        dir = newObj.defaultS.dir;
        setDir(dir);
    end

    function d = getDir()
        d = dir;
    end

    function toggleActive(state)
        newGUI.var.Enable = con_a_b(state,'on','inactive');
        newGUI.btn.Enable = con_on_off(state);
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
end

