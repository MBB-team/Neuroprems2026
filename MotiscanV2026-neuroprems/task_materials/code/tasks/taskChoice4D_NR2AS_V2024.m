                                                                                                                                                                  
function [sub_data] = taskChoice4D_NR2AS_V2024(sub_data, cfg)
%
% taskChoice4D_NR2AS_V2023 - execute the Norm Violation/reward/Audience/AversiveSanction 3-D choice task
% Launch the task with this function for testing one subject.
% The subject has choose to accept or reject an action, consituted of a
% norm violation, benefit, an audience and a sanction item
%
%   task specifications:
%       - structure: instructions -> training -> testing
%       - experimental conditions: Norm violation, option benefit, audience, aversive sanction, 
%       -attentional manipulation was removed from this version
%       - randomization:
%           pseudo-random permutation of norms violations, benefit,
%           audience and sanctions
%       - ntrial = 48
%       -choice between two lists of 12 norms each, balanced for
%       alimentary/nonalimentary and the severity of the norm
%       - trial structure: display 1 option with a norm violation, benefit
%       component, and sanction; choose one option (Y/N)
%       - training: exposure to several options (6 trials)
%
% Inputs: sub_data and cfg structures
%
% Outputs: updated sub_data with results = training_data and data tables
% with (trialNumber, isUpChoice, choicePosition, isAccept, RT) for training and
% with (trialNumber, itemNumberNormViolation, ratingNormViolation, itemNumberBenefit, ratingBenefit, itemNumberSanction, ratingSanction, 
%       isUpChoice, choicePosition, isAccept, 'RT') for testing
%
% Author: Raphael Le Bouc, Nicolas Borderies
% email address: nico.borderies@gmail.com
% September 2013; Last revision: June 2017
%
% Updated March 2020 for V2, P. CARRILLO
% Updated March 2024 for V3, making it 4D with aversive sanction, A. CLEROUIN


appariementTestingList1_file ='appariement4D_liste1_NR2AS.xlsx';

appariement_testing = readtable(appariementTestingList1_file);

ListeNb = 1;

%% Configuration
cfg = motiscanV2020_setTask(cfg);

display  = cfg.ptb.display;
L        = display.L;
H        = display.H;
x        = display.x;
y        = display.y;
win_l = [0 0 x H];
win_r = [x 0 L H];
rectImgInstruction=[0 0 2*x 2*y];
% winLup_coor = [0 0 x y];
% winLdo_coor = [0 y x H];
% winRup_coor = [x 0 L y];
% winRdo_coor = [x y L H];

key = cfg.ptb.key;

wait4release   = cfg.ptb.wait4release;
recordResponse = cfg.ptb.recordResponse;

% fontsize
if isfield(cfg.ptb,mfilename)
        ftsz_iTask = cfg.ptb.fontsize.(mfilename);
else;   ftsz_iTask = cfg.ptb.fontsize.global;
end
ftsz_big    = ftsz_iTask.ftsz_big;
ftsz_mid    = ftsz_iTask.ftsz_mid;
ftsz_small  = ftsz_iTask.ftsz_small;
% maxCharPline_instruc = ftsz_iTask.maxCharPline_instruc;
maxCharPline_instruc = 75;
% max_charPline = ftsz_iTask.maxCharPline_instruc;
max_charPline = 22;

% Load stimuli
%-----------------------------------------------

norm_ratingTaskName = 'taskRatingN';
%benefit_ratingTaskName = 'taskRatingR2';
sanction_ratingTaskName    = 'taskRatingS'; %audience
aversivesanction_ratingTaskName = 'taskRatingAS';

% testing items
normTestingList_file = 'SocialNormViolations.xlsx';
benefitTestingList_file = 'rewards2.xlsx';
sanctionTestingList_file = 'SocialSanctions.xlsx'; %audience
aversivesanctionTestingList_file = 'aversivesanctions.xlsx';
%appariementTestingList_file = 'appariement4D_NR2AS.xlsx'; %not use now we
%have list


norm_testingList = readstim(normTestingList_file)';
norm_testingList = cellfun(@(x) strrep(x, '\n', ''), norm_testingList, 'UniformOutput', false);

benefit_testingList = readstim(benefitTestingList_file)';

