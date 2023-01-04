function sma = StateMatrix(iTrial)

global BpodSystem
global TaskParameters

TrialData = BpodSystem.Data.Custom.TrialData;

%% Define ports
LeftPort = floor(mod(TaskParameters.GUI.Ports_LMR/100,10));
CenterPort = floor(mod(TaskParameters.GUI.Ports_LMR/10,10));
RightPort = mod(TaskParameters.GUI.Ports_LMR,10);

LeftPortOut = strcat('Port',num2str(LeftPort),'Out');
CenterPortOut = strcat('Port',num2str(CenterPort),'Out');
RightPortOut = strcat('Port',num2str(RightPort),'Out');

LeftPortIn = strcat('Port',num2str(LeftPort),'In');
CenterPortIn = strcat('Port',num2str(CenterPort),'In');
RightPortIn = strcat('Port', num2str(RightPort),'In');

LeftLight = strcat('PWM',num2str(LeftPort));
CenterLight = strcat('PWM',num2str(CenterPort));
RightLight = strcat('PWM',num2str(RightPort));

LeftValve = 2^(LeftPort-1);
CenterValve = 2^(CenterPort-1);
RightValve = 2^(RightPort-1);

%% Calculate value time for ports in different situations
LeftValveTime  = GetValveTimes(TrialData.RewardMagnitude(iTrial,1), LeftPort);
RightValveTime  = GetValveTimes(TrialData.RewardMagnitude(iTrial,2), RightPort);

%% Set up state matrix    
sma = NewStateMatrix();

PreITIAction = {};
sma = AddState(sma, 'Name', 'PreITI',...
    'Timer', TaskParameters.GUI.PreITI,...
    'StateChangeConditions', {'Tup', 'WaitCIn'},...
    'OutputActions', PreITIAction);

sma = AddState(sma, 'Name', 'WaitCIn',...
    'Timer', TaskParameters.GUI.WaitCInMax,...
    'StateChangeConditions', {CenterPortIn, 'StartCIn', 'Tup', 'ITI'},...
    'OutputActions', {CenterLight, 255});

sma = SetGlobalTimer(sma, 1, TaskParameters.GUI.StimulusTime + TaskParameters.GUI.StimDelay); % used to track centre poke grace period
sma = AddState(sma, 'Name', 'StartCIn',... % dummy state for trigger GlobalTimer1
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'StimulusDelay'},...
    'OutputActions', {'GlobalTimerTrig', 1, CenterLight, 255});

sma = AddState(sma, 'Name', 'StimulusDelay',...
    'Timer', TaskParameters.GUI.StimDelay,...
    'StateChangeConditions', {'Tup', 'Sampling', CenterPortOut, 'BrokeFixation'},...
    'OutputActions', {CenterLight, 255});

