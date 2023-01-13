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
LeftValveTime  = GetValveTimes(TrialData.RewardMagnitude(1,iTrial), LeftPort);
RightValveTime  = GetValveTimes(TrialData.RewardMagnitude(2,iTrial), RightPort);

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
    'StateChangeConditions', {'Tup', 'StimulusDelay', 'GlobalTimer1_End', 'StillSampling'},...
    'OutputActions', {'GlobalTimerTrig', 1, CenterLight, 255});

sma = AddState(sma, 'Name', 'StimulusDelay',...
    'Timer', TaskParameters.GUI.StimDelay,...
    'StateChangeConditions', {'Tup', 'Sampling', CenterPortOut, 'BrokeFixation', 'GlobalTimer1_End', 'StillSampling'},...
    'OutputActions', {CenterLight, 255});

BrokeFixationAction = {};
switch TaskParameters.GUIMeta.BrokeFixationFeedback.String{TaskParameters.GUI.BrokeFixationFeedback}
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
switch TaskParameters.GUIMeta.RiskType.String{TaskParameters.GUI.RiskType}
    case 'Fix' % no adjustmnet needed
    case 'BlockRand' % no adjustmnet needed
    case 'BlockFix' % no adjustmnet needed
    case 'Cued'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            SamplingAction = {'HiFi1', ['P' 6]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            SamplingAction = {'WavePlayer1', ['P' 6]};
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
switch TaskParameters.GUIMeta.EarlyWithdrawalFeedback.String{TaskParameters.GUI.EarlyWithdrawalFeedback}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            EarlyWithdrawalAction = {'HiFi1', ['P' 1]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            EarlyWithdrawalAction = {'WavePlayer1', ['P' 1]};
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
if TrialData.LightLeft(iTrial) == true
    RightLightValue = 0;
elseif TrialData.LightLeft(iTrial) == false
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
switch TaskParameters.GUIMeta.NoDecisionFeedback.String{TaskParameters.GUI.NoDecisionFeedback}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            NoDecisionAction = {'HiFi1', ['P' 2]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            NoDecisionAction = {'WavePlayer1', ['P' 2]};
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
switch TaskParameters.GUIMeta.StartNewTrialFeedback.String{TaskParameters.GUI.StartNewTrialFeedback}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            StartNewTrialAction = {'HiFi1', ['P' 3]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            StartNewTrialAction = {'WavePlayer1', ['P' 3]};
        elseif BpodSystem.EmulatorMode
            StartNewTrialAction = {};
        else
            error('Error: To run this protocol, you must first pair either a HiFi or analog module with its USB port. Click the USB config button on the Bpod console.')
        end
        
end
sma = AddState(sma, 'Name', 'StartNewTrialTimeOut',...
    'Timer', TaskParameters.GUI.StartNewTrialTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', StartNewTrialAction);

%%
FeedbackDelayLeft = TrialData.FeedbackDelay(iTrial);
FeedbackDelayRight = TrialData.FeedbackDelay(iTrial);
if TaskParameters.GUI.CatchTrial
    if TrialData.Baited(1, iTrial) == 0
        FeedbackDelayLeft = 30; % Catch 2: Unbaited Trial
    end
    if TrialData.Baited(2, iTrial) == 0
        FeedbackDelayRight = 30; % Catch 2: Unbaited Trial
    end
    
    if TrialData.LightLeft(iTrial) == 1 % Catch 1: incorrect side Trial
        FeedbackDelayRight = 30; % hard-code?
    elseif  TrialData.LightLeft(iTrial) == 0 % only not lighted side adjusted
        FeedbackDelayLeft = 30;
    end
end

sma = SetGlobalTimer(sma, 3, FeedbackDelayLeft); % used to track side poke grace period

LInStateChange = 'WaterL';
if TrialData.LightLeft(iTrial) == false
    LInStateChange = 'IncorrectChoice';
end
sma = AddState(sma, 'Name', 'StartLIn',... % dummy state for trigger GlobalTimer3
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'LIn', 'GlobalTimer3_End', LInStateChange},...
    'OutputActions',{'GlobalTimerTrig', 3, LeftLight, LeftLightValue});

sma = AddState(sma, 'Name', 'LIn',...
    'Timer', FeedbackDelayLeft,...
    'StateChangeConditions', {'GlobalTimer3_End', LInStateChange, LeftPortOut,'LInGrace'},...
    'OutputActions', {LeftLight, LeftLightValue});

WaterLAction = {};
if TrialData.RewardMagnitude(1,iTrial) > 0
    WaterLAction = {'ValveState', LeftValve};
end
sma = AddState(sma, 'Name', 'WaterL',...
    'Timer', LeftValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', WaterLAction);

sma = AddState(sma, 'Name', 'LInGrace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions', {LeftPortIn, 'LIn', 'Tup', 'SkippedFeedback',...
                              'GlobalTimer3_End', 'SkippedFeedback',...
                              CenterPortIn, 'SkippedFeedback', RightPortIn, 'SkippedFeedback'},...
    'OutputActions', {LeftLight, LeftLightValue});

sma = SetGlobalTimer(sma, 4, FeedbackDelayRight); % used to track side poke grace period

RInStateChange = 'WaterR';
if TrialData.LightLeft(iTrial) == true
    RInStateChange = 'IncorrectChoice';
end
sma = AddState(sma, 'Name', 'StartRIn',... % dummy state for trigger GlobalTimer3
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'RIn', 'GlobalTimer3_End', RInStateChange},...
    'OutputActions',{'GlobalTimerTrig', 4, RightLight, RightLightValue});

sma = AddState(sma, 'Name', 'RIn',...
    'Timer', FeedbackDelayRight,...
    'StateChangeConditions', {'GlobalTimer4_End', RInStateChange, RightPortOut,'RInGrace'},...
    'OutputActions', {RightLight, RightLightValue});

WaterRAction = {};
if TrialData.RewardMagnitude(2,iTrial) > 0
    WaterRAction = {'ValveState', RightValve};
end
sma = AddState(sma, 'Name', 'WaterR',...
    'Timer', RightValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', WaterRAction);

sma = AddState(sma, 'Name', 'RInGrace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions', {RightPortIn, 'RIn', 'Tup', 'SkippedFeedback',...
                              'GlobalTimer4_End', 'SkippedFeedback',...
                              CenterPortIn, 'SkippedFeedback', LeftPortIn, 'SkippedFeedback'},...
    'OutputActions', {RightLight, RightLightValue});

IncorrectChoiceAction = {};
switch TaskParameters.GUIMeta.IncorrectChoiceFeedback.String{TaskParameters.GUI.IncorrectChoiceFeedback}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            IncorrectChoiceAction = {'HiFi1', ['P' 4]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            IncorrectChoiceAction = {'WavePlayer1', ['P' 4]};
        elseif BpodSystem.EmulatorMode
            IncorrectChoiceAction = {};
        else
            error('Error: To run this protocol, you must first pair either a HiFi or analog module with its USB port. Click the USB config button on the Bpod console.')
        end
        
end
sma = AddState(sma, 'Name', 'IncorrectChoice',...
    'Timer', TaskParameters.GUI.IncorrectChoiceTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', IncorrectChoiceAction);

SkippedFeedbackAction = {};
switch TaskParameters.GUIMeta.SkippedFeedbackFeedback.String{TaskParameters.GUI.SkippedFeedbackFeedback}
    case 'None' % no adjustmnet needed
        
    case 'WhiteNoise'
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            SkippedFeedbackAction = {'HiFi1', ['P' 5]};
        elseif isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            SkippedFeedbackAction = {'WavePlayer1', ['P' 5]};
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