sanction_testingList = readstim(sanctionTestingList_file)';
sanction_testingList = cellfun(@(x) strrep(x, '\n', ''), sanction_testingList, 'UniformOutput', false);

aversivesanction_testingList = readstim(aversivesanctionTestingList_file)';
%appariement_testing = readtable(appariementTestingList_file);


%cd(cfg.paths.task.images); % enter img dir
% informative icons
cross=Screen('MakeTexture',display.window,imread('Cross.bmp'));
rectcross=CenterRectOnPoint(Screen('Rect',cross),x,y);

% instructions images
instruction = struct('texture',{},'position',{});
for i=1:2
    instruction(i).texture = Screen('MakeTexture',display.window,imread(['instruction_4D_'  num2str(i) '.bmp']));
end

% Stimuli images
imgItemN = struct('texture',{},'position',{});
imgItemR = struct('texture',{},'position',{});
imgItemS0 = struct('texture',{},'position',{});
imgItemS1 = struct('texture',{},'position',{});
imgItemAS0 = struct('texture',{},'position',{});
imgItemAS1 = struct('texture',{},'position',{});
imgItemAS2 = struct('texture',{},'position',{});

for i=1:24
    imgItemR(i).texture = Screen('MakeTexture',display.window,imread(['img_rewards2_' num2str(i) '.bmp']));
    imgItemN(i).texture = Screen('MakeTexture',display.window,imread(['img_SocialNormViolations_' num2str(i) '.bmp']));
end
for i=1:12
    imgItemS0(i).texture = Screen('MakeTexture',display.window,imread(['img_SocialSanctions0_' num2str(i) '.bmp']));
    imgItemS1(i).texture = Screen('MakeTexture',display.window,imread(['img_SocialSanctions1_' num2str(i) '.bmp']));
    imgItemAS0(i).texture = Screen('MakeTexture',display.window,imread(['img_AversiveSanction0_' num2str(i) '.bmp']));
    imgItemAS1(i).texture = Screen('MakeTexture',display.window,imread(['img_AversiveSanction1_' num2str(i) '.bmp']));
    imgItemAS2(i).texture = Screen('MakeTexture',display.window,imread(['img_AversiveSanction2_' num2str(i) '.bmp']));
end
    

%cd(cfg.paths.task.text) % extracting text

% recurring textstring
text.instruc = 'Instructions';
text.appuyer = 'appuyer sur une touche pour continuer...';
text.pretDebut = 'Prêt à débuter ?';
text.accept = 'Je pourrais'; % text.accept = 'Il pourrait m''arriver de';
text.pour = 'pour'; % text.pour = 'pour obtenir';
text.situation = 'dans cette situation';
text.risque = 'vous risquez';
text.oui = 'OUI';
text.non = 'NON';
text.timesUp = 'Temps coul !';
text.faster = 'Rpondez plus rapidement svp.';

% Experimental conditions
%-----------------------------------------------
nTrial      = 24;

% timing variables
ITI_duration = 0.5;
blanktime = 0.4;
ITI_jitter = 0.5;
waitAft_bigTtl = 0.2;
waitAft_instruc = 0.5;
waitAft_trial = 0.007;
maxResponseDuration = 10e3;
stim1_duration = 3; % first option(s) on screen
stim2_duration = 3; % second option(s) on screen

% Extract Ratings
% Check if the participant has completed the rating task
if isfield(sub_data.(cfg.sessNber_str).tasks, 'taskRatingR2') && ...
   isfield(sub_data.(cfg.sessNber_str).tasks.taskRatingR2, 'results') && ...
   isfield(sub_data.(cfg.sessNber_str).tasks.taskRatingR2.results, 'data')

    rtg_import = sub_data.(cfg.sessNber_str).tasks.taskRatingR2.results.data;
    ratingsBenefit = nan(24,1);                              % full 1..24 range
    ratingsBenefit(rtg_import.itemNumber) = rtg_import.rating; % place at item number
else
    ratingsBenefit = nan(24,1);
end

% Extract ratings
% tempA = sortrows(sub_data.(cfg.sessNber_str).tasks.(norm_ratingTaskName).results.data,...
%     'itemNumber', 'ascend');
%tempB = sortrows(sub_data.(cfg.sessNber_str).tasks.(benefit_ratingTaskName).results.data,...
    %'itemNumber', 'ascend');
