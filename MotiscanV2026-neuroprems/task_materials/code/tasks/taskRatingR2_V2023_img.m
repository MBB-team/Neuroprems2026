function [sub_data] = taskRatingR2_V2023_img(sub_data, cfg)
% function [sub_data] = taskRatingR2_V2023_img(sub_data, cfg)
%
% taskRatingR2 - execute the reward rating task (from motiscan battery V2)
% Launch the task with this function for testing one subject.
% The subject has to provide a subjective estimate of item likability.
%
%   task specifications: 
%       - structure: instructions -> training -> testing
%       - experimental conditions:  item subdomain (alimentary,
%       non-alimentary)
%       - randomization:  between-subject random permutation of items, random permutation of item subdomain
%       - ntrial = 24
%       - trial structure: display 1 option with a scale , record the rating
%       - training: exposure to several options (6 trials)
%
% Inputs: sub_data and cfg structures
%
% Outputs: updated sub_data with results = training_data and data tables
% with (trialNumber, itemNumber, rating, press_RT, validation_RT) for training and
% with (trialNumber, itemNumber, rating, press_RT, validation_RT) for testing
%
% Author: Raphael Le Bouc, Nicolas Borderies
% email address: nico.borderies@gmail.com 
% September 2013; Last revision: June 2017
%
% Updated March 2023 for V2023, R.JOLY

%% Configuration
% -----------------------------------------------
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
H        = display.H;
x        = display.x;
y        = display.y;

rectImgInstruction=[0 0 2*x 2*y];

key = cfg.ptb.key;

wait4release   = cfg.ptb.wait4release;
recordResponse = cfg.ptb.recordResponse;

taskName = 'RatingR2';

% fontsize
if isfield(cfg.ptb,mfilename)
        ftsz_iTask = cfg.ptb.fontsize.(mfilename);
else;   ftsz_iTask = cfg.ptb.fontsize.global;
end
ftsz_big    = ftsz_iTask.ftsz_big;
ftsz_mid    = ftsz_iTask.ftsz_mid;
ftsz_small  = ftsz_iTask.ftsz_small;

% Load stimuli
%-----------------------------------------------

cd(cfg.paths.task.images); % enter img dir

% informative icons
cross=Screen('MakeTexture',display.window,imread('Cross.bmp'));
rectcross=CenterRectOnPoint(Screen('Rect',cross),x,y);
rectImg=[x-3*y/8, y/8, x+3*y/8, 7*y/8];
yScale = y/2;
yemoji= y + yScale + 100 ;
xScaleLim = [x*1/5,x*9/5];
[img,map] = imread('emoji_neutral.png');
img = ind2rgb(img,map);img = img.*255;
emoji_neutral=Screen('MakeTexture',display.window,img);
rect_emoji_neutral=CenterRectOnPoint(Screen('Rect',emoji_neutral),xScaleLim(1),yemoji);
emoji_infinite=Screen('MakeTexture',display.window,imread('emoji_reward.png'));
rect_emoji_infinite=CenterRectOnPoint(Screen('Rect',emoji_infinite),xScaleLim(2),yemoji);

% instructions images
instruction = struct('texture',{},'position',{});
for i=1:3
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_' taskName '_' num2str(i) '.bmp']));
end

cd(cfg.paths.task.text) % extracting text

% text items
rewardList = readstim('rewards2.xlsx');

cd(cfg.paths.task.code) % returning to code directory

% Items images
imgItem = struct('texture',{},'position',{});
for i=1:24
    imgItem(i).texture = Screen('MakeTexture',display.window,imread(['img_rewards2_' num2str(i) '.bmp']));
end

% Experimental conditions
%-----------------------------------------------
nTrial   = 20;

% randomization
trialperm = randperm(nTrial);

% sample list adaptation
% Adaptation of reward list for the NeuroPrems study
%subsample = 1:24;
subsample = [1 2 3 5 6 7 8 9 11 12 13 15 16 17 18 19 20 21 23 24];
rewardList = rewardList(subsample);
imgItem = imgItem(subsample);

% timing variables
intertrial_duration=0.75;
intertrial_jitter=0.5;

% Data preparation
%-----------------------------------------------
% testing
rating                  = nan(1,nTrial);
press_responsetime      = nan(1,nTrial);
validation_responsetime = nan(1,nTrial);
cursor                  = cell(1,nTrial);

%% Testing
%-----------------------------------------------
% display
textstring = 'Instructions';
DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(0.2);
KbWait;

% instruction: explanations
for i=1:3
    Screen('DrawTexture',display.window,instruction(i).texture,[],rectImgInstruction);
    Screen(display.window,'Flip');
    WaitSecs(1);
    KbWait;
end

