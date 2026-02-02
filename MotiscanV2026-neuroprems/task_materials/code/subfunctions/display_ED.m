function [] = Display_Effort( WindowPtr, xcenter,ycenter, effort_level, cursor_level )


% Effort discounting task for Matlab and
% PsychToolbox.
%
% Display_Effort draws the vertical effort scale, and an orange cursor indicating the
% force level.
% 
% written by Raphael Le Bouc - January 2014.

ycenter=ycenter+100;
ysize=250;
ngrad=12;

% draw the scale (horizontal bars)
for yaxis=-ysize:2*ysize/ngrad/5:ysize
    Screen('DrawLine',WindowPtr,[100 0 0],(xcenter-200), (ycenter+yaxis), (xcenter+200), (ycenter+yaxis),1);
end
for yaxis=-ysize:2*ysize/ngrad:ysize
    Screen('DrawLine',WindowPtr,[255 255 255],(xcenter-200), (ycenter+yaxis), (xcenter+200), (ycenter+yaxis),3);
end


% draw the scale (vertical bar)
Screen('DrawLine',WindowPtr,[255 255 255],(xcenter-200), (ycenter+ysize), (xcenter-200), (ycenter-ysize),3);


% draw the target effort (horizontal red bar)
yaxis=ysize-(2*ysize*10/ngrad)*effort_level/100;
Screen('DrawLine',WindowPtr,[255 0 0],(xcenter-200), (ycenter+yaxis), (xcenter+200), (ycenter+yaxis),3);


% draw the orange cursor
col=[255 153 0];
Screen('FillRect',WindowPtr,col,[(xcenter-20) (ycenter+ysize-cursor_level/100*(2*ysize*10/ngrad)) (xcenter+20) (ycenter+ysize+10)]);



end