% tempC = sortrows(sub_data.(cfg.sessNber_str).tasks.(sanction_ratingTaskName).results.data,...
%     'itemNumber', 'ascend');
% tempD = sortrows(sub_data.(cfg.sessNber_str).tasks.(aversivesanction_ratingTaskName).results.data,...
%     'itemNumber', 'ascend');

% tempA_training = sortrows(sub_data.(cfg.sessNber_str).tasks.(norm_ratingTaskName).results.trainingData,...
%     'itemNumber', 'ascend');
%tempB_training = sortrows(sub_data.(cfg.sessNber_str).tasks.(benefit_ratingTaskName).results.trainingData,...
    %'itemNumber', 'ascend');
% tempC_training = sortrows(sub_data.(cfg.sessNber_str).tasks.(sanction_ratingTaskName).results.trainingData,...
%     'itemNumber', 'ascend');
% tempD_training = sortrows(sub_data.(cfg.sessNber_str).tasks.(aversivesanction_ratingTaskName).results.trainingData,...
%     'itemNumber', 'ascend');

%ratingsNorm     = tempA.rating(1:24);
ratingsNorm     = nan(24,1); % No ratingN for neuroprems. Use pilot ratings from controls.
%ratingsSanction = tempC.rating(1:12);
ratingsSanction = nan(12,1); % No ratingS for neuroprems. Use pilot ratings from controls.
%ratingsAversiveSanction = tempD.rating(1:12);
ratingsAversiveSanction = nan(12,1); % No ratingAS for neuroprems. Use pilot ratings from controls.

clear temp*
%cd(cfg.paths.task.code) % returning to code directory

%% OLD pairing, non-fixed
% first series of choices (anticorrelated): the highest P is proposed with the lowest E,
% the second highest P and the second lowest E, and so on...
% Second series (correlated): the highest P is proposed with the highest E,
% % the second highest P and the second highest E, and so on...
% [~,iB] = sort(ratingsBenefit,'ascend');
% [~,iC] = sort(ratingsCost,'ascend');
% 
% stimB = iB([ 1:24    , 1:24 ]);
% stimC = iC([ 24:-1:1 , 1:24 ]);
% 
% randomtrial = randperm(48);
% 
% stimR = stimB(randomtrial);
% stimE = stimC(randomtrial);

% %% New fixed pairing
% index = readtable(pairingList_file);
% index = table2array(index);
% index = index(randperm(size(index, 1)), :); % random permutation of rows
% stimB = index(:,2);
% stimC = index(:,1);

%% Create vectors of experimental factors

% (Adaptation for Neuroprems study)
stimN = [1:12 1:12]; % Each norme repeated 2 times
stimR = [repmat(1,1,4) repmat(2,1,4) repmat(3,1,4)]; 
stimR = [stimR(randperm(length(stimR))) stimR(randperm(length(stimR)))]; % Rlevel randomized across stimN, but not counterbalanced within norm (not enough trials)
stimS = [repmat(0,1,12) repmat(1,1,12) ];
stimAS = [repmat(0,1,4) repmat(1,1,4) repmat(2,1,4) repmat(2,1,4) repmat(1,1,4) repmat(0,1,4)]; % (0=no AS, 1=known AS, 2=uncertain AS)

index = randperm(nTrial);
stimN = stimN(index);
stimR = stimR(index);
stimS = stimS(index);
stimAS = stimAS(index);


% Data preparation
%-----------------------------------------------
% Inter-subject side randomization
sidesub = mod(sub_data.sub_id,2);

% testing
isUpChoice    = nan(1,nTrial);
choice_position = nan(1,nTrial);
choicedo        = nan(1,nTrial);
rt              = nan(1,nTrial);
sideyes         = sidesub.*(ones(1,nTrial)); % 0=down, 1=up

