function UpdateCustomDataFields(iTrial)

global BpodSystem
global TaskParameters

% data structure references
RawData = BpodSystem.Data.RawData;
RawEvents = BpodSystem.Data.RawEvents;
TrialStates = RawEvents.Trial{iTrial}.States;
TrialData = BpodSystem.Data.Custom.TrialData;

BpodSystem.Data.TrialTypes(iTrial) = 1; %??

%% OutcomeRecord
% Go through the states visited this trial and 
idxStatesVisited = RawData.OriginalStateData{iTrial};
TrialStateNames = RawData.OriginalStateNamesByNumber{iTrial};
StatesThisTrial = TrialStateNames(idxStatesVisited);

%% Pre-stimulus delivery
if any(strcmp('StartCIn',StatesThisTrial))
    TrialData.NoTrialStart(iTrial) = false;
end

if any(strcmp('BrokenFixation',StatesThisTrial))
    TrialData.BrokeFixation(iTrial) = true;
elseif any(strcmp('Sampling',StatesThisTrial))
    TrialData.BrokeFixation(iTrial) = false;
end

%% Peri-stimulus delivery and Pre-decision
% Compute length of SamplingGrace, i.e. Grace Period for Center pokes
if any(strcmp('SamplingGrace', StatesThisTrial))
    RegisteredWithdrawals = TrialStates.SamplingGrace;

    for iExit = 1:size(RegisteredWithdrawals,1) % one may enter SamplingGrace multiple time, i_exit is the number of time
        ExitTime = RegisteredWithdrawals(iExit,1);
        ReturnTime = RegisteredWithdrawals(iExit,2);
        TrialData.SamplingGrace(iExit, iTrial) = (ReturnTime - ExitTime);
    end
end  

if any(strcmp('EarlyWithdrawal',StatesThisTrial))
    TrialData.EarlyWithdrawal(iTrial) = true;
elseif any(strcmp('StillSampling',StatesThisTrial))
    TrialData.EarlyWithdrawal(iTrial) = false;
end

% Get total amount of time spent sampling
if any(strcmp('Sampling',StatesThisTrial)) % Not From StimulusDelay
    SamplingBegin = TrialStates.Sampling(1,1);
    if any(strcmp('StillSampling',StatesThisTrial))
        SamplingEnd = TrialStates.StillSampling(1,2);
    elseif any(strcmp('EarlyWithdrawal',StatesThisTrial))
        SamplingEnd = TrialStates.SamplingGrace(end,end); 
    end
    TrialData.SampleTime(iTrial) = SamplingEnd - SamplingBegin;
end

%% Peri-decision and pre-outcome
if any(strcmp('NoDecision',StatesThisTrial))
    TrialData.NoDecision(iTrial) = true;
elseif any(strcmp('StartNewTrial',StatesThisTrial)) || any(strcmp('StartLIn',StatesThisTrial)) || any(strcmp('StartRIn',StatesThisTrial))
    TrialData.NoDecision(iTrial) = false;
end

if any(strcmp('WaitSIn',StatesThisTrial))
    TrialData.MoveTime(iTrial) = TrialStates.WaitSIn(1,2) - TrialStates.WaitSIn(1,1); % from CenterPortOut to SidePortIn, old MT confirmed
end

% TrialData.StartNewTrialEnabled(iTrial) = TaskParameters.GUI.StartNewTrial; % if false TaskParameters.GUI.StartNewTrial is off;
if any(strcmp('StartNewTrial',StatesThisTrial))
    TrialData.StartNewTrial(iTrial) = true; % only concern state 'StartNewTrialTimeOut'
    TrialData.StartNewTrialSuccessful(iTrial) = false;
elseif any(strcmp('StartLIn',StatesThisTrial)) || any(strcmp('StartRIn',StatesThisTrial))
    TrialData.StartNewTrial(iTrial) = false;
end

if any(strcmp('StartNewTrialTimeOut',StatesThisTrial))
    TrialData.StartNewTrialSuccessful(iTrial) = true;
end

if any(strcmp('StartLIn',StatesThisTrial))
    TrialData.ChoiceLeft(iTrial) = true; % True if a choice is made to the left poke (also include incorrect choice)
elseif any(strcmp('StartRIn',StatesThisTrial))
    TrialData.ChoiceLeft(iTrial) = false; % True if a choice is made to the left poke (also include incorrect choice)
end

if any(strcmp('IncorrectChoice',StatesThisTrial))
    TrialData.IncorrectChoice(iTrial) = true; % True if the choice is incorrect (only for 1-arm bandit/GUI.SingleSidePoke); basically = LigthLeft & ChoiceLeft
elseif any(strcmp('LIn',StatesThisTrial)) || any(strcmp('LIn',StatesThisTrial))
   TrialData.IncorrectChoice(iTrial) = false; % True if the choice is incorrect (only for 1-arm bandit/GUI.SingleSidePoke); basically = LigthLeft & ChoiceLeft 
end

if any(strcmp('FeedbackGrace',StatesThisTrial))
    RegisteredWithdrawals = TrialStates.FeedbackGrace;

    for iExit = 1:size(RegisteredWithdrawals,1) % one may enter SamplingGrace multiple time, i_exit is the number of time
        ExitTime = RegisteredWithdrawals(iExit,1);
        ReturnTime = RegisteredWithdrawals(iExit,2);
        TrialData.FeedbackGrace(iExit, iTrial) = (ReturnTime - ExitTime);
    end
end

if any(strcmp('SkippedFeedback',StatesThisTrial))
    TrialData.SkippedFeedback(iTrial) = true; % True if SkippedFeedback
elseif (strcmp('WaterL',StatesThisTrial)) || any(strcmp('WaterR',StatesThisTrial))
   TrialData.SkippedFeedback(iTrial) = false;
end

%% Peri-outcome

if any(strcmp('WaterL',StatesThisTrial))
    TrialData.Rewarded(iTrial) = (TrialStates.WaterL(1,2) - TrialStates.WaterL(1,1)) > 0;
elseif any(strcmp('WaterR',StatesThisTrial))
    TrialData.Rewarded(iTrial) = (TrialStates.WaterR(1,2) - TrialStates.WaterR(1,1)) > 0;
end

TrialData.CatchError(iTrial) = NaN; % rate of non-SkippedFeedback amongst CorrectDecision

BpodSystem.Data.Custom.TrialData = TrialData;
end