function TwoArmBanditVariant_PlotPhotometryData(iTrial, FigNidaq1,FigNidaq2, PhotoData, Photo2Data)

global BpodSystem
global TaskParameters
global nidaq

% plot photometry data
if TaskParameters.GUI.Photometry
        
    Alignments = {[], [], []};
    if TaskParameters.GUI.SidePokeIn && (BpodSystem.Data.Custom.TrialData.NoDecision(iTrial)==0)
        Alignments{1} = 'WaitSIn';
    end
    if TaskParameters.GUI.SidePokeLeave && (BpodSystem.Data.Custom.TrialData.Rewarded(iTrial)==0)
        Alignments{2} = 'ITI';
    end
    if TaskParameters.GUI.RewardDelivery && (BpodSystem.Data.Custom.TrialData.Rewarded(iTrial)==1)
        Alignments{3} = 'Water';
    end
    
    for k = 1:length(Alignments)
        align = Alignments{k};
        if ~isempty(align)
        [currentNidaq1, rawNidaq1] = Online_NidaqDemod(PhotoData(:,1), nidaq.LED1,...
                                                       TaskParameters.GUI.LED1_Freq,...
                                                       TaskParameters.GUI.LED1_Amp, align);
        FigNidaq1 = Online_NidaqPlot('update', [], FigNidaq1, currentNidaq1, rawNidaq1, k);
        
            if TaskParameters.GUI.Isobestic405 || TaskParameters.GUI.DbleFibers || TaskParameters.GUI.RedChannel
                if TaskParameters.GUI.Isobestic405
                    [currentNidaq2, rawNidaq2] = Online_NidaqDemod(PhotoData(:,1), nidaq.LED2,...
                                                                   TaskParameters.GUI.LED2_Freq,...
                                                                   TaskParameters.GUI.LED2_Amp, align);
                elseif TaskParameters.GUI.RedChannel
                    [currentNidaq2, rawNidaq2] = Online_NidaqDemod(Photo2Data(:,1), nidaq.LED2,...
                                                                   TaskParameters.GUI.LED2_Freq,...
                                                                   TaskParameters.GUI.LED2_Amp, align);
                elseif TaskParameters.GUI.DbleFibers
                    [currentNidaq2, rawNidaq2] = Online_NidaqDemod(Photo2Data(:,1), nidaq.LED2,...
                                                                   TaskParameters.GUI.LED1b_Freq,...
                                                                   TaskParameters.GUI.LED1b_Amp, align);
                end
                FigNidaq2 = Online_NidaqPlot('update', [], FigNidaq2, currentNidaq2, rawNidaq2, k);
            end
        end %if non-empty align
    end %alignment loop
end %if photometry
end  % PlotPhotometryData()