%% Testing
%-----------------------------------------------
% instructions:  start
% display
DrawMyText(display.window,text.instruc,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(0.2);
KbWait;

% instruction: explanations
for i=1:2
    Screen('DrawTexture',display.window,instruction(i).texture,[],rectImgInstruction);
    Screen(display.window,'Flip');
    WaitSecs(1);
    KbWait;
end

DrawMyText(display.window,text.pretDebut,ftsz_big,[255 255 255],[x,y]);
DrawMyText(display.window,text.appuyer,ftsz_small,[100 100 100],[x,H*4/5]);
Screen(display.window,'Flip');
WaitSecs(waitAft_bigTtl);
KbWait;
wait4release()

% Trial structure
%-----------------------------------------------
interrupt_task=0;iTrial=0; repeat=0;
while iTrial<nTrial
    
    if repeat==0
        iTrial=iTrial+1;
    end
    
    if interrupt_task
        break
    end
    
    % int
    Screen('DrawTexture',display.window,cross,[],rectcross);
    KbReleaseWait;
    Screen(display.window,'Flip');
    WaitSecs(ITI_duration);
    wait4release()
    
    text.N = norm_testingList{appariement_testing{stimN(iTrial),1}}; % Norm number
    text.R = benefit_testingList{appariement_testing{stimN(iTrial),1+stimR(iTrial)}}; % Reward number
    text.S = sanction_testingList{appariement_testing{stimN(iTrial),5},1+stimS(iTrial)}; % Sanction {number,level}
    text.AS = aversivesanction_testingList{appariement_testing{stimN(iTrial),6},1+stimAS(iTrial)}; %a verifier avec RLB
        
    img.N = imgItemN(appariement_testing{stimN(iTrial),1}).texture;
    img.R = imgItemR(appariement_testing{stimN(iTrial),1+stimR(iTrial)}).texture;
    switch stimS(iTrial)
        case 0
            img.S = imgItemS0(appariement_testing{stimN(iTrial),5}).texture;
        case 1
            img.S = imgItemS1(appariement_testing{stimN(iTrial),5}).texture;
    end

     switch stimAS(iTrial)
        case 0
            img.AS = imgItemAS0(appariement_testing{stimN(iTrial),6}).texture; %% to check
        case 1
            img.AS = imgItemAS1(appariement_testing{stimN(iTrial),6}).texture; %% to check
         case 2
            img.AS = imgItemAS2(appariement_testing{stimN(iTrial),6}).texture;
    end

    % Write instructions & options only for all stimuli
    % (without Yes/No options)
    disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,sideyes(iTrial),3,0);
    startime = Screen(display.window,'Flip');
    %Screen(display.window,'Flip');
    WaitSecs(stim2_duration);

    % Write instructions & options only for all stimuli
    % (With Yes/No options)
    disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,sideyes(iTrial),3,1);
    Screen(display.window,'Flip');
    
    % Check Response
    exit=0;
    while exit==0
        % refresh screen
        disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,sideyes(iTrial),3,1)
        Screen(display.window,'Flip');
        
        % Record Response
        [keyisdown, ~, keycode] = KbCheck;
        if keyisdown==1
            % monitor validation & exit
            if keycode(key.escape)==1
                exit=1;
                timedown=GetSecs;
                interrupt_task=1;
            else
                if  keycode(key.up)==1
                    exit=1;
                    timedown=GetSecs;
                    isUpChoice(iTrial)=1;                                              %-1=up
                    repeat=0;
                elseif keycode(key.down)==1
                    exit=1;
                    timedown=GetSecs;
                    isUpChoice(iTrial)=0;                                               %1=down
                    repeat=0;
                end
            end
        end
        [xMouse, yMouse, buttons] = recordResponse(display.window);
        if buttons(1)~=0 && yMouse > y
                        % Check if the mouse click is above the stipple line
            if yMouse > 4*y/4 && yMouse < 5.9*y/4
                % Record response if mouse clicked above the stipple line
                isUpChoice(iTrial) = 1; % Up choice
                timedown = GetSecs;
                repeat = 0;
                exit = 1;
            elseif yMouse > 6.1*y/4 && yMouse < 2*y
                % Record response as down if clicked below stipple line
                isUpChoice(iTrial) = 0; % Down choice
                timedown = GetSecs;
                repeat = 0;
                exit = 1;
            end
        end
        WaitSecs(waitAft_trial);
        
        if isUpChoice(iTrial) == sideyes(iTrial)
            choicedo(iTrial) = 1;
        else
            choicedo(iTrial) = 0;
        end
        
        % Monitor maximal response time
        timePassed = GetSecs-startime;
        if timePassed>maxResponseDuration
            exit=1;
            repeat=repeat+1;
        end
    end
    
    if repeat==0
        rt(iTrial)=timedown-startime;
        % Show Response
        [yes_color,no_color] = color_yesno(choicedo(iTrial));
        disp_trial(display,ftsz_small,max_charPline,text,img,win_l,win_r,   ...
            sideyes(iTrial),3,1,yes_color,no_color)

        Screen(display.window,'Flip');
        tresponse = GetSecs;
        while GetSecs <= tresponse + blanktime
            
        end
    else
        % instruction: speed-up warning
        DrawMyText(display.window,text.timesUp,ftsz_big,[255 255 255],[x,y]);
        DrawMyText(display.window,text.faster,ftsz_big,[255 255 255],[x,y*1.2]);
        Screen(display.window,'Flip');
        WaitSecs(blanktime+1);
    end
