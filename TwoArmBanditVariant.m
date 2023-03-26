function TwoArmBanditVariant()
% Protocol focusing on reward probability, either block-style or
% cued-style, of either 1-arm or 2-arm bandit setting.
% Developed by Antonio Lee @ BCCN Humboldt-Universität zu Berlin
% V1.0 release in Jan 2023

global BpodSystem
global TaskParameters

TaskParameters = TwoArmBanditVariant_SetupGUI();  % Set experiment parameters in GUISetup.m
TwoArmBanditVariant_PlotSideOutcome(BpodSystem.GUIHandles,'init');

% Set up additional bpod module(s)
if ~BpodSystem.EmulatorMode % Sound/laser waveform generation is not compulsory in this protocol
    if ~isfield(BpodSystem.ModuleUSB, 'WavePlayer1') && ~isfield(BpodSystem.ModuleUSB, 'HiFi1')
        warning('Warning: To run this protocol with sound or laser, you will need to pair an Analog Output Module or a HiFi Module(hardware) with its USB port. Click the USB config button on the Bpod console.')
    else
        if isfield(BpodSystem.ModuleUSB, 'HiFi1')
            [Player, ~] = SetupHiFi(192000); % 192kHz = max sampling rate
        end
        
        ChannelNumber = 4;
        if isfield(BpodSystem.ModuleUSB, 'WavePlayer1')
            [Player, ~] = SetupWavePlayer(ChannelNumber); % 25kHz = sampling rate of 8Ch with 8Ch fully on; 50kHz for 4Ch; 100kHZ for 2Ch
        end
        LoadIndependentWaveform(Player); %Taking the last Player for now as the WaveformPlayer
    end
end

% Set up photometry module
if TaskParameters.GUI.Photometry
    [FigNidaq1,FigNidaq2] = InitializeNidaq();
end

% --------------------------Main loop------------------------------ %
RunSession = true;
iTrial = 1;

while RunSession
    TwoArmBanditVariant_InitializeCustomDataFields(iTrial); % Initialize data (trial type) vectors and first values, potentially updated TaskParameters
    TaskParameters = BpodParameterGUI('sync', TaskParameters);
    TwoArmBanditVariant_PlotSideOutcome(BpodSystem.GUIHandles.OutcomePlot,'UpdateTrial',iTrial);
    
    if ~BpodSystem.EmulatorMode
        TwoArmBanditVariant_LoadTrialDependentWaveform(Player, iTrial); % Load stimuli trains to wave player if not EmulatorMode
    end
    
    sma = TwoArmBanditVariant_StateMatrix(iTrial); % set up State Matrix
    SendStateMatrix(sma); % send State Matrix to Bpod
    
    % NIDAQ Get nidaq ready to start
    if TaskParameters.GUI.Photometry
        Nidaq_photometry('WaitToStart');
    end
    
    % Run Trial
    RawEvents = RunStateMatrix; % run Trial
    
    % NIDAQ Stop acquisition and save data in bpod structure
    if TaskParameters.GUI.Photometry
        Nidaq_photometry('Stop');
        [PhotoData,Photo2Data] = Nidaq_photometry('Save');
        BpodSystem.Data.Custom.TrialData.NidaqData{iTrial} = PhotoData;
        if TaskParameters.GUI.DbleFibers || TaskParameters.GUI.RedChannel
            BpodSystem.Data.Custom.TrialData.Nidaq2Data{iTrial} = Photo2Data;
        end
        PlotPhotometryData(iTrial, FigNidaq1, FigNidaq2, PhotoData, Photo2Data);
    end
    
    % Bpod save & update fields
    if ~isempty(fieldnames(RawEvents))
        BpodSystem.Data = AddTrialEvents(BpodSystem.Data,RawEvents);
        TwoArmBanditVariant_InsertSessionDescription(iTrial);
        TwoArmBanditVariant_UpdateCustomDataFields(iTrial);
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