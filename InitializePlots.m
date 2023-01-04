function InitializePlots()

global BpodSystem
global TaskParameters

BpodSystem.ProtocolFigures.SideOutcomePlotFig = figure('Position',TaskParameters.Figures.OutcomePlot.Position + [100, -100, 500, -500],...
                                                       'name','OutcomePlot','numbertitle','off','MenuBar','none','Resize','off');
BpodSystem.GUIHandles.OutcomePlot.HandleOutcome = axes('Position',     [  .05           .1  .9  .3]);
BpodSystem.GUIHandles.OutcomePlot.HandleTrialRate = axes('Position',   [1*.05 + 0*.08   .6  .1  .3],'Visible','off');
BpodSystem.GUIHandles.OutcomePlot.HandleStimDelay = axes('Position',   [2*.05 + 1*.08   .6  .1  .3],'Visible','off'); % old HandleFix
BpodSystem.GUIHandles.OutcomePlot.HandleSampleTime = axes('Position',  [3*.05 + 2*.08   .6  .1  .3],'Visible','off');
BpodSystem.GUIHandles.OutcomePlot.HandleMoveTime = axes('Position',    [4*.05 + 3*.08   .6  .1  .3],'Visible','off');
BpodSystem.GUIHandles.OutcomePlot.HandleFeedback = axes('Position',    [5*.05 + 4*.08   .6  .1  .3],'Visible','off');
BpodSystem.GUIHandles.OutcomePlot.HandleVevaiometric = axes('Position',[6*.05 + 5*.08   .6  .1  .3],'Visible','off');

TwoArmBanditVariant_PlotSideOutcome(BpodSystem.GUIHandles.OutcomePlot,'init');

end