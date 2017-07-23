function [guiObj,newObj] = objControl(parent,position,fontsize,style,log,target_function) 
%NEWPROGRESSBAR Summary of this function goes here

    %# data elements
    newObj = struct();

    %# switch between different postition lengths
    switch length(position)
        case 2
            position = [position(1) position(2) 415 45];
        case 3
            position = [position(1) position(2) position(3) 45];
        otherwise
            position = [5 5 415 45];
    end
    
    length_buttons = 75;
    length_progress = max(position(3)-3*80,30);
    
    %# control buttons (START STOP SKIP)
    guiObj.Start    = gui_btn(parent,[position(1) position(2) length_buttons position(4)],'Start',fontsize.bigtext,'Start measurement','btn_StartMeasurement',{@onStart});
        set(guiObj.Start,'ForegroundColor',style.color{11},'FontWeight','bold');
    guiObj.Stop     = gui_btn(parent,[position(1)+length_buttons+5 position(2) length_buttons position(4)],'Stop',fontsize.bigtext,'Abort measurement','btnStopMeasurement',{@onCancel});
        set(guiObj.Stop,'ForegroundColor',style.color{1},'FontWeight','bold');
    guiObj.Skip     = gui_btn(parent,[position(1)+2*(length_buttons+5) position(2) length_buttons position(4)],'Skip',fontsize.bigtext,'Skip','btnSkipMeasurement',{@onSkip});
        set(guiObj.Skip,'ForegroundColor',style.color{2},'FontWeight','bold');
    
    %# progress bar
    [guiObj.ProgressBar,newObj.ProgressBar] = objProgressBar(parent,[position(1)+240 position(2)+2 length_progress position(4)-4],fontsize,style,log);
    
    newObj.fun = feval(target_function,log);
    
    %# obj functions
    newObj.reset = @reset;
    newObj.update = @update;
    newObj.toggleControlState = @toggleControlState;
    newObj.skip = @onSkip;
    newObj.cancel = @onCancel;
    
    reset();
    
    function reset()
        newObj.ProgressBar.reset();
        toggleControlState()
    end
    
    %# update progress bar
    function canceled = update(progress,varargin)
        canceled = newObj.ProgressBar.update(progress,varargin{:});
    end

    %# start button callback
    function onStart(varargin)
        toggleControlState('run');
        newObj.fun.start();
        toggleControlState('idle');
    end

    %# skip button callback
    function onSkip(varargin)
        newObj.fun.skip();
    end

    %# cancel button callback
    function onCancel(varargin)
        newObj.fun.cancel();
        toggleControlState('idle');
    end

    %# (de)activate button state
    function toggleControlState(varargin)
        possible_modes = {'off','idle','run'};
        input = inputParser;
        addOptional(input,'mode','off',@(x) any(validatestring(x,possible_modes)));
        parse(input,varargin{:});
        
        switch input.Results.mode
            case 'off'
                guiObj.Start.Enable = con_on_off(0);
                guiObj.Stop.Enable = con_on_off(0);
                guiObj.Skip.Enable = con_on_off(0);
            case 'idle'
                guiObj.Start.Enable = con_on_off(1);
                guiObj.Stop.Enable = con_on_off(0);
                guiObj.Skip.Enable = con_on_off(0);
            case 'run'
                guiObj.Start.Enable = con_on_off(0);
                guiObj.Stop.Enable = con_on_off(1);
                guiObj.Skip.Enable = con_on_off(1);
            otherwise
                return;
        end
    end
end