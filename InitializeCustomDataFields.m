function InitializeCustomDataFields(iTrial)
%{ 
Initializing trial data
%}

global BpodSystem
global TaskParameters

if iTrial == 1
    BpodSystem.Data.Custom.TrialData.ChoiceLeft(iTrial) = NaN; % initializing .TrialData
end

TrialData = BpodSystem.Data.Custom.TrialData;

%% Pre-stimulus delivery
TrialData.NoTrialStart(iTrial) = true;

TrialData.BrokeFixation(iTrial) = NaN; % True if BrokeFixation
TrialData.StimDelay(iTrial) = TaskParameters.GUI.StimDelay;
switch TaskParameters.GUIMeta.GUIMeta.StimDelayDistributionType.String{TaskParameters.GUI.StimDelayDistributionType}
    case 'Fix'
        % can still be adjusted by changing TaskParameters.GUI.StimDelayMin
        
    case 'AutoIncr'
        if iTrial > 1
            History = 50; % Rat: History = 50
            Crit = 0.8; % Rat: Crit = 0.8
            ConsiderTrials = max(1,iTrial-History):1:iTrial-1;
            ConsiderTrials = ConsiderTrials(~isnan(TrialData.BrokeFixation(ConsiderTrials))); % exclude trials did not start
            NotBrokeFixationRate = sum(~TrialData.BrokeFixation(ConsiderTrials))/length(ConsiderTrials);
            
            if NotBrokeFixationRate > Crit
                if TrialData.BrokeFixation(iTrial-1) == false % If last trial is not BrokeFixation nor NaN (e.g. NoTrialStart)
                    TrialData.StimDelay(iTrial) = TrialData.StimDelay(iTrial) + TaskParameters.GUI.StimDelayIncrStepSize; % StimulusDelay increased
                end
            elseif NotBrokeFixationRate < Crit/2
                if TrialData.BrokeFixation(iTrial-1) == true % If last trial is Broke Fixation (and not NaN)
                    TrialData.StimDelay(iTrial) = TrialData.StimDelay(iTrial) - TaskParameters.GUI.StimDelayDecrStepSize; % StimulusDelay decreased
                end
            end
        end
        
    case 'TruncExp'
        TrialData.StimDelay(iTrial) = TruncatedExponential(TaskParameters.GUI.StimDelayMin, TaskParameters.GUI.StimDelayMax, TaskParameters.GUI.StimDelayTau);
    
    case 'Uniform'
        TrialData.StimDelay(iTrial) = TaskParameters.GUI.StimDelayMin + rand*(TaskParameters.GUI.StimDelayMax - TaskParameters.GUI.StimDelayMin);
        
    case 'Beta'
        %% !!to be implemented!!
end

if TrialData.StimDelay(iTrial) > TaskParameters.GUI.StimDelayMax % allow adjustment even if StimDelayAutoIncr is off
    TrialData.StimDelay(iTrial) = TaskParameters.GUI.StimDelayMax;
elseif TrialData.StimDelay(iTrial) < TaskParameters.GUI.StimDelayMin
    TrialData.StimDelay(iTrial) = TaskParameters.GUI.StimDelayMin;
end

TaskParameters.GUI.StimDelay = TrialData.StimDelay(iTrial);

%% Peri-stimulus delivery and Pre-decision
TrialData.SamplingGrace(1,trial) = NaN; % old GracePeriod, row is for the n-th time the state is entered, column is for the time in this State
TrialData.EarlyWithdrawal(iTrial) = NaN; % True if early withdrawal
TrialData.SampleTime(iTrial) = NaN; % Time that stayed CenterPortIn for sampling

% TrialData.SingleSidePokeEnabled(iTrial) = TaskParameters.GUI.SingleSidePoke;
TrialData.LightLeft(iTrial) = NaN; % if true, 1-arm bandit with left poke being correct
if TaskParameters.GUI.SingleSidePoke
    TrialData.LightLeft(iTrial) = rand < 0.5;
end

%% Peri-decision and pre-outcome
TrialData.NoDecision(iTrial) = NaN; % True if no decision made
TrialData.MoveTime(iTrial) = NaN; % from CenterPortOut to SidePortIn(or re-CenterPortIn for StartNewTrial), old MT

% TrialData.StartNewTrialEnabled(iTrial) = TaskParameters.GUI.StartNewTrial; % if false TaskParameters.GUI.StartNewTrial is off;
TrialData.StartNewTrial(iTrial) = NaN; % only concern state 'StartNewTrial'
TrialData.StartNewTrialSuccessful(iTrial) = NaN; % concern state 'StartNewTrialTimeOut'

TrialData.ChoiceLeft(iTrial) = NaN; % True if a choice is made to the left poke (also include incorrect choice)
TrialData.IncorrectChoice(iTrial) = NaN; % True if the choice is incorrect (only for 1-arm bandit/GUI.SingleSidePoke); basically = LigthLeft & ChoiceLeft

