function lassoTool(hfig,evnt) %#ok

gd=guidata(hfig);

if ~isfield(gd,'p1')
    return
end

set(gd.push4,'backgroundcolor','g')

val=get(gd.pop1,'value');

if get(gd.toggle1,'value');
    set(gd.toggle1,'value',0,...
        'backgroundcolor',[0.9255    0.9137    0.8471]);
    pan off
end


set(gd.menu6,'enable','on')

switch val
    case 1
        [pl,xs,ys] = selectdata('sel','lasso',...
            'ignore',[gd.im gd.p1]); %#ok
        
        if ~isempty(pl)
           gd.numedits=gd.numedits+1;
            gd.edits{gd.numedits}=[pl gd.out.depth(pl),...
                gd.out.vegtop(pl) gd.out.vegflag(pl),...
                gd.out.vegheight(pl) gd.out.vegcover(pl)];
            gd.edits2{gd.numedits}={'bl',[pl nan(numel(pl),1)]};
            
            gd.out.depth(pl)=NaN;
            gd.out.vegtop(pl)=NaN;
            gd.out.vegflag(pl)=0;
            gd.out.vegheight(pl)=0;
            gd.out.vegcover(pl)=0;
            
            
            set(gd.p1,'ydata',gd.out.vegtop);
            set(gd.p2,'ydata',gd.out.depth);
        end
    case 2
        gd.numedits=gd.numedits+1;
        [pl,xs,ys] = selectdata('sel','lasso',...
            'ignore',[gd.im gd.p2]); %#ok
        if ~isempty(pl)
            gd.edits{gd.numedits}=[pl gd.out.depth(pl), ...
                gd.out.vegtop(pl) gd.out.vegflag(pl),...
                gd.out.vegheight(pl) gd.out.vegcover(pl)];
            gd.edits2{gd.numedits}={'g',[pl nan(numel(pl),1),...
                zeros(numel(pl),2)]};
            
            gd.out.vegtop(pl)=NaN;
            gd.out.vegflag(pl)=0;
            gd.out.vegheight(pl)=0;
             gd.out.vegcover(pl)=0;
            
            set(gd.p1,'ydata',gd.out.vegtop);
        end
end
        

set(gd.push4,'backgroundcolor',[0.9255    0.9137    0.8471])


setFocus(hfig)
guidata(hfig,gd);