function TwoArmBanditVariant_PlotSideOutcome(AxesHandles, Action, varargin)
global nTrialsToShow %this is for convenience
global BpodSystem
global TaskParameters

% colour palette (suitable for most colourblind people)
scarlet = [254, 60, 60]/255; % for unreward sign, contracting with denim or denim
denim = [31, 54, 104]/255; % mainly for neutral signs
azure = [0, 162, 254]/255; % for reward sign

switch Action
    case 'init'
        %% initialize pokes plot
        nTrialsToShow = 90; %default number of trials to display
        
        if nargin >= 3 % custom number of trials to show
            nTrialsToShow = varargin{1};
        end
        
        %% Outcome Plot
        hold(AxesHandles.HandleOutcome, 'on');
        BpodSystem.GUIHandles.OutcomePlot.NoTrialStart = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','x','MarkerEdge',denim,'MarkerFace','none', 'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.BrokeFixation = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','square','MarkerEdge',denim,'MarkerFace','none', 'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','d','MarkerEdge',denim,'MarkerFace','none', 'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.NoDecision = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','*','MarkerEdge',denim,'MarkerFace','none', 'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.StartNewTrial = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','o','MarkerEdge',denim,'MarkerFace','none', 'MarkerSize',8);
        
        BpodSystem.GUIHandles.OutcomePlot.RewardLeft = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','<','MarkerEdge',azure,'MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.UnrewardLeft = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','<','MarkerEdge',scarlet,'MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.ChoiceLeft = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','<','MarkerEdge',denim,'MarkerFace','none', 'MarkerSize',14);
        
        BpodSystem.GUIHandles.OutcomePlot.SkippedFeedback = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','o','MarkerEdge',denim,'MarkerFace','none', 'MarkerSize',14);
        
        BpodSystem.GUIHandles.OutcomePlot.RewardRight = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','>','MarkerEdge',azure,'MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.UnrewardRight = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','>','MarkerEdge',scarlet,'MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.ChoiceRight = line(AxesHandles.HandleOutcome,-1,0,...
            'LineStyle','none','Marker','>','MarkerEdge',denim,'MarkerFace','none', 'MarkerSize',14);
        
        BpodSystem.GUIHandles.OutcomePlot.CumRwd = text(AxesHandles.HandleOutcome,1,1,'microL',...
            'verticalalignment','bottom','horizontalalignment','center');
        
        BpodSystem.GUIHandles.OutcomePlot.legend = legend(AxesHandles.HandleOutcome,'NoTrialStart','BrokeFixation','EarlyWithdrawal','NoDecision','StartNewTrial',...
                                    'Reward(L)','Unreward(L)','Choice(L)','SkippedFeedback','Location','east');
        
        
        set(AxesHandles.HandleOutcome,'TickDir','out','YLim',[0,1.2],'XLim',[0,nTrialsToShow],'YTick',[0 1],'FontSize',13);
        xlabel(AxesHandles.HandleOutcome, 'Trial#', 'FontSize', 14);
        ylabel(AxesHandles.HandleOutcome, 'RewardProb', 'FontSize', 14);
        
        %% Trial rate
        hold(AxesHandles.HandleTrialRate,'on')
        BpodSystem.GUIHandles.OutcomePlot.TrialRate = line(AxesHandles.HandleTrialRate,-1,0,'LineStyle','-','Color','k','Visible','off');
        BpodSystem.GUIHandles.OutcomePlot.NoStartP = text(AxesHandles.HandleTrialRate,0,1,'NoStartP = 0%','FontSize',8,'Units','normalized','Visible','off');
        AxesHandles.HandleTrialRate.XLabel.String = 'Time (min)'; % FIGURE OUT UNIT
        AxesHandles.HandleTrialRate.YLabel.String = 'Trial Counts';
        AxesHandles.HandleTrialRate.Title.String = 'Trial Start Rate';

        %% StimeDelay histogram
        hold(AxesHandles.HandleStimDelay,'on')
        AxesHandles.HandleStimDelay.XLabel.String = 'Time (ms)'; % FIGURE OUT UNIT
        AxesHandles.HandleStimDelay.YLabel.String = 'Trial Counts';
        AxesHandles.HandleStimDelay.Title.String = 'Stimulus Delay';
        
        %% SampleTime histogram
        hold(AxesHandles.HandleSampleTime,'on')
        AxesHandles.HandleSampleTime.XLabel.String = 'Time (ms)'; % FIGURE OUT UNIT
        AxesHandles.HandleSampleTime.YLabel.String = 'Trial Counts';
        AxesHandles.HandleSampleTime.Title.String = 'Sample Time';
        
        %% MoveTime histogram
        hold(AxesHandles.HandleMoveTime,'on')
        AxesHandles.HandleMoveTime.XLabel.String = 'Time (ms)'; % FIGURE OUT UNIT
        AxesHandles.HandleMoveTime.YLabel.String = 'Trial Counts';
        AxesHandles.HandleMoveTime.Title.String = 'Movement Time';
        
        %% FeedbackDelay histogram
        hold(AxesHandles.HandleFeedback,'on')
        AxesHandles.HandleFeedback.XLabel.String = 'Time (s)';
        AxesHandles.HandleFeedback.YLabel.String = 'Trial Counts';
        AxesHandles.HandleFeedback.Title.String = 'Feedback Delay';
        set(AxesHandles.HandleFeedback,'TickDir','out','XLim',[0,20],'XTick',[0,10,20]);
        
        %% TimeInvestment
        hold(AxesHandles.HandleTimeInvestment,'on')
        BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentPointsSkippedBaited = line(AxesHandles.HandleTimeInvestment,-1,0, 'LineStyle','none','Marker','.','MarkerEdge',denim,'MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentSkippedBaited = errorbar(AxesHandles.HandleTimeInvestment,-1,0,1, 'LineStyle','-','Marker','o','MarkerEdge',denim,'MarkerFace','none', 'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentPointsNotBaited = line(AxesHandles.HandleTimeInvestment,-1,0, 'LineStyle','none','Marker','.','MarkerEdge',azure,'MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentNotBaited = errorbar(AxesHandles.HandleTimeInvestment,-1,0,1, 'LineStyle','-','Marker','o','MarkerEdge',azure,'MarkerFace','none', 'MarkerSize',8);
        BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentPointsIncorrect = line(AxesHandles.HandleTimeInvestment,-1,0, 'LineStyle','none','Marker','.','MarkerEdge',scarlet,'MarkerFace','none', 'MarkerSize',6);
        BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentIncorrect = errorbar(AxesHandles.HandleTimeInvestment,-1,0,1, 'LineStyle','-','Marker','o','MarkerEdge',scarlet,'MarkerFace','none', 'MarkerSize',8);
        AxesHandles.HandleTimeInvestment.XLabel.String = 'RewardProb';
        AxesHandles.HandleTimeInvestment.YLabel.String = 'Time (s)';
        AxesHandles.HandleTimeInvestment.Title.String = 'Time Investment';
        set(AxesHandles.HandleTimeInvestment,'TickDir','out','XLim',[0,1.1],'YLim',[0,20],'XTick',[0,0.5,1],'YTick',[0,10,20]);
        
    case 'UpdateTrial' % Update before the trial starts, mainly for viewing what's the next trial is about
        iTrial = varargin{1};
        TrialData = BpodSystem.Data.Custom.TrialData;
        
        Baited = TrialData.Baited;
        LightLeft = TrialData.LightLeft;
        RewardProb = TrialData.RewardProb;
        RewardMagnitude = TrialData.RewardMagnitude;
        
        %% Outcome Plot
        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,iTrial,nTrialsToShow); % see below, mn being the min of xlim
        indxToPlot = mn:iTrial;
        
        % RewardLeft
        ndxRewardLeft = LightLeft(indxToPlot) ~= 0 & Baited(1,indxToPlot); % include case == 1 and == NaN
        XData = indxToPlot(ndxRewardLeft);
        YData = RewardProb(1,indxToPlot(ndxRewardLeft));
        set(BpodSystem.GUIHandles.OutcomePlot.RewardLeft, 'xdata', XData, 'ydata', YData);
        
        % RewardRight
        ndxRewardRight = LightLeft(indxToPlot) ~= 1 & Baited(2,indxToPlot); % include case == 0 and == NaN
        XData = indxToPlot(ndxRewardRight);
        YData = RewardProb(2,indxToPlot(ndxRewardRight));
        set(BpodSystem.GUIHandles.OutcomePlot.RewardRight, 'xdata', XData, 'ydata', YData);
        
        % UnrewardLeft
        ndxUnrewardLeft = LightLeft(indxToPlot) ~= 0 & ~Baited(1,indxToPlot); % include case == 1 and == NaN
        XData = indxToPlot(ndxUnrewardLeft);
        YData = RewardProb(1,indxToPlot(ndxUnrewardLeft));
        set(BpodSystem.GUIHandles.OutcomePlot.UnrewardLeft, 'xdata', XData, 'ydata', YData);
        
        % UnrewardRight
        ndxUnrewardRight = LightLeft(indxToPlot) ~= 1 & ~Baited(2,indxToPlot); % include case == 0 and == NaN
        XData = indxToPlot(ndxUnrewardRight);
        YData = RewardProb(2,indxToPlot(ndxUnrewardRight));
        set(BpodSystem.GUIHandles.OutcomePlot.UnrewardRight, 'xdata', XData, 'ydata', YData);
        
    case 'UpdateResult' % plot trial result
        iTrial = varargin{1};
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
        
        StimWaitingTime = TrialData.StimWaitingTime;
        SampleTime = TrialData.SampleTime;
        MoveTime = TrialData.MoveTime;
        StartNewTrialSuccessful = TrialData.StartNewTrialSuccessful;
        FeedbackWaitingTime = TrialData.FeedbackWaitingTime;
        Baited = TrialData.Baited;
        Rewarded = TrialData.Rewarded;

        %% OutcomePlot
        % recompute xlim
        [mn, ~] = rescaleX(AxesHandles.HandleOutcome,iTrial,nTrialsToShow); % see below, mn being the min of xlim
        indxToPlot = mn:iTrial;
        
        % NoTrialStart
        if NoTrialStart(iTrial) == 1
            ndxNoTrialStart = NoTrialStart(indxToPlot) == 1;
            XData = indxToPlot(ndxNoTrialStart);
            YData = zeros(1,sum(ndxNoTrialStart));
            set(BpodSystem.GUIHandles.OutcomePlot.NoTrialStart, 'xdata', XData, 'ydata', YData);
        end
        
        % BrokeFixation
        if BrokeFixation(iTrial) == 1
            ndxBrokeFixation = BrokeFixation(indxToPlot) == 1;
            XData = indxToPlot(ndxBrokeFixation);
            YData = zeros(1,sum(ndxBrokeFixation));
            set(BpodSystem.GUIHandles.OutcomePlot.BrokeFixation, 'xdata', XData, 'ydata', YData);
        end
        
        % EarlyWithdrawal
        if EarlyWithdrawal(iTrial) == 1
            ndxEarlyWithdrawl = EarlyWithdrawal(indxToPlot) == 1;
            XData = indxToPlot(ndxEarlyWithdrawl);
            YData = zeros(1,sum(ndxEarlyWithdrawl));
            set(BpodSystem.GUIHandles.OutcomePlot.EarlyWithdrawal, 'xdata', XData, 'ydata', YData);
        end
        
        % NoDecision
        if NoDecision(iTrial) == 1
            ndxNoDecision = NoDecision(indxToPlot) == 1;
            XData = indxToPlot(ndxNoDecision);
            YData = zeros(1,sum(ndxNoDecision));
            set(BpodSystem.GUIHandles.OutcomePlot.NoDecision, 'xdata', XData, 'ydata', YData);
        end
        
        % StartNewTrial
        if StartNewTrial(iTrial) == 1
            ndxStartNewTrial = StartNewTrial(indxToPlot) == 1;
            XData = indxToPlot(ndxStartNewTrial);
            YData = zeros(1,sum(ndxStartNewTrial));
            set(BpodSystem.GUIHandles.OutcomePlot.StartNewTrial, 'xdata', XData, 'ydata', YData);
        end
        
        if ~isnan(ChoiceLeft(iTrial))
            % ChoiceLeft
            ndxChoiceLeft = ChoiceLeft(indxToPlot) == 1;
            XData = indxToPlot(ndxChoiceLeft);
            YData = RewardProb(1,indxToPlot(ndxChoiceLeft));
            set(BpodSystem.GUIHandles.OutcomePlot.ChoiceLeft, 'xdata', XData, 'ydata', YData);
            
            % ChoiceRight
            ndxChoiceRight = ChoiceLeft(indxToPlot) == 0;
            XData = indxToPlot(ndxChoiceRight);
            YData = RewardProb(2,indxToPlot(ndxChoiceRight));
            set(BpodSystem.GUIHandles.OutcomePlot.ChoiceRight, 'xdata', XData, 'ydata', YData);
        end
        
        if SkippedFeedback(iTrial) == 1
            % SkippedFeedbackLeft
            ndxSkippedFeedbackLeft = SkippedFeedback(indxToPlot) == 1 & ChoiceLeft(indxToPlot) == 1;
            ndxSkippedFeedbackRight = SkippedFeedback(indxToPlot) == 1 & ChoiceLeft(indxToPlot) == 0;
            XData = [indxToPlot(ndxSkippedFeedbackLeft), indxToPlot(ndxSkippedFeedbackRight)];
            YData = [RewardProb(1,indxToPlot(ndxSkippedFeedbackLeft)), RewardProb(2,indxToPlot(ndxSkippedFeedbackRight))];
            set(BpodSystem.GUIHandles.OutcomePlot.SkippedFeedback, 'xdata', XData, 'ydata', YData);
        end
        
        % CumRwd
        RewardTotal = CalculateCumulativeReward(); % custom function under Bpod_Gen2/Custom
        set(BpodSystem.GUIHandles.OutcomePlot.CumRwd, ...
            'position', [iTrial+1 1], ...
            'string', [num2str(RewardTotal) ' microL']);
        
        %% Trial rate
        BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate.Visible = 'on';
        set(get(BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate,'Children'),'Visible','on');
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.XData = (BpodSystem.Data.TrialStartTimestamp-min(BpodSystem.Data.TrialStartTimestamp))/60; % (min)
        BpodSystem.GUIHandles.OutcomePlot.TrialRate.YData = cumsum(NoTrialStart==0);
        NoTrialStartP = 100*sum(NoTrialStart==1)/iTrial;
        set(BpodSystem.GUIHandles.OutcomePlot.NoStartP, 'string', ['NoStartP = ' sprintf('%1.1f',NoTrialStartP) '%']);
%         cornertext(AxesHandles.HandleTrialRate,sprintf('NoStartP=%1.2f',NoTrialStartP)) %percentage of No Trial Started
        
        %% Stimulus Delay
        if NoTrialStart(iTrial) == 0
            BpodSystem.GUIHandles.OutcomePlot.HandleStimDelay.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleStimDelay,'Children'),'Visible','on');
            cla(AxesHandles.HandleStimDelay)
            BpodSystem.GUIHandles.OutcomePlot.HistBrokeFixation = histogram(AxesHandles.HandleStimDelay,StimWaitingTime(BrokeFixation==1)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistBrokeFixation.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistBrokeFixation.FaceColor = scarlet;
            BpodSystem.GUIHandles.OutcomePlot.HistBrokeFixation.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistNBrokeFixation = histogram(AxesHandles.HandleStimDelay,StimWaitingTime(BrokeFixation==0)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistNBrokeFixation.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistNBrokeFixation.FaceColor = azure;
            BpodSystem.GUIHandles.OutcomePlot.HistNBrokeFixation.EdgeColor = 'none';
            BrokeFixationP = 100*sum(BrokeFixation==1)/sum(NoTrialStart==0);
            BpodSystem.GUIHandles.OutcomePlot.BrokeFixP = text(AxesHandles.HandleStimDelay,0,1,['BrokeFixP = ' sprintf('%1.1f',BrokeFixationP) '%'],...
                'FontSize',8,'Units','normalized');
%             cornertext(AxesHandles.HandleStimDelay,sprintf('BrokeFixP=%1.2f',BrokeFixationP)) %percentage of BrokeFixation with Trial Started
        end
        
        %% Sample Time
        if BrokeFixation(iTrial) == 0
            BpodSystem.GUIHandles.OutcomePlot.HandleSampleTime.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleSampleTime,'Children'),'Visible','on');
            cla(AxesHandles.HandleSampleTime)
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly = histogram(AxesHandles.HandleSampleTime,SampleTime(EarlyWithdrawal==1)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.FaceColor = scarlet;
            BpodSystem.GUIHandles.OutcomePlot.HistSTEarly.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistST = histogram(AxesHandles.HandleSampleTime,SampleTime(EarlyWithdrawal==0)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistST.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistST.FaceColor = azure;
            BpodSystem.GUIHandles.OutcomePlot.HistST.EdgeColor = 'none';
            EarlyP = 100*sum(EarlyWithdrawal==1)/sum(BrokeFixation==0);
            BpodSystem.GUIHandles.OutcomePlot.EarlyP = text(AxesHandles.HandleSampleTime,0,1,['EarlyP = ' sprintf('%1.1f',EarlyP) '%'],...
                'FontSize',8,'Units','normalized');
%             cornertext(AxesHandles.HandleSampleTime,sprintf('EarlyP=%1.2f',EarlyP))
        end
        
        %% MoveTime
        if NoDecision(iTrial) == 0 % no need to update if no choice made
            BpodSystem.GUIHandles.OutcomePlot.HandleMoveTime.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleMoveTime,'Children'),'Visible','on');
            cla(AxesHandles.HandleMoveTime)
            BpodSystem.GUIHandles.OutcomePlot.HistMTLeft = histogram(AxesHandles.HandleMoveTime,MoveTime(ChoiceLeft==1)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistMTLeft.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistMTLeft.FaceColor = azure;
            BpodSystem.GUIHandles.OutcomePlot.HistMTLeft.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistMTRight = histogram(AxesHandles.HandleMoveTime,MoveTime(ChoiceLeft==0)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistMTRight.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistMTRight.FaceColor = scarlet;
            BpodSystem.GUIHandles.OutcomePlot.HistMTRight.EdgeColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistMTStartNew = histogram(AxesHandles.HandleMoveTime,MoveTime(StartNewTrialSuccessful==1)*1000);
            BpodSystem.GUIHandles.OutcomePlot.HistMTStartNew.BinWidth = 50;
            BpodSystem.GUIHandles.OutcomePlot.HistMTStartNew.FaceColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistMTStartNew.EdgeColor = denim;
            LeftP = 100*sum(ChoiceLeft==1)/sum(EarlyWithdrawal==0);
            RightP = 100*sum(ChoiceLeft==0)/sum(EarlyWithdrawal==0);
            StartNewP = 100*sum(StartNewTrialSuccessful==1)/sum(EarlyWithdrawal==0);
            NoDeciP = 100*sum(NoDecision==1)/sum(EarlyWithdrawal==0);
            IncorrectP = 100*sum(IncorrectChoice==1)/sum(~isnan(ChoiceLeft));
            BpodSystem.GUIHandles.OutcomePlot.LeftP = text(AxesHandles.HandleMoveTime,0,1.00,['LeftP = ' sprintf('%1.1f',LeftP) '%'],...
                'FontSize',8,'Units','normalized');
            BpodSystem.GUIHandles.OutcomePlot.RightP = text(AxesHandles.HandleMoveTime,0,0.95,['RightP = ' sprintf('%1.1f',RightP) '%'],...
                'FontSize',8,'Units','normalized');
            BpodSystem.GUIHandles.OutcomePlot.StartNewP = text(AxesHandles.HandleMoveTime,0,0.90,['StartNewP = ' sprintf('%1.1f',StartNewP) '%'],...
                'FontSize',8,'Units','normalized');
            BpodSystem.GUIHandles.OutcomePlot.NoDeciP = text(AxesHandles.HandleMoveTime,0,0.85,['NoDeciP = ' sprintf('%1.1f',NoDeciP) '%'],...
                'FontSize',8,'Units','normalized');
            BpodSystem.GUIHandles.OutcomePlot.IncorrectP = text(AxesHandles.HandleMoveTime,0,0.80,['IncorrectP = ' sprintf('%1.1f',IncorrectP) '%'],...
                'FontSize',8,'Units','normalized');
%             cornertext(AxesHandles.HandleMoveTime,{sprintf('LeftP=%1.2f',LeftP),sprintf('RightP=%1.2f',RightP),...
%                                                    sprintf('StartNewP=%1.2f',StartNewP),sprintf('NoDeciP=%1.2f',NoDeciP),...
%                                                    sprintf('IncorrectP=%1.2f',IncorrectP)})
        end
        
        %% Feedback Delay
        if ~isnan(SkippedFeedback(iTrial)) % no need to update if no new SkippedFeedback
            BpodSystem.GUIHandles.OutcomePlot.HandleFeedback.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleFeedback,'Children'),'Visible','on');
            cla(AxesHandles.HandleFeedback)
            BpodSystem.GUIHandles.OutcomePlot.HistSFLeft = histogram(AxesHandles.HandleFeedback,FeedbackWaitingTime(SkippedFeedback==1 & ChoiceLeft==1));
            BpodSystem.GUIHandles.OutcomePlot.HistSFLeft.BinWidth = 1;
            BpodSystem.GUIHandles.OutcomePlot.HistSFLeft.FaceColor = scarlet;
            BpodSystem.GUIHandles.OutcomePlot.HistSFLeft.EdgeColor = 'none';

            BpodSystem.GUIHandles.OutcomePlot.HistSFRight = histogram(AxesHandles.HandleFeedback,FeedbackWaitingTime(SkippedFeedback==1 & ChoiceLeft==0));
            BpodSystem.GUIHandles.OutcomePlot.HistSFRight.BinWidth = 1;
            BpodSystem.GUIHandles.OutcomePlot.HistSFRight.FaceColor = azure;
            BpodSystem.GUIHandles.OutcomePlot.HistSFRight.EdgeColor = 'none';

            BpodSystem.GUIHandles.OutcomePlot.HistRFLeft = histogram(AxesHandles.HandleFeedback,FeedbackWaitingTime(SkippedFeedback==0 & ChoiceLeft==1));
            BpodSystem.GUIHandles.OutcomePlot.HistRFLeft.BinWidth = 1;
            BpodSystem.GUIHandles.OutcomePlot.HistRFLeft.FaceColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistRFLeft.EdgeColor = scarlet;

            BpodSystem.GUIHandles.OutcomePlot.HistRFRight = histogram(AxesHandles.HandleFeedback,FeedbackWaitingTime(SkippedFeedback==0 & ChoiceLeft==0));
            BpodSystem.GUIHandles.OutcomePlot.HistRFRight.BinWidth = 1;
            BpodSystem.GUIHandles.OutcomePlot.HistRFRight.FaceColor = 'none';
            BpodSystem.GUIHandles.OutcomePlot.HistRFRight.EdgeColor = azure;

            SFLeftP = 100*sum(SkippedFeedback==1 & ChoiceLeft==1)/sum(~isnan(ChoiceLeft)); % skipped feedback left
            SFRightP = 100*sum(SkippedFeedback==1 & ChoiceLeft==0)/sum(~isnan(ChoiceLeft));
            RFLeftP = 100*sum(SkippedFeedback==0 & ChoiceLeft==1)/sum(~isnan(ChoiceLeft)); % received feedback left (incl. IncorrectChoice)
            RFRightP = 100*sum(SkippedFeedback==0 & ChoiceLeft==0)/sum(~isnan(ChoiceLeft));
            BpodSystem.GUIHandles.OutcomePlot.SFLeftP = text(AxesHandles.HandleFeedback,0,1.00,['SkippedLeftP = ' sprintf('%1.1f',SFLeftP) '%'],...
                'FontSize',8,'Units','normalized');
            BpodSystem.GUIHandles.OutcomePlot.SFRightP = text(AxesHandles.HandleFeedback,0,0.95,['SkippedRightP = ' sprintf('%1.1f',SFRightP) '%'],...
                'FontSize',8,'Units','normalized');
            BpodSystem.GUIHandles.OutcomePlot.RFLeftP = text(AxesHandles.HandleFeedback,0,0.90,['ReceivedLeftP = ' sprintf('%1.1f',RFLeftP) '%'],...
                'FontSize',8,'Units','normalized');
            BpodSystem.GUIHandles.OutcomePlot.RFRightP = text(AxesHandles.HandleFeedback,0,0.85,['ReceivedRightP = ' sprintf('%1.1f',RFRightP) '%'],...
                'FontSize',8,'Units','normalized');