TrialData.FeedbackDelay(iTrial) = TaskParameters.GUI.FeedbackDelay;
switch TaskParameters.GUIMeta.GUIMeta.FeedbackDelayDistributionType.String{TaskParameters.GUI.FeedbackDelayDistributionType}
    case 'Fix'
        % can still be adjusted by changing TaskParameters.GUI.FeedbackDelayMin
        
    case 'AutoIncr'
        if iTrial > 1
            History = 50; % Rat: History = 50
            Crit = 0.8; % Rat: Crit = 0.8
            ConsiderTrials = max(1,iTrial-History):1:iTrial-1;
            ConsiderTrials = ConsiderTrials(~isnan(TrialData.ChoiceLeft(ConsiderTrials))); % exclude trials did not Choice
            NotSkippedFeedbackRate = sum(~TrialData.SkippedFeedback(ConsiderTrials))/length(ConsiderTrials);
            
            if NotSkippedFeedbackRate > Crit
                if TrialData.SkippedFeedback(iTrial-1) == false % If last trial is not Skipped Feedback nor NaN (e.g. NoDecision)
                    TrialData.FeedbackDelay(iTrial) = TrialData.FeedbackDelay(iTrial) + TaskParameters.GUI.FeedbackDelayIncrStepSize; % FeedbackDelay increased
                end
            elseif NotSkippedFeedbackRate < Crit/2
                if TrialData.SkippedFeedback(iTrial-1) == true % If last trial is Skipped Feedback (and not NaN)
                    TrialData.FeedbackDelay(iTrial) = TrialData.FeedbackDelay(iTrial) - TaskParameters.GUI.FeedbackDelayDecrStepSize; % FeedbackDelay decreased
                end
            end
        end
        
    case 'TruncExp'
        TrialData.FeedbackDelay(iTrial) = TruncatedExponential(TaskParameters.GUI.FeedbackDelayMin, TaskParameters.GUI.FeedbackDelayMax, TaskParameters.GUI.FeedbackDelayTau);
        
    case 'Beta'
        %% !!to be implemented!!
end

if TrialData.FeedbackDelay(iTrial) > TaskParameters.GUI.FeedbackDelayMax % allow adjustment even if StimDelayAutoIncr is off
    TrialData.FeedbackDelay(iTrial) = TaskParameters.GUI.FeedbackDelayMax;
elseif TrialData.FeedbackDelay(iTrial) < TaskParameters.GUI.FeedbackDelayMin
    TrialData.FeedbackDelay(iTrial) = TaskParameters.GUI.FeedbackDelayMin;
end
TaskParameters.GUI.FeedbackDelay = TrialData.FeedbackDelay(iTrial);

TrialData.FeedbackGrace(1,trial) = NaN; % first index for the number of time the state is entered
TrialData.SkippedFeedback(iTrial) = NaN; % True if SkippedFeedback

TrialData.CatchTrial(iTrial) = rand < TaskParameters.GUI.CatchTrialPercentage; % determine whether a trial is a CatchTrial
if TrialData.CatchTrial(iTrial)
    TaskParameters.GUI.CatchTrial = 'true';
else
    TaskParameters.GUI.CatchTrial = 'false';
end

%% Peri-outcome
TrialData.RewardProb(:,iTrial) = [NaN, NaN]';
TrialData.BlockNumber(iTrial) = NaN; % only adjust if RiskType is Block
TrialData.BlockTrialNumber(iTrial) = NaN; % only adjust if RiskType is Block
TrialData.RewardCueLeft(:,iTrial) = [NaN, NaN]'; % only adjust if RiskType is Cued
TrialData.RewardCueRight(:,iTrial) = [NaN, NaN]'; % only adjust if RiskType is Cued

