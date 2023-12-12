% [datafile, datapath] = uigetfile('\\ottlabfs.bccn-berlin.pri\ottlab\data\');
datapath = '\\ottlabfs.bccn-berlin.pri\ottlab\data\23\bpod_session\20230523_135544';
datafile = '23_TwoArmBanditVariant_20230523_135544.mat';
load(fullfile(datapath, datafile));

%% Load related data to local variabels
Animal = str2double(SessionData.Info.Subject);
if isnan(Animal)
    Animal = -1;
end
Date = datestr(SessionData.Info.SessionDate, 'yyyymmdd');

nTrials = SessionData.nTrials;
if nTrials < 50
    disp('nTrial < 50. Impossible for analysis.')
    FigHandle = [];
    return
end
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
% FeedbackDelay = SessionData.Custom.TrialData.FeedbackDelay(1:nTrials);
% FeedbackWaitingTime = rand(nTrials,1)*10; %delete this
% FeedbackWaitingTime = FeedbackWaitingTime';  %delete this
% FeedbackDelay = rand(nTrials,1)*10; %delete this
% FeedbackDelay= FeedbackDelay'; 

RewardProb = SessionData.Custom.TrialData.RewardProb(:, 1:nTrials);
LightLeft = SessionData.Custom.TrialData.LightLeft(1:nTrials);
LightLeftRight = [LightLeft; 1-LightLeft]; 
ChoiceLeftRight = [ChoiceLeft; 1-ChoiceLeft]; 

%% Common plots regardless of task design/ risk type
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
FigHandle = figure('Position', [   0       0     842    1191],... % DIN A3, 72 ppi (window will crop it to _ x 1024, same as disp resolution)
                   'NumberTitle', 'off',...
                   'Name', strcat(num2str(Animal), '_', Date),...
                   'MenuBar', 'none',...
                   'Resize', 'off');

%% overview of events across session
TrialOverviewAxes = axes(FigHandle, 'Position', [0.01    0.77    0.48    0.20]);
hold(TrialOverviewAxes, 'on');

%% Plot based on task design/ risk type
switch SessionData.SettingsFile.GUIMeta.RiskType.String{SessionData.SettingsFile.GUI.RiskType}
    case 'Fix'
    % not yet implemented %

    case 'BlockRand'
    % not yet implemented %

    case 'BlockFix'
    % not yet implemented %

    case 'BlockFixHolding'
    %% overview of events across session
    title(TrialOverviewAxes, strcat(num2str(Animal), '\_', Date, '\_Matching'))

    %% Block switching behaviour across session
    BlockSwitchHandle = axes(FigHandle, 'Position', [0.01    0.60    0.48    0.11]);
    hold(BlockSwitchHandle, 'on');
    if ~isempty(ChoiceLeft) && ~all(isnan(ChoiceLeft))
        xdata = 1:nTrials;
        RewardProbLeft = RewardProb(1,:);
        BlockDesignHandle = plot(BlockSwitchHandle, xdata, RewardProbLeft, '-', 'Color', [.5,.5,.5], 'LineWidth', 1);
        
        BinWidth = 10;
        ChoiceLeftSmoothed = smooth(ChoiceLeft, BinWidth, 'moving','omitnan'); %current bin width: 10 trials
        BlockChoiceHandle = plot(BlockSwitchHandle, xdata, ChoiceLeftSmoothed, '-k', 'LineWidth', 1);
        TrialChoicePlot = plot(BlockSwitchHandle, 1:nTrials, ChoiceLeft, '|', 'Color', 'k', 'MarkerSize', 1);

        set(BlockSwitchHandle,...
            'TickDir', 'out',...
            'XTickLabel', [],...
            'XAxisLocation', 'top',...
            'YLim', [-0.2 1.2],...
            'YTick', [0 0.5 1],...
            'YAxisLocation', 'right',...
            'FontSize', 10);
        ylabel('Left Choices (%)')
        % title('Block switching behaviour')
    end

    %% Lau Glimcher-model
    try 
        % preparing the data for design matrix
        Choices = ChoiceLeft';
        Choices(Choices==0) = -1; %1 = left; -1 = right
        Rewards = Rewarded'==1;
        Rewards = Rewards .* Choices; % reward per choice +/-1   % 1 = left and rewarded; -1 = right and rewarded
        Unrewards = Rewarded'==0;
        Unrewards = Rewards .* Choices;

        % build trial history kernels (n=5)
        HistoryKernelSize = 5;
        Choices = repmat(Choices, 1, HistoryKernelSize); % creates a matrix with each row representing the data from one trial
        Rewards = repmat(Rewards, 1, HistoryKernelSize); % each column is one variable associated with the explanatory varible (Choices, Rewards)
        Unrewards = repmat(Unrewards, 1, HistoryKernelSize);
        for j = 1:HistoryKernelSize                      % in this case being the last 5 trials
            Choices(:, j) = circshift(Choices(:, j), j);       
            Choices(1:j, j) = 0;                       
            Rewards(:, j) = circshift(Rewards(:, j), j);      
            Rewards(1:j, j) = 0;
            Unrewards(:, j) = circshift(Unrewards(:, j), j);      
            Unrewards(1:j, j) = 0; 
        end
        
        % concatenate to build design matrix X
        X = [Choices, Rewards];
        X(isnan(X)) = 0;
        
        mdl = fitglm(X, ChoiceLeft', 'distribution', 'binomial');
    
        % predict choices
        Ppredict = mdl.Fitted.Response;
        logodds = mdl.Fitted.LinearPredictor;   %logodds for both: left and right
        
        PredictedChoice = double(Ppredict>=0.5);
        PredictedChoice(isnan(ChoiceLeft)) = nan;
        PredictedChoicePlot = plot(BlockSwitchHandle, 1:nTrials, PredictedChoice*1.2 -0.1, '|', 'Color', 'r', 'MarkerSize', 1);
        SmoothedPredictedChoiceLeft = smooth(PredictedChoice, BinWidth, 'moving','omitnan');
        SmoothedPredictedChoicePlot = plot(BlockSwitchHandle, xdata, SmoothedPredictedChoiceLeft, '-r', 'LineWidth', 0.2);
        
        % odds based on reward or choice only
%         C0 = zeros(size(Choices));
%         R0 = zeros(size(Rewards));
%         X = [Choices,R0];
%         Ppredict = mdl.predict(X);
%         Ppredict = Ppredict';
%         logoddsChoice = log(Ppredict) - log(1 - Ppredict);
%     
%         X = [C0,Rewards];
%         Ppredict = mdl.predict(X);
%         Ppredict = Ppredict';
%         logoddsReward = log(Ppredict) - log(1 - Ppredict);
        model = true;
        
    catch
        disp('error in running model');
        model = false;
        
    end
    
    HistoryCorrelationHandle = axes(FigHandle, 'Position', [0.32    0.41    0.20    0.09]);
    hold(HistoryCorrelationHandle, 'on');

    set(HistoryCorrelationHandle, 'FontSize', 10)
    xlabel(HistoryCorrelationHandle, 'nTrials back');
    ylabel(HistoryCorrelationHandle, 'Correlation Coeff.');
    title(HistoryCorrelationHandle, 'Trial History GLM Fit')

    if model ~= false
        xdata = 1:HistoryKernelSize;
        ydataChoice = mdl.Coefficients.Estimate(2:1+HistoryKernelSize);
        ydataReward = mdl.Coefficients.Estimate(7:1+2*HistoryKernelSize);
        intercept = mdl.Coefficients.Estimate(1);
    
        ChoiceHistoryCorrelationHandle = plot(HistoryCorrelationHandle, xdata, ydataChoice',...
                                              'Color', 'blue');
        RewardHistoryCorrelationHandle = plot(HistoryCorrelationHandle, xdata, ydataReward',...
                                              'Color', 'magenta');
        CorrelationInterceptHandle = plot(HistoryCorrelationHandle,...
                                          xdata, intercept.*ones(1, length(xdata)), '--k');

        HistoryLegendHandle = legend(HistoryCorrelationHandle, {'Choice','Reward','Intercept'},...
                                 'Position', [0.41    0.45    0.12    0.05],...
                                 'NumColumns', 1,...
                                 'Box', 'off');
    end
    
    %% Residual Histogram
    ResidualHistogramAxes = axes(FigHandle, 'Position', [0.55    0.40    0.15    0.11]);
    ResidualHistogram = plotResiduals(mdl, 'Histogram');

    %% Residual Histogram
    ResidualLaggedAxes = axes(FigHandle, 'Position', [0.80    0.40    0.15    0.11]);
    ResidualLagged = plotResiduals(mdl, 'lagged', 'Marker', '.', 'MarkerSize', 1);

    %% Residual Histogram
    ResidualFittedAxes = axes(FigHandle, 'Position', [0.55    0.25    0.15    0.11]);
    ResidualFitted = plotResiduals(mdl, 'fitted', 'Marker', '.', 'MarkerSize', 1);

    %% Residual Histogram
    ResidualProbabilityAxes = axes(FigHandle, 'Position', [0.80    0.25    0.15    0.11]);
    ResidualProbability = plotResiduals(mdl, 'Probability', 'Marker', '.', 'MarkerSize', 1);

    %% psychometric
    PsychometricHandle = axes(FigHandle, 'Position', [0.06    0.41    0.20    0.09]);
    hold(PsychometricHandle, 'on')
    
    set(PsychometricHandle,...
        'FontSize', 10,...
        'YLim', [0,1])
    title(PsychometricHandle, 'Psychometric')
    ylabel('Left Choices (%)')
    
    if model ~= false
        % Choice Psychometric
        ndxValid = ~isnan(ChoiceLeft); % and EarlyWithdrawal is always 0
        DV = logodds(ndxValid);
        ChoiceL = ChoiceLeft(ndxValid);
        dvbin = linspace(-max(abs(DV)), max(abs(DV)), 10);
        [xdata, ydata, error] = BinData(DV, ChoiceL, dvbin);
        vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);
        
        ChoicePsychometricErrorBarHandle = errorbar(PsychometricHandle, xdata(vv), ydata(vv), error(vv),...
                                                    'LineStyle', 'none',...
                                                    'LineWidth', 1.5,...
                                                    'Color', 'k',...
                                                    'Marker', 'o',...
                                                    'MarkerEdgeColor', 'k');
        
        mdl = fitglm(DV, ChoiceL(:), 'Distribution', 'binomial');
        ChoicePredictedPsychometricHandle = plot(PsychometricHandle, xdata, predict(mdl, xdata), '-', 'Color', [.5,.5,.5], 'LineWidth', 0.5);
    end
    
    %% Psychometrics of NotBaited Choice with High- and Low-TI
    TIPsychometricHandle = axes(FigHandle, 'Position', [0.06    0.27    0.20    0.09]);
    hold(TIPsychometricHandle, 'on')
    
    set(TIPsychometricHandle,...
        'FontSize', 10,...
        'YLim', [0,1])
    title(TIPsychometricHandle, 'NotBaited Psychometric')
    ylabel('Left Choices (%)')

    if model ~= false
        ndxBaited = (Baited(1,:) & ChoiceLeft==1) | (Baited(2,:) & ChoiceLeft==0);
        ChoiceL = ChoiceLeft(ndxValid & ~ndxBaited);
        DV = logodds(ndxValid & ~ndxBaited);

        TI = FeedbackWaitingTime(ndxValid & ~ ndxBaited);
        TImed = nanmedian(TI);
        high = TI>TImed;
        low = TI<=TImed;
        
        [xdata, ydata, error] = BinData(DV(high), ChoiceL(high), dvbin);
        vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);

        HighTINotBaitedPsychometricErrorBarHandle = errorbar(TIPsychometricHandle, xdata(vv), ydata(vv), error(vv),...
                                                             'LineStyle', 'none',...
                                                             'LineWidth', 1,...
                                                             'Marker', 'o',...
                                                             'MarkerFaceColor', [0 0 0.9],...
                                                             'MarkerEdgeColor', [0 0 0.9],...
                                                             'Color', [0 0 0.9]);

        [xdata, ydata, error] = BinData(DV(low), ChoiceL(low), dvbin);
        vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);

        LowTINotBaitedPsychometricErrorBarHandle = errorbar(TIPsychometricHandle, xdata(vv), ydata(vv), error(vv),...
                                                            'LineStyle', 'none',...
                                                            'LineWidth', 1,...
                                                            'Marker', 'o',...
                                                            'MarkerFaceColor', 'none',...
                                                            'MarkerEdgeColor', [0.5 0.5 1],...
                                                            'Color', [0.5 0.5 1]);
        
        mdl = fitglm(DV(high), ChoiceL(high), 'Distribution', 'binomial');
        HighTINotBaitedPredictedPsychometricHandle = plot(TIPsychometricHandle, xdata, predict(mdl, xdata), '-','Color', [0,0,.9], 'LineWidth', 0.5);

        mdl = fitglm(DV(low), ChoiceL(low), 'Distribution', 'binomial');
        LowTINotBaitedPredictedPsychometricHandle = plot(TIPsychometricHandle, xdata, predict(mdl, xdata), '-', 'Color', [.5,.5,1], 'LineWidth', 0.5);
        
        TIPsychometricLegendHandle = legend(TIPsychometricHandle, {'High TI','Low TI'},...
                                            'Box', 'off',...
                                            'Position', [0.07    0.33    0.05    0.03]);
    end
    
    %% plot vevaiometric      
    VevaiometricHandle = axes(FigHandle, 'Position', [0.06    0.09    0.20    0.14]);
    hold(VevaiometricHandle, 'on')
    
    set(VevaiometricHandle, 'FontSize', 10)
    title(VevaiometricHandle, 'Vevaiometric');
    xlabel(VevaiometricHandle, 'log(odds)');
    ylabel(VevaiometricHandle, 'Invested Time (s)');
    
    if model ~= false
        ndxExploit = ChoiceLeft == (logodds'>0);
        FeedbackWT = FeedbackWaitingTime(:);

        ExploreScatter_XData = logodds(ndxValid & ~ndxBaited & ~ndxExploit);
        ExploreScatter_YData = FeedbackWT(ndxValid & ~ndxBaited & ~ndxExploit);
        ExploitScatter_XData = logodds(ndxValid & ~ndxBaited & ndxExploit);
        ExploitScatter_YData = FeedbackWT(ndxValid & ~ndxBaited & ndxExploit);

        [ExploreLine_XData, ExploreLine_YData] = Binvevaio(ExploreScatter_XData, ExploreScatter_YData, 10);
        [ExploitLine_XData, ExploitLine_YData] = Binvevaio(ExploitScatter_XData, ExploitScatter_YData, 10);
        
        ExploreLineHandle = plot(VevaiometricHandle, ExploreLine_XData, ExploreLine_YData,...
                                 'Color', 'r',...
                                 'LineWidth', 2);       
        
        ExploitLineHandle = plot(VevaiometricHandle, ExploitLine_XData, ExploitLine_YData,...
                                 'Color', 'g',...
                                 'LineWidth', 2);
        
        ExploreScatterHandle = scatter(VevaiometricHandle, ExploreScatter_XData, ExploreScatter_YData,...
                                       'Marker', '.',...
                                       'MarkerEdgeColor', 'r');
        
        ExploitScatterHandle = scatter(VevaiometricHandle, ExploitScatter_XData, ExploitScatter_YData,...
                                       'Marker', '.',...
                                       'MarkerEdgeColor', 'g');

        VevaiometryLegendHandle  = legend(VevaiometricHandle, {'Explore','Exploit'},...
                                          'Box', 'off',...
                                          'Position', [0.18    0.16    0.05    0.03]);

    end

    %% callibration plot
    CalibrationHandle = axes(FigHandle, 'Position', [0.32    0.27    0.20    0.09]);
    hold(CalibrationHandle, 'on')

    set(CalibrationHandle, 'FontSize', 10)
    % title(CalibrationHandle, 'Calibration');
    xlabel(CalibrationHandle, 'Time Investment (s)');
    ylabel(CalibrationHandle, 'Ratio Exploit');

    if model ~= false && ~all(isnan(FeedbackWaitingTime))
        Correct = ndxExploit(ndxValid & ~ndxBaited); %'correct'
        FeedbackWT = FeedbackWaitingTime;
        ti = FeedbackWT(ndxValid & ~ndxBaited);
        edges = linspace(min(ti), max(ti), 8);
        [xdata, ydata, error] = BinData(ti, Correct, edges);
        vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);
        CalibrationErrorBarHandle = errorbar(CalibrationHandle,...
                                             xdata(vv), ydata(vv), error(vv),...
                                             'LineWidth', 2, ...
                                             'Color', 'r');
    end
    
end