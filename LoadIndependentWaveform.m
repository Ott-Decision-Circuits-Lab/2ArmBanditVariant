function LoadIndependentWaveform(Player)
% global Player
% BrokeFixationSound   -> Sound Index 1
% EarlyWithdrawalSound -> 2
% NoDecisionSound      -> 3
% StartNewTrialSound   -> 4
% IncorrectChoiceSound -> 5
% SkippedFeedbackSound -> 6}
% Sound Index 10 onwards are reserved for trial-dependent waveform (Max index for HiFi: 20; for Analog: 64)
global TaskParameters

fs = Player.SamplingRate;

%%
SoundIndex = 1;
BrokeFixationSound = [];
if isfield(TaskParameters.GUI, 'BrokeFixationTimeOut') && TaskParameters.GUI.BrokeFixationTimeOut > 0
    switch TaskParameters.GUIMeta.BrokeFixationFeedback.String{TaskParameters.GUI.BrokeFixationFeedback}
        case 'None' % no adjustment
            
        case 'WhiteNoise'
            BrokeFixationSound = rand(1, fs*TaskParameters.GUI.BrokeFixationTimeOut)*2 - 1;
    end
end

if ~isempty(BrokeFixationSound)
    if BpodSystem.assertModule('WavePlayer', 1) == 1
        Player.loadWaveform(SoundIndex, BrokeFixationSound);
        Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
    elseif BpodSystem.assertModule('HiFi', 1) == 1
        Player.load(SoundIndex, BrokeFixationSound);
    end
end

%%
SoundIndex = 2;
EarlyWithdrawalSound = [];
if isfield(TaskParameters.GUI, 'EarlyWithdrawalTimeOut') && TaskParameters.GUI.EarlyWithdrawalTimeOut > 0
    switch TaskParameters.GUIMeta.EarlyWithdrawalFeedback.String{TaskParameters.GUI.EarlyWithdrawalFeedback}
        case 'None' % no adjustment
            
        case 'WhiteNoise'
            EarlyWithdrawalSound = rand(1, fs*TaskParameters.GUI.EarlyWithdrawalTimeOut)*2 - 1;
    end
end

if ~isempty(EarlyWithdrawalSound)
    if BpodSystem.assertModule('WavePlayer', 1) == 1
        Player.loadWaveform(SoundIndex, EarlyWithdrawalSound);
        Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
    elseif BpodSystem.assertModule('HiFi', 1) == 1
        Player.load(SoundIndex, EarlyWithdrawalSound);
    end
end

%%
SoundIndex = 3;
NoDecisionSound = [];
if isfield(TaskParameters.GUI, 'NoDecisionTimeOut') && TaskParameters.GUI.NoDecisionTimeOut > 0
    switch TaskParameters.GUIMeta.NoDecisionFeedback.String{TaskParameters.GUI.NoDecisionFeedback}
        case 'None' % no adjustment
            
        case 'WhiteNoise'
            NoDecisionSound = rand(1, fs*TaskParameters.GUI.NoDecisionTimeOut)*2 - 1;
    end
end

if ~isempty(NoDecisionSound)
    if BpodSystem.assertModule('WavePlayer', 1) == 1
        Player.loadWaveform(SoundIndex, NoDecisionSound);
        Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
    elseif BpodSystem.assertModule('HiFi', 1) == 1
        Player.load(SoundIndex, NoDecisionSound);
    end
end

%%
SoundIndex = 4;
StartNewTrialSound = [];
if isfield(TaskParameters.GUI, 'StartNewTrialTimeOut') && TaskParameters.GUI.StartNewTrialTimeOut > 0
    switch TaskParameters.GUIMeta.StartNewTrialFeedback.String{TaskParameters.GUI.StartNewTrialFeedback}
        case 'None' % no adjustment
            
        case 'WhiteNoise'
            StartNewTrialSound = rand(1, fs*TaskParameters.GUI.StartNewTrialTimeOut)*2 - 1;
    end
end

if ~isempty(StartNewTrialSound)
    if BpodSystem.assertModule('WavePlayer', 1) == 1
        Player.loadWaveform(SoundIndex, StartNewTrialSound);
        Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
    elseif BpodSystem.assertModule('HiFi', 1) == 1
        Player.load(SoundIndex, StartNewTrialSound);
    end
end

%%
SoundIndex = 5;
IncorrectChoiceSound = [];
if isfield(TaskParameters.GUI, 'IncorrectChoiceTimeOut') && TaskParameters.GUI.IncorrectChoiceTimeOut > 0
    switch TaskParameters.GUIMeta.IncorrectChoiceFeedback.String{TaskParameters.GUI.IncorrectChoiceFeedback}
        case 'None' % no adjustment
            
        case 'WhiteNoise'
            IncorrectChoiceSound = rand(1, fs*TaskParameters.GUI.IncorrectChoiceTimeOut)*2 - 1;
    end
end

if ~isempty(IncorrectChoiceSound)
    if BpodSystem.assertModule('WavePlayer', 1) == 1
        Player.loadWaveform(SoundIndex, IncorrectChoiceSound);
        Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
    elseif BpodSystem.assertModule('HiFi', 1) == 1
        Player.load(SoundIndex, IncorrectChoiceSound);
    end
end

%%
SoundIndex = 6;
SkippedFeedbackSound = [];
if isfield(TaskParameters.GUI, 'SkippedFeedbackTimeOut') && TaskParameters.GUI.SkippedFeedbackTimeOut > 0
    switch TaskParameters.GUIMeta.SkippedFeedbackFeedback.String{TaskParameters.GUI.SkippedFeedbackFeedback}
        case 'None' % no adjustment
            
        case 'WhiteNoise'
            SkippedFeedbackSound = rand(1, fs*TaskParameters.GUI.SkippedFeedbackTimeOut)*2 - 1;
    end
end

if ~isempty(SkippedFeedbackSound)
    if BpodSystem.assertModule('WavePlayer', 1) == 1
        Player.loadWaveform(SoundIndex, SkippedFeedbackSound);
        Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
    elseif BpodSystem.assertModule('HiFi', 1) == 1
        Player.load(SoundIndex, SkippedFeedbackSound);
    end
end

end