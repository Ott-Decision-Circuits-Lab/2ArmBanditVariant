function TwoArmBanditVariant_Matching_MultiSession_Analysis(DataFolderPath)
%{
First create on 20230622 by Antonio Lee for AG Ott @HU Berlin
With the file server architecture, this functions runs through the
session folders of the designated Animals after a PeriodStartDate and before a
PeriodEndDate to parse out the TrialData necessary for Analysis.m

V2.0 20240515 dedicated script for analyzing multiple sessions with similar
settings (no checking is done). A folder is selected instead of a .mat file
(so that a bit of back and forth looking at the concatenated data and
individual session data is allowed)

The analysis is positioned to only look at the data descriptively,
particularly identifying any indication of which some sessions are not, or
some trials are not comparable with the others (head and tail)
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

AnalysisName = 'Matching_MultiSession_Analysis';

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
                       'Interpreter', 'none');

%% Analysis across trials
% NoTrialStart Rate across session
NoTrialStartAxes = axes(AnalysisFigure, 'Position', [0.01    0.84    0.37    0.11]);
hold(NoTrialStartAxes, 'on');

NoTrialStartYData = ones(100, 2000) * 100;

set(NoTrialStartAxes,...
    'TickDir', 'out',...
    'YLim', [0 100],...
    'YTick', [0 50 100],...
    'YAxisLocation', 'right',...
    'FontSize', 10);
xlabel(NoTrialStartAxes, 'iTrial')
ylabel(NoTrialStartAxes, 'NoTrialStart (%)')

% Block 1 transition (1st -> 2nd)
Block1TransitionAxes = axes(AnalysisFigure, 'Position', [0.01    0.64    0.15    0.12]);
hold(Block1TransitionAxes, 'on');

PHighChoice = [];
Block1TransitionYData = nan(100, 61);

set(Block1TransitionAxes,...
    'TickDir', 'out',...
    'XLim', [-10 50],...
    'XTick', [0 20 40],...
    'XTickLabel', [],...
    'YLim', [0 100],...
    'YTick', [0 50 100],...
    'YAxisLocation', 'right',...
    'FontSize', 10);
ylabel(Block1TransitionAxes, 'Choice P_{high} (%)')
title(Block1TransitionAxes, 'Block 1 -> 2')

% Block 2 transition (2nd -> 3rd)
Block2TransitionAxes = axes(AnalysisFigure, 'Position', [0.01    0.49    0.15    0.12]);
hold(Block2TransitionAxes, 'on');

Block2TransitionYData = nan(100, 61);

set(Block2TransitionAxes,...
    'TickDir', 'out',...
    'XLim', [-10 50],...
    'XTick', [0 20 40],...
    'XTickLabel', [],...
    'YLim', [0 100],...
    'YTick', [0 50 100],...
    'YAxisLocation', 'right',...
    'FontSize', 10);
ylabel(Block2TransitionAxes, 'Choice P_{high} (%)')
title(Block2TransitionAxes, 'Block 2 -> 3')

% Block 3 transition (3rd -> 4th)
Block3TransitionAxes = axes(AnalysisFigure, 'Position', [0.01    0.34    0.15    0.12]);
hold(Block3TransitionAxes, 'on');

Block3TransitionYData = nan(100, 61);

set(Block3TransitionAxes,...
    'TickDir', 'out',...
    'XLim', [-10 50],...
    'XTick', [0 20 40],...
    'XTickLabel', [],...
    'YLim', [0 100],...
    'YTick', [0 50 100],...
    'YAxisLocation', 'right',...
    'FontSize', 10);
ylabel(Block3TransitionAxes, 'Choice P_{high} (%)')
title(Block3TransitionAxes, 'Block 3 -> 4')

% Block 4 transition (4rd -> 5th)
Block4TransitionAxes = axes(AnalysisFigure, 'Position', [0.01    0.19    0.15    0.12]);
hold(Block4TransitionAxes, 'on');

Block4TransitionYData = nan(100, 61);

set(Block4TransitionAxes,...
    'TickDir', 'out',...
    'XLim', [-10 50],...
    'XTick', [0 20 40],...
    'XTickLabel', [1 21 41],...
    'YLim', [0 100],...
    'YTick', [0 50 100],...
    'YAxisLocation', 'right',...
    'FontSize', 10);
