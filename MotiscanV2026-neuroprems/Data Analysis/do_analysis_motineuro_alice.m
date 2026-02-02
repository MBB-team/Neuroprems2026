clear all;
close all;

%% set analysis
% NB:

subjects = [77:79 100 200:201 400];
sess = 1;

%% get data

data = cell(numel(subjects),4); 
%%%%%%%%%%%%%%% Transform into a table (with variablenames) as soon as possible %%%%%%%%%%%%%%%%


i=0;
for nsub = subjects
    for nsess = sess

        i = i+1;

        [datasub] = get_data_motineuro(nsub,nsess);
        data{i,1} = datasub.sub_data.sub_id;
        if data{i,1} >=200 & data{i,1}<205
            data{i,2} = 'FTD';
        elseif data{i,1} >=400 & data{i,1}<599
            data{i,2} = 'AD';
        elseif (data{i,1} >=77) & data{i,1}<199
            data{i,2} = 'CTRL';
        end
        data{i,3} = datasub.sub_data.sess1.date;
        data{i,4} = datasub.sub_data.(['sess',num2str(sess)]).cfg;
        data{i,5} = datasub.sub_data.sess1.tasks;

    end
end

%% Extract task model free measures
i=0;
for nsub = subjects
    for nsess = sess

        i = i+1;

        % Extract ratingR2 measures
        try data{i, 5}.taskRatingR2;
            data{i,6} = mean(data{i, 5}.taskRatingR2.results.data.rating); % mean ratingR2
            data{i,7} = median(data{i, 5}.taskRatingR2.results.data.validation_RT); % median ratingR2 RT
        catch
            disp(['subject',num2str(nsub),'has no data for taskRatingR2']);
            data{i,6} = NaN;
            data{i,7} = NaN;
        end

        % Extract ratingE2 measures
        try data{i, 5}.taskRatingE2;
            data{i,8} = mean(data{i, 5}.taskRatingE2.results.data.rating); % mean ratingE2
            data{i,9} = median(data{i, 5}.taskRatingE2.results.data.validation_RT); % median ratingE2 RT
        catch
             disp(['subject',num2str(nsub),'has no data for taskRatingE2']);
             data{i,8} = NaN;
             data{i,9} = NaN;
        end



           % Extract ratingN measures
        try data{i, 5}.taskRatingN;
            data{i,10} = mean(data{i, 5}.taskRatingN.results.data.rating); % mean ratingN
            data{i,11} = median(data{i, 5}.taskRatingN.results.data.validation_RT); % median ratingN RT
        catch
            disp(['subject',num2str(nsub),'has no data for taskRatingN']);
            data{i,10} = NaN;
            data{i,11} = NaN;
        end


        % Extract ratingS measures
        try data{i, 5}.taskRatingS;
            data{i,12} = mean(data{i, 5}.taskRatingS.results.data.rating); % mean ratingS
            data{i,13} = median(data{i, 5}.taskRatingS.results.data.validation_RT); % median ratingS RT
        catch
            disp(['subject',num2str(nsub),'has no data for taskRatingS']);
            data{i,12} = NaN;
            data{i,13} = NaN;
        end


        % Extract ratingAS measures
        try data{i, 5}.taskRatingAS;
            data{i,14} = mean(data{i, 5}.taskRatingAS.results.data.rating); % mean ratingS
            data{i,15} = median(data{i, 5}.taskRatingAS.results.data.validation_RT); % median ratingS RT
        catch
            disp(['subject',num2str(nsub),'has no data for taskRatingAS']);
            data{i,14} = NaN;
            data{i,15} = NaN;
        end




        % Extract ChoiceR2 measures
        try data{i, 5}.taskChoiceR21D;
            data{i,16} = mean((data{i, 5}.taskChoiceR21D.results.data.ratingLeft>...
                                 data{i, 5}.taskChoiceR21D.results.data.ratingRight) ==...
                                 data{i, 5}.taskChoiceR21D.results.data.isLeftChoice); % mean choiceR2 consistency
            data{i,17} = median(data{i, 5}.taskChoiceR21D.results.data.RT); % median choiceR2 RT
        catch
            disp(['subject',num2str(nsub),'has no data for taskChoiceR21D']);
            data{i,16} = NaN;
            data{i,17} = NaN;
        end

        % Extract ChoiceE2 measures
        try data{i, 5}.taskChoiceE21D;
            data{i,18} = mean((data{i, 5}.taskChoiceE21D.results.data.ratingLeft<...
                                 data{i, 5}.taskChoiceE21D.results.data.ratingRight) ==...
                                 data{i, 5}.taskChoiceE21D.results.data.isLeftChoice); % mean choiceE2 consistency
            data{i,19} = median(data{i, 5}.taskChoiceE21D.results.data.RT); % median choiceE2 RT
        catch
            disp(['subject',num2str(nsub),'has no data for taskChoiceE21D']);
            data{i,18} = NaN;
            data{i,19} = NaN;
        end

         % Extract ChoiceN measures
        try data{i, 5}.taskChoiceN1D;
            data{i,20} = mean((data{i, 5}.taskChoiceN1D.results.data.ratingLeft<...
                                 data{i, 5}.taskChoiceN1D.results.data.ratingRight) ==...
                                 data{i, 5}.taskChoiceN1D.results.data.isLeftChoice); % mean choiceN consistency
            data{i,21} = median(data{i, 5}.taskChoiceN1D.results.data.RT); % median choiceN RT
        catch
            disp(['subject',num2str(nsub),'has no data for taskChoiceN1D']);
            data{i,20} = NaN;
            data{i,21} = NaN;
        end



        % Extract ControlPerception measures
        surf = readmatrix('greylevel_socialnorms.xlsx');
        try data{i, 5}.taskControlPerception;
            data{i,22} = mean((surf(data{i, 5}.taskControlPerception.results.data.itemNumberLeft)>...
                                 surf(data{i, 5}.taskControlPerception.results.data.itemNumberRight)) == ...
                                 data{i, 5}.taskControlPerception.results.data.isLeftChoice); % mean taskControlPerception consistency
            data{i,23} = median(data{i, 5}.taskControlPerception.results.data.RT); % median taskControlPerception RT
        catch
            disp(['subject',num2str(nsub),'has no data for taskControlPerception']);
            data{i,22} = NaN;
            data{i,23} = NaN;
        end

        % Extract ControlSemantic measures
        try data{i, 5}.taskControlSemantic;
            data{i,24} = mean(data{i, 5}.taskControlSemantic.results.data.isCorrect); % mean taskControlSemantic consistency
            data{i,25} = median(data{i, 5}.taskControlSemantic.results.data.RT); % median taskControlSemantic RT
        catch
            disp(['subject',num2str(nsub),'has no data for taskControlSemantic']);
            data{i,24} = NaN;
            data{i,25} = NaN;
        end


        % Extract ControlTOM measures
        try data{i, 5}.taskControlTOM;
            data{i,26} = mean(data{i, 5}.taskControlTOM.results.data.isCorrect); % mean taskControlTOM consistency
            data{i,27} = median(data{i, 5}.taskControlTOM.results.data.RT); % median taskControlTOM RT
        catch
            disp(['subject',num2str(nsub),'has no data for taskControlTOM']);
            data{i,26} = NaN;
            data{i,27} = NaN;
        end
        


        % Extract Choice4DNR2AS measures

        try data{i, 5}.taskChoice4DNR2AS;
            idx_lowR = find(data{i, 5}.taskChoice4DNR2AS.results.data.ratingBenefit<median(data{i, 5}.taskChoice4DNR2AS.results.data.ratingBenefit));
            idx_highR = find(data{i, 5}.taskChoice4DNR2AS.results.data.ratingBenefit>=median(data{i, 5}.taskChoice4DNR2AS.results.data.ratingBenefit));
            idx_lowN = find(data{i, 5}.taskChoice4DNR2AS.results.data.ratingNorm<median(data{i, 5}.taskChoice4DNR2AS.results.data.ratingNorm));
            idx_highN = find(data{i, 5}.taskChoice4DNR2AS.results.data.ratingNorm>=median(data{i, 5}.taskChoice4DNR2AS.results.data.ratingNorm));
            idx_S0 = find(data{i, 5}.taskChoice4DNR2AS.results.data.levelSanction==0);
            idx_S1 = find(data{i, 5}.taskChoice4DNR2AS.results.data.levelSanction==1);
            idx_lowS = find(data{i, 5}.taskChoice4DNR2AS.results.data.ratingSanction(idx_S1)<median(data{i, 5}.taskChoice4DNR2AS.results.data.ratingSanction(idx_S1)));
            idx_lowS = idx_S1(idx_lowS);
            idx_highS = find(data{i, 5}.taskChoice4DNR2AS.results.data.ratingSanction(idx_S1)>=median(data{i, 5}.taskChoice4DNR2AS.results.data.ratingSanction(idx_S1)));
            idx_highS = idx_S1(idx_highS);
            idx_AS0 = find(data{i, 5}.taskChoice4DNR2AS.results.data.levelAversiveSanction==0);
            idx_AS1 = find(data{i, 5}.taskChoice4DNR2AS.results.data.levelAversiveSanction==1);
            idx_lowAS = find(data{i, 5}.taskChoice4DNR2AS.results.data.ratingAversiveSanction(idx_AS1)<median(data{i, 5}.taskChoice4DNR2AS.results.data.ratingAversiveSanction(idx_AS1)));
            idx_lowAS = idx_AS1(idx_lowAS);
            idx_highAS = find(data{i, 5}.taskChoice4DNR2AS.results.data.ratingAversiveSanction(idx_AS1)>=median(data{i, 5}.taskChoice4DNR2AS.results.data.ratingAversiveSanction(idx_AS1)));
            idx_highAS = idx_AS1(idx_highAS);


