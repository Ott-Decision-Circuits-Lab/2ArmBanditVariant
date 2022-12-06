function TaskParameters = GUISetup()

global BpodSystem

%% Task parameters
TaskParameters = BpodSystem.ProtocolSettings;

if isempty(fieldnames(TaskParameters))
    % general
    TaskParameters.GUI.SessionDescription = 'First 2ArmBandit';
    TaskParameters.GUIMeta.SessionDescription.Style = 'edittext';
    TaskParameters.GUI.Ports_LMR = '123';
    TaskParameters.GUI.PreITI = 1.5; % before wait_Cin
    TaskParameters.GUI.CenterWaitMax = 20;
    TaskParameters.GUI.FI = 0.5; % end of trial ITI
    TaskParameters.GUI.VI = false; % exprnd based on FI
    TaskParameters.GUIMeta.VI.Style = 'checkbox';
    TaskParameters.GUI.DrinkingTime=0.3;
    TaskParameters.GUI.DrinkingGrace=0.05;
    TaskParameters.GUI.ChoiceDeadline = 10;
    TaskParameters.GUI.LightGuided = 1;
    TaskParameters.GUIMeta.LightGuided.Style = 'checkbox';
    TaskParameters.GUIPanels.General = {'SessionDescription','Ports_LMR','PreITI','CenterWaitMax','FI', 'VI',...
        'DrinkingTime','DrinkingGrace','ChoiceDeadline','LightGuided'};
    
    %"stimulus"
    TaskParameters.GUI.PlayStimulus = 1;
    TaskParameters.GUIMeta.PlayStimulus.Style = 'popupmenu';
    TaskParameters.GUIMeta.PlayStimulus.String = {'No stim.','Freq. stim.'};
    TaskParameters.GUI.MinSampleTime = 0.01;
    TaskParameters.GUI.MaxSampleTime = 0.6;
    TaskParameters.GUI.AutoIncrSample = true;
    TaskParameters.GUIMeta.AutoIncrSample.Style = 'checkbox';
    TaskParameters.GUI.MinSampleIncr = 0.01;
    TaskParameters.GUI.MinSampleDecr = 0.005;
    TaskParameters.GUI.EarlyWithdrawalTimeOut = 3;
    TaskParameters.GUI.EarlyWithdrawalNoise = true;
    TaskParameters.GUIMeta.EarlyWithdrawalNoise.Style='checkbox';
    TaskParameters.GUI.GracePeriod = 0;
    TaskParameters.GUI.SampleTime = TaskParameters.GUI.MinSampleTime;
    TaskParameters.GUIMeta.SampleTime.Style = 'text';
    TaskParameters.GUIPanels.Sampling = {'PlayStimulus','MinSampleTime','MaxSampleTime','AutoIncrSample','MinSampleIncr','MinSampleDecr','EarlyWithdrawalTimeOut','EarlyWithdrawalNoise','GracePeriod','SampleTime'};
    
    % FeedbackDelay, original named "Side Ports" ("waiting for feedback")
    % TaskParameters.GUI.EarlySoutPenalty = 0;
    TaskParameters.GUI.FeedbackDelaySelection = 1;
    TaskParameters.GUIMeta.FeedbackDelaySelection.Style = 'popupmenu';
    TaskParameters.GUIMeta.FeedbackDelaySelection.String = {'Fix','AutoIncr','TruncExp','Uniform'};
    TaskParameters.GUI.FeedbackDelayMin = 0;
    TaskParameters.GUI.FeedbackDelayMax = 0;
    TaskParameters.GUI.FeedbackDelayIncr = 0.01;
    TaskParameters.GUI.FeedbackDelayDecr = 0.01;
    TaskParameters.GUI.FeedbackDelayTau = 0.05;
    TaskParameters.GUI.FeedbackDelay = TaskParameters.GUI.FeedbackDelayMin;
    TaskParameters.GUIMeta.FeedbackDelay.Style = 'text';
    TaskParameters.GUI.FeedbackDelayGrace = 0;
    TaskParameters.GUI.CatchError = false; % random ITI
    TaskParameters.GUIMeta.CatchError.Style = 'checkbox';
    
    TaskParameters.GUI.IncorrectChoiceFeedbackType = 2;
    TaskParameters.GUIMeta.IncorrectChoiceFeedbackType.Style = 'popupmenu';
    TaskParameters.GUIMeta.IncorrectChoiceFeedbackType.String = {'None','Tone','PortLED'};
    TaskParameters.GUI.SkippedFeedbackFeedbackType = 2;
    TaskParameters.GUIMeta.SkippedFeedbackFeedbackType.Style = 'popupmenu';
    TaskParameters.GUIMeta.SkippedFeedbackFeedbackType.String = {'None','Tone','PortLED'};    
    TaskParameters.GUIPanels.FeedbackDelay = {'EarlySoutPenalty','FeedbackDelaySelection','FeedbackDelayMin',...
                                          'FeedbackDelayMax','FeedbackDelayIncr','FeedbackDelayDecr','FeedbackDelayTau',...
                                          'FeedbackDelay','FeedbackDelayGrace','CatchError',...
                                          'IncorrectChoiceFeddbackType','SkippedFeedbackFeedbackType'};
                                      
    %Reward and RewardProb
    TaskParameters.GUI.RewardAmount = 30;
