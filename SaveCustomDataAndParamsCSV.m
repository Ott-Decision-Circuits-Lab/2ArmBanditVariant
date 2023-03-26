function SaveCustomDataAndParamsCSV()
%{
Function to write trial custom data from TwoArmBanditVariant
into a comma separated value file (.csv)

Author: Antonio Lee
Date: 2023-01-23
%}

global BpodSystem

nTrials = BpodSystem.Data.nTrials;
TrialData = BpodSystem.Data.Custom.TrialData;

%{
---------------------------------------------------------------------------
preprocess the data
- remove last entry in arrays that are n_trials+1 long (from the incomplete
  last trial)
- split any n_trials x 2 array into two n_trials x 1 arrays

then save in the table as a column (requires using .', which inverts the
dimensions)
---------------------------------------------------------------------------
%}
DataTable = table();

try
    %% Pre-stimulus delivery
    DataTable.NoTrialStart = TrialData.NoTrialStart(1:nTrials).';
    DataTable.BrokeFixation = TrialData.BrokeFixation(1:nTrials).';
%     DataTable.StimDelay = TrialData.StimDelay(1:nTrials).';
    DataTable.StimWaitingTime = TrialData.StimWaitingTime(1:nTrials).';

    %% Peri-stimulus delivery and Pre-decision
    DataTable.SamplingGrace = TrialData.SamplingGrace(1, 1:nTrials).'; % only first row is exported
    DataTable.EarlyWithdrawal = TrialData.EarlyWithdrawal(1:nTrials).';
    DataTable.SampleTime = TrialData.SampleTime(1:nTrials).';
    DataTable.LightLeft = TrialData.LightLeft(1:nTrials).';

    %% Peri-decision and pre-outcome
    DataTable.NoDecision = TrialData.NoDecision(1:nTrials).';
    DataTable.MoveTime = TrialData.MoveTime(1:nTrials).';
    DataTable.StartNewTrial = TrialData.StartNewTrial(1:nTrials).';
    DataTable.StartNewTrialSuccessful = TrialData.StartNewTrialSuccessful(1:nTrials).';

    DataTable.ChoiceLeft = TrialData.ChoiceLeft(1:nTrials).';
    DataTable.IncorrectChoice = TrialData.IncorrectChoice(1:nTrials).';
%     DataTable.FeedbackDelay = TrialData.FeedbackDelay(1:nTrials).';
    DataTable.FeedbackGrace = TrialData.FeedbackGrace(1, 1:nTrials).'; % only first row is exported
    DataTable.FeedbackWaitingTime = TrialData.FeedbackWaitingTime(1:nTrials).';
    DataTable.SkippedFeedback = TrialData.SkippedFeedback(1:nTrials).';
    DataTable.TITrial = TrialData.TITrial(1:nTrials).';

    %% Peri-outcome
    DataTable.LeftRewardProb = TrialData.RewardProb(1, 1:nTrials).';
    DataTable.RightRewardProb = TrialData.RewardProb(2, 1:nTrials).';
    DataTable.BlockNumber = TrialData.BlockNumber(1:nTrials).';
    DataTable.BlockTrialNumber = TrialData.BlockTrialNumber(1:nTrials).';
    DataTable.LeftRewardCueStartFreq = TrialData.RewardCueLeft(1, 1:nTrials).';
    DataTable.LeftRewardCueEndFreq = TrialData.RewardCueLeft(2, 1:nTrials).';
    DataTable.RightRewardCueStartFreq = TrialData.RewardCueRight(1, 1:nTrials).';
    DataTable.RightRewardCueEndFreq = TrialData.RewardCueRight(2, 1:nTrials).';
    DataTable.LeftRewardMagnitude = TrialData.RewardMagnitude(1, 1:nTrials).';
    DataTable.RightRewardMagnitude = TrialData.RewardMagnitude(2, 1:nTrials).';
    DataTable.LeftBaited = TrialData.Baited(1, 1:nTrials).';
    DataTable.RightBaited = TrialData.Baited(2, 1:nTrials).';
    DataTable.Rewarded = TrialData.Rewarded(1:nTrials).';
catch
    warning('TrialData cannot convert to DataTable. No .csv file is saved.')
    return
end

% ----------------------------Params----------------------------------- %
try
    ParamNames = BpodSystem.GUIData.ParameterGUI.ParamNames;
    ParamVals = BpodSystem.Data.TrialSettings.';
    ParamsTable = cell2table(ParamVals, "VariableNames", ParamNames);
catch
    warning('SettingParam cannot convert to ParamsTable. No .csv file is saved.')
    return
end

% --------------------------------------------------------------------- %
% Combine the data and params tables and save to .csv
% --------------------------------------------------------------------- %
try
    FullTable = [DataTable ParamsTable];
catch
    warning('DataTable cannot append to ParamsTable. No .csv file is saved.')
    return
end
  
try
    [~, session_name, ~] = fileparts(BpodSystem.Path.CurrentDataFile);
    csv_name = "_trial_custom_data_and_params.csv";
    file_name = string(strcat("O:\data\", session_name, csv_name));
    writetable(FullTable, file_name)
catch
    warning('Error: writetable malfunction. No .csv file is saved.')
    return
end
disp('trial_custom_data_and_params.csv for TwoArmBanditVariant is successfully saved')
end  % save_custom_data_and_params_tsv()