ylabel(Block4TransitionAxes, 'Choice P_{high} (%)')
title(Block4TransitionAxes, 'Block 4 -> 5')


%% Analysis across sessions
SessionDateLabel = [];

% Active Time (SessionDuration - any break > 5 minutes)
ActiveTimeAxes = axes(AnalysisFigure, 'Position', [0.53    0.84    0.42    0.11]);
hold(ActiveTimeAxes, 'on');

set(ActiveTimeAxes,...
    'TickDir', 'in',...
    'XLim', [0 length(DataHolder)+1],...
    'XTickLabel', [],...
    'YLim', [0 4],...
    'YAxisLocation', 'right',...
    'FontSize', 10);
ylabel(ActiveTimeAxes, 'Active Time (h)')

% Total Water Consumption and Rate
WaterConsumptionAxes = axes(AnalysisFigure, 'Position', [0.53    0.71    0.42    0.11]);
hold(WaterConsumptionAxes, 'on');

set(WaterConsumptionAxes,...
    'TickDir', 'in',...
    'XLim', [0 length(DataHolder)+1],...
    'XTickLabel', [],...
    'YLim', [0 15],...
    'FontSize', 10);
ylabel(WaterConsumptionAxes, 'Consumed Water (mL)')

yyaxis(WaterConsumptionAxes, 'right')
set(WaterConsumptionAxes,...
    'YLim', [0 4],...
    'FontSize', 10);
ylabel(WaterConsumptionAxes, 'Rate (mL h^{-1})')

% Left-Right Move Time
LRMoveTimeAxes = axes(AnalysisFigure, 'Position', [0.53    0.58    0.42    0.11]);
hold(LRMoveTimeAxes, 'on');

set(LRMoveTimeAxes,...
    'TickDir', 'in',...
    'XLim', [0 length(DataHolder)+1],...
    'XTickLabel', [],...
    'YLim', [0 1],...
    'YAxisLocation', ' right',...
    'FontSize', 10);
ylabel(LRMoveTimeAxes, 'MoveTime (s)')

% Left-Right Time Investment (NotBaited Waiting Time)
LRTIAxes = axes(AnalysisFigure, 'Position', [0.53    0.45    0.42    0.11]);
hold(LRTIAxes, 'on');

set(LRTIAxes,...
    'TickDir', 'in',...
    'XLim', [0 length(DataHolder)+1],...
    'XTick', [],...
    'YLim', [0 12],...
    'YAxisLocation', ' right',...
    'FontSize', 10);
ylabel(LRTIAxes, 'Time Investment (s)')

% Trial Length
TrialLengthAxes = axes(AnalysisFigure, 'Position', [0.53    0.32    0.42    0.11]);
hold(TrialLengthAxes, 'on');

set(TrialLengthAxes,...
    'TickDir', 'in',...
    'XLim', [0 length(DataHolder)+1],...
    'XTickLabel', [],...
    'YLim', [0 30],...
    'YAxisLocation', ' right',...
    'FontSize', 10);
ylabel(TrialLengthAxes, 'Trial Length (s)')

% SkippedBaited Rate across session
SkippedBaitedAxes = axes(AnalysisFigure, 'Position', [0.53    0.19    0.42    0.11]);
hold(SkippedBaitedAxes, 'on');

set(SkippedBaitedAxes,...
    'TickDir', 'in',...
    'XLim', [1 length(DataHolder)+1],...
    'XTickLabel', [],...
    'YLim', [0 10],...
    'YTick', [0 5 10],...
    'YAxisLocation', 'right',...
    'FontSize', 10);
