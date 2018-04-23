function [guiObj,newObj] = objProgressBar(parent,position,fontsize,style,log) 
%NEWPROGRESSBAR Summary of this function goes here
    %# check if log is given as parameter
    if nargin<5
        log.update = @objLogFallback;
    end
    
    %# data elements
    newObj = struct();
        
    %# default values
    color_Bar = 8;
    color_Font = length(style.color);
    
    %# values (private) that can change during the run
    isCanceled = 0;
        
    %# switch between different postition lengths
    switch length(position)
        case 2
            position = [position(1) position(2) 525 25];
        case 3
            position = [position(1) position(2) position(3) 25];
        case 4
            position = [position(1) position(2) position(3) position(4)];
        otherwise
            position = [5 5 415 25];
    end
    
    position = [position(1) position(2) max(position(3),50) max(position(4),25)];
    
    %# gui elements of obj
    guiObj.axes = axes('Parent',parent, 'XLim',[0 1], 'YLim',[0 1],'XTick',[], 'YTick',[], 'Box','on', 'Layer','top', 'Units','pixel','Position',position,'ButtonDownFcn',{@onCancel});
    guiObj.patch = patch([0 0 1 1], [0 1 1 0], style.color{color_Bar}, 'Parent',guiObj.axes,'FaceColor',style.color{color_Bar}, 'EdgeColor','none');
    guiObj.text = text(0.5, 0.5, sprintf('%.0f%%',0*100),'Parent',guiObj.axes, 'Color',style.color{color_Font},'HorizontalAlign','center', 'VerticalAlign','middle','FontSize',fontsize.btn, 'FontWeight','bold');

    % device functions
    newObj.reset = @reset;
    newObj.update = @update;
    
    %# initialize default settings
    reset();
    
    function reset()
        setCanceled(0);
        update(0);
    end
    
    %# next button callback function
    function canceled = update(progress,varargin)
        canceled = 0;
        input = inputParser;
        addRequired(input,'progress',@(x) isnumeric(x) && isscalar(x));
        addOptional(input,'text',' ',@(x) ischar(x));
        parse(input,progress,varargin{:});
        
        progress = max(0,min(100*input.Results.progress,100));
        progress_text = input.Results.text;
        
        if isCanceled
            canceled = 1;
        end
        
        %# update progress bar
        guiObj.patch.XData = [0 0 progress/100 progress/100];
        guiObj.text.String = [progress_text,sprintf(' %.1f%%',progress)];
        drawnow();
    end

    function onCancel(varargin)
        setCanceled(1);
    end

    function setCanceled(state)
        input = inputParser;
        addRequired(input,'state',@(x) (islogical(x) || x==0 || x==1) && isscalar(x));
        parse(input,state);
        
        isCanceled = input.Results.state;
    end
end

