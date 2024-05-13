function TwoArmBanditVariant_Matching_MultiSession_Analysis(varargin)
%{
First create on 20230622 by Antonio Lee for AG Ott @HU Berlin
With the file server architecture, this functions runs through the
session folders of the designated Animals after a PeriodStartDate and before a
PeriodEndDate to parse out the TrialData necessary for Analysis.m
%}

%% obtain input and check if they are of the correct format
p = inputParser;
addParameter(p, 'Animal', {}, @iscell); % Cell array of numerics, holder for rat_id
addParameter(p, 'PeriodStartDate', {}, @iscell); % Cell array of char, date in the format of yyyyMMdd
addParameter(p, 'PeriodEndDate', {}, @iscell);
addParameter(p, 'TrialRange', [0 1200], @isnumeric);
addParameter(p, 'TimelineView', true, @islogical);
addParameter(p, 'ColourMap', 'RuB9', @ischar);
%{ Not Implemented
% addParameter(p, 'FilterOut', {}, @iscell); % Cell array of char
% addParameter(p, 'SeparateByAnimal', true, @islogical); % if true, the Analysis is done per Animal; if false, the Analysis is pooled
% addParameter(p, 'SeparateBySession', false, @islogical); % if true, the Analysis is done per Session; if false, the Analysis is pooled
%}

parse(p, varargin{:});
p = p.Results;

FileServerDataFolderPath = OttLabDataServerFolderPath();

if isempty(p.Animal)
    AnimalDataFolderPath = uigetdir(FileServerDataFolderPath);
    [~, RatID, ~] = fileparts(AnimalDataFolderPath);
    p.Animal = {str2double(RatID)};
end

if isempty(p.PeriodStartDate) || isempty(p.PeriodEndDate)
    error('Period is not defined')
end

if length(p.PeriodStartDate) ~= length(p.PeriodEndDate)
    error('Miscatch in length of PeriodStartDate and PeriodEndDate')
end

for iPeriodStartDate = 1:length(p.PeriodStartDate)
    PeriodStartDate = p.PeriodStartDate{iPeriodStartDate};
    PeriodStartDate = datetime(PeriodStartDate, 'Inputformat', 'yyyyMMdd');

    PeriodEndDate = p.PeriodEndDate{iPeriodStartDate};
    PeriodEndDate = datetime(PeriodEndDate, 'Inputformat', 'yyyyMMdd');   
end

if length(p.PeriodStartDate) ~= 1 && length(p.PeriodStartDate) ~= length(p.Animal)
    error('Length of PeriodStartDate is not applicable to the length of Animals')
end

if length(p.Animal) > length(p.PeriodStartDate)
    p.PeriodStartDate = repmat(p.PeriodStartDate, [1, length(p.Animal)]);
    p.PeriodEndDate = repmat(p.PeriodEndDate, [1, length(p.Animal)]);
end