ylabel(SkippedBaitedAxes, 'SkippedBaited (%)')

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
    
    %% Analysis across trials
    % NoTrialStart Rate across session
    NoTrialStartLine{iSession} = line(NoTrialStartAxes,...
                                      'xdata', idxTrial,...
                                      'ydata', smooth(movmean(NoTrialStart, [10 9])) * 100,...
                                      'LineStyle', '-',...
                                      'Marker', 'none',...
                                      'Color', SessionColor);
    
    NoTrialStartYData(iSession, 1:length(NoTrialStart)) = NoTrialStart * 100;

    % Block 1 Transition (1st -> 2nd)
    BlockTransitionIdx = find(BlockTrialNumber == 1 & BlockNumber == 2);
    PHighChoice(iSession, 1) = RewardProb(1, BlockTransitionIdx) > RewardProb(2, BlockTransitionIdx);
    ChosenPHigh = ChoiceLeft(BlockTransitionIdx - 10:BlockTransitionIdx + 50) == PHighChoice(iSession, 1);
    Block1TransitionLine{iSession} = line(Block1TransitionAxes,...
                                          'xdata', -10:50,...
                                          'ydata', smooth(movmean(ChosenPHigh, [9 0])) * 100,...
                                          'LineStyle', '-',...
                                          'Marker', 'none',...
                                          'Color', SessionColor);
    
    Block1TransitionYData(iSession, :) = ChosenPHigh * 100;
    
    % Block 2 Transition (2nd -> 3rd)
    BlockTransitionIdx = find(BlockTrialNumber == 1 & BlockNumber == 3);
    PHighChoice(iSession, 2)  = RewardProb(1, BlockTransitionIdx) > RewardProb(2, BlockTransitionIdx);
    ChosenPHigh = ChoiceLeft(BlockTransitionIdx - 10:BlockTransitionIdx + 50) == PHighChoice(iSession, 2);
    Block2TransitionLine{iSession} = line(Block2TransitionAxes,...
                                          'xdata', -10:50,...
                                          'ydata', smooth(movmean(ChosenPHigh, [9 0])) * 100,...
                                          'LineStyle', '-',...
                                          'Marker', 'none',...
                                          'Color', SessionColor);
    
    Block2TransitionYData(iSession, :) = ChosenPHigh * 100;
    
    % Block 3 Transition (3rd -> 4th)
    BlockTransitionIdx = find(BlockTrialNumber == 1 & BlockNumber == 4);
    if ~isempty(BlockTransitionIdx)
        PHighChoice(iSession, 3) = RewardProb(1, BlockTransitionIdx) > RewardProb(2, BlockTransitionIdx);
        ChosenPHigh = ChoiceLeft(BlockTransitionIdx - 10:BlockTransitionIdx + 50) == PHighChoice(iSession, 3);
        Block3TransitionLine{iSession} = line(Block3TransitionAxes,...
                                              'xdata', -10:50,...
                                              'ydata', smooth(movmean(ChosenPHigh, [9 0])) * 100,...
                                              'LineStyle', '-',...
                                              'Marker', 'none',...
                                              'Color', SessionColor);

        Block3TransitionYData(iSession, :) = ChosenPHigh * 100;
        
    else
        Block3TransitionYData(iSession, :) = nan(1, 61);
    end

    % Block 4 Transition (4th -> 5th)
    BlockTransitionIdx = find(BlockTrialNumber == 1 & BlockNumber == 5);
    if ~isempty(BlockTransitionIdx)
        PHighChoice(iSession, 4) = RewardProb(1, BlockTransitionIdx) > RewardProb(2, BlockTransitionIdx);
        ChosenPHigh = ChoiceLeft(BlockTransitionIdx - 10:BlockTransitionIdx + 50) == PHighChoice(iSession, 4);
        Block4TransitionLine{iSession} = line(Block4TransitionAxes,...
                                              'xdata', -10:50,...
                                              'ydata', smooth(movmean(ChosenPHigh, [9 0])) * 100,...
                                              'LineStyle', '-',...
                                              'Marker', 'none',...
                                              'Color', SessionColor);

        Block4TransitionYData(iSession, :) = ChosenPHigh * 100;
        
    else
        Block4TransitionYData(iSession, :) = nan(1, 61);
    end

    %% Analysis across sessions
    % Active Time (Total SessionDuration - any break > 5 minutes)
    NonActiveNess = movmean(NoTrialStart, [0 19]); % should correspond to 5 minutes
    NonActiveIdx = find(NonActiveNess == 1);

    ActiveTrial = ones(size(NoTrialStart));
    if ~isempty(NonActiveIdx)
        for iNonActiveIdx = 1:length(NonActiveIdx)
            ActiveTrial(iNonActiveIdx:iNonActiveIdx+19) = 0;
        end
    end

    TrialLength = TrialEndTimeStamp - TrialStartTimeStamp;
    SessionDuration = sum(TrialLength(ActiveTrial == 1)) / 3600;

    ActiveTimeLine{iSession} = line(ActiveTimeAxes,...
                                    'xdata', iSession,...
                                    'ydata', SessionDuration,...
                                    'Marker', 'x',...
                                    'Color', 'k');
    
    % Total Water Consumption
    WaterConsumption = sum(ChoiceLeftRight .* [Rewarded; Rewarded] .* RewardMagnitude, 'all', "omitnan") / 1000;
    
    yyaxis(WaterConsumptionAxes, 'left')
    WaterConsumptionLine{iSession} = line(WaterConsumptionAxes,...
                                          'xdata', iSession,...
                                          'ydata', WaterConsumption,...
                                          'Marker', 'x',...
                                          'Color', 'k');
    
    % Water Consumption Rate
    WaterConsumptionRate = WaterConsumption ./ SessionDuration;
    
    yyaxis(WaterConsumptionAxes, 'right')
    WaterConsumptionRateLine{iSession} = line(WaterConsumptionAxes,...
                                              'xdata', iSession,...
                                              'ydata', WaterConsumptionRate,...
                                              'Marker', '+',...
                                              'Color', 'r');
    
    % Left-Right Move Time
    LeftMoveTime = MoveTime(ChoiceLeft == 1);
    LeftMoveTimeSwarmchart{iSession} = swarmchart(LRMoveTimeAxes,...
                                                  ones(size(LeftMoveTime)) * (iSession - 0.2),...
                                                  LeftMoveTime,...
                                                  'SizeData', 5,...
                                                  'Marker', '.',...
                                                  'MarkerEdgeColor', LRPalette(1,:),...
                                                  'XJitter', 'density',...
                                                  'XJitterWidth', 0.4);

    LeftMoveTimeBoxchart = boxchart(LRMoveTimeAxes,...
                                    ones(size(LeftMoveTime)) * (iSession - 0.2),...
                                    LeftMoveTime,...
                                    'BoxWidth', 0.2,...
                                    'BoxFaceColor', 'k',...
                                    'BoxFaceAlpha', 0,...
                                    'MarkerStyle', 'none',...
                                    'LineWidth', 0.2);

    
    RightMoveTime = MoveTime(ChoiceLeft == 0);
    RightMoveTimeSwarmchart{iSession} = swarmchart(LRMoveTimeAxes,...
                                                   ones(size(RightMoveTime)) * (iSession + 0.2),...
                                                   RightMoveTime,...
                                                   'SizeData', 5,...
                                                   'Marker', '.',...
                                                   'MarkerEdgeColor', LRPalette(2,:),...
                                                   'XJitter', 'density',...
                                                   'XJitterWidth', 0.4);

    RightMoveTimeBoxchart = boxchart(LRMoveTimeAxes,...
                                     ones(size(RightMoveTime)) * (iSession + 0.2),...
                                     RightMoveTime,...
                                     'BoxWidth', 0.2,...
                                     'BoxFaceColor', 'k',...
                                     'BoxFaceAlpha', 0,...
                                     'MarkerStyle', 'none',...
                                     'LineWidth', 0.2);
    
    % Left-Right Time Investment (NotBaited Waiting Time)
    NotBaited = any(~Baited .* ChoiceLeftRight, 1) & (IncorrectChoice ~= 1);
    
    LeftTI = FeedbackWaitingTime(NotBaited == 1 & ChoiceLeft == 1);
    LeftTISwarmchart{iSession} = swarmchart(LRTIAxes,...
                                            ones(size(LeftTI)) * (iSession - 0.2),...
                                            LeftTI,...
                                            'SizeData', 5,...
                                            'Marker', '.',...
                                            'MarkerEdgeColor', LRPalette(1,:),...
                                            'XJitter', 'density',...
                                            'XJitterWidth', 0.4);

    LeftTIBoxchart = boxchart(LRTIAxes,...
                              ones(size(LeftTI)) * (iSession - 0.2),...
                              LeftTI,...
                              'BoxWidth', 0.2,...
                              'BoxFaceColor', 'k',...
                              'BoxFaceAlpha', 0,...
                              'MarkerStyle', 'none',...
                              'LineWidth', 0.2);

    
    RightTI = FeedbackWaitingTime(NotBaited == 1 & ChoiceLeft == 0);
    RightTISwarmchart{iSession} = swarmchart(LRTIAxes,...
                                             ones(size(RightTI)) * (iSession + 0.2),...
                                             RightTI,...
                                             'SizeData', 5,...
                                             'Marker', '.',...
                                             'MarkerEdgeColor', LRPalette(2,:),...
                                             'XJitter', 'density',...
                                             'XJitterWidth', 0.4);

    RightTIBoxchart = boxchart(LRTIAxes,...
                               ones(size(RightTI)) * (iSession + 0.2),...
                               RightTI,...
                               'BoxWidth', 0.2,...
                               'BoxFaceColor', 'k',...
                               'BoxFaceAlpha', 0,...
                               'MarkerStyle', 'none',...
                               'LineWidth', 0.2);
    
    % Trial Length
    TrialLength = TrialLength(~NoTrialStart);
    TrialLengthSwarmchart{iSession} = swarmchart(TrialLengthAxes,...
                                                 ones(size(TrialLength)) * iSession,...
                                                 TrialLength,...
                                                 'SizeData', 5,...
                                                 'Marker', '.',...
                                                 'MarkerEdgeColor', [0.5 0.5 0.5],...
                                                 'XJitter', 'density',...
                                                 'XJitterWidth', 0.4);

    % NoTrialStart Rate across session
    SkippedBaited = any(Baited .* ChoiceLeftRight .* [SkippedFeedback; SkippedFeedback], 1) & (IncorrectChoice ~= 1);
    SkippedBaitedLine{iSession} = line(SkippedBaitedAxes,...
                                       'xdata', iSession,...
                                       'ydata', sum(SkippedBaited == 1) ./ sum(ActiveTrial == 1) * 100,...
                                       'Marker', '+',...
                                       'Color', neon_purple);

