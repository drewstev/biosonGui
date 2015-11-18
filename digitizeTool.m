function digitizeTool(hfig,evnt) %#ok

gd=guidata(hfig);
if ~isfield(gd,'p1')
    return
end

val=get(gd.pop1,'value');

set(gd.push5,'backgroundcolor','g');

button=1;
points=0;

set(gca,'nextplot','add')


switch val
    
    case 1
        while button==1
            points=points+1;
            [x,y,button]=ginput(1);
            xp(points)=round(x); %#ok
            yp(points)=y; %#ok
            
            if points==1;
                dh=plot(xp,yp,'ro-','markerfacecolor','r');
            else
                set(dh,'xdata',xp,'ydata',yp)
            end
        end
        delete(dh);
        
        if numel(xp)>1
            [xc,xind]=unique(xp);
            yc=yp(xind);
            
            dind=(min(xp):max(xp))';
            dnew=interp1(xc,yc,dind);
            
            gd.numedits=gd.numedits+1;
            set(gd.menu6,'enable','on')
            
            gd.edits{gd.numedits}=[dind gd.out.depth(dind),...
                gd.out.vegtop(dind) gd.out.vegflag(dind),...
                gd.out.vegheight(dind) gd.out.vegcover(dind)];
            gd.edits2{gd.numedits}={'bd',[dind dnew]};
            
            gd.out.depth(dind)=dnew;
            gd.out.vegtop(dind)=dnew;
            gd.out.vegflag(dind)=0;
            gd.out.vegheight(dind)=0;
            gd.out.vegcover(dind)=0;
            
            
            set(gd.p1,'ydata',gd.out.vegtop);
            set(gd.p2,'ydata',gd.out.depth);
        end
        
    case 2
        while button==1
            points=points+1;
            [x,y,button]=ginput(1);
            xp(points)=round(x); %#ok
            yp(points)=y; %#ok
            
            if points==1;
                dh=plot(xp,yp,'go-','markerfacecolor','r');
            else
                set(dh,'xdata',xp,'ydata',yp)
            end
        end
        delete(dh);
        
        if numel(xp)>1
            [xc,xind]=unique(xp);
            yc=yp(xind);
            
            dind=(min(xp):max(xp))';
            dnew=interp1(xc,yc,dind);
            
            gd.numedits=gd.numedits+1;
            set(gd.menu6,'enable','on')
            
            gd.edits{gd.numedits}=[dind gd.out.depth(dind),...
                gd.out.vegtop(dind) gd.out.vegflag(dind),...
                gd.out.vegheight(dind) gd.out.vegcover(dind)];
            gd.edits2{gd.numedits}={'gc',[dind dnew,...
                ones(numel(dind),1), dnew-...
                gd.out.depth(dind)]};
            
            gd.out.vegtop(dind)=dnew;
            gd.out.vegheight(dind)=gd.out.vegtop(dind)-...
                gd.out.depth(dind);


            
            set(gd.p1,'ydata',gd.out.vegtop);
            set(gd.p2,'ydata',gd.out.depth);
        end
end

set(gd.push5,'backgroundcolor',[0.9255    0.9137    0.8471]);
guidata(hfig,gd)