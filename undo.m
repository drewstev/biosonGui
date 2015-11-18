function undo(hfig,evnt) %#ok

gd=guidata(hfig);

if gd.numedits>0
    gd.out.depth(gd.edits{gd.numedits}(:,1))=...
        gd.edits{gd.numedits}(:,2);
    gd.out.vegtop(gd.edits{gd.numedits}(:,1))=...
        gd.edits{gd.numedits}(:,3);
    gd.out.vegflag(gd.edits{gd.numedits}(:,1))=...
        gd.edits{gd.numedits}(:,4);
    gd.out.vegheight(gd.edits{gd.numedits}(:,1))=...
        gd.edits{gd.numedits}(:,5); 
    gd.out.vegcover(gd.edits{gd.numedits}(:,1))=...
        gd.edits{gd.numedits}(:,6); 
    
    gd.edits{gd.numedits}=[];
    gd.edits2(gd.numedits)=[];
    gd.numedits=gd.numedits-1;
    
    set(gd.p1,'ydata',gd.out.vegtop);
    set(gd.p2,'ydata',gd.out.depth);
    guidata(hfig,gd)
    
end

if gd.numedits==0;
    set(gd.menu6,'enable','off');
end


