function TwoArmBanditVariant_PoolingData_Modified()

dataFolder = 'C:\Users\emlon\Documents\ConsolidatedDocuments\Academic\Charité and ECN classes\Ott Lab\Ott Lab local data folder\Psilocybin vs PBS files TwoArmBandit\52\PBS';
sessionFiles = dir(strcat(dataFolder, '\*.mat')); % Struct with filename, folder, date, bytes, isdir, datenum

%% start looping to select SessionData as a cell array
DataHolder = {}; % Unprocessed cell that will lump together all individual SessionData

for iSession = 1:length(sessionFiles)

    sessionFileName = sessionFiles(iSession).name;
    sessionFullPath = fullfile(dataFolder, sessionFileName);
    
    load(sessionFullPath); % variable name will be 'SessionData'
    RatID = SessionData.Info.Subject;

    if SessionData.nTrials >= 50 && SessionData.SettingsFile.GUI.CatchTrial && SessionData.SettingsFile.GUI.FeedbackDelayGrace >= 0.2 && SessionData.SettingsFile.GUI.FeedbackDelayMax == 8 % Ensure that the session is valid (has many trials, and has the final settings of feedback delay)
        DataHolder{end+1} = SessionData; % Add session to DataHolder cell (1 x nSessions cell)
    end

end

dataHolderFilePath = fullfile(dataFolder, '\Selected_Data.mat'); % Create a filepath to ... 
save(dataHolderFilePath, 'DataHolder') % ... DataHolder cell
    
%% Concatenate SessionData into one single file

% ConcatenatedDataHolder is the pooled struct to be analyzed as 'SessionData'
ConcatenatedDataHolder.Info.Subject = num2str(RatID);
ConcatenatedDataHolder.Info.SessionDate = datetime('20000101', 'InputFormat', 'yyyyMMdd'); % temporary entry, later corrected
ConcatenatedDataHolder.nTrials = 0;

ConcatenatedDataHolder.RawEvents.Trial = {};
ConcatenatedDataHolder.TrialStartTimestamp = [];
ConcatenatedDataHolder.TrialEndTimestamp = [];

% ConcatenatedTrialData is a struct with trial data, will be put into ConcatenatedDataHolder
ConcatenatedTrialData.ChoiceLeft = [];
ConcatenatedTrialData.Baited = [];
ConcatenatedTrialData.IncorrectChoice = [];
ConcatenatedTrialData.NoDecision = [];
ConcatenatedTrialData.NoTrialStart = [];
ConcatenatedTrialData.BrokeFixation = [];
ConcatenatedTrialData.EarlyWithdrawal = [];
ConcatenatedTrialData.StartNewTrial = [];
ConcatenatedTrialData.SkippedFeedback = [];
ConcatenatedTrialData.Rewarded = [];

ConcatenatedTrialData.SampleTime = [];
ConcatenatedTrialData.MoveTime = [];
ConcatenatedTrialData.FeedbackWaitingTime = [];
ConcatenatedTrialData.RewardProb = [];
ConcatenatedTrialData.LightLeft = [];

ConcatenatedTrialData.BlockNumber = [];
ConcatenatedTrialData.BlockTrialNumber = [];
ConcatenatedTrialData.RewardMagnitude = [];

% for files before April 2023, no DrinkingTime is available
ConcatenatedTrialData.DrinkingTime = [];

