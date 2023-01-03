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

%% Sound Output action
StimStart2Output = {};
StimStopOutput = {};
Incorrect_Action = {};
if ~BpodSystem.EmulatorMode
    if TaskParameters.GUI.PlayStimulus == 2 %click
        SamplingAction = {'WavePlayer1', ['P' 3]}; %play the 4th profile 'HiFi1', ['P' 0]
    % elseif TaskParameters.GUI.PlayStimulus == 3 %freq
    %     StimStartOutput = {};
    %     StimStopOutput = {};
    %     StimStart2Output = {};
    end

    if TaskParameters.GUI.EarlyWithdrawalNoise
        EarlyWithdrawalAction = {'WavePlayer1', ['P' 0]}; %play the 1st profile
    end
    
    if TaskParameters.GUI.LightGuided
        Incorrect_Action = {'WavePlayer1', ['P' 4]};
    end
end

%% light guided task
if TaskParameters.GUI.LightGuided 
    if TrialData.LightLeft(iTrial)
        RightLight = 0;
    elseif ~TrialData.LightLeft(iTrial)
        LeftLight = 0;
    else
        error('Light guided state matrix error');
    end
end

%% reward available?
% The followings variables are state names
RightWaitAction = 'Incorrect_Choice';
LeftWaitAction = 'Incorrect_Choice';

DelayTime = 30;
if TrialData.RewardAvailable(iTrial)
    DelayTime = TrialData.RewardDelay(iTrial);
    
    if TaskParameters.GUI.LightGuided && TaskParameters.GUI.RandomReward %dummy state added for plotting
            if TrialData.LightLeft(iTrial)
                LeftWaitAction = 'RandomReward_water_L';
            elseif ~TrialData.LightLeft(iTrial)
                RightWaitAction = 'RandomReward_water_R';
            end
    elseif TaskParameters.GUI.LightGuided && ~TaskParameters.GUI.RandomReward
            if TrialData.LightLeft(iTrial)
                LeftWaitAction = 'water_L';
            elseif ~TrialData.LightLeft(iTrial)
                RightWaitAction = 'water_R';
            end
    elseif ~TaskParameters.GUI.LightGuided && TaskParameters.GUI.RandomReward
        LeftWaitAction = 'RandomReward_water_L';
        RightWaitAction = 'RandomReward_water_R';
    elseif ~TaskParameters.GUI.LightGuided && ~TaskParameters.GUI.RandomReward
        LeftWaitAction = 'water_L';
        RightWaitAction = 'water_R';
    end
end

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
sma = AddState(sma, 'Name', 'BrokeFixation',...
    'Timer', TaskParameters.GUI.BrokeFixationTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', BrokeFixationAction);

SamplingAction = {};
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

LInStateChange = 'StartLIn';
LeftLightValue = 255;

RInStateChange = 'StartRIn';
RightLightValue = 255;

sma = AddState(sma, 'Name', 'WaitSIn',...
    'Timer', TaskParameters.GUI.ChoiceDeadline,...
    'StateChangeConditions', {'GlobalTimer2_End', 'NoDecision', CenterPortIn, CInStateChange,...
                              LeftPortIn, LInStateChange, RightPortIn, RInStateChange},...
    'OutputActions', {LeftLight, LeftLightValue,...
                      RightLight, RightLightValue...
                      CenterLight, CenterLightValue});
                  
%%
NoDecisionAction = {};
sma = AddState(sma, 'Name', 'NoDecision',...
    'Timer', TaskParameters.GUI.NoDecisionTimeOut,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', NoDecisionAction);

sma = AddState(sma, 'Name', 'StartNewTrial',...
    'Timer', TaskParameters.GUI.StartNewTrialHoldingTime,...
    'StateChangeConditions', {'Tup', 'StartNewTrialTimeOut', CenterPortOut, 'WaitSIn'},... %'GlobalTimer2_End', 'NoDecision'!?
    'OutputActions', {CenterLight, 255});

StartNewTrialAction = {};
sma = AddState(sma, 'Name', 'StartNewTrialTimOut',...
    'Timer', TaskParameters.GUI.StartNewTrialTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', StartNewTrialAction);

IncorrectChoiceAction = {};
sma = AddState(sma, 'Name', 'IncorrectChoice',...
    'Timer', TaskParameters.GUI.IncorrcetChoiceTimeOut,...
    'StateChangeConditions', {'Tup', 'ITI'},...
    'OutputActions', IncorrectChoiceAction);

%%
FeedbackDelay = 30;
sma = SetGlobalTimer(sma, 3, FeedbackDelay); % used to track side poke grace period
sma = AddState(sma, 'Name', 'StartLIn',... % dummy state for trigger GlobalTimer3
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'LIn'},...
    'OutputActions',{'GlobalTimerTrig', 3, LeftLight, 255});

sma = AddState(sma, 'Name', 'LIn',...
    'Timer', FeedbackDelay,...
    'StateChangeConditions', {'GlobalTimer3_End', WaterL, LeftPortOut,'LInGrace'},...
    'OutputActions', {LeftLight, 255});

sma = AddState(sma, 'Name', 'WaterL',...
    'Timer', LeftValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', LeftValve});

sma = AddState(sma, 'Name', 'LInGrace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions', {LeftPortIn, 'LIn', 'Tup', 'SkippedFeedback',...
                              'GlobalTimer3_End', 'SkippedFeedback',...
                              CenterPortIn, 'SkippedFeedback', RightPortIn, 'SkippedFeedback'},...
    'OutputActions', {LeftLight, 255});

sma = AddState(sma, 'Name', 'StartRIn',... % dummy state for trigger GlobalTimer3
    'Timer', 0,...
    'StateChangeConditions', {'Tup', 'RIn'},...
    'OutputActions',{'GlobalTimerTrig', 3, RightLight, 255});

sma = AddState(sma, 'Name', 'RIn',...
    'Timer', FeedbackDelay,...
    'StateChangeConditions', {'GlobalTimer3_End', WaterR, RightPortOut,'RInGrace'},...
    'OutputActions', {RightLight, 255});

sma = AddState(sma, 'Name', 'WaterR',...
    'Timer', RightValveTime,...
    'StateChangeConditions', {'Tup','ITI'},...
    'OutputActions', {'ValveState', RightValve});

sma = AddState(sma, 'Name', 'RInGrace',...
    'Timer', TaskParameters.GUI.FeedbackDelayGrace,...
    'StateChangeConditions', {RightPortIn, 'RIn', 'Tup', 'SkippedFeedback',...
                              'GlobalTimer3_End', 'SkippedFeedback',...
                              CenterPortIn, 'SkippedFeedback', LeftPortIn, 'SkippedFeedback'},...
    'OutputActions', {RightLight, 255});

SkippedFeedbackAction = {};
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