%% start looping to select SessionData as a cell array
DataHolder = {};
for iAnimal = 1:length(p.Animal)
    RatID = p.Animal{iAnimal};
    if ~isnumeric(RatID)
        disp(['The input ', num2str(RatID), ' is not a numeric. It will be ignored.'])
        continue
    end

    if ~isfolder([FileServerDataFolderPath, num2str(RatID)])
        disp(['Folder for rat_id as ', num2str(RatID), ' is not found on the file server data folder. It will be ignored.'])
        continue
    end
    
    PeriodStartDate = datetime(p.PeriodStartDate{iAnimal}, 'InputFormat', 'yyyyMMdd');
    PeriodEndDate = datetime(p.PeriodEndDate{iAnimal}, 'InputFormat', 'yyyyMMdd');
    
    BpodSessionsFolderPath = [FileServerDataFolderPath, num2str(RatID), '\bpod_session\'];
    SessionDataFolders = dir(BpodSessionsFolderPath);
    for iSession = 1:length(SessionDataFolders)
        if ~SessionDataFolders(iSession).isdir
            continue
        end

        SessionDate = '';
        try
            SessionDate = datetime(SessionDataFolders(iSession).name, 'InputFormat', 'yyyyMMdd_HHmmss');
        catch
        end

        if isempty(SessionDate)
            continue
        end
        
        if SessionDate < PeriodStartDate || SessionDate > PeriodEndDate
            continue
        end
        
        SessionDataFolderPath = [BpodSessionsFolderPath, SessionDataFolders(iSession).name, '\'];
        SessionData = dir(SessionDataFolderPath);
        SessionFilePath = '';
        for iData = 1:length(SessionData)
            if length(SessionData(iData).name) < 19
                continue
            end

            if strcmpi(SessionData(iData).name(end-18:end), [datestr(SessionDate, 'YYYYmmDD_hhMMss'), '.mat'])
                SessionFilePath = [SessionDataFolderPath, SessionData(iData).name];
                break
            end
        end

        if isempty(SessionFilePath)
            disp(['No SessionFile in folder ', SessionDataFolders(iSession).name, ' is found.'])
            continue
        end

        load(SessionFilePath); % variable name will be 'SessionData'
        if SessionData.nTrials >= 50 &&...
           SessionData.SettingsFile.GUI.CatchTrial &&...
           SessionData.SettingsFile.GUI.FeedbackDelayGrace >= 0.2 &&...
           SessionData.SettingsFile.GUI.FeedbackDelayMax >= 8
            DataHolder{end+1} = SessionData;
        end
    end
    
    SelectedDataFolderPath = [FileServerDataFolderPath, num2str(RatID), '\bpod_session_multi_session_analysis\',...
                              num2str(RatID), '_TwoArmBandit_', p.PeriodStartDate{iAnimal}, '_', p.PeriodEndDate{iAnimal}, '\'];
    
    if ~isfolder(SelectedDataFolderPath)
        mkdir(SelectedDataFolderPath)
    end

    SelectedDataFilePath = fullfile(SelectedDataFolderPath, '\Selected_Data.mat');
    save(SelectedDataFilePath, 'DataHolder')
    
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
    
    if p.TimelineView
        EarliestSessionDate = datetime(DataHolder{1}.Info.SessionDate);
        LatestSessionDate = datetime(DataHolder{end}.Info.SessionDate);
        FullDateRange = between(EarliestSessionDate, LatestSessionDate, 'Days');
        FullDateRangeChar = char(FullDateRange);
        ColourAdjustmentDenominator = str2double(FullDateRangeChar(1:end-1));
    else
        ColourAdjustmentDenominator = size(DataHolder);
    end
    
    %% Initiatize figure
    % create figure
    FigHandle = figure('Position', [   0       0    1191     842],... % DIN A3, 72 ppi
                       'NumberTitle', 'off',...
                       'Name', strcat(num2str(RatID), '_', string(PeriodStartDate, 'yyyyMMdd'), '_', string(PeriodEndDate, 'yyyyMMdd')),...
                       'MenuBar', 'none',...
                       'Resize', 'off');
    
    TrialRange = p.TrialRange;
    CommonTrialXTick = TrialRange(1):200:TrialRange(2);
    TrialXTickLabel = CommonTrialXTick .* (mod(CommonTrialXTick, 400) == 0);
    TrialXTickLabel = string(TrialXTickLabel);
    TrialXTickLabel(strcmpi(TrialXTickLabel, "0")) = "";
    TrialXTickLabel = cellstr(TrialXTickLabel);

    % RewardRate at TimeTrialStart for past 20 trials
    RewardRateAxes = axes(FigHandle, 'Position', [0.05    0.06    0.33    0.12]);
    hold(RewardRateAxes, 'on');
    set(RewardRateAxes,...
        'TickDir', 'in',...
        'XTick', CommonTrialXTick,...
        'XTickLabel', TrialXTickLabel,...
        'FontSize', 10);
    xlim(TrialRange)
    ylabel(RewardRateAxes, 'Reward rate (\muL s^{-1})', 'FontSize', 10);

    % SkippedBaited (SB) Ratio at TimeTrialStart for past 20 trials
    SBRatioAxes = axes(FigHandle, 'Position', [0.05    0.21    0.33    0.12]);
    hold(SBRatioAxes, 'on');
    set(SBRatioAxes,...
        'TickDir', 'in',...
        'XTick', CommonTrialXTick,...
        'XTickLabel', [],...
        'FontSize', 10);
    xlim(TrialRange)
    ylabel(SBRatioAxes, 'SB ratio (%)', 'FontSize', 10);
    
    % EarlyWithdrawal (EW) Ratio at TimeTrialStart for past 20 trials
    EWRatioAxes = axes(FigHandle, 'Position', [0.05    0.36    0.33    0.12]);
    hold(EWRatioAxes, 'on');
    set(EWRatioAxes,...
        'TickDir', 'in',...
        'XTick', CommonTrialXTick,...
        'XTickLabel', [],...
        'FontSize', 10);
    xlim(TrialRange)
    ylabel(EWRatioAxes, 'EW ratio (%)', 'FontSize', 10);
    
    % NoTrialStart Ratio at TimeTrialStart for past 20 trials
    NoTrialStartRatioAxes = axes(FigHandle, 'Position', [0.05    0.51    0.33    0.12]);
    hold(NoTrialStartRatioAxes, 'on');
    set(NoTrialStartRatioAxes,...
        'TickDir', 'in',...
        'XTick', CommonTrialXTick,...
        'XTickLabel', [],...
        'FontSize', 10);
    xlim([0 1200])
    ylabel(NoTrialStartRatioAxes, 'NoTrialStart ratio (%)', 'FontSize', 10);

    title('Estimated value of last 20 trial')
    
    disp('You are beautiful')

    %% Process each SessionData one by one   
    for iSession = 1:length(DataHolder)
        SessionData = DataHolder{iSession};
        SessionDate = datetime(SessionData.Info.SessionDate);
        if p.TimelineView
            DayToLatestSession = between(SessionDate, LatestSessionDate, 'Days');
            DayToLatestSessionChar = char(DayToLatestSession);
            ColourAdjustmentNominator = str2double(DayToLatestSessionChar(1:end-1));
        else
            ColourAdjustmentNomiator = iSession;
        end

        nTrials = SessionData.nTrials;
        TrialData = SessionData.Custom.TrialData;
        TrialStartTimestamp = SessionData.TrialStartTimestamp - SessionData.TrialStartTimestamp(1);
        TrialEndTimestamp = SessionData.TrialEndTimestamp - SessionData.TrialStartTimestamp(1);
        
        MovingWindow = 20;

        % RewadRate at TimeTrialStart for past 20 trials
        RewardMagnitudeMovsum = movsum(TrialData.RewardMagnitudeL(1:nTrials) +...
                                       TrialData.RewardMagnitudeR(1:nTrials), [MovingWindow-1 0]);

        RewardMagnitudeMovsum = [0 RewardMagnitudeMovsum(1:end-1)];
        TimeFromiTrialBack = TrialStartTimestamp - [zeros(1, MovingWindow) TrialStartTimestamp(1:end-20)];
        RewardRateEstimate = RewardMagnitudeMovsum./TimeFromiTrialBack;
        
        RewardRatePlot = line(RewardRateAxes,...
                              'xdata', 1:nTrials,...
                              'ydata', RewardRateEstimate);
    end

    saveas(FigHandle, fullfile(SelectedDataFolderPath, 'Analysis.fig'))
    saveas(FigHandle, fullfile(SelectedDataFolderPath, 'Analysis.png'))
    
end % iAnimal

end % function