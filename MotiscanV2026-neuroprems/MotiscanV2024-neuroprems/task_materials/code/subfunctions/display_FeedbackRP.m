function [] = display_FeedbackRP( WindowPtr, feedbacktype, total1, total2, xcenter, ycenter )


% Display_Feedback (gain and loss version)
% shows the total earnings as a kilometer counter
% written by Raphael Le Bouc - January 2014.

% Feedback type : 1=Gain, -1=loss
% total1 : total earning at previous trial
% total2 : total earnings at current trial
% xcenter and ycenter : coordinate of the center of the screen


%___________________
% display parameters
Screen('TextSize', WindowPtr, 60);

% determine text sizes
int=1.2; % space between letters (%)
[w,h]=RectSize(Screen('TextBounds',WindowPtr,'0'));
[wcomma,hcomma]=RectSize(Screen('TextBounds',WindowPtr,','));
[wplus,hplus]=RectSize(Screen('TextBounds',WindowPtr,'+'));
[wmoins,hmoins]=RectSize(Screen('TextBounds',WindowPtr,'-'));
[wtext,~]=RectSize(Screen('TextBounds',WindowPtr,'Total'));
[wnum,~]=RectSize(Screen('TextBounds',WindowPtr,'-000.000 €'));
shift=(wtext+int*wnum)/2; % left adjustment of counter
% shift=200;


freeztime=1;                                                               % previous total display time
nstep=16;                                                                  % scrolling steps number
steptime=1/nstep;                                                          % scrolling steps duration

col=[255 255 255;                                                          % define digit color
    255 255 255;
    255 255 255;
    255 255 255;
    128 128 128;
    128 128 128;
    128 128 128;
    128 128 128];

%The display is not the same on windows and linux : 
%________________________________________________

if isunix
    ycomma1=ycenter-h-hcomma/2;
    ycomma2=ycenter+h/2-hcomma/2;
    ymaskup=ycenter-h/2;
    ymaskdown=ycenter+h/2;
else
    ycomma1=ycenter-2*h;
    ycomma2=ycenter-h/2;
    ymaskup=ycenter-0.7*h/2;
    ymaskdown=ycenter+0.7*h/2;
end
    

%___________________
% formatize totals
if total1>=0
    t1  = ['+' sprintf('%07.3f',total1)];
else
    t1  = ['-' sprintf('%07.3f',abs(total1))];
end
if total2>=0
    t2  = ['+' sprintf('%07.3f',total2)];
else
    t2  = ['-' sprintf('%07.3f',abs(total2))];
end

g   = sprintf('% 8.3f',abs(total2-total1));                                % 8 character long, padded with spaces.
spacepad = regexp(g,' ');
switch feedbacktype
    case 1, g(spacepad(end))='+';
    case -1, g(spacepad(end))='-';
end


%_______________________
% display text
Screen('DrawText',WindowPtr,'Total',xcenter-shift,ycenter-h/2,[255 255 255]);
%Screen('DrawText',WindowPtr,'€',xcenter-shift+wtext+9*int*w+w/2,ycenter-h/2,[255 255 255]);
switch feedbacktype
    case 1, Screen('DrawText',WindowPtr,'Gain',xcenter-shift,ycenter-2*h,[255 255 255]);
    case -1, Screen('DrawText',WindowPtr,'Perte',xcenter-shift,ycenter-2*h,[255 255 255]);
end


%________________________________
% display previous total and gain

