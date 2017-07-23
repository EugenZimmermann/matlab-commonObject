function [newGUI,newObj] = objPlot(parent,fontsize,style,varargin)    
% create plot gui element
% This function creates a gui obj for plotting graphs including labels, and legend.

% INPUT:
%   parent: handle to parent gui element
%   position: double array with 2, 3 or 4 elements
%       position 1&2: position of file selection gui on parent
%       position 3&4: size of file selection gui
%   fontsize: struct containing fields for different fontsizes
%   style: struct containing at least field "color"
%   varargin: additional parameters
%       varargin{1}: name: string for name of the gui element
%       varargin{2}: handle to Log object (see objLog)
%
% OUTPUT:
%   newGUI: struct containing handles to all matlab gui elements
%   newObj: struct containing links to public values and functions

% Tested: Matlab 2014a, 2014b, 2015a, Win8
% Author: Eugen Zimmermann, Konstanz, (C) 2015 eugen.zimmermann@uni-konstanz.de
% Last Modified on 2016-02-18

    input = inputParser;
    addRequired(input,'parent');
    addRequired(input,'fontsize',@(x) isstruct(x) && isfield(x,'general'));
    addRequired(input,'style',@(x) isstruct(x) && isfield(x,'color'));
    addParameter(input,'name','Plot',@(x) ischar(x));
    addParameter(input,'position',[5 5 480 410],@(x) isnumeric(x) && length(x)<=4 && length(x)>=2 && min(size(x))==1);
    parse(input,parent,fontsize,style,varargin{:});

    %# data elements
    newObj = struct();
    
    position = input.Results.position;
    %# switch between different postition lengths
    switch length(position)
        case 2
            position = [position(1) position(2) 480 410];
        case 3
            position = [position(1) position(2) position(3) 410];
        case 4
            position = [position(1) position(2) position(3) position(4)];
    end
    position = [position(1) position(2) max(position(3),200) max(position(4),200)];
    plot_length = position(3)-80;
    plot_hight = position(4)-90;
                
    %# gui elements of obj
    newGUI.MainPanel = gui_panel(parent,position,input.Results.name,fontsize.general,'');                    
        newGUI.axes = axes('Parent',newGUI.MainPanel,'Units','pixels','Position',[60 50 plot_length plot_hight]);
        
    %# obj functions
    newObj.reset = @reset;
    newObj.update = @update;
    newObj.updateSurf = @updateSurf;
    newObj.updateBar3  = @updateBar3;
    newObj.updateLabel = @updateLabel;
    newObj.updateLegend = @updateLegend;
    
    %# initialize default settings
    reset();
    
    function reset()
        cla(newGUI.axes,'reset');
        xlabel(newGUI.axes,'X ([X])');
        ylabel(newGUI.axes,'Y ([Y])');     
    end

    %# update plot
    function update(x,y,varargin)
        input = inputParser;
        addRequired(input,'x',@(x) isnumeric(x) && min(size(x))==1);
        addRequired(input,'y',@(s) isnumeric(s) && length(s)==length(x) && min(size(s))==1);
        addParameter(input,'xlabel','X (au)',@(x) ischar(x));
        addParameter(input,'ylabel','Y (au)',@(x) ischar(x));
        addParameter(input,'legend','',@(x) ischar(x) || isscell(x));
        addParameter(input,'color',1,@(x) isnumeric(x) && isscalar(x) && x>=1 && x<=length(style.color));
        addParameter(input,'hold',0,@(x) isnumeric(x) && isscalar(x) && (x==1 || x==0));
        parse(input,x,y,varargin{:});
        hold(newGUI.axes,con_on_off(input.Results.hold));
        try
            plot(newGUI.axes,x,y,'Color',style.color{input.Results.color});
        catch error
            disp(error)
            disp(error.message)
            return;
        end
        
        xlabel(newGUI.axes,input.Results.xlabel);
        ylabel(newGUI.axes,input.Results.ylabel);
        try
            if ~isempty(input.Results.legend)
                legend(newGUI.axes,input.Results.legend,'location','best')
                legend(newGUI.axes,'show')
            else
                legend(newGUI.axes,'hide')
            end
        catch error
            disp(error)
            disp(error.message)
        end
        drawnow();
    end

%     function updateYY()
%         %# 1 axes
%         ax(2).YTick = [];
%         ax(2).YColor = 'k';
%         
%         %# 2 axes
%         ax(2).YTickMode = 'auto';
%         ax(2).YColor = 'r';
%     end

    function updateSurf(x,y,z,xLabel,yLabel,zLabel)
        surf(newGUI.axes,x,y,z,'EdgeColor','none','LineStyle','none');
        view(newGUI.axes,2);
        
        xlabel(newGUI.axes,xLabel);
        ylabel(newGUI.axes,yLabel);
        zlabel(newGUI.axes,zLabel);
        drawnow();
    end

    function updateBar3(x,y,z,xLabel,yLabel,zLabel)
        b = bar3(newGUI.axes,z,0.95);
        view(newGUI.axes,2);

%         colorbar
        
        if length(x)<=11
            set(newGUI.axes, 'XTickLabel', y)
            set(newGUI.axes, 'YTickLabel', x)
        end
        
        xlabel(newGUI.axes,xLabel);
        ylabel(newGUI.axes,yLabel);
        zlabel(newGUI.axes,zLabel);
        
        for k = 1:length(b)
            zdata = b(k).ZData;
            b(k).CData = zdata;
            b(k).EdgeColor = 'none';
            b(k).FaceColor = 'interp';
        end
        drawnow();
    end

    function updateLabel(xLabel,yLabel)
        if ischar(xLabel)&&ischar(yLabel)
            xlabel(newGUI.axes,xLabel);
            ylabel(newGUI.axes,yLabel);
        end
    end

    function updateLegend(varargin)
        switch nargin
            case 1
                Legend = varargin{1};
                location = 'best';
            case 2
                Legend = varargin{1};
                location = varargin{2};
            otherwise
                legend('off')
                return;
        end
        legend(Legend,'Location',location)
    end
end