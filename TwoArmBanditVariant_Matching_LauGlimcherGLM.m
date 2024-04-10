function AnalysisFigure = TwoArmBanditVariant_Matching_LauGlimcherGLM(DataFile)
% Matching Analysis Function
% Developed by Antonio Lee @ BCCN Berlin
% Version 2.0 ~ April 2024

if nargin < 1
    global BpodSystem
    if isempty(BpodSystem) || isempty(BpodSystem.Data)
        [datafile, datapath] = uigetfile('\\ottlabfs.bccn-berlin.pri\ottlab\data\');
        load(fullfile(datapath, datafile));
    else
        SessionData = BpodSystem.Data;
    end
else
    load(DataFile);
end  

if ~isfield(SessionData, 'SettingsFile')
    disp('Error: The selected file does not have the field "SettingsFile". No further Matching Analysis is performed.')
    AnalysisFigure = [];
    return
elseif ~isfield(SessionData.SettingsFile.GUIMeta, 'RiskType')
    disp('Error: The selected SessionFile may not be a TwoArmBanditVariant session. No further Matching Analysis is performed.')
    AnalysisFigure = [];
    return
elseif ~strcmpi(SessionData.SettingsFile.GUIMeta.RiskType.String{SessionData.SettingsFile.GUI.RiskType}, 'BlockFixHolding')
    disp('Error: The selected SessionData is not a Matching session. No further Matching Analysis is performed.')
    AnalysisFigure = [];
    return
end


%% Load related data to local variabels
Animal = str2double(SessionData.Info.Subject);
if isnan(Animal)
    Animal = -1;
end
Date = datestr(SessionData.Info.SessionDate, 'yyyymmdd');
Time = datestr(SessionData.Info.SessionStartTime_UTC, 'HHMMSS');

nTrials = SessionData.nTrials;
if nTrials < 50
    disp('nTrial < 50. Impossible for analysis.')
    AnalysisFigure = [];
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

BlockNumber = SessionData.Custom.TrialData.BlockNumber(:, 1:nTrials);
BlockTrialNumber = SessionData.Custom.TrialData.BlockTrialNumber(:, 1:nTrials);

% for files before April 2023, no DrinkingTime is available
try
    DrinkingTime = SessionData.Custom.TrialData.DrinkingTime(1:nTrials);
catch
    DrinkingTime = nan(1, nTrials);
end

LeftFeedbackDelayGraceTime = [];
RightFeedbackDelayGraceTime = [];
FirstDrinkingTime = [];
LatestRewardTimestamp = [];
for iTrial = 1:nTrials
    if ChoiceLeft(iTrial) == 1
        LeftFeedbackDelayGraceTime = [LeftFeedbackDelayGraceTime;...
                                      SessionData.RawEvents.Trial{iTrial}.States.LInGrace(:,2) -...
                                      SessionData.RawEvents.Trial{iTrial}.States.LInGrace(:,1)];
    elseif ChoiceLeft(iTrial) == 0
        RightFeedbackDelayGraceTime = [RightFeedbackDelayGraceTime;...
                                       SessionData.RawEvents.Trial{iTrial}.States.RInGrace(:,2) -...
                                       SessionData.RawEvents.Trial{iTrial}.States.RInGrace(:,1)];
    end
    
    FirstDrinkingTime = [FirstDrinkingTime SessionData.RawEvents.Trial{iTrial}.States.Drinking(1,1)];
    if iTrial == 1
        LatestRewardTimestamp(iTrial) = 0;
    elseif isnan(SessionData.RawEvents.Trial{iTrial-1}.States.Drinking(1,1))
        LatestRewardTimestamp(iTrial) = LatestRewardTimestamp(iTrial-1);
    else
        LatestRewardTimestamp(iTrial) = SessionData.RawEvents.Trial{iTrial-1}.States.Drinking(1,1) + SessionData.TrialStartTimestamp(iTrial-1);
    end
end
LatestRewardTime = SessionData.TrialStartTimestamp - LatestRewardTimestamp;

LeftFeedbackDelayGraceTime = LeftFeedbackDelayGraceTime(~isnan(LeftFeedbackDelayGraceTime))';
LeftFeedbackDelayGraceTime = LeftFeedbackDelayGraceTime(LeftFeedbackDelayGraceTime < SessionData.SettingsFile.GUI.FeedbackDelayGrace - 0.0001);
RightFeedbackDelayGraceTime = RightFeedbackDelayGraceTime(~isnan(RightFeedbackDelayGraceTime))';
RightFeedbackDelayGraceTime = RightFeedbackDelayGraceTime(RightFeedbackDelayGraceTime < SessionData.SettingsFile.GUI.FeedbackDelayGrace - 0.0001);

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

carrot = [230, 97, 0]/255; % explore
violet = [93, 58, 155]/255; % exploit

% colour palette for cues: (1- P(r)) * 128 + 127
% P(0) = white; P(1) = smoky gray
RewardProbCategories = unique(RewardProb);
CuedPalette = ((1 - RewardProbCategories) * [128 128 128] + 127)/255;

% create figure
AnalysisFigure = figure('Position', [   0    0 1191  842],... % DIN A3, 72 ppi (window will crop it to _ x 1024, same as disp resolution)
                   'NumberTitle', 'off',...
                   'Name', strcat(num2str(Animal), '_', Date, '_', Time, '_Matching'),...
                   'MenuBar', 'none',...
                   'Resize', 'off');

FrameAxes = axes(AnalysisFigure, 'Position', [0 0 1 1]); % spacer for correct saving dimension
set(FrameAxes,...
    'XTick', [],...
    'YTick', [],...
    'XColor', 'w',...
    'YColor', 'w')

%% Figure Info
FigureInfoAxes = axes(AnalysisFigure, 'Position', [0.01    0.96    0.48    0.01]);
set(FigureInfoAxes,...
    'XTick', [],...
    'YTick', [],...
    'XColor', 'w',...
    'YColor', 'w')

FigureTitle = strcat(num2str(Animal), '_', Date, '_', Time, '_Matching_LauGlimcherGLM');

FigureTitleText = text(FigureInfoAxes, 0, 0,...
                       FigureTitle,...
                       'FontSize', 14,...
                       'FontWeight','bold',...
                       'Interpreter', 'none');

%% Block switching behaviour across session
BlockSwitchAxes = axes(AnalysisFigure, 'Position', [0.01    0.82    0.37    0.11]);
hold(BlockSwitchAxes, 'on');
if ~isempty(ChoiceLeft) && ~all(isnan(ChoiceLeft))
    xdata = 1:nTrials;
    RewardProbLeft = RewardProb(1,:);
    RewardProbRight = RewardProb(2,:);
    RewardProbLeftPlot = plot(BlockSwitchAxes, xdata, RewardProbLeft * 100, '-', 'Color', sand, 'LineWidth', 1);
    RewardProbRightPlot = plot(BlockSwitchAxes, xdata, RewardProbRight * 100, '-', 'Color', turquoise, 'LineWidth', 1);

    BinWidth = 10;
    ChoiceLeftSmoothed = smooth(ChoiceLeft, BinWidth, 'moving','omitnan'); %current bin width: 10 trials
    BlockChoicePlot = plot(BlockSwitchAxes, xdata, ChoiceLeftSmoothed * 100, '-k', 'LineWidth', 1);
    TrialChoicePlot = plot(BlockSwitchAxes, 1:nTrials, ChoiceLeft * 110 - 5, '|', 'Color', 'k', 'MarkerSize', 1);

    set(BlockSwitchAxes,...
        'TickDir', 'out',...
        'YLim', [-20 120],...
        'YTick', [0 50 100],...
        'YAxisLocation', 'right',...
        'FontSize', 10);
    xlabel('iTrial')
    ylabel('Left Choices (%)')
    % title('Block switching behaviour')
end

%% Lau Glimcher-model & Predicted Choice
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
    
    LauGlimcherGLM = fitglm(X, ChoiceLeft', 'distribution', 'binomial');

    % predict choices
    PredictedLeftChoiceProb = LauGlimcherGLM.Fitted.Response;
    LogOdds = LauGlimcherGLM.Fitted.LinearPredictor;   %logodds for both: left and right
    
    PredictedChoice = double(PredictedLeftChoiceProb>=0.5);
    PredictedChoice(isnan(ChoiceLeft)) = nan;
    ExploringTrial = find(abs(ChoiceLeft - PredictedChoice') >= 0.5);
    ExploitingTrial = find(abs(ChoiceLeft - PredictedChoice') < 0.5);
    PredictedExplorationChoicePlot = plot(BlockSwitchAxes, ExploringTrial, PredictedChoice(ExploringTrial) * 120 - 10,...
                                          'Color', 'none',...
                                          'Marker', '|',...
                                          'MarkerEdgeColor', carrot,...
                                          'MarkerSize', 1);

    PredictedExploitationChoicePlot = plot(BlockSwitchAxes, ExploitingTrial, PredictedChoice(ExploitingTrial) * 130 - 15,...
                                           'Color', 'none',...
                                           'Marker', '|',...
                                           'MarkerEdgeColor', violet,...
                                           'MarkerSize', 1);

    SmoothedPredictedChoiceLeft = smooth(PredictedChoice, BinWidth, 'moving','omitnan');
    SmoothedPredictedChoicePlot = plot(BlockSwitchAxes, xdata, SmoothedPredictedChoiceLeft * 100, '-r', 'LineWidth', 0.2);
    
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

if model
    %% psychometric
    PsychometricAxes = axes(AnalysisFigure, 'Position', [0.23    0.62    0.15    0.11]);
    hold(PsychometricAxes, 'on')
    
    set(PsychometricAxes,...
        'FontSize', 10,...
        'XLim', [-5 5],...
        'YLim', [0, 100],...
        'YAxisLocation', 'right')
    title(PsychometricAxes, 'Psychometric')
    xlabel('log(odds)')
    ylabel('Left Choices (%)')
    
    % Choice Psychometric
    ValidTrial = ~isnan(ChoiceLeft); % and EarlyWithdrawal is always 0
    DV = LogOdds(ValidTrial);
    ChoiceL = ChoiceLeft(ValidTrial);
    dvbin = linspace(-max(abs(DV)), max(abs(DV)), 10);
    [xdata, ydata, error] = BinData(DV, ChoiceL, dvbin);
    vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);
    
    ChoicePsychometricErrorBar = errorbar(PsychometricAxes, xdata(vv), ydata(vv)*100, error(vv),...
                                          'LineStyle', 'none',...
                                          'LineWidth', 1.5,...
                                          'Color', 'k',...
                                          'Marker', 'o',...
                                          'MarkerEdgeColor', 'k');
    
    PsychometricGLM = fitglm(DV, ChoiceL(:), 'Distribution', 'binomial');
    PsychometricGLMPlot = plot(PsychometricAxes, xdata, predict(PsychometricGLM, xdata)*100, '-', 'Color', [.5,.5,.5], 'LineWidth', 0.5);
    
    %% Coefficient of Lau-Glimcher GLM
    ModelCoefficientAxes = axes(AnalysisFigure, 'Position', [0.04    0.61    0.15    0.12]);
    hold(ModelCoefficientAxes, 'on');
    
    set(ModelCoefficientAxes, 'FontSize', 10)
    xlabel(ModelCoefficientAxes, 'iTrial back');
    ylabel(ModelCoefficientAxes, 'Coeff.');
    title(ModelCoefficientAxes, 'GLM Fitted Coefficients')
    
    xdata = 1:HistoryKernelSize;
    ydataChoice = LauGlimcherGLM.Coefficients.Estimate(2:1+HistoryKernelSize);
    ydataReward = LauGlimcherGLM.Coefficients.Estimate(7:1+2*HistoryKernelSize);
    intercept = LauGlimcherGLM.Coefficients.Estimate(1);

    ChoiceHistoryCoefficientPlot = plot(ModelCoefficientAxes, xdata, ydataChoice', '-k');
    RewardHistoryCoefficientPlot = plot(ModelCoefficientAxes, xdata, ydataReward', '--k');
    InterceptPlot = plot(ModelCoefficientAxes, xdata, intercept.*ones(size(xdata)), '-.k');
    
    ModelCoefficientLegend = legend(ModelCoefficientAxes, {'Choice (L/R=±1)', 'Reward (L/R=±1)', 'Intercept'},...
                                    'Position', [0.15    0.68    0.12    0.05],...
                                    'NumColumns', 1,...
                                    'Box', 'off');
    
    %% Residual Histogram
    ResidualHistogramAxes = axes(AnalysisFigure, 'Position', [0.04    0.42    0.15    0.11]);
    ResidualHistogram = plotResiduals(LauGlimcherGLM, 'Histogram');
    
    %% Residual Histogram
    ResidualLaggedAxes = axes(AnalysisFigure, 'Position', [0.23    0.42    0.15    0.11]);
    ResidualLagged = plotResiduals(LauGlimcherGLM, 'lagged', 'Marker', '.', 'MarkerSize', 1);
    
    %% Residual Histogram
    ResidualFittedAxes = axes(AnalysisFigure, 'Position', [0.04    0.25    0.15    0.11]);
    ResidualFitted = plotResiduals(LauGlimcherGLM, 'fitted', 'Marker', '.', 'MarkerSize', 1);
    
    %% Residual Histogram
    ResidualProbabilityAxes = axes(AnalysisFigure, 'Position', [0.23    0.25    0.15    0.11]);
    ResidualProbability = plotResiduals(LauGlimcherGLM, 'Probability', 'Marker', '.', 'MarkerSize', 1);
    
    if ~all(isnan(FeedbackWaitingTime))
        %% Psychometrics of NotBaited Choice with High- and Low-time investment (TI)
        % Time investment is limited to NotBaited trials
        TISortedPsychometricAxes = axes(AnalysisFigure, 'Position', [0.45    0.62    0.15    0.11]);
        hold(TISortedPsychometricAxes, 'on')
        
        set(TISortedPsychometricAxes,...
            'FontSize', 10,...
            'XLim', [-5 5],...
            'YLim', [0, 100])
        title(TISortedPsychometricAxes, 'TI Sorted Psychometric')
        xlabel('log(odds)')
        % ylabel('Left Choices (%)')
    
        BaitedTrial = (Baited(1,:) & ChoiceLeft==1) | (Baited(2,:) & ChoiceLeft==0);
        ChoiceL = ChoiceLeft(ValidTrial & ~BaitedTrial);
        DV = LogOdds(ValidTrial & ~BaitedTrial);
    
        TI = FeedbackWaitingTime(ValidTrial & ~ BaitedTrial);
        TImed = median(TI, "omitmissing");
        HighTITrial = TI>TImed;
        LowTITrial = TI<=TImed;
        
        [xdata, ydata, error] = BinData(DV(HighTITrial), ChoiceL(HighTITrial), dvbin);
        vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);
    
        HighTIErrorBar = errorbar(TISortedPsychometricAxes, xdata(vv), ydata(vv)*100, error(vv),...
                                  'LineStyle', 'none',...
                                  'LineWidth', 1,...
                                  'Marker', 'o',...
                                  'MarkerFaceColor', 'none',...
                                  'MarkerEdgeColor', 'k',...
                                  'Color', 'k');
    
        [xdata, ydata, error] = BinData(DV(LowTITrial), ChoiceL(LowTITrial), dvbin);
        vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);
    
        LowTIErrorBar = errorbar(TISortedPsychometricAxes, xdata(vv), ydata(vv)*100, error(vv),...
                                 'LineStyle', 'none',...
                                 'LineWidth', 1,...
                                 'Marker', 'o',...
                                 'MarkerFaceColor', 'none',...
                                 'MarkerEdgeColor', [0.5 0.5 0.5],...
                                 'Color', [0.5 0.5 0.5]);
        
        HighTIGLM = fitglm(DV(HighTITrial), ChoiceL(HighTITrial), 'Distribution', 'binomial');
        HighTIGLMPlot = plot(TISortedPsychometricAxes, xdata, predict(HighTIGLM, xdata)*100,...
                             'Marker', 'none',...
                             'Color', 'k',...
                             'LineWidth', 0.5);
    
        LowTIGLM = fitglm(DV(LowTITrial), ChoiceL(LowTITrial), 'Distribution', 'binomial');
        LowTIGLMPlot = plot(TISortedPsychometricAxes, xdata, predict(LowTIGLM, xdata)*100,...
                            'Marker', 'none',...
                            'Color', [0.5, 0.5, 0.5],...
                            'LineWidth', 0.5);
        
        TIPsychometricLegend = legend(TISortedPsychometricAxes, {'High TI','Low TI'},...
                                      'Box', 'off',...
                                      'Position', [0.55    0.63    0.05    0.03]);
        
        %% plot vevaiometric      
        VevaiometricAxes = axes(AnalysisFigure, 'Position', [0.45    0.42    0.15    0.11]);
        hold(VevaiometricAxes, 'on')
        
        set(VevaiometricAxes,...
            'FontSize', 10,...
            'YAxisLocation', 'right',...
            'XLim', [-5 5],...
            'YLim', [0 SessionData.SettingsFile.GUI.FeedbackDelayMax * 1.5])
        title(VevaiometricAxes, 'Vevaiometric');
        xlabel(VevaiometricAxes, 'log(odds)');
        ylabel(VevaiometricAxes, 'Invested Time (s)');
        
        ndxExploit = ChoiceLeft == (LogOdds'>0);
        FeedbackWT = FeedbackWaitingTime(:);
    
        ExploreXData = LogOdds(ValidTrial & ~BaitedTrial & ~ndxExploit);
        ExploreYData = FeedbackWT(ValidTrial & ~BaitedTrial & ~ndxExploit);
    
        ExploitXData = LogOdds(ValidTrial & ~BaitedTrial & ndxExploit);
        ExploitYData = FeedbackWT(ValidTrial & ~BaitedTrial & ndxExploit);
        
        ExploreScatter = scatter(VevaiometricAxes, ExploreXData, ExploreYData,...
                                 'Marker', '.',...
                                 'MarkerEdgeColor', carrot,...
                                 'SizeData', 18);
        
        ExploitScatter = scatter(VevaiometricAxes, ExploitXData, ExploitYData,...
                                 'Marker', '.',...
                                 'MarkerEdgeColor', violet,...
                                 'SizeData', 18);
    
        [ExploreLineXData, ExploreLineYData] = Binvevaio(ExploreXData, ExploreYData, 10);
        [ExploitLineXData, ExploitLineYData] = Binvevaio(ExploitXData, ExploitYData, 10);
        
        ExplorePlot = plot(VevaiometricAxes, ExploreLineXData, ExploreLineYData,...
                           'Color', carrot,...
                           'LineWidth', 2);       
        
        ExploitPlot = plot(VevaiometricAxes, ExploitLineXData, ExploitLineYData,...
                           'Color', violet,...
                           'LineWidth', 2);
    
        VevaiometryLegend = legend(VevaiometricAxes, {'Explore', 'Exploit'},...
                                   'Box', 'off',...
                                   'Position', [0.43    0.50    0.05    0.03]);
        
        %% plot vevaiometric (L/R sorted residuals = abs(ChoiceLeft - P({ChoiceLeft}^))
        LRVevaiometricAxes = axes(AnalysisFigure, 'Position', [0.66    0.42    0.15    0.11]);
        hold(LRVevaiometricAxes, 'on')
        
        set(LRVevaiometricAxes,...
            'FontSize', 10,...
            'XLim', [0 1],...
            'YLim', [0 SessionData.SettingsFile.GUI.FeedbackDelayMax * 1.5])
        title(LRVevaiometricAxes, 'LRVevaiometric');
        xlabel(LRVevaiometricAxes, 'abs(Residuals)');
        
        AbsModelResiduals = abs(LauGlimcherGLM.Residuals.Raw);
        FeedbackWT = FeedbackWaitingTime(:);
    
        LeftXData = AbsModelResiduals(ValidTrial & ~BaitedTrial & ChoiceLeft==1);
        LeftYData = FeedbackWT(ValidTrial & ~BaitedTrial & ChoiceLeft==1);
    
        RightXData = AbsModelResiduals(ValidTrial & ~BaitedTrial & ChoiceLeft==0);
        RightYData = FeedbackWT(ValidTrial & ~BaitedTrial & ChoiceLeft==0);
        
        LeftScatter = scatter(LRVevaiometricAxes, LeftXData, LeftYData,...
                              'Marker', '.',...
                              'MarkerEdgeColor', sand,...
                              'SizeData', 18);
        
        RighScatter = scatter(LRVevaiometricAxes, RightXData, RightYData,...
                              'Marker', '.',...
                              'MarkerEdgeColor', turquoise,...
                              'SizeData', 18);
    
        [LefteLineXData, LeftLineYData] = Binvevaio(LeftXData, LeftYData, 10);
        [RightLineXData, RightLineYData] = Binvevaio(RightXData, RightYData, 10);
        
        LeftPlot = plot(LRVevaiometricAxes, ExploreLineXData, ExploreLineYData,...
                        'Color', sand,...
                        'LineWidth', 2);       
        
        RightPlot = plot(LRVevaiometricAxes, ExploitLineXData, ExploitLineYData,...
                         'Color', turquoise,...
                         'LineWidth', 2);
    
        LRVevaiometryLegend = legend(LRVevaiometricAxes, {'Left', 'Right'},...
                                     'Box', 'off',...
                                     'Position', [0.78    0.50    0.05    0.03]);
        
        %% callibration plot
        CalibrationAxes = axes(AnalysisFigure, 'Position', [0.45    0.25    0.15    0.11]);
        hold(CalibrationAxes, 'on')
        
        set(CalibrationAxes,...
            'FontSize', 10,...
            'XLim', [0 SessionData.SettingsFile.GUI.FeedbackDelayMax * 1.5])
        % title(CalibrationHandle, 'Calibration');
        xlabel(CalibrationAxes, 'Invested Time (s)');
        ylabel(CalibrationAxes, 'Exploit Ratio (%)');

        Correct = ndxExploit(ValidTrial & ~BaitedTrial); %'correct'
        FeedbackWT = FeedbackWaitingTime;
        ti = FeedbackWT(ValidTrial & ~BaitedTrial);
        edges = linspace(min(ti), max(ti), 8);
        [xdata, ydata, error] = BinData(ti, Correct, edges);
        vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);
        CalibrationErrorBar = errorbar(CalibrationAxes,...
                                       xdata(vv), ydata(vv)*100, error(vv),...
                                       'LineWidth', 2, ...
                                       'Color', 'k');
    end
end

end % function