end

%% Trial average across sessions
% NoTrialStart Rate across session
AverageNoTrialStart = NoTrialStartYData(1:iSession, :);
AverageNoTrialStart = mean(AverageNoTrialStart);
AverageNoTrialStart = AverageNoTrialStart(AverageNoTrialStart ~= 100);

NoTrialStartLine{iSession + 1} = line(NoTrialStartAxes,...
                                      'xdata', 1:length(AverageNoTrialStart),...
                                      'ydata', smooth(AverageNoTrialStart),...
                                      'LineStyle', '-',...
                                      'Marker', 'none',...
                                      'Color', 'k');

% Block 1 Transition (1st -> 2nd)
Block1TransitionYData = Block1TransitionYData(1:iSession, :);
AverageBlock1Transition = mean(Block1TransitionYData);

Block1TransitionLine{iSession + 1} = line(Block1TransitionAxes,...
                                          'xdata', -10:50,...
                                          'ydata', smooth(AverageBlock1Transition),...
                                          'LineStyle', '-',...
                                          'Marker', 'none',...
                                          'Color', 'k');

AverageLeftBlock1Transition = mean(Block1TransitionYData(PHighChoice(:, 1) == 1, :));

LeftBlock1TransitionLine = line(Block1TransitionAxes,...
                                'xdata', -10:50,...
                                'ydata', smooth(AverageLeftBlock1Transition),...
                                'LineStyle', '-',...
                                'Marker', 'none',...
                                'Color', sand);

