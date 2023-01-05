function TwoArmBanditVariant_PlotSideOutcome(AxesHandles, Action, varargin)
global nTrialsToShow %this is for convenience
global BpodSystem
global TaskParameters

switch Action
    case 'init'
        %% initialize pokes plot
        nTrialsToShow = 90; %default number of trials to display
        
        if nargin >= 3 %custom number of trials
            nTrialsToShow = varargin{1};
        end
        
        axes(AxesHandles.HandleOutcome);
        %plot in specified axes
        OutcomePlot = BpodSystem.GUIHandles.OutcomePlot;
        OutcomePlot.NoTrialStart = line(-1,0,'LineStyle','none','Marker','x','MarkerEdge','b','MarkerFace','none', 'MarkerSize',8);
        OutcomePlot.BrokeFixation = line(-1,0,'LineStyle','none','Marker','square','MarkerEdge','b','MarkerFace','none', 'MarkerSize',8);
        OutcomePlot.EarlyWithdrawal = line(-1,0,'LineStyle','none','Marker','d','MarkerEdge','b','MarkerFace','none', 'MarkerSize',8);
        OutcomePlot.NoDecision = line(-1,0,'LineStyle','none','Marker','*','MarkerEdge','b','MarkerFace','none', 'MarkerSize',8);
        OutcomePlot.StartNewTrial = line(-1,0,'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','none', 'MarkerSize',8);
        
        OutcomePlot.ChoiceLeft = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','none', 'MarkerSize',10);
        OutcomePlot.SkippedFeedbackLeft = line(-1,0, 'LineStyle','none','Marker','x','MarkerEdge','b','MarkerFace','none', 'MarkerSize',10);
        OutcomePlot.RewardLeft = line(-1,0, 'LineStyle','none','Marker','<','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        OutcomePlot.UnrewardLeft = line(-1,0, 'LineStyle','none','Marker','<','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        OutcomePlot.CatchLeft = line(-1,0,'LineStyle','none','Marker','<','MarkerEdge','b','MarkerFace','b', 'MarkerSize',3);
        
        OutcomePlot.legend = legend('NoTrialStart','BrokeFixation','EarlyWithdrawal','NoDecision','StartNewTrial',...
                                    'Choice','SkippedFeedback','Reward','Unreward','CatchTrial');
        
        OutcomePlot.RewardRight = line(-1,0, 'LineStyle','none','Marker','>','MarkerEdge','g','MarkerFace','g', 'MarkerSize',6);
        OutcomePlot.UnrewardRight = line(-1,0, 'LineStyle','none','Marker','>','MarkerEdge','r','MarkerFace','r', 'MarkerSize',6);
        OutcomePlot.CatchRight = line(-1,0,'LineStyle','none','Marker','>','MarkerEdge','b','MarkerFace','b', 'MarkerSize',3);
        OutcomePlot.ChoiceRight = line(-1,0, 'LineStyle','none','Marker','o','MarkerEdge','b','MarkerFace','none', 'MarkerSize',10);
        OutcomePlot.SkippedFeedbackRight = line(-1,0, 'LineStyle','none','Marker','x','MarkerEdge','b','MarkerFace','none', 'MarkerSize',10);
        
        OutcomePlot.CumRwd = text(1,1,'0mL','verticalalignment','bottom','horizontalalignment','center');
        
        BpodSystem.GUIHandles.OutcomePlot = OutcomePlot;
        
        set(AxesHandles.HandleOutcome,'TickDir','out','YLim',[0,1],'XLim',[0,nTrialsToShow],'YTick',[0 1],'FontSize', 13);
        xlabel(AxesHandles.HandleOutcome, 'Trial#', 'FontSize', 14);
        ylabel(AxesHandles.HandleOutcome, 'RewardProb', 'FontSize', 14);
        hold(AxesHandles.HandleOutcome, 'on');
        
        %% Trial rate
        hold(AxesHandles.HandleTrialRate,'on')
        AxesHandles.HandleTrialRate.XLabel.String = 'Time (min)'; % FIGURE OUT UNIT
        AxesHandles.HandleTrialRate.YLabel.String = 'Trial Counts';
        AxesHandles.HandleTrialRate.Title.String = 'Trial rate';

        %% StimeDelay histogram
        hold(AxesHandles.HandleStimDelay,'on')
        AxesHandles.HandleTrialRate.XLabel.String = 'Time (ms)'; % FIGURE OUT UNIT
        AxesHandles.HandleTrialRate.YLabel.String = 'Trial Counts';
        AxesHandles.HandleTrialRate.Title.String = 'Stimulus Delay';
        
        %% SampleTime histogram
        hold(AxesHandles.HandleSampleTime,'on')
        AxesHandles.HandleST.XLabel.String = 'Time (ms)';
        AxesHandles.HandleST.YLabel.String = 'Trial Counts';
        AxesHandles.HandleST.Title.String = 'Sample time';
        
        %% MoveTime histogram
        hold(AxesHandles.HandleMoveTime,'on')
        AxesHandles.HandleMT.XLabel.String = 'Time (ms)';
        AxesHandles.HandleMT.YLabel.String = 'Trial Counts';
        AxesHandles.HandleMT.Title.String = 'Movement time';
        
        %% FeedbackDelay histogram
        hold(AxesHandles.HandleFeedback,'on')
        AxesHandles.HandleMT.XLabel.String = 'Time (ms)';
        AxesHandles.HandleMT.YLabel.String = 'Trial Counts';
        AxesHandles.HandleMT.Title.String = 'FeedbackDelay';
        
        %% Vevaiometric histogram
        hold(AxesHandles.HandleVevaiometric,'on')
        AxesHandles.HandleMT.XLabel.String = 'Time (ms)';
        AxesHandles.HandleMT.YLabel.String = 'Time (ms)';
        AxesHandles.HandleMT.Title.String = 'FeedbackDelay';
        
    case 'UpdateTrial' % Update before the trial starts, mainly for viewing what's the next trial is about
        CurrentTrial = varargin{1};
        TrialData = BpodSystem.Data.Custom.TrialData;
        
        LightLeft = TrialData.LightLeft;
        CatchTrial = TrialData.CatchTrial;
        RewardProb = TrialData.RewardProb;
        RewardMagnitude = TrialData.RewardMagnitude;
        
        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,CurrentTrial,nTrialsToShow); % see below, mn being the min of xlim
        indxToPlot = mn:CurrentTrial;
        
        % RewardLeft
        ndxRewardLeft = LightLeft(indxToPlot) ~= 0 & RewardMagnitude(1,indxToPlot) > 0; % include case == 1 and == NaN
        XData = indxToPlot(ndxRewardLeft);
        YData = RewardProb(1,ndxRewardLeft);
        set(BpodSystem.GUIHandles.OutcomePlot.RewardLeft, 'xdata', XData, 'ydata', YData);
        
        % RewardRight
        ndxRewardRight = LightLeft(indxToPlot) ~= 1 & RewardMagnitude(2,indxToPlot) > 0; % include case == 0 and == NaN
        XData = indxToPlot(ndxRewardRight);
        YData = RewardProb(2,ndxRewardRight);
        set(BpodSystem.GUIHandles.OutcomePlot.RewardRight, 'xdata', XData, 'ydata', YData);
        
        % UnrewardLeft
        ndxUnrewardLeft = LightLeft(indxToPlot) ~= 0 & RewardMagnitude(1,indxToPlot) == 0; % include case == 1 and == NaN
        XData = indxToPlot(ndxUnrewardLeft);
        YData = RewardProb(1,ndxUnrewardLeft);
        set(BpodSystem.GUIHandles.OutcomePlot.UnrewardLeft, 'xdata', XData, 'ydata', YData);
        
        % UnrewardRight
        ndxUnrewardRight = LightLeft(indxToPlot) ~= 1 & RewardMagnitude(2,indxToPlot) == 0; % include case == 0 and == NaN
        XData = indxToPlot(ndxUnrewardRight);
        YData = RewardProb(2,ndxUnrewardRight);
        set(BpodSystem.GUIHandles.OutcomePlot.UnrewardRight, 'xdata', XData, 'ydata', YData);
        
        % CatchLeft
        ndxCatchLeft = LightLeft(indxToPlot) ~= 0 & CatchTrial(indxToPlot) == 1; % include case == 1 and == NaN
        XData = indxToPlot(ndxCatchLeft);
        YData = RewardProb(1,ndxCatchLeft);
        set(BpodSystem.GUIHandles.OutcomePlot.CatchLeft, 'xdata', XData, 'ydata', YData);
        
        % CatchRight
        ndxCatchRight = LightLeft(indxToPlot) ~= 1 & CatchTrial(indxToPlot) == 1; % include case == 0 and == NaN
        XData = indxToPlot(ndxCatchRight);
        YData = RewardProb(2,ndxCatchRight);
        set(BpodSystem.GUIHandles.OutcomePlot.CatchRight, 'xdata', XData, 'ydata', YData);
        
    case 'UpdateResult' % plot trial result
        CurrentTrial = varargin{1};
        TrialData = BpodSystem.Data.Custom.TrialData;
        
        NoTrialStart = TrialData.NoTrialStart;
        BrokeFixation = TrialData.BrokeFixation;
        EarlyWithdrawal = TrialData.EarlyWithdrawal;
        NoDecision = TrialData.NoDecision;
        StartNewTrial = TrialData.StartNewTrial;
        ChoiceLeft = TrialData.ChoiceLeft;
        IncorrectChoice = TrialData.IncorrectChoice;
        SkippedFeedback = TrialData.SkippedFeedback;
        RewardProb = TrialData.RewardProb;
        
        SampleTime = TrialData.SampleTime;
        MoveTime = TrialData.MoveTime;
        StartNewTrialSuccessful = TrialData.StartNewTrialSuccessful;

        %% OutcomePlot
        % recompute xlim
        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,CurrentTrial,nTrialsToShow); % see below, mn being the min of xlim
        indxToPlot = mn:CurrentTrial;
        
        % NoTrialStart
        if ~isempty(NoTrialStart)
            ndxNoTrialStart = NoTrialStart(indxToPlot) == 1;
            XData = indxToPlot(ndxNoTrialStart);
            YData = zeros(1,sum(ndxNoTrialStart));
            set(BpodSystem.GUIHandles.OutcomePlot.NoTrialStart, 'xdata', XData, 'ydata', YData);
        end
        
        % BrokeFixation
        if ~isempty(BrokeFixation)
            ndxBrokeFixation = BrokeFixation(indxToPlot) == 1;
            XData = indxToPlot(ndxBrokeFixation);
            YData = zeros(1,sum(ndxBrokeFixation));
            set(BpodSystem.GUIHandles.OutcomePlot.BrokeFixation, 'xdata', XData, 'ydata', YData);
        end
        
        % EarlyWithdrawal
        if ~isempty(EarlyWithdrawal)
            ndxEarlyWithdrawl = EarlyWithdrawal(indxToPlot) == 1;
            XData = indxToPlot(ndxEarlyWithdrawl);
            YData = zeros(1,sum(ndxEarlyWithdrawl));
            set(BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal, 'xdata', XData, 'ydata', YData);
        end
        
        % NoDecision
        if ~isempty(NoDecision)
            ndxNoDecision = NoDecision(indxToPlot) == 1;
            XData = indxToPlot(ndxNoDecision);
            YData = zeros(1,sum(ndxNoDecision));
            set(BpodSystem.GUIHandles.OutcomePlot.NoDecision, 'xdata', XData, 'ydata', YData);
        end
        
        % StartNewTrial
        if ~isempty(StartNewTrial)
            ndxStartNewTrial = StartNewTrial(indxToPlot) == 1;
            XData = indxToPlot(ndxStartNewTrial);
            YData = zeros(1,sum(ndxStartNewTrial));
            set(BpodSystem.GUIHandles.OutcomePlot.StartNewTrial, 'xdata', XData, 'ydata', YData);
        end
        
        if ~isempty(ChoiceLeft)
            % ChoiceLeft
            ndxChoiceCorrectLeft = ChoiceLeft(indxToPlot) == 1 && IncorrectChoice(indxToPlot) == 0;
            ndxChoiceIncorrectLeft = ChoiceLeft(indxToPlot) == 1 && IncorrectChoice(indxToPlot) == 1;
            XData = [indxToPlot(ndxChoiceCorrectLeft), indxToPlot(ndxChoiceIncorrectLeft)];
            YData = [RewardProb(1,ndxChoiceCorrectLeft), zeros(1,sum(ndxChoiceIncorrectLeft))];
            set(BpodSystem.GUIHandles.OutcomePlot.ChoiceLeft, 'xdata', XData, 'ydata', YData);
      
        
            % ChoiceRight
            ndxChoiceCorrectRight = ChoiceLeft(indxToPlot) == 0 && IncorrectChoice(indxToPlot) == 0;
            ndxChoiceIncorrectRight = ChoiceLeft(indxToPlot) == 0 && IncorrectChoice(indxToPlot) == 1;
            XData = [indxToPlot(ndxChoiceCorrectRight), indxToPlot(ndxChoiceIncorrectRight)];
            YData = [RewardProb(1,ndxChoiceCorrectRight), zeros(1,sum(ndxChoiceIncorrectRight))];
            set(BpodSystem.GUIHandles.OutcomePlot.ChoiceRight, 'xdata', XData, 'ydata', YData);
        end
        
        if ~isempty(SkippedFeedback)
            % SkippedFeedbackLeft
            ndxSkippedFeedbackLeft = SkippedFeedback(indxToPlot) == 1 && ChoiceLeft(indxToPlot) == 1;
            XData = indxToPlot(ndxSkippedFeedbackLeft);
            YData = RewardProb(1,ndxSkippedFeedbackLeft);
            set(BpodSystem.GUIHandles.OutcomePlot.SkippedFeedbackLeft, 'xdata', XData, 'ydata', YData);
            
            % SkippedFeedbackLeft
            ndxSkippedFeedbackRight = SkippedFeedback(indxToPlot) == 1 && ChoiceLeft(indxToPlot) == 0;
            XData = indxToPlot(ndxSkippedFeedbackRight);
            YData = RewardProb(2,ndxSkippedFeedbackRight);
            set(BpodSystem.GUIHandles.OutcomePlot.SkippedFeedbackRight, 'xdata', XData, 'ydata', YData);
        end
        
        % CumRwd
        reward_total = calculate_cumulative_reward(); % custom function under Bpod_Gen2/Custom
        set(BpodSystem.GUIHandles.OutcomePlot.CumRwd, ...
            'position', [CurrentTrial+1 1], ...
            'string', [num2str(reward_total) ' microL']);
        
        %% Trial rate
        BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate,'Children'),'Visible','on');
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData = (BpodSystem.Data.TrialStartTimestamp-min(BpodSystem.Data.TrialStartTimestamp))/60;
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.YData = 1:numel(BpodSystem.Data.Custom.TrialData.ChoiceLeft(1:end));
        
        %% Stimulus Delay
        BpodSystem.GUIHandles.OutcomePlot.HandleStimDelay.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleStimDelay,'Children'),'Visible','on');
        cla(AxesHandles.HandleStimDelay)
        BpodSystem.GUIHandles.OutcomePlot.HistBrokeFixation = histogram(AxesHandles.HandleSampleTime,SampleTime(BrokeFixation==1)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistBrokeFixation.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistBrokeFixation.FaceColor = 'r';
        BpodSystem.GUIHandles.OutcomePlot.HistBrokeFixation.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistNBrokeFixation = histogram(AxesHandles.HandleSampleTime,SampleTime(BrokeFixation==0)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistNBrokeFixation.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistNBrokeFixation.FaceColor = 'b';
        BpodSystem.GUIHandles.OutcomePlot.HistNBrokeFixation.EdgeColor = 'none';
        BrokenFixationP = sum(~isnan(BrokeFixation))/sum(NoTrialStart);
        cornertext(AxesHandles.HandleST,sprintf('P=%1.2f',BrokenFixationP)) %percentage of BrokeFixation with Trial Started
        
        
BpodSystem.GUIHandles.OutcomePlot.HandleStimDelay = axes('Position',   [2*.05 + 1*.08   .65  .1  .3],'Visible','off'); % old HandleFix
BpodSystem.GUIHandles.OutcomePlot.HandleFeedback = axes('Position',    [5*.05 + 4*.08   .65  .1  .3],'Visible','off');
BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric = axes('Position',[6*.05 + 5*.08   .65  .1  .3],'Visible','off');

        
        %% Sample Time
        BpodSystem.GUIHandles.OutcomePlot.HandleSampleTime.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleSampleTime,'Children'),'Visible','on');
        cla(AxesHandles.HandleSampleTime)
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly = histogram(AxesHandles.HandleSampleTime,SampleTime(EarlyWithdrawal==1)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.FaceColor = 'r';
        BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.EdgeColor = 'none';
        BpodSystem.GUIHandles.OutcomePlot.HistST = histogram(AxesHandles.HandleSampleTime,SampleTime(EarlyWithdrawal==0)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistST.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistST.FaceColor = 'b';
        BpodSystem.GUIHandles.OutcomePlot.HistST.EdgeColor = 'none';
        EarlyP = sum(BpodSystem.Data.Custom.TrialData.EarlyWithdrawal)/size(BpodSystem.Data.Custom.TrialData.ChoiceLeft,2);
        cornertext(AxesHandles.HandleST,sprintf('P=%1.2f',EarlyP))
        
        %% MoveTime
        BpodSystem.GUIHandles.OutcomePlot.HandleMoveTime.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleMT,'Children'),'Visible','on');
        cla(AxesHandles.HandleMT)
        BpodSystem.GUIHandles.OutcomePlot.HistMT = histogram(AxesHandles.HandleMT,BpodSystem.Data.Custom.TrialData.move_time(~BpodSystem.Data.Custom.TrialData.EarlyWithdrawal)*1000);
        BpodSystem.GUIHandles.OutcomePlot.HistMT.BinWidth = 50;
        BpodSystem.GUIHandles.OutcomePlot.HistMT.FaceColor = 'b';
        BpodSystem.GUIHandles.OutcomePlot.HistMT.EdgeColor = 'none';
        LeftBias = sum(BpodSystem.Data.Custom.TrialData.ChoiceLeft==1)/sum(~isnan(BpodSystem.Data.Custom.TrialData.ChoiceLeft),2);
        cornertext(AxesHandles.HandleMT,sprintf('Bias=%1.2f',LeftBias))

end

end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end

function cornertext(h,str)
unit = get(h,'Units');
set(h,'Units','char');
pos = get(h,'Position');
if ~iscell(str)
    str = {str};
end
for i = 1:length(str)
    x = pos(1)+1;y = pos(2)+pos(4)-i;
    uicontrol(h.Parent,'Units','char','Position',[x,y,length(str{i})+1,1],'string',str{i},'style','text','background',[1,1,1],'FontSize',8);
end
set(h,'Units',unit);
end