%             data{i,26} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept); % global acceptance rate
% 
%             data{i,27} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_highR))... 
%                          - mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_lowR)); % Acceptance rate for high R minus Low R
% 
%             data{i,28} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_highN))...
%                          - mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_lowN)); % Acceptance rate for high N minus Low N
% 

% 
%             data{i,30} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_highS))...
%                          - mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_lowS)); % Acceptance rate for (High ratingS & levelS=1) minus (low ratingS & levelS=1) 
%             
%             data{i,31} =  mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_Bfirst1))...
%                          - mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_Bfirst0)); % Acceptance rate for isBenefitFirstOnScreen=1 minus isBenefitFirstOnScreen=0 
%             
%             data{i,32} = median(data{i, 5}.taskChoice4DNR2AS.results.data.RT); % Response time


            data{i,28} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept); % global acceptance rate
            data{i,29} = median(data{i, 5}.taskChoice4DNR2AS.results.data.RT); % Response time

            data{i,30} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_highR));% Acceptance rate for high R
            data{i,31} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_lowR));% Acceptance rate for Low R
            data{i,32} = data{i,30}- data{i,31}; % Acceptance rate for high R minus Low R

            data{i,33} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_highN));% Acceptance rate for high N
            data{i,34} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_lowN)); % Acceptance rate forLow N
            data{i,35} = data{i,33} - data{i,34};% Acceptance rate for high N minus Low N

            data{i,36} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_S1));% Acceptance rate for S1
            data{i,37} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_S0)); % Acceptance rate for S0
            data{i,38} = data{i,36} - data{i,37};% Acceptance rate for S1 minus S0

            data{i,39} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_highS));% Acceptance rate for high S
            data{i,40} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_lowS)); % Acceptance rate forLow S
            data{i,41} = data{i,39} - data{i,40};% Acceptance rate for high S minus Low S

            data{i,42} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_AS1));% Acceptance rate for S1
            data{i,43} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_AS0)); % Acceptance rate for S0
            data{i,44} = data{i,42} - data{i,43};% Acceptance rate for AS1 minus AS0

            data{i,45} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_highAS));% Acceptance rate for high AS
            data{i,46} = mean(data{i, 5}.taskChoice4DNR2AS.results.data.isAccept(idx_lowAS)); % Acceptance rate forLow AS
            data{i,47} = data{i,45} - data{i,46};% Acceptance rate for high AS minus Low AS



