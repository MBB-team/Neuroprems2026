function [] = draw_scale_instruction_3(WindowHandle,x,y,question,answers,ftsz)
    
    [W,H]=Screen('WindowSize',WindowHandle);
    x=W/2;
    y=H/2;
    xScaleLim = [x*1/5,x*9/5];
    yscale = 1/2*y;
%     xScaleLim = [x-400,x+400];
%     yscale = 200;

    DrawMyText(WindowHandle,question,ftsz,[100 100 100],[x,y-100+yscale]);
    DrawMyText(WindowHandle,answers{1},ftsz,[255 153 0],[xScaleLim(1)-25,y-60+5/12*y]);
    DrawMyText(WindowHandle,answers{2},ftsz,[255 153 0],[xScaleLim(1)-25,y-60+yscale]);
    DrawMyText(WindowHandle,answers{3},ftsz,[255 153 0],[xScaleLim(2)+25,y-60+5/12*y]);
    DrawMyText(WindowHandle,answers{4},ftsz,[255 153 0],[xScaleLim(2)+25,y-60+yscale]);



end