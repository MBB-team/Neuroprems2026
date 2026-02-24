function [] = display_effortTarget_precision( WindowPtr, xcenter,ycenter, level , target, range )


% Adaptation of the Emotional grip force task (Schmidt et al.,
% JNeurosci2009; Clery-Melin et al., Plos One, 2011) fot Matlab and
% PsychToolbox.
%
% Display_Effort draws the vertical effort scale, and an orange cursor indicating the
% force level.
% 
% written by Raphael Le Bouc - May 2013.

level = max([level,0]);


ylimScale = [ -3/4*ycenter  3/4*ycenter  ];
yScaleRange = ylimScale(2) - ylimScale(1);
xlimScale = [-200 200];
nTick = 25;

% draw the scale (horizontal bars)
for yaxis = ylimScale(1)
    Screen('DrawLine',WindowPtr,[255 255 255],(xcenter-200), (ycenter+yaxis), (xcenter+200), (ycenter+yaxis),3);
end
for yaxis = ylimScale(1):yScaleRange/nTick:ylimScale(2)
    Screen('DrawLine',WindowPtr,[100 0 0],(xcenter-200), (ycenter+yaxis), (xcenter+200), (ycenter+yaxis),1);
end


% draw the target 
rect = [0 0 diff(xlimScale) range*yScaleRange];
rect = CenterRectOnPoint(rect,xcenter,(ycenter+ylimScale(2)-target*yScaleRange));
Screen('FrameRect',WindowPtr,[0 255 0],rect,3);

% draw the orange cursor
col=[255 153 0];
Screen('FillRect',WindowPtr,col,[(xcenter-20) (ycenter+ylimScale(2)-level/100*yScaleRange) (xcenter+20) (ycenter+1.05*ylimScale(2))]);



end

