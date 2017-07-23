function guiObj = objAbout(parent,fontsize,style,varargin)

    defaultText = [{'Software'};{'written by'};{'Eugen Zimmermann'};{''};{'University of Konstanz'};{[char(169),' ',datestr(now,'yyyy')]}];
    
    input = inputParser;
    addRequired(input,'parent');
    addRequired(input,'fontsize',@(x) isstruct(x) && isfield(x,'general'));
    addRequired(input,'style',@(x) isstruct(x) && isfield(x,'color'));
    addParameter(input,'text',defaultText,@(x) iscell(x));
    addParameter(input,'name','About',@(x) ischar(x));
    addParameter(input,'position',200,@(x) isnumeric(x) && isscalar(x) && x>0 && x<430);
    parse(input,parent,fontsize,style,varargin{:});
    
    parent = input.Results.parent;
    fontsize = input.Results.fontsize;
    style = input.Results.style;
    text = input.Results.text;
    name = input.Results.name;
    position = input.Results.position;

    guiObj = struct();
    guiObj.menu = uimenu(ancestor(parent,'figure','toplevel'),'Label','About','ForegroundColor',style.color{end},'Callback',@onOpen);
    guiObj.main = figure('Units','pixel','NumberTitle','off','MenuBar','none',...
                      'Name',[name,' About'],'DockControls','off',...
                      'Position',[0 0 430 310],'Resize','off', 'Tag','gui_main','Visible','off','CloseRequestFcn',@onClose);
    	movegui(guiObj.main,'center');
%         iptwindowalign(ancestor(parent,'figure','toplevel'), 'left', guiObj.main, 'right');
        
    imgData = imread('gsicht.png');%imresize(imread('gsicht.png'),1);   % or: imread(URL)
    guiObj.Gsicht = uicontrol('parent',guiObj.main,'Position',[5 5 size(imgData,2) size(imgData,1)],'CData',imgData,'Interruptible','off');
                   
    for n1 = 1:length(text)
        guiObj.(['txt',num2str(n1)]) = uicontrol('Parent',guiObj.main,'Style','text','Units','pixels',...
                                          'Position',[220 position-(n1-1)*25 210 25],'String',text{n1},'Max', 2,...
                                          'HorizontalAlignment','center','Fontsize',fontsize.general);
    end
    
    function onOpen(varargin)
        guiObj.main.Visible = 'on';
		figure(guiObj.main);
    end

    function onClose(varargin)
        guiObj.main.Visible = 'off';
    end
end