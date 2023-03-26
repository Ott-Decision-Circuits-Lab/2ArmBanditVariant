function TwoArmBanditVariant_InsertSessionDescription(iTrial)
global BpodSystem
global TaskParameters

% insert session description in protocol into data.info
if iTrial == 1
    BpodSystem.Data.Info.SessionDescription = "To observe subject's behaviour under cued or blocked risk task";
    BpodSystem.Data.Custom.General.SessionDescription = BpodSystem.Data.Info.SessionDescription;
end

% append session description in setting into data.info
if TaskParameters.GUI.SessionDescription ~= BpodSystem.Data.Info.SessionDescription(end)
    BpodSystem.Data.Info.SessionDescription = [BpodSystem.Data.Info.SessionDescription, TaskParameters.GUI.SessionDescription];
    BpodSystem.Data.Custom.General.SessionDescription = BpodSystem.Data.Info.SessionDescription;
end
end