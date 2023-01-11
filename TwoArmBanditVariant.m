function TwoArmBanditVariant()
% Protocol focusing on reward probability, either block-style or
% cued-style, of either 1-arm or 2-arm bandit setting.
% Developed by Antonio Lee @ BCCN Humboldt-Universitšt zu Berlin
% V1.0 release in Jan 2023

global BpodSystem
global TaskParameters

TaskParameters = GUISetup();  % Set experiment parameters in GUISetup.m
InitializePlots();

if ~BpodSystem.EmulatorMode
    if isfield(BpodSystem.ModuleUSB, 'WavePlayer1') && BpodSystem.assertModule('WavePlayer', 1) == 1
        [Player, ~] = SetupWavePlayer(50000); % 25kHz =sampling rate of 8Ch with 8Ch fully on; 50kHz for 4Ch; 100kHZ for 2Ch
        LoadIndependentWaveform(Player);
    elseif isfield(BpodSystem.ModuleUSB, 'HiFi1')  && BpodSystem.assertModule('HiFi', 1) == 1
        [Player, ~] = SetupHiFi(192000); % 192kHz = max sampling rate
        LoadIndependentWaveform(Player);
    else
        error('Error: To run this protocol, you must first pair a Analog Output Module or a HiFi Module(hardware) with its USB port. Click the USB config button on the Bpod console.')
    end
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
    TwoArmBanditVariant_PlotSideOutcome(BpodSystem.GUIHandles.OutcomePlot,'UpdateTrial',iTrial);
    
    if ~BpodSystem.EmulatorMode
        TwoArmBanditVariant_LoadTrialDependentWaveform(Player, iTrial); % Load stimuli trains to wave player if not EmulatorMode
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
    TwoArmBanditVariant_PlotSideOutcome(BpodSystem.GUIHandles.OutcomePlot,'UpdateResult',iTrial);
    
    HandlePauseCondition; % Checks to see if the protocol is paused. If so, waits until user resumes.
    if BpodSystem.Status.BeingUsed == 0
        return
    end
    iTrial = iTrial + 1;
    
end % Main loop
end % Protocol