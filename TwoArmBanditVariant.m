function TwoArmBanditVariant()
% Protocol focusing on reward probability, either block-style or
% cued-style, of either 1-arm or 2-arm bandit setting.
% Developed by Antonio Lee @ BCCN Humboldt-Universität zu Berlin
% V1.0 release in Jan 2023

global BpodSystem
global TaskParameters

TaskParameters = GUISetup();  % Set experiment parameters in GUISetup.m
InitializePlots();

if ~BpodSystem.EmulatorMode
    [Player, fs] = SetupWavePlayer(25000); % 25kHz =sampling rate of 8Ch with 8Ch fully on
    LoadIndependentWaveform(Player);
    LoadTriggerProfileMatrix(Player);
end
    
if TaskParameters.GUI.Photometry
    [FigNidaq1,FigNidaq2] = InitializeNidaq();
end

% --------------------------Main loop------------------------------ %
RunSession = true;
iTrial = 1;

while RunSession
    InitializeCustomDataFields(iTrial); % Initialize data (trial type) vectors and first values, potentially updated TaskParameters
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    
    if ~BpodSystem.EmulatorMode
        LoadTrialDependentWaveform(Player, iTrial, 5, 2); % Load stimuli trains to wave player if not EmulatorMode
    end
    
    % NIDAQ Get nidaq ready to start
    if TaskParameters.GUI.Photometry
        Nidaq_photometry('WaitToStart');
    end
    
    sma = StateMatrix(iTrial); % set up State Matrix
    SendStateMatrix(sma); % send State Matrix to Bpod
    RawEvents = RunStateMatrix; % run Trial
    
    % NIDAQ Stop acquisition and save data in bpod structure
    if TaskParameters.GUI.Photometry
        Nidaq_photometry('Stop');
        [PhotoData,Photo2Data] = Nidaq_photometry('Save');
        BpodSystem.Data.TrialData.NidaqData{iTrial} = PhotoData;
        if TaskParameters.GUI.DbleFibers || TaskParameters.GUI.RedChannel
            BpodSystem.Data.TrialData.Nidaq2Data{iTrial} = Photo2Data;
        end
        PlotPhotometryData(FigNidaq1, FigNidaq2, PhotoData, Photo2Data);
    end
    
    % Bpod save & update fields
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        InsertSessionDescription(iTrial);
        UpdateCustomDataFields(iTrial);
        SaveBpodSessionData();
    end
    
    % update figures
    TwoArmBanditVariant_PlotSideOutcome(BpodSystem.GUIHandles.OutcomePlot,'update',iTrial);
    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
    iTrial = iTrial + 1;
    
end % Main loop
end % Protocol