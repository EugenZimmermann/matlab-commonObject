function [guiObj,newObj] = objLog(parent,fontsize,style,varargin) 
%objLog Log object to display and save log data 
%   Detailed explanation goes here

    %# check input
    if isa(parent,'matlab.ui.container.TabGroup')
        possible_gui = {'Window','Tab'};
    else
        possible_gui = {'Window'};
    end
    
    input = inputParser;
    addRequired(input,'parent');
    addRequired(input,'fontsize',@(x) isstruct(x) && isfield(x,'general'));
    addRequired(input,'style',@(x) isstruct(x) && isfield(x,'color'));
    addParameter(input,'folder','',@(x) ischar(x) || isempty(x));
    addParameter(input,'name','Log',@(x) ischar(x));
    addParameter(input,'gui_style','Window',@(x) any(validatestring(x,possible_gui)));
    parse(input,parent,fontsize,style,varargin{:});
    
    parent = input.Results.parent;
    fontsize = input.Results.fontsize;
    style = input.Results.style;
    folder = input.Results.folder;
    name = input.Results.name;
    gui_style = input.Results.gui_style;
    
    %# struct for public obj functions and variables
    newObj = struct();
    
    %# private obj variables
    [nameStatus,tempName] = check_string(name,'filename');
    name = con_a_b(nameStatus,tempName,'Log');
         
    %# gui elements of obj
    switch gui_style
        case 'Tab'
            guiObj.main = uitab('parent',parent,'title','Log','Tag',name);
        case 'Window'
            guiObj.menu = uimenu(ancestor(parent,'figure','toplevel'),'Label',name,...
                                'ForegroundColor',style.color{end},'Callback',@onOpen);
            guiObj.main = figure('Units','pixel','NumberTitle','off','MenuBar','none',...
                                'Name',name,'DockControls','off','Position',[0 0 430 310],...
                                'Resize','on', 'Tag','guiLog','Visible','off','CloseRequestFcn',@onClose);
            	movegui(guiObj.main,'center');
                iptwindowalign(ancestor(parent,'figure','toplevel'), 'bottom', guiObj.main, 'top');
                
    end
    guiObj.Panel  = uipanel('Parent',guiObj.main,'Units','normalized','Position',[0 0 1 1],'Title',name,...
               'Fontsize',fontsize.general,'Clipping','on');
        guiObj.txt = uicontrol(guiObj.Panel,'Enable','inactive','Units','normalized','Position',[0 0 1 1],'Style','edit','FontSize',fontsize.general,'Min',0,'Max',2,'HorizontalAlignment','left');
        set(guiObj.txt,'String','');
        
    %# definition of public obj functions
    newObj.reset = @reset;
    newObj.update = @update;
    newObj.save = @save;
    newObj.setDir = @setDir;
    
    function reset()
        set(guiObj.txt,'String','');
    end

    function tempFolder = setDir(new_folder)
        [folderStatus,tempFolder] = check_string(new_folder,'folder');
        if folderStatus
            folder = tempFolder;
            save();
        end
    end

    function save(varargin)
        %# do not save log file, until valid folder is defined
        if isempty(folder)
            return;
        end
        
        switch nargin
            case 1
                fo = folder;
                na = name;
                LogData.data = varargin{1};
            case 2
                fo = varargin{1};
                na = varargin{2};
                LogData.data = guiObj.txt.String;
            case 3
                fo = varargin{1};
                na = varargin{2};
                LogData.data = varargin{3};
            otherwise
                fo = folder;
                na = name;
                LogData.data = guiObj.txt.String;
        end
        LogData.Date = datestr(clock,'yyyy-mm-dd');
        exportLog(fo,na,LogData);
    end

    function update(str)
        input = inputParser;
        addRequired(input,'str',@(x) ischar(x));
        parse(input,str);
        
        str = input.Results.str;
        
        time_string = datestr(clock,'yyyy-mm-dd HH:MM:SS: ');
        
        %# check if log window has to many entries
        if size(guiObj.txt.String,1)>500
            guiObj.txt.String=guiObj.txt.String(1:100);
        end
        
        guiObj.txt.String = [{[time_string,str]};guiObj.txt.String];
        save([time_string,str]);
    end
    
    function onOpen(varargin)
        guiObj.main.Visible = 'on';
		figure(guiObj.main);
    end

    function onClose(varargin)
        guiObj.main.Visible = 'off';
    end
end

