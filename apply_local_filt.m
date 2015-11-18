function apply_local_filt(hfig,eventdata,handles)%#ok

gd=guidata(hfig);

if ~isfield(gd,'p1')
    return
end

switch gd.lfd.lftype
    case 1
        fun=@min;
    case 2
        fun=@max;
    case 3
        fun=@mean;
    case 4
        fun=@median;
end

if get(gd.toggle1,'value');
    set(gd.toggle1,'value',0,...
        'backgroundcolor',[0.9255    0.9137    0.8471]);
    pan off
end


val=get(gd.pop1,'value');
switch val
    case 1
         [pl,xs,ys] = selectdata('sel','lasso',...
             'ignore',[gd.im gd.p1]); %#ok
         
         if numel(pl)>gd.lfd.lflen 
             dnew=slidefun(fun,gd.lfd.lflen,...
                 gd.out.depth(pl));
             
             gd.numedits=gd.numedits+1;
             set(gd.menu6,'enable','on')
             
             gd.edits{gd.numedits}=[pl gd.out.depth(pl),...
                gd.out.vegtop(pl) gd.out.vegflag(pl),...
                gd.out.vegheight(pl) gd.out.vegcover(pl)];
            gd.edits2{gd.numedits}={'b',[pl dnew]};
            
            gd.out.depth(pl)=dnew;           
            
            set(gd.p1,'ydata',gd.out.vegtop);
            set(gd.p2,'ydata',gd.out.depth);
         end
         
    case 2
        [pl,xs,ys] = selectdata('sel','lasso',...
            'ignore',[gd.im gd.p2]); %#ok
         
         if numel(pl)>gd.lfd.lflen 
             gnew=slidefun(fun,gd.lfd.lflen,...
                 gd.out.vegtop(pl));
             
             gd.numedits=gd.numedits+1;
             set(gd.menu6,'enable','on')
             
             gd.edits{gd.numedits}=[pl gd.out.depth(pl),...
                 gd.out.vegtop(pl) gd.out.vegflag(pl),...
                 gd.out.vegheight(pl) gd.out.vegcover(pl)];
             gd.edits2{gd.numedits}={'gl',[pl gnew]};
            
                  
            gd.out.vegtop(pl)=gnew;
            gd.out.vegflag(pl)=0;
            gd.out.vegheight(pl)=0;
            gd.out.vegcover(pl)=0;
            
            set(gd.p1,'ydata',gd.out.vegtop);
            set(gd.p2,'ydata',gd.out.depth);
         end
end
             

guidata(hfig,gd)
setFocus(hfig)

