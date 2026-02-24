function [] = Display_Effort( WindowPtr, xcenter,ycenter, level, incentive )


% Adaptation of the Emotional grip force task (Schmidt et al.,
% JNeurosci2009; Clery-Melin et al., Plos One, 2011) fot Matlab and
% PsychToolbox.
%
% Display_Effort draws the vertical effort scale, and an orange cursor indicating the
% force level.
% 
% written by Raphael Le Bouc - May 2013.


% correct level to display only positive values
level = max([level,0]);

% draw the scale (horizontal bars)
for yaxis=-300:60/5:300
    Screen('DrawLine',WindowPtr,[100 0 0],(xcenter-200), (ycenter+yaxis), (xcenter+200), (ycenter+yaxis),1);
end
for yaxis=-240:60:300
    Screen('DrawLine',WindowPtr,[255 255 255],(xcenter-200), (ycenter+yaxis), (xcenter+200), (ycenter+yaxis),3);
end

% draw ticks on the y-axis
if exist('incentive','var')
    Screen('TextSize', WindowPtr, 16);
    yaxis=[-300:60:300];
    for ntick=1:11
        tick=num2str(incentive*(ntick-1)/10);
        [w,h]=RectSize(Screen('TextBounds',WindowPtr,tick));
        Screen('DrawText',WindowPtr,tick,xcenter-210-w,ycenter-yaxis(ntick)-h/2,[255 255 255]);
    end
end


% draw the scale (vertical bar)
Screen('DrawLine',WindowPtr,[255 255 255],(xcenter-200), (ycenter+300), (xcenter-200), (ycenter-300),3);


% draw the orange cursor
col=[255 153 0];
Screen('FillRect',WindowPtr,col,[(xcenter-20) (ycenter+300-level/100*600) (xcenter+20) (ycenter+310)]);



end

