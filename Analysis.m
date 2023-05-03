function FigHandle = Analysis(DataFile)
% 2ArmBanditVariant Analysis Function
% Developed by Nina Grimme & Antonio Lee @ BCCN Berlin
% Version 1.0 ~ April 2023

if nargin < 1
    global BpodSystem
    if isempty(BpodSystem)
        [datafile, datapath] = uigetfile();
        load(fullfile(datapath, datafile));
    else
        SessionData = BpodSystem.Data;
    end
else
    load(DataFile);
end

%% Load related data to local variabels
Animal = str2double(SessionData.Info.Subject);
if isnan(Animal)
    Animal = -1;
end
Date = datestr(SessionData.Info.SessionDate, 'yyyymmdd');

nTrials = SessionData.nTrials;
ChoiceLeft = SessionData.Custom.TrialData.ChoiceLeft(1:nTrials);
Baited = SessionData.Custom.TrialData.Baited(:, 1:nTrials);
IncorrectChoice = SessionData.Custom.TrialData.IncorrectChoice(1:nTrials);
NoDecision = SessionData.Custom.TrialData.NoDecision(1:nTrials);
NoTrialStart = SessionData.Custom.TrialData.NoTrialStart(1:nTrials);
BrokeFixation = SessionData.Custom.TrialData.BrokeFixation(1:nTrials);
EarlyWithdrawal = SessionData.Custom.TrialData.EarlyWithdrawal(1:nTrials);
StartNewTrial = SessionData.Custom.TrialData.StartNewTrial(1:nTrials);
SkippedFeedback = SessionData.Custom.TrialData.SkippedFeedback(1:nTrials);
Rewarded = SessionData.Custom.TrialData.Rewarded(1:nTrials);

SampleTime = SessionData.Custom.TrialData.SampleTime(1:nTrials);
MoveTime = SessionData.Custom.TrialData.MoveTime(1:nTrials);
FeedbackWaitingTime = SessionData.Custom.TrialData.FeedbackWaitingTime(1:nTrials);
DrinkingTime = SessionData.Custom.TrialData.DrinkingTime(1:nTrials);
FeedbackDelay = SessionData.Custom.TrialData.FeedbackDelay(1:nTrials);
%FeedbackWaitingTime = rand(nTrials,1)*10; %delete this
%FeedbackWaitingTime = FeedbackWaitingTime';  %delete this
%FeedbackDelay = rand(nTrials,1)*10; %delete this
%FeedbackDelay= FeedbackDelay'; 

RewardProb = SessionData.Custom.TrialData.RewardProb(:, 1:nTrials);
LightLeft = SessionData.Custom.TrialData.LightLeft(1:nTrials);

