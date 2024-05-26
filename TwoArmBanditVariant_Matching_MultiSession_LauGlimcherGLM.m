function TwoArmBanditVariant_Matching_MultiSession_LauGlimcherGLM(DataFolderPath)
%{
First create on 20240519 by Antonio Lee for AG Ott @HU Berlin

V1.0 20240519 dedicated script for analyzing multiple sessions with similar
settings (no checking is done). A folder is selected instead of a .mat file
(so that a bit of back and forth looking at the concatenated data and
individual session data is allowed)

The analysis is positioned to look at the data using Lau-Glimcher models of
individual sessions, i.e. sessions are considered differently. Additional
plots of how the coefficients evolve during the sessions are made.
%}

if nargin < 1
    DataFolderPath = uigetdir('\\ottlabfs.bccn-berlin.pri\ottlab\data\');
elseif ~ischar(DataFolderPath) && ~isstring(DataFolderPath)
    disp('Error: Unknown input format. No further analysis can be performed.')
    return
end

try
    load(fullfile(DataFolderPath, '\Selected_Data.mat'));
    load(fullfile(DataFolderPath, '\Concatenated_Data.mat'));
catch
    disp('Error: Selected DataFolderPath does not contain the required .mat for further steps.')
    return
end

SessionDateRange = DataFolderPath(end-16:end);
[~, RatName] = fileparts(fileparts(fileparts(DataFolderPath)));

RatID = str2double(RatName);
if isnan(RatID)
    RatID = -1;
end
RatName = num2str(RatID);

AnalysisName = 'Matching_MultiSession_LauGlimcherGLM';

%% Check if all sessions are of the same SettingsFile
%{
% not sure how to best do it yet, as some settings are drawn in each trial
and displayed
for iSession = 1:length(DataHolder)
    SessionData = DataHolder{iSession};

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
end
%}
    
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
% RewardProbCategories = unique(RewardProb);
% CuedPalette = ((1 - RewardProbCategories) * [128 128 128] + 127)/255;

%{
if p.TimelineView
    EarliestSessionDate = datetime(DataHolder{1}.Info.SessionDate);
    LatestSessionDate = datetime(DataHolder{end}.Info.SessionDate);
    FullDateRange = between(EarliestSessionDate, LatestSessionDate, 'Days');
    FullDateRangeChar = char(FullDateRange);
    ColourAdjustmentDenominator = str2double(FullDateRangeChar(1:end-1));
else
    ColourAdjustmentDenominator = size(DataHolder);
end
%}

%% Initiatize figure
% create figure
AnalysisFigure = figure('Position', [   0       0    1191     842],... % DIN A3, 72 ppi
                        'NumberTitle', 'off',...
                        'Name', strcat(RatName, '_', SessionDateRange, '_', AnalysisName),...
                        'MenuBar', 'none',...
                        'Resize', 'off');

% spacer for correct saving dimension
FrameAxes = axes(AnalysisFigure, 'Position', [0 0 1 1]);
set(FrameAxes,...
    'XTick', [],...
    'YTick', [],...
    'XColor', 'w',...
    'YColor', 'w')

% Figure Info
FigureInfoAxes = axes(AnalysisFigure, 'Position', [0.01    0.98    0.48    0.01]);
set(FigureInfoAxes,...
    'XTick', [],...
    'YTick', [],...
    'XColor', 'w',...
    'YColor', 'w')

FigureTitle = strcat(RatName, '_', SessionDateRange, '_', AnalysisName);

FigureTitleText = text(FigureInfoAxes, 0, 0,...
                       FigureTitle,...
                       'FontSize', 14,...
                       'FontWeight','bold',...
                       'Interpreter', 'none');AnalysisFigure = figure('Position', [   0       0    1191     842],... % DIN A3, 72 ppi
                        'NumberTitle', 'off',...
                        'Name', strcat(RatName, '_', SessionDateRange, '_', AnalysisName),...
                        'MenuBar', 'none',...
                        'Resize', 'off');

% spacer for correct saving dimension
FrameAxes = axes(AnalysisFigure, 'Position', [0 0 1 1]);
set(FrameAxes,...
    'XTick', [],...
    'YTick', [],...
    'XColor', 'w',...
    'YColor', 'w')

% Figure Info
FigureInfoAxes = axes(AnalysisFigure, 'Position', [0.01    0.98    0.48    0.01]);
set(FigureInfoAxes,...
    'XTick', [],...
    'YTick', [],...
    'XColor', 'w',...
    'YColor', 'w')

FigureTitle = strcat(RatName, '_', SessionDateRange, '_', AnalysisName);

FigureTitleText = text(FigureInfoAxes, 0, 0,...
                       FigureTitle,...
                       'FontSize', 14,...
                       'FontWeight','bold',...
                       'Interpreter', 'none');

%% Analysis across sessions
SessionDateLabel = [];

% Psychometric
PsychometricAxes = axes(AnalysisFigure, 'Position', [0.01    0.74    0.17    0.19]);
hold(PsychometricAxes, 'on')

AllPredictedProb = [];
AllLogOdds = [];
AllChoiceLeft = [];

set(PsychometricAxes,...
    'FontSize', 10,...
    'XLim', [-5 5],...
    'XTickLabel', [],...
    'YLim', [0, 100],...
    'YAxisLocation', 'right')
title(PsychometricAxes, 'Psychometric')
% xlabel('log(odds)')
ylabel('Left Choices (%)')

% Coefficient of Lau-Glimcher GLM
ModelCoefficientAxes = axes(AnalysisFigure, 'Position', [0.24    0.74    0.17    0.19]);
hold(ModelCoefficientAxes, 'on');

ChoiceCoefficients = [];
RewardCoefficients = [];
Intercept = [];

set(ModelCoefficientAxes,...
    'FontSize', 10,...
    'XLim', [-5 -1],...
    'YLim', [-1, 3],...
    'YAxisLocation', 'right')
xlabel(ModelCoefficientAxes, 'iTrial back');
ylabel(ModelCoefficientAxes, 'Coeff.');
title(ModelCoefficientAxes, 'GLM Fitted Coefficients')

% Vevaiometric      
VevaiometricAxes = axes(AnalysisFigure, 'Position', [0.01    0.52    0.17    0.19]);
hold(VevaiometricAxes, 'on')

set(VevaiometricAxes,...
    'FontSize', 10,...
    'XLim', [-5 5],...
    'YLim', [0 12],...
    'YAxisLocation', 'right')
title(VevaiometricAxes, 'Vevaiometric');
xlabel(VevaiometricAxes, 'log(odds)');
ylabel(VevaiometricAxes, 'Invested Time (s)');

% Vevaiometric z-score
VevaiometricZScoreAxes = axes(AnalysisFigure, 'Position', [0.01    0.30    0.17    0.19]);
hold(VevaiometricZScoreAxes, 'on')

set(VevaiometricZScoreAxes,...
    'FontSize', 10,...
    'XLim', [-5 5],...
    'YLim', [-5 5],...
    'YAxisLocation', 'right')
xlabel(VevaiometricZScoreAxes, 'log(odds)');
ylabel(VevaiometricZScoreAxes, 'Invested Time (z-score)');

%{
% TI    
VevaiometricAxes = axes(AnalysisFigure, 'Position', [0.01    0.52    0.17    0.19]);
hold(VevaiometricAxes, 'on')

set(VevaiometricAxes,...
    'FontSize', 10,...
    'XLim', [-5 5],...
    'YLim', [0 SessionData.SettingsFile.GUI.FeedbackDelayMax * 1.5],...
    'YAxisLocation', 'right')
title(VevaiometricAxes, 'Vevaiometric');
xlabel(VevaiometricAxes, 'log(odds)');
ylabel(VevaiometricAxes, 'Invested Time (s)');

% Choice Psychometric
ValidTrial = ~isnan(ChoiceLeft); % and EarlyWithdrawal is always 0
NotBaitedLogOdds = LogOdds(ValidTrial);
NotBaitedChoice = ChoiceLeft(ValidTrial);
dvbin = linspace(-max(abs(NotBaitedLogOdds)), max(abs(NotBaitedLogOdds)), 10);
[xdata, ydata, error] = BinData(NotBaitedLogOdds, NotBaitedChoice, dvbin);
vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);

ChoicePsychometricErrorBar = errorbar(PsychometricAxes, xdata(vv), ydata(vv)*100, error(vv)*100,...
                                      'LineStyle', 'none',...
                                      'LineWidth', 1.5,...
                                      'Color', 'k',...
                                      'Marker', 'o',...
                                      'MarkerEdgeColor', 'k');

PsychometricGLM = fitglm(NotBaitedLogOdds, NotBaitedChoice(:), 'Distribution', 'binomial');
PsychometricGLMPlot = plot(PsychometricAxes, xdata, predict(PsychometricGLM, xdata)*100, '-', 'Color', [.5,.5,.5], 'LineWidth', 0.5);


xdata = 1:HistoryKernelSize;
ydataChoice = LauGlimcherGLM.Coefficients.Estimate(2:1+HistoryKernelSize);
ydataReward = LauGlimcherGLM.Coefficients.Estimate(7:1+2*HistoryKernelSize);
intercept = LauGlimcherGLM.Coefficients.Estimate(1);

ChoiceHistoryCoefficientPlot = plot(ModelCoefficientAxes, xdata, ydataChoice', '-k');
RewardHistoryCoefficientPlot = plot(ModelCoefficientAxes, xdata, ydataReward', '--k');
InterceptPlot = plot(ModelCoefficientAxes, xdata, intercept.*ones(size(xdata)), '-.k');

ModelCoefficientLegend = legend(ModelCoefficientAxes, {'Choice (L/R=±1)', 'Reward (L/R=±1)', 'Intercept'},...
                                'Position', [0.15    0.62    0.12    0.05],...
                                'NumColumns', 1,...
                                'Box', 'off');



ExploringLogOdds = LogOdds(ExploringTITrial);
ExploitingLogOdds = LogOdds(ExploitingTITrial);

ExploringTrialTIScatter = scatter(VevaiometricAxes, ExploringLogOdds, ExploringTI,...
                                  'Marker', '.',...
                                  'MarkerEdgeColor', carrot,...
                                  'SizeData', 18);

ExploitingTrialTIScatter = scatter(VevaiometricAxes, ExploitingLogOdds, ExploitingTI,...
                                   'Marker', '.',...
                                   'MarkerEdgeColor', violet,...
                                   'SizeData', 18);

[ExploreLineXData, ExploreLineYData] = Binvevaio(ExploringLogOdds, ExploringTI, 10);
[ExploitLineXData, ExploitLineYData] = Binvevaio(ExploitingLogOdds, ExploitingTI, 10);

ExplorePlot = plot(VevaiometricAxes, ExploreLineXData, ExploreLineYData,...
                   'Color', carrot,...
                   'LineWidth', 1);       

ExploitPlot = plot(VevaiometricAxes, ExploitLineXData, ExploitLineYData,...
                   'Color', violet,...
                   'LineWidth', 1);

%% Psychometrics of NotBaited Choice with High- and Low-time investment (TI)
% Time investment is limited to NotBaited trials
TISortedPsychometricAxes = axes(AnalysisFigure, 'Position', [0.45    0.56    0.15    0.11]);
hold(TISortedPsychometricAxes, 'on')

TI = FeedbackWaitingTime(NotBaited);
TImed = median(TI, "omitnan");
HighTITrial = FeedbackWaitingTime>TImed & NotBaited;
LowTITrial = FeedbackWaitingTime<=TImed & NotBaited;

[xdata, ydata, error] = BinData(LogOdds(HighTITrial), ChoiceLeft(HighTITrial), dvbin);
vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);

HighTIErrorBar = errorbar(TISortedPsychometricAxes, xdata(vv), ydata(vv)*100, error(vv)*100,...
                          'LineStyle', 'none',...
                          'LineWidth', 1,...
                          'Marker', 'o',...
                          'MarkerFaceColor', 'none',...
                          'MarkerEdgeColor', 'k',...
                          'Color', 'k');

[xdata, ydata, error] = BinData(LogOdds(LowTITrial), ChoiceLeft(LowTITrial), dvbin);
vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);

LowTIErrorBar = errorbar(TISortedPsychometricAxes, xdata(vv), ydata(vv)*100, error(vv)*100,...
                         'LineStyle', 'none',...
                         'LineWidth', 1,...
                         'Marker', 'o',...
                         'MarkerFaceColor', 'none',...
                         'MarkerEdgeColor', [0.5 0.5 0.5],...
                         'Color', [0.5 0.5 0.5]);

HighTIGLM = fitglm(LogOdds(HighTITrial), ChoiceLeft(HighTITrial), 'Distribution', 'binomial');
HighTIGLMPlot = plot(TISortedPsychometricAxes, xdata, predict(HighTIGLM, xdata)*100,...
                     'Marker', 'none',...
                     'Color', 'k',...
                     'LineWidth', 0.5);

LowTIGLM = fitglm(LogOdds(LowTITrial), ChoiceLeft(LowTITrial), 'Distribution', 'binomial');
LowTIGLMPlot = plot(TISortedPsychometricAxes, xdata, predict(LowTIGLM, xdata)*100,...
                    'Marker', 'none',...
                    'Color', [0.5, 0.5, 0.5],...
                    'LineWidth', 0.5);

TIPsychometricLegend = legend(TISortedPsychometricAxes, {'High TI','Low TI'},...
                              'Box', 'off',...
                              'Position', [0.55    0.57    0.05    0.03]);

set(TISortedPsychometricAxes,...
    'FontSize', 10,...
    'XLim', [-5 5],...
    'YLim', [0, 100])
title(TISortedPsychometricAxes, 'TI Sorted Psychometric')
xlabel('log(odds)')
% ylabel('Left Choices (%)')

%% callibration plot
CalibrationAxes = axes(AnalysisFigure, 'Position', [0.66    0.56    0.15    0.11]);
hold(CalibrationAxes, 'on')

Correct = Exploit(NotBaited); %'correct'
edges = linspace(min(TI), max(TI), 8);

[xdata, ydata, error] = BinData(TI, Correct, edges);
vv = ~isnan(xdata) & ~isnan(ydata) & ~isnan(error);
CalibrationErrorBar = errorbar(CalibrationAxes,...
                               xdata(vv), ydata(vv)*100, error(vv),...
                               'LineWidth', 2, ...
                               'Color', 'k');

set(CalibrationAxes,...
    'FontSize', 10,...
    'XLim', [0 SessionData.SettingsFile.GUI.FeedbackDelayMax * 1.5])
% title(CalibrationHandle, 'Calibration');
xlabel(CalibrationAxes, 'Invested Time (s)');
ylabel(CalibrationAxes, 'Exploit Ratio (%)');
%}