% Fill pre-allocated fields, one session at a time
for iSession = 1:length(DataHolder)

    % Assign trial data for this iteration
    nTrials = DataHolder{iSession}.nTrials;
    ConcatenatedDataHolder.nTrials = ConcatenatedDataHolder.nTrials + nTrials;
    TrialData = DataHolder{iSession}.Custom.TrialData;
    
    ConcatenatedTrialData.ChoiceLeft = [ConcatenatedTrialData.ChoiceLeft, TrialData.ChoiceLeft(1:nTrials)];
    ConcatenatedTrialData.Baited = [ConcatenatedTrialData.Baited, TrialData.Baited(:, 1:nTrials)];
    ConcatenatedTrialData.IncorrectChoice = [ConcatenatedTrialData.IncorrectChoice, TrialData.IncorrectChoice(1:nTrials)];
    ConcatenatedTrialData.NoDecision = [ConcatenatedTrialData.NoDecision, TrialData.NoDecision(1:nTrials)];
    ConcatenatedTrialData.NoTrialStart = [ConcatenatedTrialData.NoTrialStart, TrialData.NoTrialStart(1:nTrials)];
    ConcatenatedTrialData.BrokeFixation = [ConcatenatedTrialData.BrokeFixation, TrialData.BrokeFixation(1:nTrials)];
    ConcatenatedTrialData.EarlyWithdrawal = [ConcatenatedTrialData.EarlyWithdrawal, TrialData.EarlyWithdrawal(1:nTrials)];
    ConcatenatedTrialData.StartNewTrial = [ConcatenatedTrialData.StartNewTrial, TrialData.StartNewTrial(1:nTrials)];
    ConcatenatedTrialData.SkippedFeedback = [ConcatenatedTrialData.SkippedFeedback, TrialData.SkippedFeedback(1:nTrials)];
    ConcatenatedTrialData.Rewarded = [ConcatenatedTrialData.Rewarded, TrialData.Rewarded(1:nTrials)];
    
    ConcatenatedTrialData.SampleTime = [ConcatenatedTrialData.SampleTime, TrialData.SampleTime(1:nTrials)];
    ConcatenatedTrialData.MoveTime = [ConcatenatedTrialData.MoveTime, TrialData.MoveTime(1:nTrials)];
    ConcatenatedTrialData.FeedbackWaitingTime = [ConcatenatedTrialData.FeedbackWaitingTime, TrialData.FeedbackWaitingTime(1:nTrials)];
    ConcatenatedTrialData.RewardProb = [ConcatenatedTrialData.RewardProb, TrialData.RewardProb(:, 1:nTrials)];
    ConcatenatedTrialData.LightLeft = [ConcatenatedTrialData.LightLeft, TrialData.LightLeft(1:nTrials)];
    
    ConcatenatedTrialData.BlockNumber = [ConcatenatedTrialData.BlockNumber, TrialData.BlockNumber(:, 1:nTrials)];
    ConcatenatedTrialData.BlockTrialNumber = [ConcatenatedTrialData.BlockTrialNumber, TrialData.BlockTrialNumber(:, 1:nTrials)];
    ConcatenatedTrialData.RewardMagnitude = [ConcatenatedTrialData.RewardMagnitude, TrialData.RewardMagnitude(:, 1:nTrials)];
    
    % for files before April 2023, no DrinkingTime is available
    try
        ConcatenatedTrialData.DrinkingTime = [ConcatenatedTrialData.DrinkingTime, TrialData.DrinkingTime(1:nTrials)];
    catch
        ConcatenatedTrialData.DrinkingTime = [ConcatenatedTrialData.DrinkingTime, nan(1, nTrials)];
    end
    
    ConcatenatedDataHolder.RawEvents.Trial = [ConcatenatedDataHolder.RawEvents.Trial, DataHolder{iSession}.RawEvents.Trial];
    ConcatenatedDataHolder.TrialStartTimestamp = [ConcatenatedDataHolder.TrialStartTimestamp, DataHolder{iSession}.TrialStartTimestamp(:, 1:nTrials)];
    ConcatenatedDataHolder.TrialEndTimestamp = [ConcatenatedDataHolder.TrialEndTimestamp, DataHolder{iSession}.TrialEndTimestamp(:, 1:nTrials)];
end
ConcatenatedDataHolder.Custom.TrialData = ConcatenatedTrialData; % Add concatenated trial data to ConcatenatedDataHolder
ConcatenatedDataHolder.SettingsFile = DataHolder{iSession}.SettingsFile;

SessionData = ConcatenatedDataHolder;
ConcatenatedDataFilePath = fullfile(dataFolder, 'Concatenated_Data.mat');
save(ConcatenatedDataFilePath, 'SessionData')

% FigHandle = Analysis(ConcatenatedDataFilePath);
% saveas(FigHandle, fullfile(SelectedDataFolderPath, 'Analysis.fig'))
% saveas(FigHandle, fullfile(SelectedDataFolderPath, 'Analysis.png'))
    