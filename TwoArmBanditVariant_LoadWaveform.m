function TwoArmBanditVariant_LoadWaveform(Player, Mode, iTrial)
% BrokeFixationSound   -> Sound Index 1
% EarlyWithdrawalSound -> 2
% NoDecisionSound      -> 3
% StartNewTrialSound   -> 4
% IncorrectChoiceSound -> 5
% SkippedFeedbackSound -> 6
% NotBaiedSFeedbackSound -> 7}
% Sound Index 8 onwards are reserved for trial-dependent waveform (Max index for HiFi: 20; for Analog: 64)

global BpodSystem
global TaskParameters

if nargin < 3
    iTrial = 0;
end

% load auditory stimuli
fs = Player.SamplingRate;

switch Mode
    case 'TrialIndependent'
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
            if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                Player.loadWaveform(SoundIndex, BrokeFixationSound);
                Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
            elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
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
            if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                Player.loadWaveform(SoundIndex, EarlyWithdrawalSound);
                Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
            elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
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
            if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                Player.loadWaveform(SoundIndex, NoDecisionSound);
                Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
            elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
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
               
                case 'Beep' % 1k Hz
                    StartNewTrialSound = GenerateRiskCue(fs, TaskParameters.GUI.StartNewTrialTimeOut, 'Freq', 1, 1);

            end
        end

        if ~isempty(StartNewTrialSound)
            if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                Player.loadWaveform(SoundIndex, StartNewTrialSound);
                Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
            elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
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
            if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                Player.loadWaveform(SoundIndex, IncorrectChoiceSound);
                Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
            elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
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
                    
                case 'Beep' % 1k Hz
                    SkippedFeedbackSound = GenerateRiskCue(fs, TaskParameters.GUI.SkippedFeedbackTimeOut, 'Freq', 1, 1);

            end
        end

        if ~isempty(SkippedFeedbackSound)
            if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                Player.loadWaveform(SoundIndex, SkippedFeedbackSound);
                Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
            elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
                Player.load(SoundIndex, SkippedFeedbackSound);
            end
        end
        
        %%
        SoundIndex = 7;
        NotBaitedSound = [];
        if isfield(TaskParameters.GUI, 'NotBaitedTimeOut') && TaskParameters.GUI.NotBaitedTimeOut > 0
            switch TaskParameters.GUIMeta.NotBaitedFeedback.String{TaskParameters.GUI.NotBaitedFeedback}
                case 'None' % no adjustment

                case 'WhiteNoise'
                    NotBaitedSound = rand(1, fs*TaskParameters.GUI.NotBaitedTimeOut)*2 - 1;
                    
                case 'Beep' % 0.5k Hz
                    NotBaitedSound = GenerateRiskCue(fs, TaskParameters.GUI.NotBaitedTimeOut, 'Freq', 0.5, 0.5);
            end
        end

        if ~isempty(NotBaitedSound)
            if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                Player.loadWaveform(SoundIndex, NotBaitedSound);
                Player.TriggerProfiles(SoundIndex, 1:2) = SoundIndex;
            elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
                Player.load(SoundIndex, NotBaitedSound);
            end
        end

    case 'TrialDependent'
        switch TaskParameters.GUIMeta.RiskType.String{TaskParameters.GUI.RiskType}
            case "Cued"
                TrialData = BpodSystem.Data.Custom.TrialData;
                StimulusTime = TaskParameters.GUI.StimulusTime;
                                
                SoundIndex = 8;
                LeftSound = [];
                RightSound = [];
                if StimulusTime > 0
                    LeftSound = GenerateRiskCue(fs, StimulusTime, 'Freq', TrialData.RewardCueLeft(1,iTrial), TrialData.RewardCueLeft(2,iTrial));
                    RightSound = GenerateRiskCue(fs, StimulusTime, 'Freq', TrialData.RewardCueRight(1,iTrial), TrialData.RewardCueRight(2,iTrial));
                else
                    disp('StimulusTime in GUI should be a positive number. Empty track will be loaded.')
                end
                
                if TrialData.LightLeft(iTrial) == 0
                    LeftSound = [];
                elseif TrialData.LightLeft(iTrial) == 1
                    RightSound = [];
                end

                if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                    if ~isempty(LeftSound)
                        Player.loadWaveform(SoundIndex, LeftSound);
                    end
                    if ~isempty(RightSound)
                        Player.loadWaveform(SoundIndex+1, RightSound);
                    end
                    Player.TriggerProfiles(SoundIndex, 1:2) = [SoundIndex SoundIndex+1];
                elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
                    Player.load(SoundIndex, [LeftSound; RightSound]);
                end

        end
end % switch
end % function