function tick_patch = draw_tick

% input parameters
tick_type = 'x'; % y
tick_value = [-2,-1,0,1,2];
tick_label = [-2,-1,0,1,2]; % or {}
tick_num = length(tick_value);
tick_len = 0.2;
tick_tag = strcat(tick_type, 'tick');
tick_label_tag = strcat(tick_type, 'ticklabel');

for i = 1:tick_num
    if strcmpi(tick_type, 'x')
        x = [0 tick_len];
        y = [tick_value(i), tick_value(i)];
    elseif strcmpi(tick_type, 'y')
        x = [tick_value(i), tick_value(i)];
        y = [0 tick_len];
    end
    patchline(x,y);
end

% prepare data