switch TaskParameters.GUIMeta.RiskType.String{TaskParameters.GUI.RiskType}
    case 'Fix'
        TrialData.RewardProb(1,iTrial) = TaskParameters.GUI.RewardProbLeft;
        TrialData.RewardProb(2,iTrial) = TaskParameters.GUI.RewardProbRight;
        
    case 'BlockRand'
        if iTrial == 1
            TrialData.BlockNumber(iTrial) = 1;
            TrialData.BlockTrialNumber(iTrial) = 1;
            TaskParameters.GUI.BlockLen = randi([TaskParameters.GUI.BlockLenMin,TaskParameters.GUI.BlockLenMax]);
            TaskParameters.GUI.NextBlockTrialNumber = TaskParameters.GUI.BlockLen;
            TrialData.RewardProb(:,iTrial) = randi([TaskParameters.GUI.RewardProbMin,TaskParameters.GUI.RewardProbMax],2,1);
        else
            TrialData.BlockNumber(iTrial) = TrialData.BlockNumber(iTrial-1);
            TrialData.BlockTrialNumber(iTrial) = TrialData.BlockTrialNumber(iTrial-1) + 1;
            TrialData.RewardProb(:,iTrial) = TrialData.RewardProb(:,iTrial-1);
            if TrialData.BlockTrialNumber(iTrial) > TaskParameters.GUI.BlockLen
                TrialData.BlockNumber(iTrial) = TrialData.BlockNumber(iTrial-1) + 1;
                TrialData.BlockTrialNumber(iTrial) = 1;
                TaskParameters.GUI.BlockLen = randi([TaskParameters.GUI.BlockLenMin,TaskParameters.GUI.BlockLenMax]);
                TaskParameters.GUI.NextBlockTrialNumber = (iTrial-1) + TaskParameters.GUI.BlockLen;
                TrialData.RewardProb(:,iTrial) = randi([TaskParameters.GUI.RewardProbMin,TaskParameters.GUI.RewardProbMax],2,1);
            end
        end
        
    case 'BlockFix'
        if iTrial == 1
            TrialData.BlockNumber(iTrial) = 1;
            TrialData.BlockTrialNumber(iTrial) = 1;
            TaskParameters.GUI.BlockLen = randi([TaskParameters.GUI.BlockLenMin,TaskParameters.GUI.BlockLenMax]);
            TaskParameters.GUI.NextBlockTrialNumber = TaskParameters.GUI.BlockLen;
            TrialData.RewardProb(:,iTrial) = [TaskParameters.GUI.RewardProbMin,TaskParameters.GUI.RewardProbMax]';
        else
            TrialData.BlockNumber(iTrial) = TrialData.BlockNumber(iTrial-1);
            TrialData.BlockTrialNumber(iTrial) = TrialData.BlockTrialNumber(iTrial-1) + 1;
            TrialData.RewardProb(:,iTrial) = TrialData.RewardProb(:,iTrial-1);
            if TrialData.BlockTrialNumber(iTrial) > TaskParameters.GUI.BlockLen
                TrialData.BlockNumber(iTrial) = TrialData.BlockNumber(iTrial-1) + 1;
                TrialData.BlockTrialNumber(iTrial) = 1;
                TaskParameters.GUI.BlockLen = randi([TaskParameters.GUI.BlockLenMin,TaskParameters.GUI.BlockLenMax]);
                TaskParameters.GUI.NextBlockTrialNumber = (iTrial-1) + TaskParameters.GUI.BlockLen;
                TrialData.RewardProb(:,iTrial) = flip(TrialData.RewardProb(:,iTrial-1));
            end
        end
        
    case 'Cued'
        NoOfValidCue = min([size(TaskParameters.GUI.ToneRiskTable.ToneStartFreq, 1), size(TaskParameters.GUI.ToneRiskTable.ToneEndFreq, 1), TaskParameters.GUI.ToneRiskTable.ToneCuedRewardProbability]);
        CueLeft = randi(NoOfValidCue);
        CueRight = randi(NoOfValidCue);
        TrialData.RewardCueLeft(:,iTrial) = [TaskParameters.GUI.ToneRiskTable.ToneStartFreq(CueLeft), TaskParameters.GUI.ToneRiskTable.ToneEndFreq(CueLeft)]';
        TrialData.RewardCueRight(:,iTrial) = [TaskParameters.GUI.ToneRiskTable.ToneStartFreq(CueRight), TaskParameters.GUI.ToneRiskTable.ToneEndFreq(CueRight)]';
        TrialData.RewardProb(:,iTrial) = [TaskParameters.GUI.ToneRiskTable.ToneCuedRewardProbability(CueLeft), TaskParameters.GUI.ToneRiskTable.ToneCuedRewardProbability(CueRight)]';
        
end

TaskParameters.GUI.RewardProbActualLeft = TrialData.RewardProb(1,iTrial);
TaskParameters.GUI.RewardProbActualRight = TrialData.RewardProb(2,iTrial);

%{ Should not adjust RewardProb in 1-arm task as some codes use (i-1)th values
% if TrialData.LightLeft(iTrial) == 1 
%     TrialData.RewardProb(2,iTrial) = 0;
% elseif TrialData.LightLeft(iTrial) == 0
%     TrialData.RewardProb(1,iTrial) = 0;
% end}

TrialData.RewardMagnitude(:, iTrial) = [TaskParameters.GUI.RewardAmount, TaskParameters.GUI.RewardAmount]'; % first index is for left or right poke
if TrialData.LightLeft(iTrial) == 1 % adjustment by SingleSidePoke, i.e. 1-arm bandit
    TrialData.RewardMagnitude(2,iTrial) = 0;
elseif TrialData.LightLeft(iTrial) == 0
    TrialData.RewardMagnitude(1,iTrial) = 0;
end

if TaskParameters.GUI.ExpressedAsExpectedValue
    TrialData.RewardMagnitude = TrialData.RewardProb .* TrialData.RewardMagnitude;
else
    TrialData.RewardMagnitude = TrialData.RewardMagnitude.* (rand(2,1) < TrialData.RewardProb);
end

TrialData.Rewarded(iTrial) = NaN; % true if a non-zero reward is delivered

%%
BpodSystem.Data.Custom.TrialData = TrialData;

end