BrokeFixationAction = {};
switch TaskParameters.GUIMeta.BrokeFixationFeedbackType.String{TaskParameters.GUI.BrokeFixationFeedbackType}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            BrokeFixationAction = {'HiFi1', ['P' 0]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            BrokeFixationAction = {'WavePlayer1', ['P' 0]};
        elseif BpodSystem.EmulatorMode
            BrokeFixationAction = {};
        else
            error('Error: To run this protocol, you must first pair either a HiFi or analog module with its USB port. Click the USB config button on the Bpod console.')
        end
        
end
sma = AddState(sma, 'Name', 'BrokeFixation',...
    'Timer', TaskParameters.GUI.BrokeFixationTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', BrokeFixationAction);

SamplingAction = {};
switch TaskParameters.GUIMeta.PlayStimulus.String{TaskParameters.GUI.PlayStimulus}
    case 'None' % no adjustmnet needed
        
    case 'Freq'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            SamplingAction = {'HiFi1', ['P' 1]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            SamplingAction = {'WavePlayer1', ['P' 1]};
        elseif BpodSystem.EmulatorMode
            SamplingAction = {};
        else
            error('Error: To run this protocol, you must first pair either a HiFi or analog module with its USB port. Click the USB config button on the Bpod console.')
        end
        
end
sma = AddState(sma, 'Name', 'Sampling',...
    'Timer', TaskParameters.GUI.StimulusTime,...
    'StateChangeConditions', {CenterPortOut, 'SamplingGrace', 'GlobalTimer1_End', 'StillSampling'},...
    'OutputActions', [SamplingAction {CenterLight, 255}]);

sma = AddState(sma, 'Name', 'SamplingGrace',...
    'Timer', TaskParameters.GUI.SamplingGrace,...
    'StateChangeConditions', {CenterPortIn, 'Sampling', 'Tup', 'EarlyWithdrawal',...
                              'GlobalTimer1_End', 'EarlyWithdrawal', LeftPortIn, 'EarlyWithdrawal',...
                              RightPortIn, 'EarlyWithdrawal'},...
    'OutputActions', {CenterLight, 255});

EarlyWithdrawalAction = {};
switch TaskParameters.GUIMeta.EarlyWithdrawalFeedbackType.String{TaskParameters.GUI.EarlyWithdrawalFeedbackType}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            EarlyWithdrawalAction = {'HiFi1', ['P' 2]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            EarlyWithdrawalAction = {'WavePlayer1', ['P' 2]};
        elseif BpodSystem.EmulatorMode
            EarlyWithdrawalAction = {};
        else
            error('Error: To run this protocol, you must first pair either a HiFi or analog module with its USB port. Click the USB config button on the Bpod console.')
        end
        
end
sma = AddState(sma, 'Name', 'EarlyWithdrawal',...
    'Timer', TaskParameters.GUI.EarlyWithdrawalTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', EarlyWithdrawalAction);

sma = SetGlobalTimer(sma, 2, TaskParameters.GUI.ChoiceDeadline); % used to track side poke grace period
sma = AddState(sma, 'Name', 'StillSampling',... % dummy state for trigger GlobalTimer2
    'Timer', TaskParameters.GUI.ChoiceDeadline,...
    'StateChangeConditions', {CenterPortOut, 'WaitSIn', 'GlobalTimer2_End', 'NoDecision'},...
    'OutputActions', {'GlobalTimerTrig', 2});
%%
CInStateChange = 'WaitSIn';
CenterLightValue = 0;
if TaskParameters.GUI.StartNewTrial
    CInStateChange = 'StartNewTrial';
    CenterLightValue = 255;
end

LeftLightValue = 255;
RightLightValue = 255;
if TrialData.LightLeft == true
    RightLightValue = 0;
elseif TrialData.LightLeft == false
    LeftLightValue = 0;
end

sma = AddState(sma, 'Name', 'WaitSIn',...
    'Timer', TaskParameters.GUI.ChoiceDeadline,...
    'StateChangeConditions', {'GlobalTimer2_End', 'NoDecision', CenterPortIn, CInStateChange,...
                              LeftPortIn, 'StartLIn', RightPortIn, 'StartRIn'},...
    'OutputActions', {LeftLight, LeftLightValue,...
                      RightLight, RightLightValue...
                      CenterLight, CenterLightValue});
                  
%%
NoDecisionAction = {};
switch TaskParameters.GUIMeta.NoDecisionFeedbackType.String{TaskParameters.GUI.NoDecisionFeedbackType}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            NoDecisionAction = {'HiFi1', ['P' 3]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            NoDecisionAction = {'WavePlayer1', ['P' 3]};
        elseif BpodSystem.EmulatorMode
            NoDecisionAction = {};
        else
            error('Error: To run this protocol, you must first pair either a HiFi or analog module with its USB port. Click the USB config button on the Bpod console.')
        end
        
end
sma = AddState(sma, 'Name', 'NoDecision',...
    'Timer', TaskParameters.GUI.NoDecisionTimeOut,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', NoDecisionAction);

sma = AddState(sma, 'Name', 'StartNewTrial',...
    'Timer', TaskParameters.GUI.StartNewTrialHoldingTime,...
    'StateChangeConditions', {'Tup', 'StartNewTrialTimeOut', CenterPortOut, 'WaitSIn'},... %'GlobalTimer2_End', 'NoDecision'!?
    'OutputActions', {CenterLight, 255});

StartNewTrialAction = {};
switch TaskParameters.GUIMeta.StartNewTrialFeedbackType.String{TaskParameters.GUI.StartNewTrialFeedbackType}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            StartNewTrialAction = {'HiFi1', ['P' 4]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            StartNewTrialAction = {'WavePlayer1', ['P' 4]};
        elseif BpodSystem.EmulatorMode
            StartNewTrialAction = {};
        else
            error('Error: To run this protocol, you must first pair either a HiFi or analog module with its USB port. Click the USB config button on the Bpod console.')
        end
        
end
sma = AddState(sma, 'Name', 'StartNewTrialTimOut',...
    'Timer', TaskParameters.GUI.StartNewTrialTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', StartNewTrialAction);

%%
FeedbackDelay = TrialData.FeedbackDelay(iTrial);
if TrialData.CatchTrial(iTrial)
    FeedbackDelay = 20; % hard-code?
end
sma = SetGlobalTimer(sma, 3, FeedbackDelay); % used to track side poke grace period
sma = AddState(sma, 'Name', 'StartLIn',... % dummy state for trigger GlobalTimer3
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'LIn'},...
    'OutputActions',{'GlobalTimerTrig', 3, LeftLight, LeftLightValue});

LInStateChange = 'WaterL';
if TrialData.LightLeft == false
    LInStateChange = 'IncorrectChoice';
end
sma = AddState(sma, 'Name', 'LIn',...
    'Timer', FeedbackDelay,...
    'StateChangeConditions', {'GlobalTimer3_End', LInStateChange, LeftPortOut,'LInGrace'},...
    'OutputActions', {LeftLight, LeftLightValue});

sma = AddState(sma, 'Name', 'WaterL',...
    'Timer', LeftValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', LeftValve});

sma = AddState(sma, 'Name', 'LInGrace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions', {LeftPortIn, 'LIn', 'Tup', 'SkippedFeedback',...
                              'GlobalTimer3_End', 'SkippedFeedback',...
                              CenterPortIn, 'SkippedFeedback', RightPortIn, 'SkippedFeedback'},...
    'OutputActions', {LeftLight, LeftLightValue});

sma = AddState(sma, 'Name', 'StartRIn',... % dummy state for trigger GlobalTimer3
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'RIn'},...
    'OutputActions',{'GlobalTimerTrig', 3, RightLight, RightLightValue});

RInStateChange = 'WaterR';
if TrialData.LightLeft == true
    RInStateChange = 'IncorrectChoice';
end
sma = AddState(sma, 'Name', 'RIn',...
    'Timer', FeedbackDelay,...
    'StateChangeConditions', {'GlobalTimer3_End', RInStateChange, RightPortOut,'RInGrace'},...
    'OutputActions', {RightLight, RightLightValue});

sma = AddState(sma, 'Name', 'WaterR',...
    'Timer', RightValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', RightValve});

sma = AddState(sma, 'Name', 'RInGrace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions', {RightPortIn, 'RIn', 'Tup', 'SkippedFeedback',...
                              'GlobalTimer3_End', 'SkippedFeedback',...
                              CenterPortIn, 'SkippedFeedback', LeftPortIn, 'SkippedFeedback'},...
    'OutputActions', {RightLight, RightLightValue});

IncorrectChoiceAction = {};
switch TaskParameters.GUIMeta.IncorrectChoiceFeedbackType.String{TaskParameters.GUI.IncorrectChoiceFeedbackType}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            IncorrectChoiceAction = {'HiFi1', ['P' 5]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            IncorrectChoiceAction = {'WavePlayer1', ['P' 5]};
        elseif BpodSystem.EmulatorMode
            IncorrectChoiceAction = {};
        else
            error('Error: To run this protocol, you must first pair either a HiFi or analog module with its USB port. Click the USB config button on the Bpod console.')
        end
        
end
sma = AddState(sma, 'Name', 'IncorrectChoice',...
    'Timer', TaskParameters.GUI.IncorrcetChoiceTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', IncorrectChoiceAction);

SkippedFeedbackAction = {};
switch TaskParameters.GUIMeta.SkippedFeedbackFeedbackType.String{TaskParameters.GUI.SkippedFeedbackFeedbackType}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            SkippedFeedbackAction = {'HiFi1', ['P' 6]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            SkippedFeedbackAction = {'WavePlayer1', ['P' 6]};
        elseif BpodSystem.EmulatorMode
            SkippedFeedbackAction = {};
        else
            error('Error: To run this protocol, you must first pair either a HiFi or analog module with its USB port. Click the USB config button on the Bpod console.')
        end
        
end
sma = AddState(sma, 'Name', 'SkippedFeedback',...
    'Timer', TaskParameters.GUI.SkippedFeedbackTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', SkippedFeedbackAction);

ITITimer = TaskParameters.GUI.ITI;
if TaskParameters.GUI.VI
    ITITimer = exprnd(TaskParameters.GUI.ITI);
end
sma = AddState(sma, 'Name', 'ITI',...
    'Timer', ITITimer,...
    'StateChangeConditions',{'Tup', 'exit'},...
    'OutputActions',{});

end % StateMatrix
