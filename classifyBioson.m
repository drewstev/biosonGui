function classifyBioson(hfig,eventdata,handles) %#ok

gd=guidata(hfig);
string=get(gd.text8,'string');
set(gd.text8,'string','Running Classification Algorithm',...
    'foregroundcolor','r');
drawnow

%get values from the various edit boxes
gd.xlims=get(gca,'xlim');
gd.ylims=get(gca,'ylim');


gd.opt.blanking=str2double(get(gd.edit1,'string'));
% gd.opt.vblanking=str2double(get(gd.edit2,'string'));
gd.opt.smoothing=str2double(get(gd.edit3,'string'));
gd.opt.threshold=str2double(get(gd.edit5,'string'));
gd.opt.maxdepth=str2double(get(gd.edit6,'string'));
gd.opt.mindepth=str2double(get(gd.edit10,'string'));
gd.opt.vegheight=str2double(get(gd.edit7,'string'));
gd.opt.minflen=str2double(get(gd.edit11,'string'));


%set blanking distance below transducer
dr=gd.raw.range(2)-gd.raw.range(1);
if gd.opt.blanking==0
    blkInd=1;
else
    blkInd=ceil(gd.opt.blanking/dr);
end



%acoustic bottom width
bwidth=((gd.raw.snd.pulselen/1000)*...
    gd.raw.env.sv)/2;

%find first instance where return is greater than threshold value
data=num2cell(gd.raw.vals,1);
ind1=cellfun(@(x)(find(x(blkInd:end)>=...
    gd.opt.threshold,1,'first')),data,'uni',0);


%this block of code protects against the case that there is no
%bottom signal (ie, the bottom is below the max range of acoustics)
badflag=cellfun(@isempty,ind1);
ind1(badflag)={1};
indt=cell2mat(ind1)+(blkInd-1);

%max value between first threshold and bottom window length
%put in a catch statement in case the bottom is near the max range

[~,ind2]=cellfun(@(x,y)(max(x(y+blkInd:end))),...
    data,ind1,'uni',0);
ind2(badflag)={1};
indb=indt+cell2mat(ind2);


% d2=cellfun(@(x,y)(x(y-blkInd2:y)),data,num2cell(indb),...
%     'uni',0,'error',@errorh);

ind3=cellfun(@(x,y)(find(x(blkInd:y)>=gd.opt.threshold,1,'first')),...
    data,num2cell(indb),'uni',0,'error',@errorh);

ind3(cellfun(@isempty,ind3))={1};
indv=cell2mat(ind3)+(blkInd-1);


%define depths of vegetation top and bottom
%replace bad values with NaNs
top=-gd.raw.range(indv);
top(badflag)=NaN;


btm=-gd.raw.range(indb)+bwidth;
btm(badflag)=NaN;


%remove (most) max values occuring in vegetation canopy
if gd.opt.minflen>1
    
%     funh=@(x)(std(detrend(x)));
%     rough=slidefun(funh,gd.opt.minflen,btm);
%     fbtm=slidefun('min',gd.opt.minflen,btm,'forward');
%     
%     thres=nanmean(rough)+nanstd(rough);
%     btm(rough>thres)=fbtm(rough>thres);

    funh=@(x)(std(detrend(x)));
    rough=slidefun(funh,gd.opt.minflen,btm);
%     fbtm=slidefun('min',gd.opt.minflen,btm,'forward');
    
    thres=nanmean(rough)+nanstd(rough);
    btm(rough>thres)=nan;
    btm=fillgaps(btm);

end





%apply bottom edits
if gd.numedits>0
    for i=1:length(gd.edits2)
        
        if ~isempty(gd.edits2{i})
            etype=gd.edits2{i}{1};
            switch etype
                case {'gl';'bl'}
                    top(gd.edits2{i}{2}(:,1))=...
                        gd.edits2{i}{2}(:,2);
                case {'bd';'b'}
                    btm(gd.edits2{i}{2}(:,1))=...
                        gd.edits2{i}{2}(:,2);
                    
            end
        end
    end
end

%height between first return and bottom
bz=top-btm;


%define vegetation
%limit to defined depth limits
%and to vegetation over minimum height
vegFlag=zeros(length(btm),1);
vegFlag(bz>gd.opt.vegheight & ...
    -btm<gd.opt.maxdepth & ...
    -btm>gd.opt.mindepth)=1;

btm(vegFlag==0)=top(vegFlag==0);

if gd.opt.minflen>1
    
%     funh=@(x)(std(detrend(x)));
%     rough=slidefun(funh,gd.opt.minflen,btm);
%     fbtm=slidefun('min',gd.opt.minflen,btm,'forward');
%     
%     thres=nanmean(rough)+nanstd(rough);
%     btm(rough>thres)=fbtm(rough>thres);

    funh=@(x)(std(detrend(x)));
    rough=slidefun(funh,gd.opt.minflen,btm);
%     fbtm=slidefun('min',gd.opt.minflen,btm,'forward');
    
    thres=nanmean(rough)+nanstd(rough);
    btm(rough>thres)=nan;
    btm=fillgaps(btm);

end





vegTop=zeros(length(btm),1);
vegTop(vegFlag==1)=top(vegFlag==1);

