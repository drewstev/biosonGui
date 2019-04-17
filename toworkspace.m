function toworkspace(hfig,evnt) %#ok

gd=guidata(hfig);


assignin('base','dtx',gd.raw)
assignin('base','opt',gd.opt)

if isfield(gd,'out')
    classifyBioson(hfig);
    gd=guidata(hfig);
    
    assignin('base','dtc',gd.out);
    if isfield(gd,'edits')
        assignin('base','edits',gd.edits)
        assignin('base','edits2',gd.edits2)
    end
    
end
