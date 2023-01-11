function TwoArmBanditVariant_LoadTrialDependentWaveform(Player, iTrial)
global BpodSystem
global TaskParameters
% global Player

% load auditory stimuli
TrialData = BpodSystem.Data.Custom.TrialData;
fs = Player.SamplingRate;

if TaskParameters.GUIMeta.RiskType.String{TaskParameters.GUI.RiskType} == 'Cued'
    if isnumeric(TaskParameters.GUI.StimulusTime) || TaskParameters.GUI.StimulusTime <= 0
        error('Error: StimulusTime in GUI should be a positive number.')
    else
        SoundIndex = 7;
        switch TrialData.LeftLight(iTrial)
            case 0
                RightSound = GenerateRiskCue(fs, TaskParameters.GUI.StimulusTime, 'Freq', TrialData.RewardCueRight(1,iTrial), TrialData.RewardCueRight(2,iTrial));
                if BpodSystem.assertModule('WavePlayer', 1) == 1
                    Player.loadWaveform(SoundIndex, RightSound);
                    Player.TriggerProfiles(SoundIndex, 2) = SoundIndex;
                elseif BpodSystem.assertModule('HiFi', 1) == 1
                    Player.load(SoundIndex, RightSound);
                end
                
            case 1
                LeftSound = GenerateRiskCue(fs, TaskParameters.GUI.StimulusTime, 'Freq', TrialData.RewardCueLeft(1,iTrial), TrialData.RewardCueLeft(2,iTrial));
                if BpodSystem.assertModule('WavePlayer', 1) == 1
                    Player.loadWaveform(SoundIndex, LeftSound);
                    Player.TriggerProfiles(SoundIndex, 1) = SoundIndex;
                elseif BpodSystem.assertModule('HiFi', 1) == 1
                    Player.load(SoundIndex, LeftSound);
                end
                
            otherwise % TrialData.LeftLight == NaN
                LeftSound = GenerateRiskCue(fs, TaskParameters.GUI.StimulusTime, 'Freq', TrialData.RewardCueLeft(1,iTrial), TrialData.RewardCueLeft(2,iTrial));
                RightSound = GenerateRiskCue(fs, TaskParameters.GUI.StimulusTime, 'Freq', TrialData.RewardCueRight(1,iTrial), TrialData.RewardCueRight(2,iTrial));
                if BpodSystem.assertModule('WavePlayer', 1) == 1
                    Player.loadWaveform(SoundIndex, LeftSound);
                    Player.loadWaveform(SoundIndex+1, RightSound);
                    Player.TriggerProfiles(SoundIndex, 1:2) = [SoundIndex SoundIndex+1];
                elseif BpodSystem.assertModule('HiFi', 1) == 1
                    Player.load(SoundIndex, [LeftSound; RightSound]);
                end
                
        end
    end
end
end