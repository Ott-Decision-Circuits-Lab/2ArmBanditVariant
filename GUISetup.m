function TaskParameters = GUISetup()

global BpodSystem

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;

if isempty(fieldnames(TaskParameters))
    %% general
    TaskParameters.GUI.SessionDescription = 'First risk task'; % free space to document setting purposes
    TaskParameters.GUIMeta.SessionDescription.Style = 'edittext';
    
    TaskParameters.GUI.Ports_LMR = '123'; % bpod port number for poke connection
    TaskParameters.GUI.PreITI = 0.5; % before wait_Cin
    TaskParameters.GUI.WaitCInMax = 20; % max waiting time for C_in before a new trial starts, useful to track progress
    TaskParameters.GUI.ChoiceDeadline = 10; % max waiting time for S_in after stimuli
    
    TaskParameters.GUI.SingleSidePoke = false;
    TaskParameters.GUIMeta.SingleSidePoke.Style = 'checkbox'; % old light-guided
    TaskParameters.GUI.IncorrectChoiceTimeOut = 1; % (s), for single-side poke settings only, where subject chooses the side poke without light
    TaskParameters.GUI.IncorrectChoiceFeedbackType = 1; % feedback for IncorrectChoice
    TaskParameters.GUIMeta.IncorrectChoiceFeedbackType.Style = 'popupmenu';
    TaskParameters.GUIMeta.IncorrectChoiceFeedbackType.String = {'None','WhiteNoise'};
  
    TaskParameters.GUI.StartNewTrial = false; % check if starting a new trial by C_in after stimulus
    TaskParameters.GUIMeta.StartNewTrial.Style = 'checkbox';
    TaskParameters.GUI.StartNewTrialHoldingTime = 0.35; % time required to trigger starting a new trial
    TaskParameters.GUI.StartNewTrialFeedbackType = 1; % feedback for successful StartNewTrial
    TaskParameters.GUIMeta.StartNewTrialFeedbackType.Style = 'popupmenu';
    TaskParameters.GUIMeta.StartNewTrialFeedbackType.String = {'None','WhiteNoise'};
    TaskParameters.GUI.StartNewTrialTimeOut = 3; % (s), for the case where subject starts a new trial by choosing the centre poke after stimulus
    %{it may need an extra GracePeriod for the decision of starting a new task}
    
    TaskParameters.GUI.ITI = 5; % end of trial ITI
    TaskParameters.GUI.VI = false; % exprnd based on ITI
    TaskParameters.GUIMeta.VI.Style = 'checkbox';
    
    TaskParameters.GUIPanels.General = {'SessionDescription','Ports_LMR','PreITI','Wait_Cin_Max',...
                                        'ChoiceDeadline','SingleSidePoke','IncorrectChoiceTimeOut',...
                                        'IncorrectChoiceFeedbackType','StartNewTrial','StartNewTrialHoldingTime',...
                                        'StartNewTrialFeedbackType','StartNewTrialTimeOut','ITI', 'VI'};
    
    %% StimDelay
    TaskParameters.GUI.StimDelayMin = 0; % lower boundary for autoincrementing stimulus delay time, for all
    TaskParameters.GUI.StimDelayMax = 0; % upper boundary for autoincrementing stimulus delay time
    
    TaskParameters.GUI.StimDelay = TaskParameters.GUI.StimDelayMin; % current stimulus delay time
    TaskParameters.GUIMeta.StimDelay.Style = 'text';
    
    TaskParameters.GUI.StimDelayDistributionType = 1;
    TaskParameters.GUIMeta.StimDelayDistributionType.Style = 'popupmenu';
    TaskParameters.GUIMeta.StimDelayDistributionType.String = {'Fix','AutoIncr','TruncExp','Uniform','Beta'}; % Fix = fix time; AutoIncr = incremental along session; TruncExp = random drawn within a range with prob distribution based on TrucExp; Beta = like TruncExp, but with beta distribution
    
    TaskParameters.GUI.StimDelayIncrStepSize = 0.01; % step size for autoincrementing stimulus delay time, for AutoIncr only
    TaskParameters.GUI.StimDelayDecrStepSize = 0.01;
    TaskParameters.GUI.StimDelayTau = 0.05; % step size for StimDelay, only for TruncExp
    TaskParameters.GUI.StimDelayAlpha = 0.05; % step size for StimDelay, only for Beta
    TaskParameters.GUI.StimDelayBeta = 0.05; % step size for StimDelay, only for Beta
    
    TaskParameters.GUI.BrokeFixationTimeOut = 2; % (s), penalty for C_out before stimulus starts
    TaskParameters.GUI.BrokeFixationFeedbackType = 1; % feedback for BrokeFixation
    TaskParameters.GUIMeta.BrokeFixationFeedbackType.Style = 'popupmenu';
    TaskParameters.GUIMeta.BrokeFixationFeedbackType.String = {'None','WhiteNoise'};
    
    TaskParameters.GUI.PlayStimulus = 1; % stimulus type
    TaskParameters.GUIMeta.PlayStimulus.Style = 'popupmenu';
    TaskParameters.GUIMeta.PlayStimulus.String = {'None','Freq'}; % if freq

    TaskParameters.GUI.StimulusTime = 0.35; % legnth of stimulus reception, also how long the animal is required to sample (to avoid random decision)
    
    TaskParameters.GUI.SamplingGrace = 0; % allowance for brief C_out and then C_in, for flickering action/device
    TaskParameters.GUI.EarlyWithdrawalTimeOut = 1; % penalty for C_out before stimulus delivery ends
    TaskParameters.GUI.EarlyWithdrawalFeedbackType = 1; % feedback for EarlyWithdrawal
    TaskParameters.GUIMeta.EarlyWithdrawalFeedbackType.Style = 'popupmenu';
    TaskParameters.GUIMeta.EarlyWithdrawalFeedbackType.String = {'None','WhiteNoise'};

    TaskParameters.GUIPanels.Sampling = {'StimDelay','StimDelayDistributionType','StimDelayMin','StimDelayMax',...
                                         'StimDelayIncrStepSize','StimDelayDecrStepSize','StimDelayTau',...
                                         'StimDelayAlpha','StimDelayBeta','BrokeFixationTimeOut',...
                                         'BrokeFixationFeedbackType','PlayStimulus','StimulusTime',...
                                         'SamplingGrace','EarlyWithdrawalTimeOut','EarlyWithdrawalFeedbackType'};
                                     
    %% FeedbackDelay, original named "Side Ports" ("waiting for feedback(either reward or punishment)")
    TaskParameters.GUI.FeedbackDelayDistributionType = 1;
    TaskParameters.GUIMeta.FeedbackDelayDistributionType.Style = 'popupmenu';
    TaskParameters.GUIMeta.FeedbackDelayDistributionType.String = {'Fix','AutoIncr','TruncExp','Beta'}; % Fix = fix time; AutoIncr = incremental along session; TruncExp = random drawn within a range with prob distribution based on TrucExp; Beta = like TruncExp, but with beta distribution
    TaskParameters.GUI.FeedbackDelayMin = 0; % lower boundary for FeedbackDelay; after (i+1)th value is created, it is used to bound the value
    TaskParameters.GUI.FeedbackDelayMax = 0; % upper boundary for FeedbackDelay
    
    TaskParameters.GUI.FeedbackDelayIncrStepSize = 0.01; % step size for FeedbackDelay, only for AutoIncr
    TaskParameters.GUI.FeedbackDelayDecrStepSize = 0.01; % step size for FeedbackDelay, only for AutoIncr
    TaskParameters.GUI.FeedbackDelayTau = 0.05; % step size for FeedbackDelay, only for TruncExp
    TaskParameters.GUI.FeedbackDelayAlpha = 0.05; % step size for FeedbackDelay, only for Beta
    TaskParameters.GUI.FeedbackDelayBeta = 0.05; % step size for FeedbackDelay, only for Beta
    
    TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin; % current FeedbackDelay
    TaskParameters.GUIMeta.FeedbackDelay.Style = 'text';
    TaskParameters.GUI.FeedbackDelayGrace = 0; 
    
    TaskParameters.GUI.SkippedFeedbackTimeOut = 3;
    TaskParameters.GUI.SkippedFeedbackFeedbackType = 1; % feedback for SkippedFeedback
    TaskParameters.GUIMeta.SkippedFeedbackFeedbackType.Style = 'popupmenu';
    TaskParameters.GUIMeta.SkippedFeedbackFeedbackType.String = {'None','WhiteNoise'};
    
    TaskParameters.GUI.CatchTrialPercentage = 0; % determine whether a trial is with extended FeedbackDelay, thus "catching" the time investment behaviour
    TaskParameters.GUI.CatchTrial = 'true'; % is the current trial a CatchTrial?
    TaskParameters.GUIMeta.CatchTrial.Style = 'text';
    
    TaskParameters.GUIPanels.FeedbackDelay = {'FeedbackDelayDistributionType','FeedbackDelayMin',...
                                              'FeedbackDelayMax','FeedbackDelayIncr','FeedbackDelayDecr',...
                                              'FeedbackDelayTau','FeedbackDelayAlpha','FeedbackDelayBeta',...
                                              'FeedbackDelay','FeedbackDelayGrace','SkippedFeedbackTimeOut',...
                                              'SkippedFeedbackFeedbackType','CatchTrialPercentage','CatchTrial'};
                                      
    %% Reward and RewardProb
    TaskParameters.GUI.RewardAmount = 30; % (ul), baseline value for reward (adjusted by ExpressedAsExpectedValue)
    TaskParameters.GUI.ExpressedAsExpectedValue = false; %
    TaskParameters.GUIMeta.ExpressedAsExpectedValue.Style = 'checkbox'; % if true, reward probability = 1 while reward amount discounted by the set probability
    
    TaskParameters.GUI.RiskType = 1;
    TaskParameters.GUIMeta.RiskType.Style = 'popupmenu';
    TaskParameters.GUIMeta.RiskType.String = {'Fix','BlockRand','BlockFix','Cued'}; % decide how reward probability is expressed: Fix, based on RewardProbLeft value to express fix RewardProb; BlockRand, randomly draw a value between Min and Max and assign; BlockFix, based on Max and Min and reverse L-R value; Cue, cued by Tone
    
    TaskParameters.GUI.RewardProbLeft = 50; % Reward Probability of Left Poke, only for Fix in RiskType
    TaskParameters.GUI.RewardProbRight = 50; % Reward Probability of Left Poke, only for Fix in RiskType
    
    TaskParameters.GUI.BlockLenMin = 100; % lower boundart of BlockLen, only for Block in RiskType
    TaskParameters.GUI.BlockLenMax = 150; % upper boundart of BlockLen, only for Block in RiskType
    TaskParameters.GUI.BlockLen = TaskParameters.GUI.BlockLenMin; % draw from the range confined as above, uniform distribution
    TaskParameters.GUIMeta.BlockLen.Style = 'text';
    TaskParameters.GUI.NextBlockTrialNumber = TaskParameters.GUI.BlockLen; % the trial, where the next block starts
    TaskParameters.GUIMeta.NextBlockTrialNumber.Style = 'text';
    
    TaskParameters.GUI.RewardProbMax = 100; % upper boundary of reward probability, only for Block in RiskType
    TaskParameters.GUI.RewardProbMin = 40; % lower boundary of reward probability, only for Block in RiskType
      
    TaskParameters.GUI.ToneRiskTable.ToneStartFreq = [2 5 10 20 40]'; % (kHz), only for Cue in RiskType
    TaskParameters.GUI.ToneRiskTable.ToneEndFreq = [2 5 10 20 40]'; % (kHz), features for sweep, only for Cue in RiskType
    TaskParameters.GUI.ToneRiskTable.ToneCuedRewardProbability = [40, 50, 60, 70, 80]'; % reward probability of corresponding tone, only for Cue in RiskType
    TaskParameters.GUIMeta.ToneRiskTable.Style = 'table';
    TaskParameters.GUIMeta.ToneRiskTable.String = 'Tone cued reward probability';
    TaskParameters.GUIMeta.ToneRiskTable.ColumnLabel = {'StartFreq','EndFreq','RewardProbability'};

    TaskParameters.GUI.RewardProbActualLeft = TaskParameters.GUI.RewardProbLeft; % Reward Probability of Left Poke, for all RiskType
    TaskParameters.GUIMeta.RewardProbBlockLeft.Style = 'text';
    TaskParameters.GUI.RewardProbBlockRight = TaskParameters.GUI.RewardProbRight; % Reward Probability of Right Poke, for all RiskType
    TaskParameters.GUIMeta.RewardProbActualRight.Style = 'text';
  
    TaskParameters.GUIPanels.Reward = {'RewardAmount','ExpressedAsExpectedValue','RiskType',...
                                       'RewardProbLeft','RewardProbRight','BlockLenMin',...
                                       'BlockLenMax','BlockLen','NextBlockTrialNumber',...
                                       'RewardProbMax','RewardProbMin','ToneRiskTable',...
                                       'RewardProbActualLeft','RewardProbActualRight',};
    
    %% Photometry
    %photometry general
    TaskParameters.GUI.Photometry = 0;
    TaskParameters.GUIMeta.Photometry.Style = 'checkbox';
    
    TaskParameters.GUI.DbleFibers = 0;
    TaskParameters.GUIMeta.DbleFibers.Style = 'checkbox';
    TaskParameters.GUIMeta.DbleFibers.String = 'Auto';
    
    TaskParameters.GUI.Isobestic405 = 0;
    TaskParameters.GUIMeta.Isobestic405.Style = 'checkbox';
    TaskParameters.GUIMeta.Isobestic405.String = 'Auto';
    
    TaskParameters.GUI.RedChannel = 1;
    TaskParameters.GUIMeta.RedChannel.Style = 'checkbox';
    TaskParameters.GUIMeta.RedChannel.String = 'Auto';
    
    TaskParameters.GUIPanels.PhotometryRecording = {'Photometry','DbleFibers','Isobestic405','RedChannel'};
    
    %plot photometry
    TaskParameters.GUI.TimeMin = -1;
    TaskParameters.GUI.TimeMax = 15;
    TaskParameters.GUI.NidaqMin = -5;
    TaskParameters.GUI.NidaqMax = 10;
    TaskParameters.GUI.SidePokeIn = 1;
	TaskParameters.GUIMeta.SidePokeIn.Style = 'checkbox';
    
    TaskParameters.GUI.SidePokeLeave = 1;
	TaskParameters.GUIMeta.SidePokeLeave.Style = 'checkbox';
    
    TaskParameters.GUI.RewardDelivery = 1;
	TaskParameters.GUIMeta.RewardDelivery.Style = 'checkbox';
    
    TaskParameters.GUI.RandomRewardDelivery = 1;
	TaskParameters.GUIMeta.RandomRewardDelivery.Style = 'checkbox';
    
    TaskParameters.GUI.BaselineBegin = 0.5;
    TaskParameters.GUI.BaselineEnd = 1.8;
    TaskParameters.GUIPanels.PhotometryPlot = {'TimeMin','TimeMax','NidaqMin','NidaqMax',...
                                               'SidePokeIn','SidePokeLeave','RewardDelivery',...
                                               'RandomRewardDelivery', 'BaselineBegin','BaselineEnd'};
    
    %% Nidaq and Photometry
    TaskParameters.GUI.PhotometryVersion = 1;
    TaskParameters.GUI.Modulation = 1;
    TaskParameters.GUIMeta.Modulation.Style = 'checkbox';
    TaskParameters.GUIMeta.Modulation.String = 'Auto';
    
	TaskParameters.GUI.NidaqDuration = 4;
    TaskParameters.GUI.NidaqSamplingRate = 6100;
    TaskParameters.GUI.DecimateFactor = 610;
    
    TaskParameters.GUI.LED1_Name = 'Fiber1 470-A1';
    TaskParameters.GUIMeta.LED1_Name.Style = 'edittext';
    TaskParameters.GUI.LED1_Amp = 1;
    TaskParameters.GUI.LED1_Freq = 211;
    
    TaskParameters.GUI.LED2_Name = 'Fiber1 405 / 565';
    TaskParameters.GUIMeta.LED2_Name.Style = 'edittext';
    TaskParameters.GUI.LED2_Amp = 5;
    TaskParameters.GUI.LED2_Freq = 531;
    
    TaskParameters.GUI.LED1b_Name = 'Fiber2 470-mPFC';
    TaskParameters.GUIMeta.LED1b_Name.Style = 'edittext';
    TaskParameters.GUI.LED1b_Amp = 2;
    TaskParameters.GUI.LED1b_Freq = 531;

    TaskParameters.GUIPanels.PhotometryNidaq={'PhotometryVersion','Modulation','NidaqDuration',...
                            'NidaqSamplingRate','DecimateFactor',...
                            'LED1_Name','LED1_Amp','LED1_Freq',...
                            'LED2_Name','LED2_Amp','LED2_Freq',...
                            'LED1b_Name','LED1b_Amp','LED1b_Freq'};
                        
    %% rig-specific
    TaskParameters.GUI.nidaqDev = 'Dev2';
    TaskParameters.GUIMeta.nidaqDev.Style = 'edittext';

    TaskParameters.GUIPanels.PhotometryRig = {'nidaqDev'};
    
    TaskParameters.GUITabs.General = {'General','Sampling','Reward','FeedbackDelay'};
    TaskParameters.GUITabs.Photometry = {'PhotometryRecording','PhotometryNidaq','PhotometryPlot','PhotometryRig'};
       
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    TaskParameters.Figures.OutcomePlot.Position = [100, 100, 1000, 800];
end
BpodParameterGUI('init', TaskParameters);

end  % End function