%             cornertext(AxesHandles.HandleFeedback,{sprintf('SFLeftP=%1.2f',SFLeftP),sprintf('SFRightP=%1.2f',SFRightP),...
%                                                    sprintf('RFLeftP=%1.2f',RFLeftP),sprintf('RFRightP=%1.2f',RFRightP)})
        end
        
        %% TimeInvestment
        if TaskParameters.GUI.CatchTrial && Rewarded(iTrial) == 0 % only when CatchTrial is true
            BpodSystem.GUIHandles.OutcomePlot.HandleTimeInvestment.Visible = 'on';
            set(get(BpodSystem.GUIHandles.OutcomePlot.HandleTimeInvestment,'Children'),'Visible','on');
            % cla(AxesHandles.HandleTimeInvestment)
            
            ChoiceLeftRight = [ChoiceLeft; 1-ChoiceLeft];
            ndxIncorrect = IncorrectChoice == 1; %all (completed) error trials (including catch errors)
            ndxNotBaited = any((Baited == 0) .* ChoiceLeftRight, 1); % Choice is non-baited
            ndxSkippedBaited = any((Baited == 1) .* ChoiceLeftRight .* [SkippedFeedback; SkippedFeedback], 1); % Choice made is Baited but Skipped
            
            ChoiceRewardProb = sum(RewardProb.*ChoiceLeftRight, 1);
            IncorrectChoiceRewardProb = ChoiceRewardProb(ndxIncorrect);
            NotBaitedCorrectChoiceRewardProb = ChoiceRewardProb(ndxNotBaited);
            SkippedBaitedCorrectChoiceRewardProb = ChoiceRewardProb(ndxSkippedBaited);
            
            IncorrectChoiceWT = FeedbackWaitingTime(ndxIncorrect);
            NotBaitedCorrectChoiceWT = FeedbackWaitingTime(ndxNotBaited);
            SkippedBaitedCorrectChoiceWT = FeedbackWaitingTime(ndxSkippedBaited);
            
            % scatter plot
            set(BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentPointsIncorrect, 'xdata', IncorrectChoiceRewardProb, 'ydata', IncorrectChoiceWT);
            set(BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentPointsNotBaited, 'xdata', NotBaitedCorrectChoiceRewardProb, 'ydata', NotBaitedCorrectChoiceWT);
            set(BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentPointsSkippedBaited, 'xdata', SkippedBaitedCorrectChoiceRewardProb, 'ydata', SkippedBaitedCorrectChoiceWT);
            
            % Mean-Error curve
            %% NOT IMPLEMENTED %%