%             data{i,29} = nanmean(data{i, 5}.task4DNR2ASS.results.data.isAccept(idx_S1))...
%                          - nanmean(data{i, 5}.task4DNR2AS.results.data.isAccept(idx_S0)); % Acceptance rate for levelS=1 minus LevelS=0
% 
%             data{i,30} = nanmean(data{i, 5}.task4DNR2AS.results.data.isAccept(idx_highS))...
%                          - nanmean(data{i, 5}.task4DNR2AS.results.data.isAccept(idx_lowS)); % Acceptance rate for (High ratingS & levelS=1) minus (low ratingS & levelS=1) 
%             
%             data{i,31} =  nanmean(data{i, 5}.taskChoice3DNRS.results.data.isAccept(idx_Bfirst1))...
%                          - nanmean(data{i, 5}.taskChoice3DNRS.results.data.isAccept(idx_Bfirst0)); % Acceptance rate for isBenefitFirstOnScreen=1 minus isBenefitFirstOnScreen=0 
             
            

        catch
            disp(['subject',num2str(nsub),'has no data for taskChoice4DNR2AS']);
        end




    end
end

%% plot results
idx{1} = find(strcmp(data(:,2),'AD'));
idx{2} = find(strcmp(data(:,2),'FTD'));
idx{3} = find(strcmp(data(:,2),'CTRL'));
%idx{4} = find(strcmp(data(:,2),'AD'));

groupname = {'FTD','AD','CTRL'};
groupcol = {[1 0 0], [0 1 0], [0 0 1], [0.5 0.5 0.5]};
varname = {'Subject Id','Group','Date','Sessions','Tasks','Reward rating','Reward rating time','Effort rating',...
    'Effort rating time','Norm rating','Norm rating time','Reputation concern rating','Reputation concern rating time',...
    'Aversive sanction rating','Aversive sanction rating time', ...
    'Reward choice consistency','Reward choice time','Effort choice consistency','Effort choice time',...
    'Norm choice consistency','Norm choice time','Control Perception consistency',...
    'Control Perception time','Control Semantic consistency','Control Semantic time',...
    'Control TOM consistency','Control TOM time',...
    'Norm violation','Norm violation choice time',...
    'norm violation (High reward)','norm violation (Low reward)','Reward effect \newlineon norm violation',...
    'norm violation (High Norm)','norm violation (Low Norm)','Norm effect \newlineon norm violation',...
    'norm violation (Audience)','norm violation (No Audience)','Audience effect \newlineon norm violation',...
    'norm violation (High reputation)','norm violation (Low reputation)','Reputation effect \newlineon norm violation',...
    'norm violation (Av sanction)','norm violation (No Av sanction)','Av sanction effect \newlineon norm violation',...
    'norm violation (High sanction','norm violation (Low sanction)','Sanction effect \newlineon norm violation'};



table = cell2table(data,'VariableNames',varname);

%'norm violation (Benefit first on screen)','norm violation (Cost first on screen)','Attention effect \newlineon norm violation'

% Plot rating R2 results
for nvar = 6:7
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end

