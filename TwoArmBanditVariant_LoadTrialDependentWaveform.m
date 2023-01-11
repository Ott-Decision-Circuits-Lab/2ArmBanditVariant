function TwoArmBanditVariant_LoadTrialDependentWaveform(Player, iTrial)
global BpodSystem
global TaskParameters
% global Player

% load auditory stimuli
TrialData = BpodSystem.Data.Custom.TrialData;
fs = Player.SamplingRate;

if TaskParameters.GUIMeta.RiskType.String{TaskParameters.GUI.RiskType} == "Cued"
    if ~isnumeric(TaskParameters.GUI.StimulusTime) || TaskParameters.GUI.StimulusTime <= 0
        error('Error: StimulusTime in GUI should be a positive number.')
    else
        SoundIndex = 7;
        if TrialData.LightLeft(iTrial) == 0
                RightSound = GenerateRiskCue(fs, TaskParameters.GUI.StimulusTime, 'Freq', TrialData.RewardCueRight(1,iTrial), TrialData.RewardCueRight(2,iTrial));
                if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                    Player.loadWaveform(SoundIndex, RightSound);
                    Player.TriggerProfiles(SoundIndex, 1:2) = [0, SoundIndex];
                elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
                    Player.load(SoundIndex, RightSound);
                end
                
        elseif TrialData.LightLeft(iTrial) == 1
                LeftSound = GenerateRiskCue(fs, TaskParameters.GUI.StimulusTime, 'Freq', TrialData.RewardCueLeft(1,iTrial), TrialData.RewardCueLeft(2,iTrial));
                if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                    Player.loadWaveform(SoundIndex, LeftSound);
                    Player.TriggerProfiles(SoundIndex, 1:2) = [SoundIndex, 0];
                elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
                    Player.load(SoundIndex, LeftSound);
                end
                
        else % TrialData.LeftLight == NaN
                LeftSound = GenerateRiskCue(fs, TaskParameters.GUI.StimulusTime, 'Freq', TrialData.RewardCueLeft(1,iTrial), TrialData.RewardCueLeft(2,iTrial));
                RightSound = GenerateRiskCue(fs, TaskParameters.GUI.StimulusTime, 'Freq', TrialData.RewardCueRight(1,iTrial), TrialData.RewardCueRight(2,iTrial));
                if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
                    Player.loadWaveform(SoundIndex, LeftSound);
                    Player.loadWaveform(SoundIndex+1, RightSound);
                    Player.TriggerProfiles(SoundIndex, 1:2) = [SoundIndex SoundIndex+1];
                elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')
                    Player.load(SoundIndex, [LeftSound; RightSound]);
                end
                
        end
    end
end
end