ChoiceLeftRight = [ChoiceLeft; 1-ChoiceLeft]; 
%% Plot based on task design/ risk type
switch SessionData.SettingsFile.GUIMeta.RiskType.String{SessionData.SettingsFile.GUI.RiskType}
    case 'Fix'
    % not yet implemented %

    case 'BlockRand'
    % not yet implemented %

    case 'BlockFix'
    % not yet implemented %

    case 'BlockFixHolding'
    %%
        FigHandle = figure('Position', [360  187	1056	598],...
                           'NumberTitle', 'off',...
                           'Name', num2str(Animal));

        %running choice average

        RewardProbLeft = RewardProb(1,:);
        
        %% Block switching behaviour across trial
        subplot(3,3,1) %needs adjustment! depends on the number of plots in the end
        if ~isempty(ChoiceLeft) && ~all(isnan(ChoiceLeft))
            xdata = 1:nTrials;
            plot(xdata, RewardProbLeft, '-k', 'Color', [.5,.5,.5], 'LineWidth', 2);
            hold on;

            ChoiceLeftSmoothed = smooth(ChoiceLeft, 10, 'moving','omitnan'); %current bin width: 10 trials
            plot(xdata, ChoiceLeftSmoothed, '-k', 'LineWidth', 2);
            ylim([0 1]);
            xlim([0 nTrials]);
            ylabel('Ratio of Left Choices (%)')
            xlabel('Trials')
            title('Block switching behaviour')
        end

        %% all trials overview (counts for each observed behavior)

        ChoiceLeftRight = [ChoiceLeft; 1-ChoiceLeft];
        NotBaited = any((Baited == 0) .* ChoiceLeftRight, 1);

        counts = zeros(1,6)';
        events = {'NoChoice', 'BrokeFix','EarlyWith','SkippedFeedback','Rewarded','NotBaited'};
        AllSessionEvents = table(counts,'RowNames',events);

        if ~isempty(NoDecision) && ~all(isnan(NoDecision))
            AllSessionEvents('NoChoice','counts') = {length(NoDecision(NoDecision==1))};
        end
        if ~isempty(BrokeFixation) && ~all(isnan(BrokeFixation))
            AllSessionEvents('BrokeFix','counts') = {length(BrokeFixation(BrokeFixation==1))};
        end
        if ~isempty(EarlyWithdrawal) && ~all(isnan(EarlyWithdrawal))
            AllSessionEvents('EarlyWith','counts') = {length(EarlyWithdrawal(EarlyWithdrawal==1))};
        end
        if ~isempty(SkippedFeedback) && all(isnan(SkippedFeedback))
            AllSessionEvents('SkippedFeedback','counts') = {length(SkippedFeedback(SkippedFeedback==1))}; %-length(indxNotBaited(indxNotBaited==1))};
        end                                                                                              %is skipped feedback now seperate from not-baited?
        if ~isempty(Rewarded) && ~all(isnan(Rewarded))
            AllSessionEvents('Rewarded','counts') = {length(Rewarded(Rewarded==1))};
        end
        if ~isempty(NotBaited) && ~all(isnan(NotBaited))

            AllSessionEvents('NotBaited','counts')= {length(NotBaited(NotBaited==1))};

        end
        
        y = AllSessionEvents.counts;  
        xlabels = {'No Choice','Broke Fix','Early With','Skipped Feedback','Rewarded','NotBaited'};
        colors = {'yellow', "#77AC30",'blue',"#EDB120",'black','cyan'};  

        subplot(3,3,2)   %needs adjustment, depends on the number of subplots
        hold on

        for i = 1:length(y)
            bar(i, y(i), 'FaceColor', colors{i}, 'EdgeColor', 'none')
        end

        set(gca, 'XTick', 1:length(y))
        set(gca, 'XTickLabel', xlabels)
        %legend(xlabels)
        title('All trials');
        ylabel("counts");

        %% distribution of waiting time of notbaited trials
        
        if ~isempty(FeedbackWaitingTime) && ~all(isnan(FeedbackWaitingTime))
            
            RewardProbChosen = RewardProb .* ChoiceLeftRight;
            RewardProbChosen = RewardProbChosen(1,:) + RewardProbChosen(2,:);
            WaitingTimeBlocks = [FeedbackWaitingTime;RewardProbChosen];
            NotBaitedWT = WaitingTimeBlocks(:,NotBaited==1);
            PHigh = max(RewardProbChosen);
            PLow = min(RewardProbChosen);
            WTHigh = NotBaitedWT(:,NotBaitedWT(2,:) == PHigh);
            WTLow = NotBaitedWT(:,NotBaitedWT(2,:) == PLow);
            nHigh = length(WTHigh);
            nLow = length(WTLow);
            meanHigh = [mean(WTHigh(1));PHigh];
            meanLow = [mean(WTLow(1));PLow];

            subplot(3,3,3);    %needs adjustment!
            swarmchart(WTLow(2,:),WTLow(1,:),'cyan');
            hold on
            swarmchart(WTHigh(2,:),WTHigh(1,:),'blue');
            %plot(meanHigh(2,:),meanHigh(1,:),'x','MarkerSize',10,'MarkerEdgeColor','black','LineWidth',2);
            %plot(meanLow(2,:),meanHigh(2,:),'x','MarkerSize',10,'MarkerEdgeColor','black','LineWidth',2);
            %xlim([0 1]);
            %ticks = [PLow,PHigh];
            %xticks(ticks);
            %xticklabels({'PLow','PHigh'});
            boxplot(WTLow(1,:),WTLow(2,:));
            boxplot(WTHigh(1,:),WTHigh(2,:));
            %set(gca, 'XTick', ticks)
            set(gca, 'XTickLabel', {'PLow', 'PHigh'})
            ylabel('time investment (s)');
            text1 = sprintf('n = %d',nLow);
            text2 = sprintf('n = %d',nHigh);
            text(PLow,max(FeedbackWaitingTime),text1);
            text(PHigh,max(FeedbackWaitingTime),text2);
            title('Waiting times for not-baited trials')
            
        end

        %% plotting the drinking times

         DrinkingTime = DrinkingTime(~isnan(DrinkingTime));

        if ~all(isnan(DrinkingTime))

            subplot(3,3,4);              % specification of the binning could be added
            histogram(DrinkingTime,'FaceColor',[.5,.5,.5],'EdgeColor',[1,1,1]);
            xlabel('drinking times (s)')
            ylabel('n')
            title('Distribution of drinking times')

        end


        %% calculating the actual ITI (inter-trial interval)

        ITI = nan(nTrials-1,1);

        for i = 1:nTrials
            if i == 1

                ITI(i) = SessionData.TrialStartTimestamp(1) - SessionData.Info.SessionStartTime_MATLAB + SessionData.RawEvents.Trial{i}.States.ITI(2) - SessionData.RawEvents.Trial{i}.States.ITI(1);

            else

                ITI(i) = SessionData.TrialStartTimestamp(i) - SessionData.TrialEndTimestamp(i-1) + SessionData.RawEvents.Trial{i}.States.ITI(2) - SessionData.RawEvents.Trial{i}.States.ITI(1);

            end
        end
        ITI = ITI';
        cc=linspace(min(ITI),max(ITI));    % not working yet

        if ~all(isnan(ITI))

            subplot(3,3,5);
            histogram(ITI,cc)%,'FaceColor',[.5,.5,.5],'EdgeColor',[1,1,1]); %binning could be specified
            xlabel('actual ITI');
            ylabel('n')
            xlim([min(cc) max(cc)]);
            txt = sprintf('GUI ITI: %d',SessionData.SettingsFile.GUI.ITI);
            title('InterTrial intervals');
            subtitle(txt);

        end

        %% Lau Glimcher-model
        try 
            %preparing the data for design matrix
            Choices = ChoiceLeft';
            Choices(Choices==0) = -1;     %1 = left; -1 = right
            Rewards = Rewarded';
            Rewards = Rewards.*Choices; % reward per choice +/-1   % 1 = left and rewarded; -1 = right and rewarded

            % build trial history kernels (n=5)
            Choices = repmat(Choices,1,5);                    %creates a matrix with each row representing the data from one trial
            Rewards = repmat(Rewards,1,5);                    % each column is one variable associated with the explanatory varible (Choices, Rewards)
            for j = 1:size(Choices,2)                         % in this case being the last 5 trials
                Choices(:,j) = circshift(Choices(:,j),j);       
                Choices(1:j,j) = 0;                       
                Rewards(:,j) = circshift(Rewards(:,j),j);      
                Rewards(1:j,j) = 0;                       
            end

            % concatenate to build design matrix X
            X = [Choices, Rewards];
            X(isnan(X)) = 0;

            mdl = fitglm(X,ChoiceLeft','distribution','binomial');

            % predict choices
            Ppredict = mdl.predict(X);
            logodds = log(Ppredict) - log(1 - Ppredict);   %logodds for both: left and right

            % odds based on reward or choice only
            C0=zeros(size(Choices));
            R0=zeros(size(Rewards));
            X = [Choices,R0];
            Ppredict=mdl.predict(X);
            logoddsChoice = log(Ppredict) - log(1 - Ppredict);

            X = [C0,Rewards];
            Ppredict=mdl.predict(X);
            logoddsReward = log(Ppredict) - log(1 - Ppredict);
            model = true;

        catch

            disp('error in running model');
            model = false;

        end
        
        if model ~= false
            
            subplot(3,3,6)
            hold on
            
            xdata = 1:5;
            ydataChoice = mdl.Coefficients.Estimate(2:6);
            ydataReward = mdl.Coefficients.Estimate(7:11);
            intercept = mdl.Coefficients.Estimate(1);

            plot(xdata,ydataChoice,'Color','blue')
            plot(xdata,ydataReward,'Color','magenta')
            scatter(1,intercept,'filled','MarkerFaceColor','k')
            plot(xdata,intercept.*ones(1,length(xdata)),'--k');
            xticks(xdata);
            xlabel('n trials back');
            ylabel('correlation coefficients');
            title('GLM Fit')
            legend('choice','reward','intercept');



        end

        %psychometric
        %ConditionColors = [0,0,0;1,0,0;1,.6,.6];

        %subplot(3,3,7)
        %hold on

        %ChoiceL=~isnan(ChoiceLeft); ChoiceL = ChoiceLeft(:);
        %DV = logodds(ChoiceL);
        %dvbin=linspace(-max(abs(DV)),max(abs(DV)),10);
        %[x,y,e]=BinData(DV,ChoiceLeft,dvbin);
        %vv=~isnan(x) & ~isnan(y) & ~isnan(e);
        %errorbar(x(vv),y(vv),e(vv),'Color',ConditionColors(c,:),'LineStyle','none','LineWidth',2,'Marker','o','MarkerFaceColor',ConditionColors(c,:))

        %xlabel('log odds')
        %ylabel('P(Left)')
        %fit
        %mdl = fitglm(DV,ChoiceLeft(:),'Distribution','binomial');
        %xx=linspace(dvbin(1),dvbin(end),100);
        %plot(xx,predict(mdl,xx'),'-k')


        %% callibration plot

        subplot(3,3,8)
        hold on
        ndxValid = ~isnan(ChoiceLeft) & EarlyWithdrawal==0;
        ndxValid = ndxValid(:);
    
        ndxExploit = ChoiceLeft(:) == (logodds>0);
        ndxBaited = (Baited(1,:) & ChoiceLeft==1) | (Baited(2,:) & ChoiceLeft==0);
        ndxBaited = ndxBaited(:);
        left = ChoiceLeft(ndxValid & ~ndxBaited)==1; %?
        corr = ndxExploit(ndxValid & ~ndxBaited); %'correct'
        FeedbackDel = FeedbackDelay(:);
        ti = FeedbackDel(ndxValid & ~ndxBaited); ti = ti(:);
        edges = linspace(min(ti),max(ti),8);
        [x,y,e]=BinData(ti,corr,edges);
        vv=~isnan(x) & ~isnan(y) & ~isnan(e);
        errorbar(x(vv),y(vv),e(vv))
        xlabel('Time investment (s)')
        ylabel('Percent exploit')

      %plot vevaiometric    
        subplot(3,3,9)
        hold on

        ndxBaited = (Baited(1,:) & ChoiceLeft==1) | (Baited(2,:) & ChoiceLeft==0);
        ndxBaited = ndxBaited(:);
        ndxValid =  ~isnan(ChoiceLeft) & EarlyWithdrawal==0;
        ndxValid = ndxValid(:);
        ndxExploit = ChoiceLeft(:) == (logodds>0);
        ExploreScatter_XData = logodds(ndxValid & ~ndxBaited & ~ndxExploit);
        FeedbackDel = FeedbackDelay(:);
        ExploreScatter_YData = FeedbackDel(ndxValid & ~ndxBaited & ~ndxExploit)';
        ExploitScatter_XData = logodds(ndxValid & ~ndxBaited & ndxExploit);
        ExploitScatter_YData = FeedbackDel(ndxValid & ~ndxBaited & ndxExploit)';
        [ExploreLine_XData, ExploreLine_YData] = Binvevaio(ExploreScatter_XData,ExploreScatter_YData,10);
        [ExploitLine_XData, ExploitLine_YData] = Binvevaio(ExploitScatter_XData,ExploitScatter_YData,10);

        scatter(ExploitScatter_XData, ExploitScatter_YData,'.g','MarkerFaceColor','g');
        scatter(ExploreScatter_XData, ExploreScatter_YData,'.r','MarkerFaceColor','r');
        h1=plot(ExploreLine_XData, ExploreLine_YData, 'r','LineWidth',3);
        h2=plot(ExploitLine_XData, ExploitLine_YData,'g','LineWidth',3);
        l=legend([h1,h2],{'Explore','Exploit'});
        l.Box='off';
        l.Location='northwest';
        try
        ylim([min([ExploitScatter_YData;ExploreScatter_YData]),max([ExploitScatter_YData;ExploreScatter_YData])])
        xlim([-max(abs([ExploitScatter_XData;ExploreScatter_XData])),max(abs([ExploitScatter_XData;ExploreScatter_XData]))])
        catch
        end




    case 'Cued' % currently only designed for 1-arm
        % colour palette for events (suitable for most colourblind people)
            scarlet = [254, 60, 60]/255; % for incorrect sign, contracting with azure
        denim = [31, 54, 104]/255; % mainly for unsuccessful trials
        azure = [0, 162, 254]/255; % for rewarded sign
        
        neon_green = [26, 255, 26]/255; % for NotBaited
        neon_purple = [168, 12, 180]/255; % for SkippedBaited
        
        sand = [225, 190 106]/255; % for left-right
        turquoise = [64, 176, 166]/255;
        LRPalette = [sand; turquoise];
        
        % colour palette for cues: (1- P(r)) * 128 + 127
        % P(0) = white; P(1) = smoky gray
        RewardProbCategories = unique(RewardProb);
        CuedPalette = ((1 - RewardProbCategories) * [128 128 128] + 127)/255;

        % create figure
        FigHandle = figure('Position', [   0       0     842    1191],... % DIN A3, 72 ppi
                           'NumberTitle', 'off',...
                           'Name', strcat(num2str(Animal), '_', Date),...
                           'MenuBar', 'none',...
                           'Resize', 'off');
        
        %% overview of events across sessions
        TrialOverviewHandle = axes(FigHandle, 'Position', [0.01    0.77    0.48    0.20]);
        hold(TrialOverviewHandle, 'on');
        set(TrialOverviewHandle,...
            'TickDir', 'out',...
            'YAxisLocation', 'right',...
            'YLim', [0,10],...
            'YTick', 1:9,...
            'YTickLabel', {'NoTrialStart', 'BrokeFixation', 'EarlyWithdrawal',...
                           'NoDecision', 'StartNewTrial', 'IncorrectChoice',...
                           'Rewarded', 'NotBaited', 'SkippedBaited'},...
            'FontSize', 12);
        xlabel(TrialOverviewHandle, 'nTrial', 'FontSize', 14);
        title(strcat(num2str(Animal), '\_', Date, '\_CuedRisk'))
        
        idxTrial = 1:nTrials;
        NoTrialStartndxTrial = idxTrial(NoTrialStart == 1);
        NoTrialStartHandle = line(TrialOverviewHandle,...
                                  'xdata', NoTrialStartndxTrial,...
                                  'ydata', ones(size(NoTrialStartndxTrial)) * 1,...
                                  'LineStyle', 'none',...
                                  'Marker', '.',...
                                  'MarkerEdge', denim);
        
        BrokeFixationndxTrial = idxTrial(BrokeFixation == 1);
        BrokeFixationHandle = line(TrialOverviewHandle,...
                                   'xdata', BrokeFixationndxTrial,...
                                   'ydata', ones(size(BrokeFixationndxTrial)) * 2,...
                                   'LineStyle', 'none',...
                                   'Marker', '.',...
                                   'MarkerEdge', denim);
        
        EarlyWithdrawalndxTrial = idxTrial(EarlyWithdrawal == 1);
        EarlyWithdrawalHandle = line(TrialOverviewHandle,...
                                     'xdata', EarlyWithdrawalndxTrial,...
                                     'ydata', ones(size(EarlyWithdrawalndxTrial)) * 3,...
                                     'LineStyle', 'none',...
                                     'Marker', '.',...
                                     'MarkerEdge', denim);
        
        NoDecisionndxTrial = idxTrial(NoDecision == 1);
        NoDecisionHandle = line(TrialOverviewHandle,...
                                'xdata', NoDecisionndxTrial,...
                                'ydata', ones(size(NoDecisionndxTrial)) * 4,...
                                'LineStyle', 'none',...
                                'Marker', '.',...
                                'MarkerEdge', denim);
        
        StartNewTrialndxTrial = idxTrial(StartNewTrial == 1);
        StartNewTrialHandle = line(TrialOverviewHandle,...
                                   'xdata', StartNewTrialndxTrial,...
                                   'ydata', ones(size(StartNewTrialndxTrial)) * 5,...
                                   'LineStyle', 'none',...
                                   'Marker', '.',...
                                   'MarkerEdge', denim);
        
        IncorrectChoicendxTrial = idxTrial(IncorrectChoice == 1);
        IncorrectChoiceHandle = line(TrialOverviewHandle,...
                                     'xdata', IncorrectChoicendxTrial,...
                                     'ydata', ones(size(IncorrectChoicendxTrial)) * 6,...
                                     'LineStyle', 'none',...
                                     'Marker', '.',...
                                     'MarkerEdge', scarlet);
        
        RewardedndxTrial = idxTrial(Rewarded == 1);
        RewardedHandle = line(TrialOverviewHandle,...
                            'xdata', RewardedndxTrial,...
                            'ydata', ones(size(RewardedndxTrial)) * 7,...
                            'LineStyle', 'none',...
                            'Marker', '.',...
                            'MarkerEdge', azure);
        
        NotBaited = any(~Baited .* ChoiceLeftRight, 1) &(IncorrectChoice ~= 1);
        NotBaitedndxTrial = idxTrial(NotBaited == 1);
        NotBaitedHandle = line(TrialOverviewHandle,...
                               'xdata', NotBaitedndxTrial,...
                               'ydata', ones(size(NotBaitedndxTrial)) * 8,...
                               'LineStyle', 'none',...
                               'Marker', '.',...
                               'MarkerEdge', neon_green);
        
        SkippedBaited = any(Baited .* ChoiceLeftRight .* [SkippedFeedback; SkippedFeedback], 1) & (IncorrectChoice ~= 1);
        SkippedBaitedndxTrial = idxTrial(SkippedBaited == 1); % Choice made is Baited but Skipped
        SkippedBaitedHandle = line(TrialOverviewHandle,...
                                   'xdata', SkippedBaitedndxTrial,...
                                   'ydata', ones(size(SkippedBaitedndxTrial)) * 9,...
                                   'LineStyle', 'none',...
                                   'Marker', '.',...
                                   'MarkerEdge', neon_purple);
        
        %% count and ratio of events per cue
        EventOverviewHandle = axes(FigHandle, 'Position', [0.76    0.77    0.22    0.20]);
        hold(EventOverviewHandle, 'on');
        YTickLabel = {strcat(num2str(nTrials), ' | 100%'),...
                      strcat(num2str(length(NoTrialStartndxTrial)), ' | ', sprintf('%04.1f', 100*length(NoTrialStartndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(BrokeFixationndxTrial)), ' | ', sprintf('%04.1f', 100*length(BrokeFixationndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(EarlyWithdrawalndxTrial)), ' | ', sprintf('%04.1f', 100*length(EarlyWithdrawalndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(NoDecisionndxTrial)), ' | ', sprintf('%04.1f', 100*length(NoDecisionndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(StartNewTrialndxTrial)), ' | ', sprintf('%04.1f', 100*length(StartNewTrialndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(IncorrectChoicendxTrial)), ' | ', sprintf('%04.1f', 100*length(IncorrectChoicendxTrial)/nTrials), '%'),...
                      strcat(num2str(length(RewardedndxTrial)), ' | ', sprintf('%04.1f', 100*length(RewardedndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(NotBaitedndxTrial)), ' | ', sprintf('%04.1f', 100*length(NotBaitedndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(SkippedBaitedndxTrial)), ' | ', sprintf('%04.1f', 100*length(SkippedBaitedndxTrial)/nTrials), '%'),...
                      'Count |       %'};

        set(EventOverviewHandle,...
            'TickDir', 'out',...
            'XLim', [0, 100],...
            'YLim', [0, 10],...
            'YTick', 0:10,...
            'YTickLabel', YTickLabel,...
            'FontSize', 12);
        xlabel(EventOverviewHandle, 'Proportion (%)', 'FontSize', 12);
        title('Event Proportion', 'FontSize', 12)
        
        LightLeftRight = [LightLeft; 1-LightLeft];
        TrialRewardProb = max(RewardProb .* LightLeftRight, [], 1); % max is chosen for a later possible design of 2-arm, but LightLeft is NaN
        TrialDataTable = table(TrialRewardProb', EarlyWithdrawal', NoDecision', StartNewTrial',...
                               IncorrectChoice', Rewarded', NotBaited', SkippedBaited',...
                               ChoiceLeft', SampleTime',MoveTime',...
                               FeedbackWaitingTime', DrinkingTime',...
                               'VariableNames',{'TrialRewardProb', 'EarlyWithdrawal', 'NoDecision', 'StartNewTrial',...
                                                'IncorrectChoice', 'Rewarded', 'NotBaited', 'SkippedBaited',...
                                                'ChoiceLeft', 'SampleTime', 'MoveTime',...
                                                'FeedbackWaitingTime', 'DrinkingTime'});
        
        RewardProbSortedEventMean = table2array(grpstats(fillmissing(TrialDataTable(:, 1:8), 'constant', 0), 'TrialRewardProb'));
        RewardProbSortedEventCount = RewardProbSortedEventMean(:, 2) .* RewardProbSortedEventMean(:, 3:end);
        RewardProbSortedEventProportion = 100 * RewardProbSortedEventCount ./ sum(RewardProbSortedEventCount, 1);
        
        xdata = 3:9;
        ydata = RewardProbSortedEventProportion';
        EventRatioHandle = barh(EventOverviewHandle, xdata, ydata, 'stacked');

        for i = 1:length(EventRatioHandle)
            EventRatioHandle(i).FaceColor = CuedPalette(i, :);
        end
        
        RewardProbLegend = string(RewardProbCategories)';
        EventRatioLegendHandle = legend(EventOverviewHandle, RewardProbLegend,...
                                        'Position', [0.77    0.79    0.20    0.012]);
        
        
        % ??ABOVE maybe the percentage on the graph??
        
	    %% sample time per cue
        SampleTimeHandle = axes(FigHandle, 'Position', [0.76    0.57    0.22    0.13]);
        hold(SampleTimeHandle, 'on');
        
        SampleTimeScatterHandle = [];
        for i = 1:length(RewardProbCategories)
            SampleTimeScatterHandle(i) = swarmchart(SampleTimeHandle, TrialDataTable(TrialDataTable.TrialRewardProb == RewardProbCategories(i), :),...
                                                    'TrialRewardProb', 'SampleTime',...
                                                    'Marker', '.',...
                                                    'MarkerEdgeColor', CuedPalette(i,:),...
                                                    'XJitter', 'density',...
                                                    'XJitterWidth', 0.2);
        end

        StimulusTimeCutOffHandle = line(SampleTimeHandle,...
                                        'xdata', [0, 1],...
                                        'ydata', [1, 1] * SessionData.SettingsFile.GUI.StimulusTime,...
                                        'LineStyle', ':',...
                                        'Marker', 'none');
        
        set(SampleTimeHandle,...
            'TickDir', 'out',...
            'XLim', [0, 1],...
            'YLim', [0, 1],...
            'FontSize', 10);
        title('Sampling Time', 'FontSize', 12)
        xlabel(SampleTimeHandle, '')
        ylabel(SampleTimeHandle, 'Time (s)')
        
        NotBrokeFixationTrialData = TrialDataTable(~isnan(TrialDataTable.EarlyWithdrawal), :);
        SampleTimeBoxChartHandle = boxchart(SampleTimeHandle, NotBrokeFixationTrialData.TrialRewardProb, NotBrokeFixationTrialData.SampleTime);
        set(SampleTimeBoxChartHandle,...
            'BoxWidth', 0.05,...
            'BoxFaceColor', 'k',...
            'BoxFaceAlpha', 0,...
            'MarkerStyle', 'none',...
            'LineWidth', 0.2);
        
        SampleTimeStats = grpstats(NotBrokeFixationTrialData,...
                                   'TrialRewardProb', {'mean', 'std'},...
                                   'DataVars', 'SampleTime',...
                                   'VarNames', {'Pr', 'Count', 'Mean', 'Std'});

        SampleTimeStatsHandle = [];
        for i = 1:length(RewardProbCategories)
            SampleTimeStatsHandle(i) = text(SampleTimeHandle, RewardProbCategories(i), -0.35,...
                                            sprintf('%3.0f\n%5.3f\n%5.3f',...
                                                    SampleTimeStats.Count(i),...
                                                    SampleTimeStats.Mean(i),...
                                                    SampleTimeStats.Std(i)),...
                                            'FontSize', 10,...
                                            'HorizontalAlignment', 'center');
        end
        SampleTimeStatsHandle(i+1) = text(SampleTimeHandle, 0, -0.35,...
                                          sprintf('Count\nMean\nStd'),...
                                          'FontSize', 10,...
                                          'HorizontalAlignment', 'right');
        
        %% move time per cue
        MoveTimeHandle = axes(FigHandle, 'Position', [0.76    0.35    0.22    0.13]);
        hold(MoveTimeHandle, 'on');
        
        MoveTimeScatterHandle = [];
        for i = 1:length(RewardProbCategories)
            MoveTimeScatterHandle(i) = swarmchart(MoveTimeHandle, TrialDataTable(TrialDataTable.TrialRewardProb == RewardProbCategories(i), :),...
                                                  'TrialRewardProb', 'MoveTime',...
                                                  'Marker', '.',...
                                                  'MarkerEdgeColor', CuedPalette(i,:),...
                                                  'XJitter', 'density',...
                                                  'XJitterWidth', 0.2);
        end
        
        set(MoveTimeHandle,...
            'TickDir', 'out',...
            'XLim', [0, 1],...
            'YLim', [0, 1],...
            'FontSize', 10);
        title('Move Time', 'FontSize', 12)
        xlabel(MoveTimeHandle, '')
        ylabel(MoveTimeHandle, 'Time (s)')
        
        DecidedTrialData = TrialDataTable(TrialDataTable.NoDecision==0, :);
        MoveTimeBoxChartHandle = boxchart(MoveTimeHandle, DecidedTrialData.TrialRewardProb, DecidedTrialData.MoveTime);
        set(MoveTimeBoxChartHandle,...
            'BoxWidth', 0.05,...
            'BoxFaceColor', 'k',...
            'BoxFaceAlpha', 0,...
            'MarkerStyle', 'none',...
            'LineWidth', 0.2);
        
        MoveTimeStats = grpstats(DecidedTrialData,...
                                 'TrialRewardProb', {'mean', 'std'},...
                                 'DataVars', 'MoveTime',...
                                 'VarNames', {'Pr', 'Count', 'Mean', 'Std'});

        MoveTimeStatsHandle = [];
        for i = 1:length(RewardProbCategories)
            MoveTimeStatsHandle(i) = text(MoveTimeHandle, RewardProbCategories(i), -0.35,...
                                          sprintf('%3.0f\n%5.3f\n%5.3f',...
                                                  MoveTimeStats.Count(i),...
                                                  MoveTimeStats.Mean(i),...
                                                  MoveTimeStats.Std(i)),...
                                          'FontSize', 10,...
                                          'HorizontalAlignment', 'center');
        end
        MoveTimeStatsHandle(i+1) = text(MoveTimeHandle, 0, -0.35,...
                                        sprintf('Count\nMean\nStd'),...
                                        'FontSize', 10,...
                                        'HorizontalAlignment', 'right');
        
        %% time investment for NotBaited per cue
        FeedbackWaitingTimeHandle = axes(FigHandle, 'Position', [0.76    0.09    0.22    0.16]);
        hold(FeedbackWaitingTimeHandle, 'on');
        
        FeedbackWaitingTimeScatterHandle = [];
        for i = 1:length(RewardProbCategories)
            FeedbackWaitingScatterHandle(i) = swarmchart(FeedbackWaitingTimeHandle, TrialDataTable(TrialDataTable.TrialRewardProb == RewardProbCategories(i), :),...
                                                         'TrialRewardProb', 'FeedbackWaitingTime',...
                                                         'Marker', '.',...
                                                         'MarkerEdgeColor', CuedPalette(i,:),...
                                                         'XJitter', 'density',...
                                                         'XJitterWidth', 0.2);
        end
        
        set(FeedbackWaitingTimeHandle,...
            'TickDir', 'out',...
            'XLim', [0, 1],...
            'YLim', [0, 4],...
            'FontSize', 10);
        title('NotBaited Invested Time', 'FontSize', 12)
        xlabel(FeedbackWaitingTimeHandle, 'Reward Prob')
        ylabel(FeedbackWaitingTimeHandle, 'Time (s)')
        
        NotBaitedTrialData = TrialDataTable(TrialDataTable.NotBaited==1, :);
        FeedbackWaitingTimeBoxChartHandle = boxchart(FeedbackWaitingTimeHandle, NotBaitedTrialData.TrialRewardProb, NotBaitedTrialData.FeedbackWaitingTime);
        set(FeedbackWaitingTimeBoxChartHandle,...
            'BoxWidth', 0.05,...
            'BoxFaceColor', 'k',...
            'BoxFaceAlpha', 0,...
            'MarkerStyle', 'none',...
            'LineWidth', 0.2);
        
        FeedbackWaitingTimeStats = grpstats(NotBaitedTrialData,...
                                            'TrialRewardProb', {'mean', 'std'},...
                                            'DataVars', 'FeedbackWaitingTime',...
                                            'VarNames', {'Pr', 'Count', 'Mean', 'Std'});

        FeedbackWaitingTimeStatsHandle = [];
        for i = 1:length(RewardProbCategories)
            FeedbackWaitingTimeStatsHandle(i) = text(FeedbackWaitingTimeHandle, RewardProbCategories(i), -1.5,...
                                                     sprintf('%3.0f\n%5.3f\n%5.3f',...
                                                             FeedbackWaitingTimeStats.Count(i),...
                                                             FeedbackWaitingTimeStats.Mean(i),...
                                                             FeedbackWaitingTimeStats.Std(i)),...
                                                     'FontSize', 10,...
                                                     'HorizontalAlignment', 'center');
        end
        FeedbackWaitingTimeStatsHandle(i+1) = text(FeedbackWaitingTimeHandle, 0, -1.5,...
                                        sprintf('Count\nMean\nStd'),...
                                        'FontSize', 10,...
                                        'HorizontalAlignment', 'right');

        %% move time per Left-Right
        LRMoveTimeHandle = axes(FigHandle, 'Position', [0.55    0.35    0.12    0.13]);
        hold(LRMoveTimeHandle, 'on');
        
        LRTrialDataTable = table(1-ChoiceLeft', NoDecision', NotBaited',...
                                 MoveTime', FeedbackWaitingTime', DrinkingTime',...
                                 'VariableNames',{'ChoiceRight', 'NoDecision', 'NotBaited',...
                                                  'MoveTime', 'FeedbackWaitingTime', 'DrinkingTime'});
        LRMoveTimeScatterHandle = [];
        for i = 1:2
            LRMoveTimeScatterHandle(i) = swarmchart(LRMoveTimeHandle, LRTrialDataTable(LRTrialDataTable.ChoiceRight == i-1, :),...
                                                    'ChoiceRight', 'MoveTime',...
                                                    'Marker', '.',...
                                                    'MarkerEdgeColor', LRPalette(i,:),...
                                                    'XJitter', 'density',...
                                                    'XJitterWidth', 0.8);
        end
        
        set(LRMoveTimeHandle,...
            'TickDir', 'out',...
            'XLim', [-1, 2],...
            'XTick', [0 1],...
            'XTickLabel', {'Left', 'Right'},...
            'YLim', [0, 1],...
            'YAxisLocation', 'right',...
            'FontSize', 10);
        title('Move Time', 'FontSize', 12)
        xlabel(LRMoveTimeHandle, '')
        ylabel(LRMoveTimeHandle, '')
        
        LRDecidedTrialData = LRTrialDataTable(LRTrialDataTable.NoDecision==0, :);
        LRMoveTimeBoxChartHandle = boxchart(LRMoveTimeHandle, LRDecidedTrialData.ChoiceRight, LRDecidedTrialData.MoveTime);
        set(LRMoveTimeBoxChartHandle,...
            'BoxWidth', 0.2,...
            'BoxFaceColor', 'k',...
            'BoxFaceAlpha', 0,...
            'MarkerStyle', 'none',...
            'LineWidth', 0.2);
        
        LRMoveTimeStats = grpstats(LRDecidedTrialData,...
                                   'ChoiceRight', {'mean', 'std'},...
                                   'DataVars', 'MoveTime',...
                                   'VarNames', {'LR', 'Count', 'Mean', 'Std'});

        LRMoveTimeStatsHandle = [];
        for i = 1:2
            LRMoveTimeStatsHandle(i) = text(LRMoveTimeHandle, i-1, -0.35,...
                                            sprintf('%3.0f\n%4.2f\n%4.2f',...
                                                    LRMoveTimeStats.Count(i),...
                                                    LRMoveTimeStats.Mean(i),...
                                                    LRMoveTimeStats.Std(i)),...
                                            'FontSize', 10,...
                                            'HorizontalAlignment', 'center');
        end
        LRMoveTimeStatsHandle(i+1) = text(LRMoveTimeHandle, -1, -0.35,...
                                          sprintf('Count\nMean\nStd'),...
                                          'FontSize', 10,...
                                          'HorizontalAlignment', 'right');
        
        %% time investment for NotBaited per Left-Right
        LRFeedbackWaitingTimeHandle = axes(FigHandle, 'Position', [0.55    0.09    0.12    0.16]);
        hold(LRFeedbackWaitingTimeHandle, 'on');
        
        LRFeedbackWaitingTimeScatterHandle = [];
        for i = 1:2
            LRFeedbackWaitingScatterHandle(i) = swarmchart(LRFeedbackWaitingTimeHandle, LRTrialDataTable(LRTrialDataTable.ChoiceRight == i-1, :),...
                                                           'ChoiceRight', 'FeedbackWaitingTime',...
                                                           'Marker', '.',...
                                                           'MarkerEdgeColor', LRPalette(i,:),...
                                                           'XJitter', 'density',...
                                                           'XJitterWidth', 0.8);
        end
        
        set(LRFeedbackWaitingTimeHandle,...
            'TickDir', 'out',...
            'XLim', [-1, 2],...
            'XTick', [0 1],...
            'XTickLabel', {'Left', 'Right'},...
            'YLim', [0, 4],...
            'YAxisLocation', 'right',...
            'FontSize', 10);
        title('NotBaited Invested Time', 'FontSize', 12)
        xlabel(LRFeedbackWaitingTimeHandle, '')
        ylabel(LRFeedbackWaitingTimeHandle, '')
        
        LRNotBaitedTrialData = LRTrialDataTable(LRTrialDataTable.NotBaited==1, :);
        LRFeedbackWaitingTimeBoxChartHandle = boxchart(LRFeedbackWaitingTimeHandle, LRNotBaitedTrialData.ChoiceRight, LRNotBaitedTrialData.FeedbackWaitingTime);
        set(LRFeedbackWaitingTimeBoxChartHandle,...
            'BoxWidth', 0.2,...
            'BoxFaceColor', 'k',...
            'BoxFaceAlpha', 0,...
            'MarkerStyle', 'none',...
            'LineWidth', 0.2);
        
        LRFeedbackWaitingTimeStats = grpstats(LRNotBaitedTrialData,...
                                              'ChoiceRight', {'mean', 'std'},...
                                              'DataVars', 'FeedbackWaitingTime',...
                                              'VarNames', {'LR', 'Count', 'Mean', 'Std'});

        LRFeedbackWaitingTimeStatsHandle = [];
        for i = 1:2
            LRFeedbackWaitingTimeStatsHandle(i) = text(LRFeedbackWaitingTimeHandle, i-1, -1.5,...
                                                     sprintf('%3.0f\n%4.2f\n%4.2f',...
                                                             LRFeedbackWaitingTimeStats.Count(i),...
                                                             LRFeedbackWaitingTimeStats.Mean(i),...
                                                             LRFeedbackWaitingTimeStats.Std(i)),...
                                                     'FontSize', 10,...
                                                     'HorizontalAlignment', 'center');
        end
        LRFeedbackWaitingTimeStatsHandle(i+1) = text(LRFeedbackWaitingTimeHandle, -1, -1.5,...
                                                     sprintf('Count\nMean\nStd'),...
                                                     'FontSize', 10,...
                                                     'HorizontalAlignment', 'right');
        i;
        % waiting time of not-baited trials per reward probability

        %get only the actually used reward probabilities
        %{
        LightLeftRight = [LightLeft;1-LightLeft];
        LightRewardProb = RewardProb .* LightLeftRight;
        RewardProbUsed = LightRewardProb(1,:) + LightRewardProb(2,:);

        if ~isempty(FeedbackWaitingTime) && ~all(isnan(FeedbackWaitingTime))

            %get the waiting time and reward probability for not-baited trials

            indxNotBaited = (IncorrectChoice==0) & any((Baited == 0) .* ChoiceLeftRight, 1); 
            NotBaitedWT = FeedbackWaitingTime(indxNotBaited==1); 
            NotBaitedRP = RewardProbUsed(indxNotBaited==1);
            WaitingTime = NotBaitedWT';
            RewardProb = NotBaitedRP';
            NotBaitedWTRP = table(RewardProb,WaitingTime); % does not need to be in this format, can also be an array/matrix
            WTRPSummary = groupsummary(NotBaitedWTRP,"RewardProb",{"mean","std"}); %then groupstats need to be used instead of groupsummary

            %plot waiting time and reward probability

            subplot(2,2,1)                      %needs adjustment to the final number of plots
            xdata = WTRPSummary.RewardProb;
            ydata = WTRPSummary.mean_WaitingTime;
            swarmchart(NotBaitedWTRP.RewardProb,NotBaitedWTRP.WaitingTime,'cyan','filled')
            hold on
            errbar = WTRPSummary.std_WaitingTime;
            plot(xdata,ydata,'diamond','MarkerSize',8,'MarkerEdgeColor','black','LineWidth',2);
            title("Not Baited trials")
            xlabel("reward probability in %");
            ylabel("time investment in s ");
            errorbar(xdata,ydata,errbar,'Linestyle','none','Color','k');
            xdataticks = WTRPSummary.RewardProb';
            xticks(xdataticks)           
            xticklabels(string(xdataticks));        %test this?
            xlim([0 1])
            counts = string(WTRPSummary.GroupCount);
            ylabels = ydata + 0.2;   
            text(xdata,ylabels,counts,'Color','black','FontSize',12)
            annotation('textbox', [0.77, 0.7, 0.1, 0.1], 'String', "total counts",'Color','black')

        end
        %}
 
end