%     TaskParameters.GUI.CenterPortRewAmount = 10;
%     TaskParameters.GUI.CenterPortProb = 0.8;
    TaskParameters.GUI.RewardProbType = 1;
    TaskParameters.GUIMeta.RewardProbType.Style = 'popupmenu';
    TaskParameters.GUIMeta.RewardProbType.String = {'Fix','Block','Cued','ExpectedValue'};
    
    TaskParameters.GUI.BlockLenMin = 100;
    TaskParameters.GUI.BlockLenMax = 150;
    TaskParameters.GUI.BlockLen = TaskParameters.GUI.BlockLenMin;
    TaskParameters.GUIMeta.BlockLen.Style = 'text';
    TaskParameters.GUI.NextBlockTrialNumber = TaskParameters.GUI.BlockLen;
    TaskParameters.GUIMeta.BlockLen.Style = 'text';
    
    TaskParameters.GUI.ToneRiskTable.ToneStartFreq = [1 2 5 10 20 40]; % in kHz
    TaskParameters.GUI.ToneRiskTable.ToneEndFreq = [1 2 5 10 20 40]; % features for sweep
    TaskParameters.GUI.ToneRiskTable.ToneCuedRewardProbability = [30, 40, 50, 60, 70, 80]';
    TaskParameters.GUIMeta.ToneRiskTable.Style = 'table';
    TaskParameters.GUIMeta.ToneRiskTable.String = 'Tone cued reward probability';
    TaskParameters.GUIMeta.ToneRiskTable.ColumnLabel = {'StartFreq','EndFreq','RewardProbability'};
    
    TaskParameters.GUI.RewardProbMax =  100; % 0-100% Highest reward probability
    TaskParameters.GUI.RewardProbMin =  30; % 0-100% Lowest reward probability
    TaskParameters.GUI.RewardProb = TaskParameters.GUI.RewardProbMax;
    TaskParameters.GUIMeta.RewardProb.Style = 'text';

    TaskParameters.GUIPanels.Reward = {'RewardAmount','RewardProbType','BlockLenMin',...
                                       'BlockLenMax','BlockLen','NextBlockTrialNumber',...
                                       'ToneRiskTable','RewardProbMax','RewardProbMin',...
                                       'RewardProb'};
    
    %% Photometry
    %photometry general
    TaskParameters.GUI.Photometry=0;
    TaskParameters.GUIMeta.Photometry.Style='checkbox';
    TaskParameters.GUI.DbleFibers=0;
    TaskParameters.GUIMeta.DbleFibers.Style='checkbox';
    TaskParameters.GUIMeta.DbleFibers.String='Auto';
    TaskParameters.GUI.Isobestic405=0;
    TaskParameters.GUIMeta.Isobestic405.Style='checkbox';
    TaskParameters.GUIMeta.Isobestic405.String='Auto';
    TaskParameters.GUI.RedChannel=1;
    TaskParameters.GUIMeta.RedChannel.Style='checkbox';
    TaskParameters.GUIMeta.RedChannel.String='Auto';    
    TaskParameters.GUIPanels.PhotometryRecording={'Photometry','DbleFibers','Isobestic405','RedChannel'};
    
    %plot photometry
    TaskParameters.GUI.TimeMin=-1;
    TaskParameters.GUI.TimeMax=15;
    TaskParameters.GUI.NidaqMin=-5;
    TaskParameters.GUI.NidaqMax=10;
    TaskParameters.GUI.SidePokeIn=1;
	TaskParameters.GUIMeta.SidePokeIn.Style='checkbox';
    TaskParameters.GUI.SidePokeLeave=1;
	TaskParameters.GUIMeta.SidePokeLeave.Style='checkbox';
    TaskParameters.GUI.RewardDelivery=1;
	TaskParameters.GUIMeta.RewardDelivery.Style='checkbox';
    
    TaskParameters.GUI.RandomRewardDelivery=1;
	TaskParameters.GUIMeta.RandomRewardDelivery.Style='checkbox';
    
    TaskParameters.GUI.BaselineBegin=0.5;
    TaskParameters.GUI.BaselineEnd=1.8;
    TaskParameters.GUIPanels.PhotometryPlot={'TimeMin','TimeMax','NidaqMin','NidaqMax','SidePokeIn','SidePokeLeave','RewardDelivery',...
        'RandomRewardDelivery', 'BaselineBegin','BaselineEnd'};
    
    %% Nidaq and Photometry
    TaskParameters.GUI.PhotometryVersion=1;
    TaskParameters.GUI.Modulation=1;
    TaskParameters.GUIMeta.Modulation.Style='checkbox';
    TaskParameters.GUIMeta.Modulation.String='Auto';
	TaskParameters.GUI.NidaqDuration=4;
    TaskParameters.GUI.NidaqSamplingRate=6100;
    TaskParameters.GUI.DecimateFactor=610;
    TaskParameters.GUI.LED1_Name='Fiber1 470-A1';
    TaskParameters.GUIMeta.LED1_Name.Style='edittext';
    TaskParameters.GUI.LED1_Amp=1;
    TaskParameters.GUI.LED1_Freq=211;
    TaskParameters.GUI.LED2_Name='Fiber1 405 / 565';
    TaskParameters.GUIMeta.LED2_Name.Style='edittext';
    TaskParameters.GUI.LED2_Amp=5;
    TaskParameters.GUI.LED2_Freq=531;
    TaskParameters.GUI.LED1b_Name='Fiber2 470-mPFC';
    TaskParameters.GUIMeta.LED1b_Name.Style='edittext';
    TaskParameters.GUI.LED1b_Amp=2;
    TaskParameters.GUI.LED1b_Freq=531;

    TaskParameters.GUIPanels.PhotometryNidaq={'PhotometryVersion','Modulation','NidaqDuration',...
                            'NidaqSamplingRate','DecimateFactor',...
                            'LED1_Name','LED1_Amp','LED1_Freq',...
                            'LED2_Name','LED2_Amp','LED2_Freq',...
                            'LED1b_Name','LED1b_Amp','LED1b_Freq'};
                        
    %% rig-specific
    TaskParameters.GUI.nidaqDev='Dev2';
    TaskParameters.GUIMeta.nidaqDev.Style='edittext';

    TaskParameters.GUIPanels.PhotometryRig={'nidaqDev'};
    
    TaskParameters.GUITabs.General = {'General','Sampling','Reward','FeedbackDelay'};
    TaskParameters.GUITabs.Photometry = {'PhotometryRecording','PhotometryNidaq','PhotometryPlot','PhotometryRig'};
       
    TaskParameters.GUI = orderfields(TaskParameters.GUI);
    TaskParameters.Figures.OutcomePlot.Position = [200, 200, 1000, 400];
end
BpodParameterGUI('init', TaskParameters);

end  % End function