%% 2ArmBandittask analysis function

function FigHandle = Analysis(DataFile)
global BpodSystem

if nargin < 1
    SessionData = BpodSystem.Data;
else
    load(DataFile);
end

%% Load related data to local variabels
try
    Animal = str2double(SessionData.Info.Subject);
catch
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

%FeedbackWaitingTime = DataFile.Custom.TrialData.FeedbackWaitingTime(1:nTrials);
FeedbackWaitingTime = rand(684,1)*10'; %delete this
FeedbackWaitingTime = FeedbackWaitingTime';  %delete this
RewardProb = SessionData.Custom.TrialData.RewardProb(:, 1:nTrials);
LightLeft = SessionData.Custom.TrialData.LightLeft(1:nTrials);

ChoiceLeftRight = [ChoiceLeft; 1-ChoiceLeft]; 
%% Plot based on task design/ risk type
switch SessionData.SettingsFile.GUIMeta.RiskType.String{SessionData.SettingsFile.GUI.RiskType}
    case 'Fix'
    %%
        %not yet implemented

    case 'BlockRand'
    %%
        %not yet implemented

    case 'BlockFix'
    %%
        %not yet implemented

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
            title('Block switching behviour')
        end

        %% all trials overview (counts for each observed behavior)

        ChoiceLeftRight = [ChoiceLeft; 1-ChoiceLeft];
        NotBaited = any((Baited == 0) .* ChoiceLeftRight, 1);

        counts = zeros(1,6)';
        events = {'NoChoice', 'BrokeFix','EarlyWith','SkippedFeedback','Rewarded','NotBaited'};
        AllSessionEvents = table(counts,'RowNames',events);

        if ~isempty(NoChoice) && ~all(isnan(NoChoice))
            AllSessionEvents('NoChoice','counts') = {length(NoChoice(NoChoice==1))};
        end
        if ~isempty(BrokeFix) && ~all(isnan(BrokeFix))
            AllSessionEvents('BrokeFix','counts') = {length(BrokeFix(BrokeFix==1))};
        end
        if ~isempty(EarlyWith) && ~all(isnan(EarlyWith))
            AllSessionEvents('EarlyWith','counts') = {length(EarlyWith(EarlyWith==1))};
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

        subplot(2,2,2)   %needs adjustment, depends on the number of subplots
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

            scatter(WTLow(2,:),WTLow(1,:),'cyan');
            hold on
            scatter(WTHigh(2,:),WTHigh(1,:),'blue');
            plot(meanHigh(2,:),meanHigh(1,:),'x','MarkerSize',10,'MarkerEdgeColor','black','LineWidth',2);
            plot(meanLow(2,:),meanHigh(2,:),'x','MarkerSize',10,'MarkerEdgeColor','black','LineWidth',2);
            xlim([0 1]);
            ticks = [PLow,PHigh];
            xticks(ticks);
            xticklabels({'PLow','PHigh'});
            ylabel('time investment (s)');
            text1 = sprintf('n = %d',nLow);
            text2 = sprintf('n = %d',nHigh);
            text(PLow,max(FeedbackWaitingTime),text1);
            text(PHigh,max(FeedbackWaitingTime),text2);
            title('Waiting times for not-baited trials')
            

        end

        %% calculating the drinking times

        DrinkingTime = [];

        for i = 1:nTrials

            if Rewarded(i) == 1

                DrinkingTime(end+1) = DataFile.RawEvents.Trial{i}.States.Drinking(2) - DataFile.RawEvents.Trial{1,1}.States.Drinking(1);

            end

        end

        if ~all(isnan(DrinkingTime))

            subplot(3,3,4);              % specification of the binning could be added
            histogram(DrinkingTime,'FaceColor',[.5,.5,.5],'EdgeColor',[1,1,1]);
            xlabel('drinking times (s)')
            ylabel('n')
            title('Distribution of drinking times')

        end


        %% calculating the actual ITI (inter-trial interval)

        ITI = nan(nTrials,1);

        for i = 1:nTrials
            if i == 1

                ITI(i) = SessionData.TrialStartTimestamp(1) - SessionData.Info.SessionStartTime_MATLAB + SessionData.RawEvents.Trial{i}.States.ITI(2) - SessionData.RawEvents.Trial{i}.States.ITI(1);

            else

                ITI(i) = SessionData.TrialStartTimestamp(i) - SessionData.TrialEndTimestamp(i-1) + SessionData.RawEvents.Trial{i}.States.ITI(2) - SessionData.RawEvents.Trial{i}.States.ITI(1);

            end
        end

        if ~all(isnan(ITI))

            subplot(3,3,5);
            histogram(ITI,'FaceColor',[.5,.5,.5],'EdgeColor',[1,1,1]); %binning could be specified
            xlabel('actual ITI');
            ylabel('n')
            txt = sprintf('GUI ITI: %d',SessionData.SettingsFile.GUI.ITI);
            title('InterTrial intervals');
            subtitle(txt);
        end


    case 'Cued' % currently only designed for 1-arm
        % colour palette (suitable for most colourblind people)
        scarlet = [254, 60, 60]/255; % for incorrect sign, contracting with azure
        denim = [31, 54, 104]/255; % mainly for unsuccessful trials
        azure = [0, 162, 254]/255; % for rewarded sign
        
        neon_green = [26, 255, 26]/255; % for NotBaited
        neon_purple = [168, 12, 180]/255; % for SkippedBaited
        
        sand = [225, 190 106]/255; % for left-right
        turquoise = [64, 176, 166]/255;
        
        black = [0, 0, 0]/255; % for cues/reward probability
        graphite = [63, 63, 63]/255;
        smoke = [127, 127, 127]/255;
        silver = [191, 191, 191]/255;

        % create figure
        FigHandle = figure('Position', [   0       0     842    1191],... % DIN A3, 72 ppi
                           'NumberTitle', 'off',...
                           'Name', strcat(num2str(Animal), '_', Date),...
                           'MenuBar', 'none',...
                           'Resize', 'off');
        
        % overview of events across sessions
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
        
        % count and ratio of events per cue
        EventOverviewHandle = axes(FigHandle, 'Position', [0.76    0.77    0.22    0.20]);
        hold(EventOverviewHandle, 'on');
        YTickLabel = {'Count |       %',...
                      strcat(num2str(length(NoTrialStartndxTrial)), ' | ', sprintf('%04.1f', 100*length(NoTrialStartndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(BrokeFixationndxTrial)), ' | ', sprintf('%04.1f', 100*length(BrokeFixationndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(EarlyWithdrawalndxTrial)), ' | ', sprintf('%04.1f', 100*length(EarlyWithdrawalndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(NoDecisionndxTrial)), ' | ', sprintf('%04.1f', 100*length(NoDecisionndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(StartNewTrialndxTrial)), ' | ', sprintf('%04.1f', 100*length(StartNewTrialndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(IncorrectChoicendxTrial)), ' | ', sprintf('%04.1f', 100*length(IncorrectChoicendxTrial)/nTrials), '%'),...
                      strcat(num2str(length(RewardedndxTrial)), ' | ', sprintf('%04.1f', 100*length(RewardedndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(NotBaitedndxTrial)), ' | ', sprintf('%04.1f', 100*length(NotBaitedndxTrial)/nTrials), '%'),...
                      strcat(num2str(length(SkippedBaitedndxTrial)), ' | ', sprintf('%04.1f', 100*length(SkippedBaitedndxTrial)/nTrials), '%'),...
                  };
        set(EventOverviewHandle,...
            'TickDir', 'out',...
            'XLim', [0, 100],...
            'YLim', [0, 10],...
            'YTick', 0:9,...
            'YTickLabel', YTickLabel,...
            'FontSize', 12);
        xlabel(EventOverviewHandle, 'Proportion (%)', 'FontSize', 12);
        title('Event per Cue', 'FontSize', 10)
        
        LightLeftRight = [LightLeft; 1-LightLeft];
        TrialRewardProb = max(RewardProb .* LightLeftRight, [], 1); % max is chosen for a later possible design of 2-arm
        TrialRewardProbEvent = table(TrialRewardProb', EarlyWithdrawal', NoDecision', StartNewTrial',...
                                     IncorrectChoice', Rewarded', NotBaited', SkippedBaited',...
                                     'VariableNames',{'TrialRewardProb', 'EarlyWithdrawal', 'NoDecision', 'StartNewTrial',...
                                                      'IncorrectChoice', 'Rewarded', 'NotBaited', 'SkippedBaited'});
        
        RewardProbSortedEventMean = table2array(grpstats(fillmissing(TrialRewardProbEvent, 'constant', 0), 'TrialRewardProb'));
        RewardProbSortedEventCount = RewardProbSortedEventMean;
        RewardProbSortedEventCount(:, 3:end) = RewardProbSortedEventMean(:, 2) .* RewardProbSortedEventMean(:, 3:end);
        
        RewardProbSortedEventProportion = RewardProbSortedEventMean;
        RewardProbSortedEventProportion(:, 3:end) = 100 * RewardProbSortedEventMean(:, 3:end) ./ sum(RewardProbSortedEventMean(:, 3:end), 1);
        
        xdata = 3:9;
        ydata = RewardProbSortedEventProportion(:, xdata)';
        EventRatioHandle = barh(EventOverviewHandle, xdata, ydata, 'stacked');
        FaceColourPalette = [silver; smoke; graphite; black];
        for i = 1:length(EventRatioHandle)
            EventRatioHandle(i).FaceColor = FaceColourPalette(i, :);
        end
        
        RewardProbLegend = string(RewardProbSortedEventCount(:, 1))';
        EventRatioLegendHandle = legend(EventOverviewHandle, RewardProbLegend,...
                                        'Position', [0.77    0.79    0.20    0.012]);
        
	    % sample time per cue
        
        %waiting time of not-baited trials per reward probability

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