disp('YOu aRE a bEAutIFul HUmaN BeiNG, saID anTOniO.')

%% Plotting
for iSession = 1:length(DataHolder)
    % Import SessionData
    SessionData = DataHolder{iSession};
    
    nTrials = SessionData.nTrials;
    if nTrials < 50
        disp(['Session ', num2char(iSession), ' has nTrial < 50. Impossible for analysis.'])
        continue
    end
    
    SessionDateLabel = [SessionDateLabel string(datestr(datetime(SessionData.Info.SessionDate), 'YYYYmmDD(ddd)'))];

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
    
    RewardMagnitude = SessionData.Custom.TrialData.RewardMagnitude(:, 1:nTrials);
    TrialStartTimeStamp = SessionData.TrialStartTimestamp;
    TrialEndTimeStamp = SessionData.TrialEndTimestamp;

    idxTrial = 1:nTrials;
    SessionColor = [1, 1, 1] * 0.85; % ([1, 1, 1] - iSession / length(DataHolder)) * 0.9;
    
    %% Analysis across sessions
    % Lau-Glimcher Model
    try
        HistoryKernelSize = 5;

        Choices = [];
        Rewards = [];
        
        ChoiceLeftCoding = ChoiceLeft * 2 - 1;
        RewardedLeftCoding = Rewarded .* ChoiceLeftCoding;
        
        for i = 1:HistoryKernelSize
            Choices(:, i) = [zeros(i, 1); ChoiceLeftCoding(1:end-i)'];
            Rewards(:, i) = [zeros(i, 1); RewardedLeftCoding(1:end-i)'];
        end
        
        X = [Choices, Rewards];
        X(isnan(X)) = 0;

        LauGlimcherGLM = fitglm(X, ChoiceLeft', 'distribution', 'binomial');

        % predict choices
        PredictedLeftChoiceProb = LauGlimcherGLM.Fitted.Response;
        LogOdds = LauGlimcherGLM.Fitted.LinearPredictor;   %logodds for both: left and right

        PredictedChoice = double(PredictedLeftChoiceProb>=0.5);
        PredictedChoice(isnan(ChoiceLeft)) = nan;
        
        ExploringTrial = find(abs(ChoiceLeft - PredictedLeftChoiceProb') >= 0.5);
        ExploitingTrial = find(abs(ChoiceLeft - PredictedLeftChoiceProb') < 0.5);
            
    catch
        disp(strcat('Error: running model in iSession ', num2str(iSession)));
        continue
        
    end
    
    AllPredictedProb = [AllPredictedProb, PredictedLeftChoiceProb'];
    AllLogOdds = [AllLogOdds, LogOdds'];
    AllChoiceLeft = [AllChoiceLeft, ChoiceLeft];

    % Psychometric
    ValidTrial = ~isnan(ChoiceLeft); % and EarlyWithdrawal is always 0
    ValidLogOdds = LogOdds(ValidTrial);
    ValidChoice = ChoiceLeft(ValidTrial)';
    
    Bin = linspace(-5, 5, 11);
    [XData, YData, Error] = BinData(ValidLogOdds, ValidChoice, Bin);
    ValidData = ~isnan(XData) & ~isnan(YData) & ~isnan(Error);
    
    ChoicePsychometricLine{iSession} = line(PsychometricAxes,...
                                            'xdata', XData(ValidData),...
                                            'ydata', YData(ValidData) * 100,...
                                            'LineStyle', '-',...
                                            'LineWidth', 0.5,...
                                            'Color', SessionColor);
    
    % Coefficient of Lau-Glimcher GLM
    XData = 1:HistoryKernelSize;
    ChoiceCoefficients(iSession, :) = LauGlimcherGLM.Coefficients.Estimate(2:1+HistoryKernelSize);
    RewardCoefficients(iSession, :) = LauGlimcherGLM.Coefficients.Estimate(7:1+2*HistoryKernelSize);
    Intercept(iSession, :) = LauGlimcherGLM.Coefficients.Estimate(1) .* ones(flip(size(XData)));

    ChoiceCoefficientLine{iSession} = line(ModelCoefficientAxes,...
                                           'xdata', -XData,...
                                           'ydata', ChoiceCoefficients(iSession,:)',...
                                           'LineStyle', ':',...
                                           'Color', SessionColor);

    RewardCoefficientLine{iSession} = line(ModelCoefficientAxes,...
                                           'xdata', -XData,...
                                           'ydata', RewardCoefficients(iSession,:)',...
                                           'LineStyle', '-',...
                                           'Color', SessionColor);

    InterceptLine{iSession} = line(ModelCoefficientAxes,...
                                   'xdata', -XData,...
                                   'ydata', Intercept(iSession, :),...
                                   'LineStyle', '--',...
                                   'Color', SessionColor);
    
    % Vevaiometric
    NotBaited = any(~Baited .* ChoiceLeftRight, 1) & (IncorrectChoice ~= 1);
    Exploit = ChoiceLeft == (LogOdds'>0);
    
    ExploringTITrial = NotBaited & ~Exploit;
    ExploitingTITrial = NotBaited & Exploit;
    ExploringTI = FeedbackWaitingTime(ExploringTITrial);
    ExploitingTI = FeedbackWaitingTime(ExploitingTITrial);
    
    ExploringLogOdds = LogOdds(ExploringTITrial);
    ExploitingLogOdds = LogOdds(ExploitingTITrial);
    
    ExploringTrialTIScatter{iSession} = scatter(VevaiometricAxes, ExploringLogOdds, ExploringTI,...
                                                'Marker', '.',...
                                                'MarkerEdgeColor', carrot,...
                                                'SizeData', 1);
    
    ExploitingTrialTIScatter{iSession} = scatter(VevaiometricAxes, ExploitingLogOdds, ExploitingTI,...
                                                 'Marker', '.',...
                                                 'MarkerEdgeColor', violet,...
                                                 'SizeData', 1);

    % Vevaiometric z-score
    ExploringTIZScore = zscore(ExploringTI);
    ExploitingTIZScore = zscore(ExploitingTI);
    
    ExploringLogOddsZScore = zscore(ExploringLogOdds);
    ExploitingLogOddsZScore = zscore(ExploitingLogOdds);
    
    ExploringTrialTIZScoreScatter{iSession} = scatter(VevaiometricZScoreAxes, ExploringLogOdds, ExploringTIZScore,...
                                                      'Marker', '.',...
                                                      'MarkerEdgeColor', carrot,...
                                                      'SizeData', 1);
    
    ExploitingTrialTIZScoreScatter{iSession} = scatter(VevaiometricZScoreAxes, ExploitingLogOdds, ExploitingTIZScore,...
                                                       'Marker', '.',...
                                                       'MarkerEdgeColor', violet,...
                                                       'SizeData', 1);

end

%% Average across sessions
% Psychometric
ValidTrial = ~isnan(AllChoiceLeft); % and EarlyWithdrawal is always 0
ValidLogOdds = AllLogOdds(ValidTrial);
ValidChoice = AllChoiceLeft(ValidTrial)';

Bin = linspace(-5, 5, 11);
[XData, YData, Error] = BinData(ValidLogOdds, ValidChoice, Bin);
ValidData = ~isnan(XData) & ~isnan(YData) & ~isnan(Error);

ChoicePsychometricLine{iSession} = line(PsychometricAxes,...
                                        'xdata', XData(ValidData),...
                                        'ydata', YData(ValidData) * 100,...
                                        'LineStyle', '-',...
                                        'LineWidth', 0.5,...
                                        'Color', 'k');

% Coefficient of Lau-Glimcher GLM
XData = 1:HistoryKernelSize;
AverageChoiceCoefficients = mean(ChoiceCoefficients);
AverageRewardCoefficients = mean(RewardCoefficients);
AverageIntercept = mean(Intercept);

ChoiceCoefficientLine{iSession + 1} = line(ModelCoefficientAxes,...
                                           'xdata', -XData,...
                                           'ydata', AverageChoiceCoefficients',...
                                           'LineStyle', ':',...
                                           'Color', 'k');

RewardCoefficientLine{iSession + 1} = line(ModelCoefficientAxes,...
                                           'xdata', -XData,...
                                           'ydata', AverageRewardCoefficients',...
                                           'LineStyle', '-',...
                                           'Color', 'k');

InterceptLine{iSession + 1} = line(ModelCoefficientAxes,...
                                   'xdata', -XData,...
                                   'ydata', AverageIntercept,...
                                   'LineStyle', '--',...
                                   'Color', 'k');

% SkippedBaited Rate across session
set(SkippedBaitedAxes,...
    'XTickLabel', SessionDateLabel(SkippedBaitedAxes.XTick),...
    'XTickLabelRotation', 90);

disp('YOu aRE a bEAutIFul HUmaN BeiNG, saID anTOniO.')

DataPath = strcat(DataFolderPath, '\', FigureTitle, '.png');
exportgraphics(AnalysisFigure, DataPath);

end % function