AverageRightBlock1Transition = mean(Block1TransitionYData(PHighChoice(:, 1) == 0, :));

RightBlock1TransitionLine = line(Block1TransitionAxes,...
                                 'xdata', -10:50,...
                                 'ydata', smooth(AverageRightBlock1Transition),...
                                 'LineStyle', '-',...
                                 'Marker', 'none',...
                                 'Color', turquoise);

% Block 2 Transition (2nd -> 3rd)
Block2TransitionYData = Block2TransitionYData(1:iSession, :);
AverageBlock2Transition = mean(Block2TransitionYData);

Block2TransitionLine{iSession + 1} = line(Block2TransitionAxes,...
                                          'xdata', -10:50,...
                                          'ydata', smooth(AverageBlock2Transition),...
                                          'LineStyle', '-',...
                                          'Marker', 'none',...
                                          'Color', 'k');

AverageLeftBlock2Transition = mean(Block2TransitionYData(PHighChoice(:, 2) == 1, :));

LeftBlock2TransitionLine = line(Block2TransitionAxes,...
                                'xdata', -10:50,...
                                'ydata', smooth(AverageLeftBlock2Transition),...
                                'LineStyle', '-',...
                                'Marker', 'none',...
                                'Color', sand);

AverageRightBlock2Transition = mean(Block2TransitionYData(PHighChoice(:, 2) == 0, :));