end

% display end
Screen(display.window,'Flip');
sca;

%% Data saving
%-----------------------------------------------
varNames      = {'trialNumber','ListNumber','itemNumberNorm', 'ratingNorm', 'itemNumberBenefit', 'levelBenefit', 'ratingBenefit', 'itemNumberSanction', 'levelSanction','ratingSanction', 'itemNumberAversiveSanction', 'levelAversiveSanction','ratingAversiveSanction','isUpChoice', 'choicePosition', 'isAccept', 'RT'};

itemNumberNorm = appariement_testing{stimN,1};
ratingNorm    = ratingsNorm(appariement_testing{stimN,1});


%ratingNorm    = ratingsNorm(stimN(:));
ListNbUsed = repmat (ListeNb, 1, nTrial);



count=0;
for j=stimR+1
    count=count+1;
    stimR_Nbr(count) = appariement_testing{stimN(count),j};
end

ratingBenefit = ratingsBenefit(stimR_Nbr(:));
stimS_Nbr     = appariement_testing{stimN,5};
ratingSanction= ratingsSanction(stimS_Nbr).*stimS';% consider rating equal zero for no sanction
stimAS_Nbr     = appariement_testing{stimN,6};
ratingAversiveSanction = ratingsAversiveSanction(stimAS_Nbr).*(stimAS==1)';

data          = table((1:nTrial)',ListNbUsed', itemNumberNorm,ratingNorm,stimR_Nbr', stimR', ratingBenefit,stimS_Nbr,stimS',ratingSanction,stimAS_Nbr,stimAS',ratingAversiveSanction,isUpChoice',choice_position',choicedo',rt','VariableNames',varNames);

%removed 'isBenefitFirstOnScreen', and stimOrder',
%'nameNorm',  nameNorm =norm_testingList{appariement_testing{stimN(nTrial),1}};   ,nameNorm'



% saving
if interrupt_task
    %sub_data.(cfg.sessNbertaskRatingN_str).tasks.taskChoice4DNR2AS.completed...
    sub_data.(cfg.sessNber_str).tasks.taskChoice4DNR2AS.completed...
        = false;
else; sub_data.(cfg.sessNber_str).tasks.taskChoice4DNR2AS.completed...
        = true;
end
sub_data.(cfg.sessNber_str).tasks.taskChoice4DNR2AS.results =      ...
    struct('data', data);
    
end

function [] = disp_trial(display,ftsz,max_charPline,text,img,win_l,win_r,   ...
    side_oui,whichstim,show_response,varargin)

H = display.H;
x = display.x;
y = display.y;

rectImg1=[x/4-3*y/8, y/8, x/4+2*y/8, 7*y/8];
rectImg2=[3*x/4-3*y/8, y/8, 3*x/4+2*y/8, 7*y/8];
rectImg3=[5*x/4-3*y/8, y/8, 5*x/4+2*y/8, 7*y/8];
rectImg4=[7*x/4-3*y/8, y/8, 7*x/4+2*y/8, 7*y/8];

%rectImg1=[x/4-3*y/8, y/8, x/4+3*y/8, 7*y/8];
%rectImg2=[3*x/4-3*y/8, y/8, 3*x/4+3*y/8, 7*y/8];
%rectImg3=[5*x/4-3*y/8, y/8, 5*x/4+3*y/8, 7*y/8];
%rectImg4=[7*x/4-3*y/8, y/8, 7*x/4+3*y/8, 7*y/8]; %%AS okay??