% display trial gain
for i=1:length(g)
    if strcmp(g(i), '.') % show a comma instead of a period
        Screen('DrawText',WindowPtr,',',xcenter-shift+wtext-0.8*w/2+i*int*w,ycomma1,col(i,:));
    elseif strcmp(g(i), '+')
        Screen('DrawText',WindowPtr,g(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-1.5*h-hplus/2,col(i,:));
    elseif strcmp(g(i), '-')
        Screen('DrawText',WindowPtr,g(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-1.5*h-hmoins/2,col(i,:));
    else
        Screen('DrawText',WindowPtr,g(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-2*h,col(i,:));
    end
end

% display previous total
for i=1:length(t1)
   if strcmp(g(i), '.') % show a comma instead of a period
        Screen('DrawText',WindowPtr,',',xcenter-shift+wtext-0.8*w/2+i*int*w,ycomma2,col(i,:));
    elseif strcmp(t1(i), '+')
        Screen('DrawText',WindowPtr,t1(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-0*h-hplus/2,col(i,:));
    elseif strcmp(t1(i), '-')
        Screen('DrawText',WindowPtr,t1(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-0*h-hmoins/2,col(i,:));
    else
        Screen('DrawText',WindowPtr,t1(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-h/2,col(i,:));
    end
end
Screen(WindowPtr,'Flip');
WaitSecs(freeztime);


%_______________________
% display new total
timestart=GetSecs;
count=0;

while count<nstep
    
    tic;
    count=count+1;
    
    for i=1:length(t1)
        
        
   if strcmp(g(i), '.') % show a comma instead of a period
        Screen('DrawText',WindowPtr,',',xcenter-shift+wtext-0.8*w/2+i*int*w,ycomma2,col(i,:));
        elseif strcmp(t1(i), '+')
            Screen('DrawText',WindowPtr,t1(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-0*h-hplus/2,col(i,:));
        elseif strcmp(t1(i), '-')
            Screen('DrawText',WindowPtr,t1(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-0*h-hmoins/2,col(i,:));
        else
            if t1(i)==t2(i) % display unchanged digits
                Screen('DrawText',WindowPtr,t1(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-h/2,col(i,:));
                
            else % display changing digits
                
                % how many digits to scroll?
                switch feedbacktype*sign(total1+eps)
                    case 1
                        if t1(i)>t2(i)
                            nscroll=10-(t1(i)-t2(i));
                        else
                            nscroll=t2(i)-t1(i);
                        end
                    case -1
                        if t1(i)>t2(i)
                            nscroll=t1(i)-t2(i);
                        else
                            nscroll=10-(t2(i)-t1(i));
                        end
                end
                
                
                % scroll digits
                switch feedbacktype*sign(total1+eps)
                    case 1
                        for j=0:nscroll
                            Screen('DrawText',WindowPtr,num2str(mod(str2num(t1(i))+j,10)),xcenter-shift+wtext-w/2+i*int*w,ycenter+h*j-(count*h*nscroll)/nstep-h/2,col(i,:));
                        end
                    case -1
                        for j=0:nscroll
                            Screen('DrawText',WindowPtr,num2str(mod(str2num(t1(i))-j,10)),xcenter-shift+wtext-w/2+i*int*w,ycenter-h*j+(count*h*nscroll)/nstep-h/2,col(i,:));
                        end
                end
                
                
                
            end
            
        end
        
    end
    
    
    
    %______________________
    % Mask scrolling digits
    Screen('FillRect',WindowPtr,[0 0 0],[0 0 2*xcenter ymaskup]);
    Screen('FillRect',WindowPtr,[0 0 0],[0 ymaskdown (2*xcenter) (2*ycenter)]);
    
    %______________________
    % Re-draw a comma on top of the mask
    i=5;
    Screen('DrawText',WindowPtr,',',xcenter-shift+wtext-0.8*w/2+i*int*w,ycomma2,col(i,:));
    
    %_______________________
    % display text
    Screen('DrawText',WindowPtr,'Total',xcenter-shift,ycenter-h/2,[255 255 255]);
    %Screen('DrawText',WindowPtr,'€',xcenter-shift+wtext+9*int*w+w/2,ycenter-h/2,[255 255 255]);
    switch feedbacktype
        case 1, Screen('DrawText',WindowPtr,'Gain',xcenter-shift,ycenter-2*h,[255 255 255]);
        case -1, Screen('DrawText',WindowPtr,'Perte',xcenter-shift,ycenter-2*h,[255 255 255]);
    end
    
    
    
    %_______________________
    % display trial gain
    for i=1:length(g)
    if strcmp(g(i), '.') % show a comma instead of a period
        Screen('DrawText',WindowPtr,',',xcenter-shift+wtext-0.8*w/2+i*int*w,ycomma1,col(i,:));
        elseif strcmp(g(i), '+')
            Screen('DrawText',WindowPtr,g(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-1.5*h-hplus/2,col(i,:));
        elseif strcmp(g(i), '-')
            Screen('DrawText',WindowPtr,g(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-1.5*h-hmoins/2,col(i,:));
        else
            Screen('DrawText',WindowPtr,g(i),xcenter-shift+wtext-w/2+i*int*w,ycenter-2*h,col(i,:));
        end
    end
    
    Screen(WindowPtr,'Flip');
    WaitSecs(steptime-toc);
    
end