RightBlock2TransitionLine = line(Block2TransitionAxes,...
                                 'xdata', -10:50,...
                                 'ydata', smooth(AverageRightBlock2Transition),...
                                 'LineStyle', '-',...
                                 'Marker', 'none',...
                                 'Color', turquoise);

% Block 3 Transition (3rd -> 4th)
Block3TransitionYData = Block3TransitionYData(1:iSession, :);
AverageBlock3Transition = mean(Block3TransitionYData, 'omitnan');

Block3TransitionLine{iSession + 1} = line(Block3TransitionAxes,...
                                          'xdata', -10:50,...
                                          'ydata', smooth(AverageBlock3Transition),...
                                          'LineStyle', '-',...
                                          'Marker', 'none',...
                                          'Color', 'k');

AverageLeftBlock3Transition = mean(Block3TransitionYData(PHighChoice(:, 3) == 1, :), 'omitnan');

LeftBlock3TransitionLine = line(Block3TransitionAxes,...
                                'xdata', -10:50,...
                                'ydata', smooth(AverageLeftBlock3Transition),...
                                'LineStyle', '-',...
                                'Marker', 'none',...
                                'Color', sand);

AverageRightBlock3Transition = mean(Block3TransitionYData(PHighChoice(:, 3) == 0, :), 'omitnan');

RightBlock3TransitionLine = line(Block3TransitionAxes,...
                                 'xdata', -10:50,...
                                 'ydata', smooth(AverageRightBlock3Transition),...
                                 'LineStyle', '-',...
                                 'Marker', 'none',...
                                 'Color', turquoise);

% Block 4 Transition (4th -> 5th)
Block4TransitionYData = Block4TransitionYData(1:iSession, :);
AverageBlock4Transition = mean(Block4TransitionYData, 'omitnan');

Block4TransitionLine{iSession + 1} = line(Block4TransitionAxes,...
                                          'xdata', -10:50,...
                                          'ydata', smooth(AverageBlock4Transition),...
                                          'LineStyle', '-',...
                                          'Marker', 'none',...
                                          'Color', 'k');

AverageLeftBlock4Transition = mean(Block4TransitionYData(PHighChoice(:, 4) == 1, :), 'omitnan');

LeftBlock4TransitionLine = line(Block4TransitionAxes,...
                                'xdata', -10:50,...
                                'ydata', smooth(AverageLeftBlock4Transition),...
                                'LineStyle', '-',...
                                'Marker', 'none',...
                                'Color', sand);

AverageRightBlock4Transition = mean(Block4TransitionYData(PHighChoice(:, 4) == 0, :), 'omitnan');

RightBlock4TransitionLine = line(Block4TransitionAxes,...
                                 'xdata', -10:50,...
                                 'ydata', smooth(AverageRightBlock4Transition),...
                                 'LineStyle', '-',...
                                 'Marker', 'none',...
                                 'Color', turquoise);

% SkippedBaited Rate across session
set(SkippedBaitedAxes,...
    'XTickLabel', SessionDateLabel(SkippedBaitedAxes.XTick),...
    'XTickLabelRotation', 90);

disp('YOu aRE a bEAutIFul HUmaN BeiNG, saID anTOniO.')

DataPath = strcat(DataFolderPath, '\', FigureTitle, '.png');
exportgraphics(AnalysisFigure, DataPath);

end % function