vegHeight=zeros(length(btm),1);
vegHeight(vegFlag==1)=bz(vegFlag==1);



% %fill small gaps in bottom
% %fill gaps less than max value
% if gd.fill_btm_gaps==1
%     gaps=isnan(btm(2:end-1));
%     if isempty(gaps)~=1;
%         [c,ind]=getchunks(gaps,'-full');
%         ind(ind==1)=[];
%         bind=find(isnan(btm(ind))==1);
%         bstart=ind(bind)-1;
%         bend=bsxfun(@plus,bstart,c(bind)+1);
%
%         gap_len=cellfun(@(x,y)(gd.raw.pingnum(y)-...
%             gd.raw.pingnum(x)),...
%             num2cell(bstart),num2cell(bend));
%
%         fillGaps=find(gap_len<gd.fill_btm_maxgapsize); %provide ui input later
%         fillStart=bstart(fillGaps);
%         fillEnd=bend(fillGaps);
%
%
%         for i=1:numel(fillGaps)
%
%             btm(fillStart(i):fillEnd(i))=...
%                 interp1([gd.raw.pingnum(fillStart(i));...
%                 gd.raw.pingnum(fillEnd(i))],...
%                 [btm(fillStart(i));btm(fillEnd(i))],...
%                 gd.raw.pingnum(fillStart(i):fillEnd(i)));
%         end
%
%     end
% end

%apply bottom edits
if gd.numedits>0
    for i=1:length(gd.edits2)
        if ~isempty(gd.edits2{i})
            etype=gd.edits2{i}{1};
            switch etype
                case {'g';'gc'}
                    
                    vegTop(gd.edits2{i}{2}(:,1))=...
                        gd.edits2{i}{2}(:,2);
                    vegFlag(gd.edits2{i}{2}(:,1))=...
                        gd.edits2{i}{2}(:,3);
                    vegHeight(gd.edits2{i}{2}(:,1))=...
                        gd.edits2{i}{2}(:,4);
                case {'bd';'b'}
                    btm(gd.edits2{i}{2}(:,1))=...
                        gd.edits2{i}{2}(:,2);
            end
        end
    end
end

%smooth bottom out
if gd.opt.smoothing>1
    bareBtms=slidefun(@nanmean,gd.opt.smoothing,btm);
else
    bareBtms=btm;
end
vegTop(vegFlag==0)=bareBtms(vegFlag==0);

%calculate percent cover

pi=[1:gd.opt.avgint:numel(vegFlag),numel(vegFlag)+1];
[n,bin]=histc(gd.raw.pingnum,pi);

fun=@(x)(numel(find(x==1))/numel(x));
pc=accumarray(bin(bin~=0)',vegFlag(bin~=0),...
    [numel(n(n~=0)) 1],fun);

percentcover=cell2mat(cellfun(@(x,y)(repmat(x,y,1)),num2cell(pc),...
    num2cell(n(n~=0))','un',0));



%do we want to plot classifcation
if isfield(gd,'p1')
    set(gd.p1,'ydata',vegTop)
else
    gd.p1=plot(gd.raw.pingnum,vegTop,'g','linewidth',2,...
        'visible','off');
end

if isfield(gd,'p2')
    set(gd.p2,'ydata',bareBtms)
else
    gd.p2=plot(gd.raw.pingnum,bareBtms,'r','linewidth',2,...
        'visible','off');
end


if ~isfield(gd,'out')
    set(gd.check2,'enable','on')
    set(gd.check3,'enable','on')
    set(gd.push4,'enable','on')
    set(gd.push5,'enable','on')
    set(gd.push6,'enable','on')
    set(gd.pop1,'enable','on')
    
end



%raw (single ping) output to structure
gd.out.filename=gd.opt.filename;
if isfield(gd,'bopt')
    gd.out.bathy_opts=gd.bopt;
end
gd.out.pingnum=gd.raw.pingnum(:);
gd.out.mtime=gd.raw.mtime(:);
gd.out.latitude=gd.raw.gps.latitude(:);
gd.out.longitude=gd.raw.gps.longitude(:);
gd.out.gpsmode=gd.raw.gps.quality(:);
if isfield(gd.raw.gps,'elevation')
    gd.out.elevation=gd.raw.gps.elevation(:);
end
gd.out.depth=bareBtms(:);
if isfield(gd,'bopt')
    if gd.bopt.use_tide
        gd.out.tide=gd.raw.gps.tide(:);
        gd.out.zc=gd.out.depth+gd.out.tide(:);
    end
    if gd.bopt.use_ppk_tide
        gd.out.tide=gd.raw.gps.tide(:);
        gd.out.zc=gd.out.depth+gd.out.tide(:);
    end
end
gd.out.vegflag=vegFlag(:);
gd.out.vegtop=vegTop(:);
gd.out.vegheight=vegHeight(:);
gd.out.vegcover=percentcover(:);


set(gd.text8,'string',string,...
    'foregroundcolor','k')
set(gd.menu13,'enable','on');
set(gd.menu15,'enable','on')
set(gd.menu18,'enable','on')
set(gd.menu19,'enable','on')
set(gd.menu21,'enable','on')
set(gd.menu22,'enable','on')

guidata(hfig,gd);
showclass(hfig);
setFocus(hfig);