% y20_acpt = 4;
% y20_pour = 8;
y20_resp = 14;

txt_accept_size = Screen('TextSize', display.window);

if nargin > 10; color_yes = varargin{1}; color_no = varargin{2};
else; color_yes = [255 255 255]; color_no = [255 255 255];
end

Screen('TextSize', display.window, ftsz);

%%change et ajouter pour AS + retirer case 1 and case 2 ??

switch whichstim
    %case 1
        %DrawFormattedText(display.window,text.pour,'center','center',[100 100 100],max_charPline,0,0,1,0);
        %DrawFormattedText(display.window,text.R,'center',9*y/8,[255 255 255],max_charPline,0,0,1,0);
        %Screen('DrawTexture',display.window,img.R,[],rectImg2);
     
    %case 2
        %DrawFormattedText(display.window,text.accept,x/3-3*y/8,'center',[100 100 100],max_charPline,0,0,1,0);
        %DrawFormattedText(display.window,text.N,x/3-3*y/8,9*y/8,[255 255 255],max_charPline, 0,0,1,0);
        %Screen('DrawTexture',display.window,img.N,[],rectImg1);

        %DrawFormattedText(display.window,text.situation,5*x/3-3*y/8,'center',[100 100 100],max_charPline,0,0,1,0);
        %DrawFormattedText(display.window,text.S,5*x/3-3*y/8,9*y/8,[255 255 255],max_charPline,0,0,1,0);
        %Screen('DrawTexture',display.window,img.S,[],rectImg3);

    case 3 %%avant case 3
        DrawFormattedText(display.window,text.accept,x/4-3*y/8,'center',[100 100 100],max_charPline,0,0,1,0);%%check les coordonnes
        %DrawFormattedText(display.window,text.N,x/4-3*y/8,9*y/8,[255 255 255],max_charPline, 0,0,1,0);
        DrawFormattedText(display.window, text.N, x/4-3*y/8, 9*y/8, [255 255 255], max_charPline, 0, 0, 1, 0);%%check les coordonnes
        Screen('DrawTexture',display.window,img.N,[],rectImg1);

        DrawFormattedText(display.window,text.pour,3*x/4-3*y/8,'center',[100 100 100],max_charPline,0,0,1,0);%%check les coordonnes
        DrawFormattedText(display.window,text.R,3*x/4-3*y/8,9*y/8,[255 255 255],max_charPline,0,0,1,0);%%check les coordonnes
        Screen('DrawTexture',display.window,img.R,[],rectImg2);

        DrawFormattedText(display.window,text.situation,5*x/4-3*y/8,'center',[100 100 100],max_charPline,0,0,1,0);%%check les coordonnes
        DrawFormattedText(display.window,text.S,5*x/4-3*y/8,9*y/8,[255 255 255],max_charPline,0,0,1,0);%%check les coordonnes
        Screen('DrawTexture',display.window,img.S,[],rectImg3);

        DrawFormattedText(display.window,text.risque,7*x/4-3*y/8,'center',[100 100 100],max_charPline,0,0,1,0); %%check les coordonnes
        DrawFormattedText(display.window,text.AS,7*x/4-3*y/8,9*y/8,[255 255 255],max_charPline,0,0,1,0);%%check les coordonnes
        Screen('DrawTexture',display.window,img.AS,[],rectImg4);


end


if show_response
    if side_oui == 0
    DrawFormattedText(display.window,text.oui,'center',1.70*y,color_yes,max_charPline,0,0,2,0); % oui down
    DrawFormattedText(display.window,text.non,'center',1.30*y,color_no,max_charPline,0,0,2,0); % non up
    else
    DrawFormattedText(display.window,text.oui,'center',1.30*y,color_yes,max_charPline,0,0,2,0); % oui up
    DrawFormattedText(display.window,text.non,'center',1.70*y,color_no,max_charPline,0,0,2,0); % non down
    end


    Screen('LineStipple',display.window, 1, 2, mod(ceil((1:16)/8),2));
    Screen('DrawLine', display.window, [255 255 255]*0.5,x/2,3*y/2,3*x/2,3*y/2, 3);

end

end

function [color_yes,color_no] = color_yesno(choice)
color_yes = [255*(choice==0) 255 255*(choice==0)];
color_no  = [255*(choice==1) 255 255*(choice==1)];
end