% instructions:  start
textstring = 'Prêt à débuter ?';
DrawMyText(display.window,textstring,ftsz_big,[255 255 255],[x,y]);
textstring = 'appuyer sur une touche pour continuer';
DrawMyText(display.window,textstring,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(1);
KbWait;
wait4release()

% Trial structure
%-----------------------------------------------
stoptask=0;ntrial=0; repeat=0;
while ntrial<nTrial
    
    if repeat==0
        ntrial=ntrial+1;
    end
    
    if stoptask
        break
    end
    
    % int
    Screen('DrawTexture',display.window,cross,[],rectcross);
    KbReleaseWait;
    wait4release()
    Screen(display.window,'Flip');
    WaitSecs( intertrial_duration + rand*intertrial_jitter );
    
    %  Check Response
    exit=0;
    iCursor = 1;
    cursor{ntrial}(iCursor) = 50;
    buttons = 0;
    
    % Get trialtime
    startime=GetSecs;
    
    while exit==0
        % Write item
        DrawMyText(display.window,rewardList{trialperm(ntrial)},ftsz_small,[255 255 255],[x,y]);

        % Display stimulus image
        Screen('DrawTexture',display.window,imgItem(trialperm(ntrial)).texture,[],rectImg);
        
        % Write instructions
        question_name = 'Ça me plaît :';
        answer_names = {'Pas du tout','Enormément'};
        draw_scale_instruction_2(display.window,x,y,question_name,answer_names,ftsz_small);
        Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
        Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
        
        % Display cursor and scale
        display_rating_likert(display.window,x,y,[]);
        Screen(display.window,'Flip');
        iCursor = iCursor + 1;
        cursor{ntrial}(iCursor) = cursor{ntrial}(iCursor-1);
        
        % Check keys
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % monitor validation & exit
            if  keycode(key.space)==1
                exit=1;
                validation_responsetime(ntrial) = GetSecs - startime;
            elseif keycode(key.escape)==1
                exit     = 1;
                stoptask = 1;
            else % keyboard arrows
                % monitor rating time
                if isnan(press_responsetime(ntrial))
                    press_responsetime(ntrial) = GetSecs - startime;
                end
                if  keycode(key.right)==1
                    cursor{ntrial}(iCursor)=min([cursor{ntrial}(iCursor)+1 100]);
                elseif keycode(key.left)==1
                    cursor{ntrial}(iCursor)=max([cursor{ntrial}(iCursor)-1 0]);
                end
            end
        end
        
        [xMouse,yMouse,buttons] = recordResponse(display.window);
        xcursor = (xMouse - xScaleLim(1))/diff(xScaleLim)*100;
        xcursor = round(max([min([xcursor,100]),0]));
        cursor{ntrial}(iCursor) = xcursor ;
        % monitor rating time
        if isnan(press_responsetime(ntrial)) && cursor{ntrial}(iCursor)~=cursor{ntrial}(1)
            press_responsetime(ntrial) = GetSecs - startime;
        end
        % monitor confirmation
        exit = any(buttons~=0) & (yMouse>=y);
        validation_responsetime(ntrial) = GetSecs - startime;
        WaitSecs(0.007);
    end
    
    % Update data to save
    rating(ntrial)=cursor{ntrial}(iCursor);
    
    DrawMyText(display.window,rewardList{trialperm(ntrial)},ftsz_small,[255 255 255],[x,y]);
    draw_scale_instruction_2(display.window,x,y,question_name,answer_names,ftsz_small);
    display_rating_likert(display.window,x,y,rating(ntrial)) ;
    Screen('DrawTexture',display.window,emoji_neutral,[],rect_emoji_neutral);
    Screen('DrawTexture',display.window,emoji_infinite,[],rect_emoji_infinite);
    Screen('DrawTexture',display.window,imgItem(trialperm(ntrial)).texture,[],rectImg);
    
    Screen(display.window,'Flip');
    WaitSecs(1);
end

% Ratings transformation (from 0->100 to 0->10)
rating(rating <5)   = 0;
rating(rating <95 & rating >=5) = ceil((rating(rating <95 & rating >=5)-4)/10);
rating(rating >=95) = 10;

% display end
Screen(display.window,'Flip');
Screen('CloseAll');

%% Data saving
%-----------------------------------------------
% data creation
itemNumberReal = subsample(trialperm);   % real item IDs, e.g. 1 2 4 5 ... 24

varNames = {'trialNumber', 'itemNumber', 'rating', 'press_RT', 'validation_RT'};
data     = table((1:nTrial)', itemNumberReal(:), rating', press_responsetime', validation_responsetime', 'VariableNames', varNames);
% saving
sub_data.(cfg.sessNber_str).tasks.taskRatingR2.results      = struct('data', data);
% Do we really need this ?
sub_data.(cfg.sessNber_str).tasks.taskRatingR2.rewardList   = rewardList;

end

