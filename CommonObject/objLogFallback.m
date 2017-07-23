function objLogFallback(varargin)
    temp_var = varargin{1};
    if ischar(temp_var)
        helpdlg(temp_var);
    else
        disp('Wrong parameter type for objLogFallback!');
    end
end