disp('ttest rating R2 results (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},6}],[data{idx{3},6}]);
%disp('ttest rating R2 results (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},6}],[data{idx{4},6}]);


%mean rating R2 DFT
mean([data{idx{2},6}]);
%mean rating R2 MA
%mean([data{idx{4},6}]);
%mean rating R2 CTRL
mean([data{idx{3},6}]);

% Plot rating E2 results
for nvar = 8:9
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end
disp('ttest rating E2 results (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},8}],[data{idx{3},8}])
%disp('ttest rating E2 results (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},8}],[data{idx{4},8}])

%mean rating E2 DFT
mean([data{idx{2},8}]);
%mean rating E2 MA
%mean([data{idx{3},8}])
%mean rating E2 CTRL
mean([data{idx{3},8}])

% Plot rating N results
for nvar = 10:11
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end
disp('ttest rating N results (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},10}],[data{idx{3},10}])
%disp('ttest rating N results (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},10}],[data{idx{4},10}])

%mean rating N DFT
mean([data{idx{2},10}])
%mean rating N MA
%mean([data{idx{3},10}])
%mean rating N CTRL
mean([data{idx{3},10}])

% disp('ttest rating N results (Pilot vs Ctrl)');
% [h,p]=ttest2([data{idx{1},10}],[data{idx{4},10}])


% Plot rating S results
for nvar = 12:13
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end
disp('ttest rating S results (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},12}],[data{idx{3},12}])
%disp('ttest rating S results (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},12}],[data{idx{4},12}])

%mean rating S DFT
mean([data{idx{2},12}]);
%mean rating S MA
%mean([data{idx{3},12}])
%mean rating S CTRL
mean([data{idx{3},12}])

% Plot rating AS results
for nvar = 14:15
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end
disp('ttest rating S results (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},14}],[data{idx{3},14}])
%disp('ttest rating S results (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},12}],[data{idx{4},12}])

%mean rating S DFT
mean([data{idx{2},14}]);
%mean rating S MA
%mean([data{idx{3},12}])
%mean rating S CTRL
mean([data{idx{3},14}])



% Plot Choice R21D results
for nvar = 16:17
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end
disp('ttest Choice R21D results (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},16}],[data{idx{3},16}])

%disp('ttest Choice R21D results (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},16}],[data{idx{4},14}])

% mean consistency R21D for FTD
mean([data{idx{2},16}])
% mean consistency R21D for MA
%mean([data{idx{3},14}])
% mean consistency R21D for CTRL
mean([data{idx{3},16}])

% Plot Choice E21D results
for nvar = 18:19
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end
disp('ttest Choice E21D results (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},18}],[data{idx{3},18}])
%disp('ttest Choice E21D results (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},16}],[data{idx{4},16}])

% mean consistency E21D for FTD
mean([data{idx{2},18}])
% mean consistency E21D for MA
%mean([data{idx{3},16}])
% mean consistency E21D for CTRL
mean([data{idx{3},18}])

% Plot Choice N1D results
for nvar = 20:21
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end
disp('ttest Choice N1D results (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},18}],[data{idx{3},20}])
%disp('ttest Choice N1D results (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},18}],[data{idx{4},18}])

% mean consistency N1D for FTD
mean([data{idx{2},20}])
% mean consistency N1D for MA
%mean([data{idx{3},20}])
% mean consistency N1D for CTRL
mean([data{idx{3},20}])

% Plot Choice Control Perception results
for nvar = 22:23
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end
disp('ttest Choice Control Perception results (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},22}],[data{idx{3},22}])
%disp('ttest Choice Control Perception results (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},22}],[data{idx{4},22}])


% mean consistency perception for FTD
mean([data{idx{2},22}])
% mean consistency perception for MA
%mean([data{idx{3},22}])
% mean consistency perception for CTRL
nmean([data{idx{3},22}])


% Plot Choice Control Semantic results
for nvar = 24:25
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end
disp('ttest Choice Control Semantic results (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},24}],[data{idx{3},24}])
%disp('ttest Choice Control Semantic results (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},24}],[data{idx{4},24}])

% mean consistency semantic for FTD
mean([data{idx{2},24}])
% mean consistency semantic for MA
%mean([data{idx{3},24}])
% mean consistency semantic for CTRL
mean([data{idx{3},24}])

% Plot Choice Control TOM results
for nvar =26:27
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end
disp('ttest Choice Control TOM (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},26}],[data{idx{3},26}])

%disp('ttest Choice Control TOM (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},26}],[data{idx{4},26}])

% mean consistency TOM for FTD
mean([data{idx{2},26}])
% mean consistency TOM for MA
%mean([data{idx{3},26}])
% mean consistency TOM for CTRL
mean([data{idx{3},26}])


%% Plot Choice4DNR2AS results 
for nvar = [28 29 32 35 38 41 44 47]
    figure('Color','w','Position',[0 0 300 300]);
    hold on;
    for ngroup = 1:length(idx)
        jitter = (rand(1,numel(idx{ngroup}))/10)-0.05;
        bar(ngroup,mean([data{idx{ngroup},nvar}]),'FaceColor',groupcol{ngroup});
        scatter(ngroup+jitter,[data{idx{ngroup},nvar}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
        errorbar(ngroup,mean([data{idx{ngroup},nvar}]),std([data{idx{ngroup},nvar}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    end
    set(gca,'Xtick',1:length(idx),'XTicklabel',groupname);
    ylabel(varname(nvar));
    xtickangle(60);
end
disp('ttest norm violation (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},28}],[data{idx{3},28}])
%disp('ttest norm violation (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},28}],[data{idx{4},28}])
disp('ttest reward effect on norm vilation (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},32}],[data{idx{3},32}])
%disp('ttest reward effect on norm vilation (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},30}],[data{idx{4},30}])
disp('ttest audience effect on norm vilation (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},38}],[data{idx{3},38}])
%disp('ttest audience effect on norm vilation (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},36}],[data{idx{4},36}])
disp('ttest norm effect on norm vilation (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},35}],[data{idx{3},35}])
%disp('ttest norm effect on norm vilation (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},33}],[data{idx{4},33}])
disp('ttest reputation effect on norm vilation (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},41}],[data{idx{3},41}])
%disp('ttest reputation effect on norm vilation (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},39}],[data{idx{4},39}])
disp('ttest attention effect on norm vilation (DFT vs Ctrl)');
[h,p,~,stats]=ttest2([data{idx{2},44}],[data{idx{3},44}])
%disp('ttest attention effect on norm vilation (MA vs Ctrl)');
%[h,p,~,stats]=ttest2([data{idx{3},42}],[data{idx{4},42}])
% disp('ttest reward effect on norm vilation (Pilot vs Ctrl)');
% [h,p]=ttest2([data{idx{1},30}],[data{idx{4},30}])


%mean norm violation DFT
mean([data{idx{2},26}])
%mean norm violation MA
mean([data{idx{3},26}])
%mean norm violation CTRL
mean([data{idx{4},26}])
%mean norm effect on norm violation DFT
mean([data{idx{2},33}])
%mean norm effect on norm violation MA
mean([data{idx{3},33}])
%mean norm effect on norm violation CTRL
mean([data{idx{4},33}])
%mean audience effect on norm violation DFT
mean([data{idx{2},36}])
%mean audience effect on norm violation MA
mean([data{idx{3},36}])
%mean audience effect on norm violation CTRL
mean([data{idx{4},36}])
%mean reward effect on norm violation DFT
mean([data{idx{2},30}])
%mean reward effect on norm violation MA
mean([data{idx{3},30}])
%mean reward effect on norm violation CTRL
mean([data{idx{4},30}])
%mean attention effect on norm violation DFT
mean([data{idx{2},42}])
%mean attention effect on norm violation MA
mean([data{idx{3},42}])
%mean attention effect on norm violation CTRL
mean([data{idx{4},42}])
%mean reputation effect on norm violation DFT
nanmean([data{idx{2},39}])
%mean reputation effect on norm violation MA
nanmean([data{idx{3},39}])
%mean reputation effect on norm violation CTRL
nanmean([data{idx{4},39}])

% reward median split
nvar1=29;
nvar2=28;
figure('Color','w','Position',[0 0 300 300]);
hold on;
for ngroup = 2:length(idx)
    jitter = (rand(1,numel(idx{ngroup}))/10)-0.05;
    bar(ngroup-0.2,nanmean([data{idx{ngroup},nvar1}]),0.4,'FaceColor',groupcol{ngroup});
    bar(ngroup+0.2,nanmean([data{idx{ngroup},nvar2}]),0.4,'FaceColor',groupcol{ngroup});
    scatter(ngroup-0.2+jitter,[data{idx{ngroup},nvar1}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
    scatter(ngroup+0.2+jitter,[data{idx{ngroup},nvar2}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
    errorbar(ngroup-0.2,nanmean([data{idx{ngroup},nvar1}]),nanstd([data{idx{ngroup},nvar1}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    errorbar(ngroup+0.2,nanmean([data{idx{ngroup},nvar2}]),nanstd([data{idx{ngroup},nvar2}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');

end
set(gca,'Xtick',2:length(idx),'XTicklabel',groupname);
ylabel('Norm violation \newlineper reward level');
% ############## ADD A legend Here ###############
xtickangle(60);


disp('ttest norm violation for high vs low reward level (DFT)');
[h,p,~,stats]=ttest([data{idx{2},28}],[data{idx{2},29}])
disp('ttest norm violation for high vs low reward level (MA)');
[h,p,~,stats]=ttest([data{idx{3},28}],[data{idx{3},29}])
disp('ttest norm violation for high vs low reward level (Ctrl)');
[h,p,~,stats]=ttest([data{idx{4},28}],[data{idx{4},29}])


% difference mean norm violation for high - norm violation for low reward
% level in DFT
mean([data{idx{2},28}])-mean([data{idx{2},29}])
% difference mean norm violation for high - norm violation for low reward
% level in MA
mean([data{idx{3},28}])-mean([data{idx{3},29}])
% difference mean norm violation for high - norm violation for low reward
% level in CTRL
mean([data{idx{4},28}])-mean([data{idx{4},29}])


% norm median split
nvar1=32;
nvar2=31;
figure('Color','w','Position',[0 0 300 300]);
hold on;
for ngroup = 2:length(idx)
    jitter = (rand(1,numel(idx{ngroup}))/10)-0.05;
    bar(ngroup-0.2,nanmean([data{idx{ngroup},nvar1}]),0.4,'FaceColor',groupcol{ngroup});
    bar(ngroup+0.2,nanmean([data{idx{ngroup},nvar2}]),0.4,'FaceColor',groupcol{ngroup});
    scatter(ngroup-0.2+jitter,[data{idx{ngroup},nvar1}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
    scatter(ngroup+0.2+jitter,[data{idx{ngroup},nvar2}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
    errorbar(ngroup-0.2,nanmean([data{idx{ngroup},nvar1}]),nanstd([data{idx{ngroup},nvar1}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    errorbar(ngroup+0.2,nanmean([data{idx{ngroup},nvar2}]),nanstd([data{idx{ngroup},nvar2}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');

end
set(gca,'Xtick',2:length(idx),'XTicklabel',groupname);
ylabel('Norm violation \newlineper norm level');
xtickangle(60);

disp('ttest norm violation for high vs low norm level (DFT)');
[h,p,~,stats]=ttest([data{idx{2},32}],[data{idx{2},31}])
disp('ttest norm violation for high vs low norm level (MA)');
[h,p,~,stats]=ttest([data{idx{3},32}],[data{idx{3},31}])
disp('ttest norm violation for high vs low norm level (Ctrl)');
[h,p,~,stats]=ttest([data{idx{4},32}],[data{idx{4},31}])

% difference mean norm violation for high norm vs low norm in DFT
mean([data{idx{2},31}])-mean([data{idx{2},32}])
% difference mean norm violation for high norm vs low norm in MA
mean([data{idx{3},31}])-mean([data{idx{3},32}])
% difference mean norm violation for high norm vs low norm in CTRL
mean([data{idx{4},31}])-mean([data{idx{4},32}])

% audience
nvar1=35;
nvar2=34;
figure('Color','w','Position',[0 0 300 300]);
hold on;
for ngroup = 2:length(idx)
    jitter = (rand(1,numel(idx{ngroup}))/10)-0.05;
    bar(ngroup-0.2,nanmean([data{idx{ngroup},nvar1}]),0.4,'FaceColor',groupcol{ngroup});
    bar(ngroup+0.2,nanmean([data{idx{ngroup},nvar2}]),0.4,'FaceColor',groupcol{ngroup});
    scatter(ngroup-0.2+jitter,[data{idx{ngroup},nvar1}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
    scatter(ngroup+0.2+jitter,[data{idx{ngroup},nvar2}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
    errorbar(ngroup-0.2,nanmean([data{idx{ngroup},nvar1}]),nanstd([data{idx{ngroup},nvar1}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    errorbar(ngroup+0.2,nanmean([data{idx{ngroup},nvar2}]),nanstd([data{idx{ngroup},nvar2}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');

end
set(gca,'Xtick',2:length(idx),'XTicklabel',groupname);
ylabel('Norm violation \newlineper audience');
xtickangle(60);

disp('ttest norm violation for audience vs no audience (DFT)');
[h,p,~,stats]=ttest([data{idx{2},34}],[data{idx{2},35}])
disp('ttest norm violation for audience vs no audience (MA)');
[h,p,~,stats]=ttest([data{idx{3},34}],[data{idx{3},35}])
disp('ttest norm violation for audience vs no audience (Ctrl)');
[h,p,~,stats]=ttest([data{idx{4},34}],[data{idx{4},35}])

% difference mean norm violation for audience vs no audience in DFT
mean([data{idx{2},34}])-mean([data{idx{2},35}])
% difference mean norm violation for audience vs no audience in MA
mean([data{idx{3},34}])-mean([data{idx{3},35}])
% difference mean norm violation for audience vs no audience in CTRL
mean([data{idx{4},34}])-mean([data{idx{4},35}])


% reputation concern median split
nvar1=38;
nvar2=37;
figure('Color','w','Position',[0 0 300 300]);
hold on;
for ngroup = 2:length(idx)
    jitter = (rand(1,numel(idx{ngroup}))/10)-0.05;
    bar(ngroup-0.2,nanmean([data{idx{ngroup},nvar1}]),0.4,'FaceColor',groupcol{ngroup});
    bar(ngroup+0.2,nanmean([data{idx{ngroup},nvar2}]),0.4,'FaceColor',groupcol{ngroup});
    scatter(ngroup-0.2+jitter,[data{idx{ngroup},nvar1}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
    scatter(ngroup+0.2+jitter,[data{idx{ngroup},nvar2}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
    errorbar(ngroup-0.2,nanmean([data{idx{ngroup},nvar1}]),nanstd([data{idx{ngroup},nvar1}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    errorbar(ngroup+0.2,nanmean([data{idx{ngroup},nvar2}]),nanstd([data{idx{ngroup},nvar2}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');

end
set(gca,'Xtick',2:length(idx),'XTicklabel',groupname);
ylabel('Norm violation \newlineper reputation concern');
xtickangle(60);

disp('ttest norm violation for high vs low reputation (DFT)');
[h,p,~,stats]=ttest([data{idx{2},37}],[data{idx{2},38}])
disp('ttest norm violation for high vs low reputation (MA)');
[h,p,~,stats]=ttest([data{idx{3},37}],[data{idx{3},38}])
disp('ttest norm violation for high vs low reputation (Ctrl)');
[h,p,~,stats]=ttest([data{idx{4},37}],[data{idx{4},38}])

% difference mean norm violation for low vs high reputation in DFT
nanmean([data{idx{2},37}])-nanmean([data{idx{2},38}])
% difference mean norm violation for low vs high reputation in MA
nanmean([data{idx{3},37}])-nanmean([data{idx{3},38}])
% difference mean norm violation for low vs high reputation in CTRL
nanmean([data{idx{4},37}])-nanmean([data{idx{4},38}])


% attention effect
nvar1=41;
nvar2=40;
figure('Color','w','Position',[0 0 300 300]);
hold on;
for ngroup = 2:length(idx)
    jitter = (rand(1,numel(idx{ngroup}))/10)-0.05;
    bar(ngroup-0.2,nanmean([data{idx{ngroup},nvar1}]),0.4,'FaceColor',groupcol{ngroup});
    bar(ngroup+0.2,nanmean([data{idx{ngroup},nvar2}]),0.4,'FaceColor',groupcol{ngroup});
    scatter(ngroup-0.2+jitter,[data{idx{ngroup},nvar1}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
    scatter(ngroup+0.2+jitter,[data{idx{ngroup},nvar2}],30,'filled','MarkerFaceColor',[0.7 0.7 0.7],'MarkerEdgeColor','none');
    errorbar(ngroup-0.2,nanmean([data{idx{ngroup},nvar1}]),nanstd([data{idx{ngroup},nvar1}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');
    errorbar(ngroup+0.2,nanmean([data{idx{ngroup},nvar2}]),nanstd([data{idx{ngroup},nvar2}])/sqrt(numel(idx{ngroup})),'Color','k','LineStyle','none');

end
set(gca,'Xtick',2:length(idx),'XTicklabel',groupname);
ylabel('Norm violation \newlineper attention effect');
xtickangle(60);

disp('ttest norm violation for benefice vs cost first on screen (DFT)');
[h,p,~,stats]=ttest([data{idx{2},40}],[data{idx{2},41}])
disp('ttest norm violation for benefice vs cost first on screen (MA)');
[h,p,~,stats]=ttest([data{idx{3},40}],[data{idx{3},41}])
disp('ttest norm violation for benefice vs cost first on screen (Ctrl)');
[h,p,~,stats]=ttest([data{idx{4},40}],[data{idx{4},41}])

% difference mean norm violation for low vs high reputation in DFT
nanmean([data{idx{2},41}])-nanmean([data{idx{2},40}])
% difference mean norm violation for low vs high reputation in MA
nanmean([data{idx{3},41}])-nanmean([data{idx{3},40}])
% difference mean norm violation for low vs high reputation in CTRL
nanmean([data{idx{4},41}])-nanmean([data{idx{4},40}])


%% Logistic regression on 3DNRS choice task

%loop over subjects
% beta=[];
% i=0;
% for nsub = subjects
%     for nsess = sess
%         i = i+1;
%         if i > 6  %%exclude pilots. To be modified
% %         try data{i, 5}.taskChoice3DNRS.results.data;
%             mdl = fitglm(data{i, 5}.taskChoice3DNRS.results.data,'isAccept ~ ratingBenefit + ratingNorm + levelSanction + levelSanction:ratingSanction + isBenefitFirstOnScreen');
%             beta(i,:) = mdl.Coefficients{:,1}';
% %         catch
% %             disp(['no 3DNRS data for sub',num2str(nsub)]);
%         else
%             beta(i,:) = nan;
%         end
%     end
% end

%loop over subjects
beta=nan(length(subjects) * length(sess), 5);
i=0;
for nsub = subjects
    for nsess = sess
        i = i+1;
        %if i ~=[18:20,26,31,38]  %% exclude participants with low variability in behavioral response.
        if data{i,1} ~=[208:212,214,305,310,315]  %% exclude participants with low variability in behavioral response.
%         try data{i, 5}.taskChoice3DNRS.results.data;
            %mdl = fitglm(data{i, 5}.taskChoice3DNRS.results.data,'isAccept ~ ratingBenefit + ratingNorm + levelSanction + levelSanction:ratingSanction + isBenefitFirstOnScreen');
            data{i, 5}.taskChoice3DNRS.results.data.ratingBenefit_z = zscore(data{i, 5}.taskChoice3DNRS.results.data.ratingBenefit);
            data{i, 5}.taskChoice3DNRS.results.data.ratingNorm_z = zscore(data{i, 5}.taskChoice3DNRS.results.data.ratingNorm);
            data{i, 5}.taskChoice3DNRS.results.data.levelSanction_z = zscore(data{i, 5}.taskChoice3DNRS.results.data.levelSanction);
            data{i, 5}.taskChoice3DNRS.results.data.isBenefitFirstOnScreen_z = zscore(data{i, 5}.taskChoice3DNRS.results.data.isBenefitFirstOnScreen);
            mdl = fitglm(data{i, 5}.taskChoice3DNRS.results.data,'isAccept ~ ratingBenefit_z + ratingNorm_z + levelSanction_z + isBenefitFirstOnScreen_z','Distribution','binomial', 'Options',statset('Display','off','MaxIter',100000));
%             mdl = fitglm(data{i, 5}.taskChoice3DNRS.results.data,'isAccept ~ ratingBenefit_z + ratingNorm_z + levelSanction_z','Distribution','binomial', 'Options',statset('Display','off','MaxIter',100000));
            beta(i,:) = mdl.Coefficients{:,1}';
%         catch
%             disp(['no 3DNRS data for sub',num2str(nsub)]);
        else
            beta(i,:) = nan;
        end
    end
end


disp('ttest result in group control');
group_idx= find(strcmp(data(:,2),'CTRL'));
[h,p] = ttest(beta(group_idx,:))
nanmean(beta(group_idx,:),1)

disp('ttest result in AD group');
group_idx= find(strcmp(data(:,2),'AD'));
[h,p] = ttest(beta(group_idx,:))
nanmean(beta(group_idx,:),1)

disp('ttest result in FTD group');
group_idx= find(strcmp(data(:,2),'FTD'));
[h,p] = ttest(beta(group_idx,:))
nanmean(beta(group_idx,:),1)

disp('ttest result between FTD and CTRL groups');
group_idx1= find(strcmp(data(:,2),'FTD'));
group_idx2= find(strcmp(data(:,2),'CTRL'));
[h,p] = ttest2(beta(group_idx1,:),beta(group_idx2,:))




                

%% Correlation of social norm violation in tests, with FrSBe disinhibition difference for patients


% Chargement des donn�es Excel
excelData = xlsread('C:\Users\raphael.joly\ownCloud - JOLY Raphael (raphael.joly@icm-institute.org)@owncloud.icm-institute.org2\diagrammes r�sultats\statistiques\data_all.xlsx');

% Chargement de la cellule MATLAB contenant vos donn�es
% load(data);

% Initialisation des indices des controles (1 � 8)
% ControlIndices = [1:2, 7:8, 301:311]';
PatientIndices = [101:103, 105, 106, 108, 110, 111, 202, 208:211]';
rowPatientExcel = find(ismember(excelData(:, 1), PatientIndices));
rowPatientData = find(ismember(cell2mat(data(:,1)), PatientIndices));

% Extraction des donn�es de la colonne "disinhibition" pour les patients dans ControlIndices
disinhibitionData = excelData(rowPatientExcel, 11); % 11: colonne pour la DIFFERENCE de d�sinhibition dans le fichier excel

% Extraction des donn�es de la colonne 26 de la cellule pour les patients dans ControlIndices
cellData = cell2mat(data(rowPatientData, 26));

% Calcul de la corr�lation et de la p-valeur
[rho, p] = corr(cellData, disinhibitionData,'Type', 'Spearman');

% Affichage des r�sultats
disp('Corr�lation et p-valeur :');
disp([rho, p]);

%% Correlation of social norm violation in tests, with FrSBe actual disinhibition score for patients

% Chargement des donn�es Excel
excelData = xlsread('C:\Users\raphael.joly\ownCloud - JOLY Raphael (raphael.joly@icm-institute.org)@owncloud.icm-institute.org2\diagrammes r�sultats\statistiques\data_all.xlsx');

% Initialisation des indices des participants
PatientIndices = [101:103, 105, 106, 108, 110, 111, 202, 208:211]';
rowPatientExcel = find(ismember(excelData(:, 1), PatientIndices));
rowPatientData = find(ismember(cell2mat(data(:,1)), PatientIndices));

% Extraction des donn�es de la colonne "disinhibition" pour les participants dans PatientIndices
disinhibitionDataPatient = excelData(rowPatientExcel, 12); % 12: colonne pour la d�sinhibition ACTUELLE dans le fichier excel

% Extraction des donn�es de la colonne 26 de la cellule pour les patients dans ControlIndices
cellDataPatient = cell2mat(data(rowPatientData, 26));

% Calcul de la corr�lation et de la p-valeur
[rho, p] = corr(cellDataPatient, disinhibitionDataPatient,'Type', 'Spearman');

% Affichage des r�sultats
disp('Corr�lation et p-valeur :');
disp([rho, p]);


%% Correlation of social norm violation in tests, with FrSBe actual disinhibition score for controls

% Chargement des donn�es Excel
excelData = xlsread('C:\Users\raphael.joly\ownCloud - JOLY Raphael (raphael.joly@icm-institute.org)@owncloud.icm-institute.org2\diagrammes r�sultats\statistiques\data_all.xlsx');

% Initialisation des indices des participants
ControlIndices = [301:309]';
rowControlExcel = find(ismember(excelData(:, 1), ControlIndices));
rowControlData = find(ismember(cell2mat(data(:,1)), ControlIndices));

% Extraction des donn�es de la colonne "disinhibition" pour les participants dans ControlIndices
disinhibitionDataControl = excelData(rowControlExcel, 12); % 12: colonne pour la d�sinhibition ACTUELLE dans le fichier excel

% Extraction des donn�es de la colonne 26 de la cellule pour les patients dans ControlIndices
cellDataControl = cell2mat(data(rowControlData, 26));

% Calcul de la corr�lation et de la p-valeur
[rho, p] = corr(cellDataControl, disinhibitionDataControl,'Type', 'Spearman');

% Affichage des r�sultats
disp('Corr�lation et p-valeur :');
disp([rho, p]);


%% Correlation of social norm violation in tests, with FARDEAU/Zarit for patients


% Chargement des donn�es Excel
excelData = xlsread('C:\Users\raphael.joly\ownCloud - JOLY Raphael (raphael.joly@icm-institute.org)@owncloud.icm-institute.org2\diagrammes r�sultats\statistiques\data_all.xlsx');

% Chargement de la cellule MATLAB contenant vos donn�es
% load(data);

% Initialisation des indices des controles (1 � 8)
% ControlIndices = [1:2, 7:8, 301:311]';
PatientIndices = [101:103, 105, 106, 108, 110, 111, 202, 208:211]';
rowPatientExcel = find(ismember(excelData(:, 1), PatientIndices));
rowPatientData = find(ismember(cell2mat(data(:,1)), PatientIndices));

% Extraction des donn�es de la colonne "disinhibition" pour les patients dans ControlIndices
disinhibitionData = excelData(rowPatientExcel, 8); % 8: colonne pour ZARIT/Fardeau dans le fichier excel

% Extraction des donn�es de la colonne 26 de la cellule pour les patients dans ControlIndices
cellData = cell2mat(data(rowPatientData, 26));

% Calcul de la corr�lation et de la p-valeur
[rho, p] = corr(cellData, disinhibitionData,'Type', 'Spearman');

% Affichage des r�sultats
disp('Corr�lation et p-valeur :');
disp([rho, p]);


%% Correlation of sensibility to reward in 3DNRS task for FTD patients, with FrSBe disinhibition difference


% Chargement des donn�es Excel
excelData = xlsread('C:\Users\raphael.joly\ownCloud - JOLY Raphael (raphael.joly@icm-institute.org)@owncloud.icm-institute.org2\diagrammes r�sultats\statistiques\data_all.xlsx');

% Chargement de la cellule MATLAB contenant vos donn�es
% load(data);

% Initialisation des indices des controles (1 � 8)
% ControlIndices = [1:2, 7:8, 301:311]';
PatientIndices = [101:103, 105, 106, 108, 110, 111]';
rowPatientExcel = find(ismember(excelData(:, 1), PatientIndices));
rowPatientData = find(ismember(cell2mat(data(:,1)), PatientIndices));

% Extraction des donn�es de la colonne "disinhibition" pour les patients dans ControlIndices
disinhibitionData = excelData(rowPatientExcel, 11); % 11: colonne pour diff�rence de d�sinhibition dans le fichier excel

% Extraction des donn�es de la colonne 26 de la cellule pour les patients dans ControlIndices
cellData = cell2mat(data(rowPatientData, 30)); %30: sensibilit� aux r�compenses dans la t�che 3DNRS

% Calcul de la corr�lation et de la p-valeur
[rho, p] = corr(cellData, disinhibitionData,'Type', 'Spearman');

% Affichage des r�sultats
disp('Corr�lation et p-valeur :');
disp([rho, p]);


%% Correlation of TOM consistency, with FrSBe disinhibition difference, for FTD patients only


% Chargement des donn�es Excel
excelData = xlsread('C:\Users\raphael.joly\ownCloud - JOLY Raphael (raphael.joly@icm-institute.org)@owncloud.icm-institute.org2\diagrammes r�sultats\statistiques\data_all.xlsx');

% Chargement de la cellule MATLAB contenant vos donn�es
% load(data);

% Initialisation des indices des controles (1 � 8)
% ControlIndices = [1:2, 7:8, 301:311]';
PatientIndices = [101:103, 105, 106, 108, 110, 111]';
rowPatientExcel = find(ismember(excelData(:, 1), PatientIndices));
rowPatientData = find(ismember(cell2mat(data(:,1)), PatientIndices));

% Extraction des donn�es de la colonne "disinhibition" pour les patients dans ControlIndices
disinhibitionData = excelData(rowPatientExcel, 11); % % 11: colonne pour diff�rence de d�sinhibition dans le fichier excel

% Extraction des donn�es de la colonne 26 de la cellule pour les patients dans ControlIndices
cellData = cell2mat(data(rowPatientData, 24)); %24: TOM consistency

% Calcul de la corr�lation et de la p-valeur
[rho, p] = corr(cellData, disinhibitionData,'Type', 'Spearman');

% Affichage des r�sultats
disp('Corr�lation et p-valeur :');
disp([rho, p]);