%             RewardProbBin = 0.1;
%             XBinIdx = 0:RewardProbBin:(1-RewardProbBin);
%             
%             IncorrectChoiceTable = table(discretize(IncorrectChoiceRewardProb, XBinIdx)',IncorrectChoiceWT', 'VariableNames',{'RewardProbBin', 'WT'});
%             NotBaitedCorrectChoiceTable = table(discretize(NotBaitedCorrectChoiceRewardProb, XBinIdx)',NotBaitedCorrectChoiceWT', 'VariableNames',{'RewardProbBin', 'WT'});
%             SkippedBaitedCorrectChoiceTable = table(discretize(SkippedBaitedCorrectChoiceRewardProb, XBinIdx)',SkippedBaitedCorrectChoiceWT', 'VariableNames',{'RewardProbBin', 'WT'});
%             
%             XBinIdx = XBinIdx + RewardProbBin/2;
%             
%             IncorrectChoiceGrpStats = grpstats(IncorrectChoiceTable, 'RewardProbBin', {'mean','sem'},'DataVars','WT');
%             IncorrectChoiceWTBin = IncorrectChoiceGrpStats.RewardProbBin;
%             IncorrectChoiceWTBinMean = IncorrectChoiceGrpStats.mean_WT;
%             IncorrectChoiceWTBinErr = IncorrectChoiceGrpStats.sem_WT;
% 
%             NotBaitedCorrectChoiceGrpStats = grpstats(NotBaitedCorrectChoiceTable, 'RewardProbBin', {'mean','sem'},'DataVars','WT');
%             NotBaitedCorrectChoiceWTBin = NotBaitedCorrectChoiceGrpStats.RewardProbBin;
%             NotBaitedCorrectChoiceWTBinMean = NotBaitedCorrectChoiceGrpStats.mean_WT;
%             NotBaitedCorrectChoiceWTBinErr = NotBaitedCorrectChoiceGrpStats.sem_WT;
%             
%             SkippedBaitedCorrectChoiceGrpStats = grpstats(SkippedBaitedCorrectChoiceTable, 'RewardProbBin', {'mean','sem'},'DataVars','WT');
%             SkippedBaitedCorrectChoiceWTBin = SkippedBaitedCorrectChoiceGrpStats.RewardProbBin;
%             SkippedBaitedCorrectChoiceWTBinMean = SkippedBaitedCorrectChoiceGrpStats.mean_WT;
%             SkippedBaitedCorrectChoiceWTBinErr = SkippedBaitedCorrectChoiceGrpStats.sem_WT;
%             
%             set(BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentIncorrect, 'xdata', XBinIdx(IncorrectChoiceWTBin), 'ydata', IncorrectChoiceWTBinMean, 'YNegativeDelta', IncorrectChoiceWTBinErr, 'YPositiveDelta', IncorrectChoiceWTBinErr);
%             set(BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentNotBaited, 'xdata', XBinIdx(NotBaitedCorrectChoiceWTBin), 'ydata', NotBaitedCorrectChoiceWTBinMean, 'YNegativeDelta', NotBaitedCorrectChoiceWTBinErr, 'YPositiveDelta', NotBaitedCorrectChoiceWTBinErr);
%             set(BpodSystem.GUIHandles.OutcomePlot.TimeInvestmentSkippedBaited, 'xdata', XBinIdx(SkippedBaitedCorrectChoiceWTBin), 'ydata', SkippedBaitedCorrectChoiceWTBinMean, 'YNegativeDelta', SkippedBaitedCorrectChoiceWTBinErr, 'YPositiveDelta', SkippedBaitedCorrectChoiceWTBinErr);
        end
        
end % switch end
end % function end

function [mn,mx] = rescaleX(AxesHandle,CurrentTrial,nTrialsToShow)
FractionWindowStickpoint = .75; % After this fraction of visible trials, the trial position in the window "sticks" and the window begins to slide through trials.
mn = max(round(CurrentTrial - FractionWindowStickpoint*nTrialsToShow),1);
mx = mn + nTrialsToShow - 1;
set(AxesHandle,'XLim',[mn-1 mx+1]);
end

% function cornertext(h,str) % Not in use due to long computation time
% unit = get(h,'Units');
% set(h,'Units','char');
% pos = get(h,'Position');
% if ~iscell(str)
%     str = {str};
% end
% for i = 1:length(str)
%     x = pos(1)+1;y = pos(2)+pos(4)-i;
%     uicontrol(h.Parent,'Units','char','Position',[x,y,length(str{i})+1,1],'string',str{i},'style','text','background',[1,1,1],'FontSize',8);
% end
% set(h,'Units',unit);
% end