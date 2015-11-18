function cpfcn(hfig,evnt)

gd=guidata(hfig);
pan off


switch evnt.Key
    case 'o'
        localopen2(hfig)
    case 'z'
        zoomto(hfig)
    case 'f'
        fullExtents(hfig)
    case 'e'
        if isfield(gd,'out')
            lassoTool(hfig)
        end
    case 'u'
        undo(hfig)
    case 'd'
        digitizeTool(hfig)
    case 'l'
        apply_local_filt(hfig)
    case 'return'
        classifyBioson(hfig)
     
end