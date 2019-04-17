function [dtx,varargout] = rd_dtx(varargin)
% RD_DTX - read contents of a .DT4 (Biosonics) file
%       
%   DTX = RD_DTX(FILENAME) - reads the contents of the .DT4 file,
%       FILENAME and output in a structure, DTX. For multiplexed
%       data, the output will be an M x 1 multidimensional array, 
%       where M is the number of transducers. This code was tested
%       on versions 2.2 and 2.3 DT4 file formats (Biosonics, 2010).
%       GPS information, if available, is read and interpolated 
%       for each ping (and transducer) in the file.
%
%   [...,GPS] = RD_DTX(FILENAME) - will output the raw GPS information
%       contained in the .DT4 file.  Currently, this software only 
%       will read the following GPS strings: RMC, GGA, VTG, ZDA.
%
% DTX - A structure array with the following fields
%       'channel'   -   Channel number
%       'env'       -   Environmental variables (structure array)
%       'snd'       -   Sounder settings (structure array)
%                       The 'snd' field also contains a sub-
%                       structure array, 'rxee', or the receiver
%                       EPROM image, containing other useful 
%                       configuration info
%       'mtime'     -   Matlab datenum. Time info from the GPS 
%                       will be used if present in the file.
%       'ptime'     -   Elapsed time within the data record (milisecs)
%       'pingnum'   -   Ping number
%       'range'     -   Range below the xducer (meters)
%       'vals'      -   Amplitude (log10 of the units supplied in the file)
%       'bot'       -   If present, digitized bottom pick (meters from 
%                       xducer)
%       'gps'       -   If present, data from the gps (structure array).
%                       The fields present in the 'gps' field vary
%                       based on the NMEA strings supplied during 
%                       data collection
% 
% NOTES 
%   This is a modified verion of RDDTX, written by Rich Pawlowicz.
%   
% REFERENCE
%   Biosonics, 2010, DT4 File Format Specification, Rev. 2.0.
%
% A.W. Stevens
% 08/29/2014

%parse optional input
error(nargchk(0,1,nargin,'struct'));
if nargin ==0
    [filename, pathname] = uigetfile( ...
        {'*.dt4', 'DT4 Files (*.dt4)'},...
        'Select a DT4 file');
    fname=[pathname,filename];
    if filename==0
        dtx=[];
        varargout{1}=[];
        return
    end
    
else
    fname=varargin{1};
    if ~ischar(fname)
        error('Filename should be a string.')
    elseif exist(fname,'file')==0
        error('File not found.')
    else
    end
end


[~,f,ext]=fileparts(fname);
tic
fprintf('Reading file: %s%s, Please Wait...\n',f,ext);

%open the file
fd=fopen(fname,'r','ieee-le');
fseek(fd,0,'eof');
numbytes=ftell(fd);
frewind(fd)
pos=0;
ngps=1;
nhpr=1;


while pos<numbytes
    [tag,siz,pos]=rd_tag(fd);
    
    switch tag
        case 'FFFF' %start of file
            [sig,pos]=rd_sig(fd,siz,pos); %#ok
            
        case '001E' %environment tuple
            [env,pos] = rd_env(fd,siz,pos);
                        
            %create output struct
            dtx=repmat(struct('channel',[],...
                'env',env,...
                'snd',[],...
                'mtime',[],...
                'ptime',[],...
                'pingnum',[],...
                'range',[],...
                'vals',[]),env.nsdr,1);     
            
        case '0012' %channel descriptor tuple
            [snd,pos]=rd_snd(fd,siz,pos);
            snd.rxee=rd_eprom(snd);
            
            %initialize output structure
            dtx(snd.address).channel=snd.address;
            dtx(snd.address).snd=snd;
            dtx(snd.address).mtime=nan(1,snd.npings);
            dtx(snd.address).ptime=nan(1,snd.npings);
            dtx(snd.address).pingnum=nan(1,snd.npings);
            dtx(snd.address).range=((1:snd.sampperping)'+...
                snd.blank)*snd.sampperiod*env.sv/2e6;
            dtx(snd.address).vals=nan(snd.sampperping,snd.npings);
            
            
        case '0013' %pulse tuple
            [pulse,pos]=rd_pulse(fd,siz,pos); %#ok
            
        case '0010' %mark tuple
            [mark,pos]=rd_mark(fd,siz,pos); %#ok
            
        case {'000F', '0020'} %time tuple
            [tm,pos]=rd_time(fd,siz,pos);
            
        case '0015' %single-beam ping tuple
            
            [ping,pos]=rd_ping(fd,siz,pos);
            
            dtx(ping.address).ptime(ping.pingnum)=ping.ptime;
            dtx(ping.address).mtime(ping.pingnum)=tm.mtime;
            dtx(ping.address).pingnum(ping.pingnum)=ping.pingnum;
            dtx(ping.address).vals(1:numel(ping.samps),...
                ping.pingnum)=log10(ping.samps);
            
        case '001D' %split-beam ping tuple
            
            [ping,pos]=rd_split(fd,siz,pos);
            
            dtx(ping.address).ptime(ping.pingnum)=ping.ptime;
            dtx(ping.address).pingnum(ping.pingnum)=ping.pingnum;
            dtx(ping.address).vals(1:numel(ping.samps),...
                ping.pingnum)=log10(ping.samps);
            
            
        case '0036' %extended channel descriptor tuple
            [snd2,pos]=rd_snd2(fd,siz,pos);
            
            %add the extended channel descriptor to the
            %original channel descriptor
            fields=fieldnames(snd2);
            sdata=struct2cell(snd2);
            snd=dtx(snd2.channel).snd;
            for i=2:length(fields)
                snd.(fields{i})=sdata{i};
            end
            dtx(snd2.channel).snd=snd;
            
        case '0031' %heading-pitch-roll tuple
            [hpr,pos]=rd_hpr(fd,siz,pos); 
            
            if nhpr==1
                hpr_est=ceil(numbytes/pos)*9;
                hpr_mat=struct('ptime',zeros(1,hpr_est),...
                    'heading',zeros(1,hpr_est),...
                    'pitch',zeros(1,hpr_est),...
                    'roll',zeros(1,hpr_est));
            end
            
            hpr_mat.ptime(nhpr)=hpr.ptime;
            hpr_mat.heading(nhpr)=hpr.heading;
            hpr_mat.pitch(nhpr)=hpr.pitch;
            hpr_mat.roll(nhpr)=hpr.roll;
            nhpr=nhpr+1;
                
            
        case '0032' %bottom pick tuple
            [bot,pos]=rd_bot(fd,siz,pos);
            
            if ~isfield(dtx,'bot')
                nsamps=arrayfun(@(x)(nan(1,snd.npings)),dtx,'un',0);
                [dtx(:).bot]=deal(nsamps{:});
            end
            if bot.flag
                dtx(bot.ch).bot(bot.pn)=bot.range;
            end
            
        case '0011' %depreciated nav string
            switch env.ftype
                case 'old'
                    [string,pos]=rd_gps_old(fd,siz,pos);
                    gpsd=decode_nmea(string);
                    gpsd.ptime=tm.ptime;
                    if ~isempty(gpsd)
                        nfields=fieldnames(gpsd);
                        
                        %estimate how many gps fixes are in file
                        %and intialize variables
                        if ngps==1
                            gps_est=ceil(numbytes/pos)*5;
                            gfields=fieldnames(gpsd);
                            vars=cell(length(gfields),1);
                            [vars{:}]=deal(nan(gps_est,1));
                            gps=cell2struct(vars,gfields);
                        end
                        
                        %populate the gps data into the struct
                        %in some files, string may not be sent at the same
                        %rate, so added flexibility
                        [~,ia,ib]=intersect(gfields,nfields);
                        for i = 1:length(ia)
                            gps.(gfields{ia(i)})(ngps)=...
                                gpsd.(nfields{ib(i)});
                        end
                        
                        ngps=ngps+1;
                    end
                case 'new'
                    fseek(fd,siz+2,'cof');
            end
            
            
        case '0030' %time-stamped nav string
            [nav,pos]=rd_gps(fd,siz,pos);
            gpsd=decode_nmea(nav.string);
           
            if ~isempty(gpsd)
                gpsd.ptime=nav.ptime;
                nfields=fieldnames(gpsd);
                
                %estimate how many gps fixes are in file
                %and intialize variables
                if ngps==1
                    gps_est=ceil(numbytes/pos)*10;
                    gfields=fieldnames(gpsd);
                    vars=cell(length(gfields),1);
                    [vars{:}]=deal(nan(gps_est,1));
                    gps=cell2struct(vars,gfields);
                else
                    gfields=fieldnames(gps);
                end
                
                
                %make sure all the fields are included in 'gps'
                check=setdiff(nfields,gfields);
                if ~isempty(check)
                     for i = 1:length(check)
                         gps.(check{i})=nan(gps_est,1);
                     end
                end
                
                %populate the gps data into the struct
                %in some files, string may not be sent at the same
                %rate, so added flexibility
                [~,ia,ib]=intersect(gfields,nfields);
                for i = 1:length(ia)
                    gps.(gfields{ia(i)})(ngps)=gpsd.(nfields{ib(i)});
                end
                
                ngps=ngps+1;

            end

        case 'FFFE'
            break
            
        otherwise
            fseek(fd,siz+2,'cof');
            
    end
end

fclose(fd);

% %have seen an instance where length(vals) > length(range);
% [m,~]=size(dtx.vals);
% if m~=length(dtx.range);
%     dtx.vals=dtx.vals(1:length(range,:));
% end



% need to fix hpr data for mutiple transducers
% %hpr data?
% if exist('hpr_mat','var');
%     hpr_mat=structfun(@(x)(x(1:nhpr-1)),hpr_mat,'un',0);
%     hfields=fieldnames(hpr_mat);
%     for i=1:env.nsdr
%         for j=2:length(hfields)
%             dtx.(hfields{j})=interp1(hpr_mat.ptime,hpr_mat.(hfields{j}),...
%                 dtx(i).ptime);
%         end
%     end
% end
%     


%trim the gps output
if ngps>1
    gps=structfun(@(x)(x(1:ngps-1)),gps,'un',0);
    goodtimes=isfinite(gps.ptime);
    gps=structfun(@(x)(x(goodtimes)),gps,'un',0);
    
    %first interpolate gps time (typically ZDA string sent at slower
    %time intervals
    if isfield(gps,'mtime')
        if any(isnan(gps.mtime))
            ctime=interp1(gps.ptime(isfinite(gps.mtime)),...
                gps.mtime(isfinite(gps.mtime)),gps.ptime,'linear','extrap');
            gps.mtime=ctime;
        end
    end
    
    %interpolate gps (if available) data onto sounder
    for i = 1:env.nsdr
        for j=1:length(gfields)
            gpsi.(gfields{j})=interp1(gps.ptime,gps.(gfields{j}),...
                dtx(i).ptime,'linear','extrap');
        end
        %make sure mtime is from gps
        dtx(i).gps=gpsi;
        %take mtime is from gps (if possible)
        if isfield(gpsi,'mtime')
            dtx(i).snd.timesource='GPS';
            dtx(i).mtime=gpsi.mtime;
        end
        
    end
    warning('on','MATLAB:interp1:NaNinY')
    varargout{1}=gps;
else
    warning('ASTEVENS:rd_dtx:nogps','No GPS data found.')
    varargout{1}=[];
end


    


t=toc;
fprintf('Done Reading File in %0.1f secs.\n',t);

%--------------------------------------------------------------------------
function [tag,siz,pos]=rd_tag(fd)

siz=fread(fd,1,'uint16');
tag=dec2hex(fread(fd,1,'uint16'),4);
pos=ftell(fd);

%--------------------------------------------------------------------------
function [sig,pos]=rd_sig(fd,siz,pos)

sig.m1=dec2hex(fread(fd,1,'uint16'),4);
fseek(fd,8,'cof');
sig.m2=dec2hex(fread(fd,1,'uint32'),8);
sig.ver_maj=dec2hex(fread(fd,1,'uint8'),2);
sig.ver_min=dec2hex(fread(fd,1,'uint8'),2);
fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function [env,pos]=rd_env(fd,siz,pos)

bits=fread(fd,siz,'uint8');
env.absorb      =        ( bits(1) + bits(2)*256 )/0.0001;
env.sv          =        ( bits(3) + bits(4)*256 )*.0025+1400;
env.temperature = twoscvt( bits(5) + bits(6)*256 )*.01;
env.salinity    =        ( bits(7) + bits(8)*256 )*.01;
env.power       = -twoscvt( bits(9) + bits(10)*256 )*.1;
env.nsdr        = bits(11) + bits(12)*256;
if siz<=12
        env.ftype='old';
        fseek(fd,siz+2+pos-ftell(fd),'cof');
        pos=ftell(fd);
        return
else
        env.tz=twoscvt( bits(13) + bits(14)*256 );
        env.dst=bits(15)+bits(16);
        env.ftype='new';
        fseek(fd,siz+2+pos-ftell(fd),'cof');
        pos=ftell(fd);
end

%--------------------------------------------------------------------------
function [snd,pos]=rd_snd(fd,siz,pos)

bits= fread(fd,siz,'uint8');

snd.address     =        ( bits(1) + bits(2)*256 );
snd.npings      = twoscvt( bits(3) + bits(4)*256+  ...
    bits(5)*65536 + bits(6)*16777216,4); %ULong
snd.sampperping =        ( bits(7) + bits(8)*256 );
snd.sampperiod  =        ( bits(9) + bits(10)*256 )/1000;
snd.pulselen    =        ( bits(13) + bits(14)*256 )/1000;
snd.pingperiod  =        ( bits(15) + bits(16)*256 )/1000; 
snd.blank       =        ( bits(17) + bits(18)*256 );
snd.maxdata     =        ( bits(19) + bits(20)*256 );
snd.threshold   = twoscvt( bits(21) + bits(22)*256 )*.01;
snd.rxee        =        bits(23+(0:127));
snd.txee        =        bits(151+(0:127));
snd.ccor        =        ( bits(279) + bits(280)*256 )*.001;
fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function [snd2,pos]=rd_snd2(fd,siz,pos)

snd2.channel=fread(fd,1,'uint16');
snd2.corrwide=fread(fd,1,'int16');
thtype=fread(fd,1,'uint16');
switch thtype
    case 40
        snd2.thtype='squared';
    case 20
        snd2.thtype='linear';
    case 0
        snd2.thtype='constant';
end
putype=fread(fd,1,'uint16');
switch putype
    case 0
        snd2.putype='passive';
    case 1
        snd2.putype='active';
end
snd2.dpt=fread(fd,1,'float');
snd2.ph=fread(fd,1,'float');
fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function eprom=rd_eprom(snd)
%rd_eprom: reads details of the eprom image from
%the channel descriptor tuple. Input "snd" is an
%output from rd_snd subroutine in the rddtx
%program.

eprom.ssn=char(snd.rxee(3:10))'; %transducer serial number
calDateSec=(snd.rxee(37)+snd.rxee(38)*256+snd.rxee(38)*65536 + snd.rxee(38)*16777216);
eprom.calDateNum=datenum(1970,1,1,0,0,0)+(calDateSec/86400);
eprom.calDateStr=datestr(eprom.calDateNum); %datestring of calibration date
eprom.calTech=char(snd.rxee(53:56))'; %initials of calibration technician
eprom.sl=(snd.rxee(59)+snd.rxee(60)*256); % source level 0.1 dB @ 1 m
eprom.rs=twoscvt(snd.rxee(65)+snd.rxee(66)*256); %0.1 dB(counts/microPa)
eprom.rsw=(snd.rxee(77)+snd.rxee(78)*256); %0.1 dB(counts/microPa)
eprom.pdpy=snd.rxee(81)/255; %sign of split beam y-axis separation (zero=positive, nonzero=negative);
eprom.pdpx=snd.rxee(82)/255; %sign of split beam y-axis separation (zero=positive, nonzero=negative);
eprom.noiseFloor=(snd.rxee(83)+snd.rxee(84)*256);  % max counts due to noise
transducerType=(snd.rxee(85)+snd.rxee(86)*256); %0=single, 3=dual, 4= split
switch transducerType
    case 0
        eprom.transducerType='single';
    case 3
        eprom.transducerType='dual';
    case 4
        eprom.transducerType='split';
end
eprom.frequency=(snd.rxee(87)+snd.rxee(88)*256+snd.rxee(89)*65536 + snd.rxee(90)*16777216); %Hz
eprom.pdy=(snd.rxee(91)+snd.rxee(92)*256); %y-axis element separation (mm)
eprom.pdx=(snd.rxee(93)+snd.rxee(94)*256); %x-axis element separation (mm)
eprom.phpy=snd.rxee(95)/255; %split beam y-axis element polarity
eprom.phpx=snd.rxee(96)/255; %split beam y-axis element polarity
eprom.aoy=(snd.rxee(97)+snd.rxee(98)*256);  %0.01 degrees
eprom.aox=(snd.rxee(99)+snd.rxee(100)*256);  %0.01 degrees
eprom.bwy=(snd.rxee(101)/255); %minor axis(y) -3dB one-way beam width, narrow beam(0.1 degrees)
eprom.bwx=(snd.rxee(102)/255); %major axis(x) -3dB one-way beam width,narrow beam (0.1 degrees)
eprom.sampleRate=(snd.rxee(103)+snd.rxee(104)*256+snd.rxee(105)*65536 + snd.rxee(106)*16777216); %hz
eprom.bwwy=(snd.rxee(107)/255); %minor axis(y) -3dB one-way beam width, wide beam(0.01 degrees)
eprom.bwwx=(snd.rxee(108)/255); %minor axis(x) -3dB one-way beam width, wide beam(0.01 degrees)
eprom.phy=(snd.rxee(109)+snd.rxee(110)*256); %y-axis phase aperture (0.1 degrees)
eprom.phx=(snd.rxee(111)+snd.rxee(112)*256); %x-axis phase aperture (0.1 degrees)

%--------------------------------------------------------------------------
function [pulse,pos]=rd_pulse(fd,siz,pos)

bits=fread(fd,siz,'uint8');

switch twoscvt( bits(1) + bits(2)*256 ),
    case 0
        pulse.type='raw';
    case 1
        pulse.type='integrated';
    case 2
        pulse.type='chirp';
end;
pulse.address     =        ( bits(3) + bits(4)*256 );
fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function [mark,pos]=rd_mark(fd,siz,pos)

bits=fread(fd,siz,'uint8');
switch twoscvt( bits(1) + bits(2)*256 ),
    case 0
        mark.type='event';
    case 1
        mark.type='start';
    case 2
        mark.type='end';
end;
mark.address     =        ( bits(3) + bits(4)*256 );
fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function [tm,pos]=rd_time(fd,siz,pos)

mtime=(fread(fd,1,'uint32')/86400)+datenum(1970,1,1);
bit=fread(fd,1,'uint8');
switch dec2hex(bit,2),
    case '02',
        tm.source='calendar';
    case '06',
        tm.source='radio';
    case '09',
        tm.source='chronometer';
    case '11',
        tm.source='GPS';
    case '12',
        tm.source='LORAN-C';
    otherwise
        fprintf('Unrecognized clock source - %s\n',...
            dec2hex(bit));
end
fseek(fd,1,'cof'); %skip ss
tm.ptime  = fread(fd,1,'uint32');
tm.mtime=mtime+rem(tm.ptime,1000)/86400000;
fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function [ping,pos]=rd_ping(fd,siz,pos)

bits=fread(fd,siz,'uint8');
ping.address =  ( bits(1) + bits(2)*256 );
ping.pingnum =  ( bits(3) + bits(4)*256+  bits(5)*65536 + ...
    bits(6)*16777216);
ping.ptime   =        ( bits(7) + bits(8)*256+ ...
    bits(9)*65536 + bits(10)*16777216);

nsamp= ( bits(11) + bits(12)*256 );


rle=[0;find(bits(14:2:end)==255);nsamp];  
nrle=[-1;bits(11+2*rle(2:end-1))+2;-1];

exponent=                       bitshift( bits(14:2:end), -4);
mantissa=   bits(13:2:end-1)+256*bitand(   bits(14:2:end),15);

il=exponent==0;
samps(il)=mantissa(il);
samps(~il)=bitshift( mantissa(~il)+hex2dec('1000'), exponent(~il)-1);

nused=0;
for k=2:length(rle),
    ping.samps((rle(k-1)+1:rle(k)-1)+nused)=samps(rle(k-1)+1:rle(k)-1);
    if nrle(k)>0,
        ping.samps((rle(k)+(0:nrle(k)-1))+nused)=0;
        nused=nused+nrle(k)-1;
    end;
end;

fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function [ping,pos] = rd_split(fd,siz,pos)

bits=fread(fd,siz,'uint8');
ping.address     =        ( bits(1) + bits(2)*256 );
ping.pingnum     =        ( bits(3) + bits(4)*256+...
    bits(5)*65536 + bits(6)*16777216);
ping.ptime       =        ( bits(7) + bits(8)*256+...
    bits(9)*65536 + bits(10)*16777216);

nsamp= ( bits(11) + bits(12)*256 );


rleI=find(bits(14:4:end)==255);
rleI2=(rleI*4)+10;
nrle=[-1;bits(rleI2-1)+2;-1];

rle=[0;rleI;nsamp];


exponent=                        bitshift( bits(14:4:end), -4);
mantissa=    bits(13:4:end-1)+256*bitand(   bits(14:4:end),15);

il=exponent==0;
samps(il)=mantissa(il);
samps(~il)=bitshift( mantissa(~il)+hex2dec('1000'), exponent(~il)-1);



nused=0;
for k=2:length(rle),
    ping.samps((rle(k-1)+1:rle(k)-1)+nused)=samps(rle(k-1)+1:rle(k)-1);
    if nrle(k)>0 && rle(k)< nsamp,
        ping.samps((rle(k)+(0:nrle(k)-1))+nused)=0;
        nused=nused+nrle(k)-1;
    end;
end;

fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function [hpr,pos]=rd_hpr(fd,siz,pos)

fseek(fd,2,'cof');
hpr.ch=fread(fd,1,'uint16');
hpr.ptime=fread(fd,1,'ulong');
fseek(fd,2,'cof');
hpr.Q_0=fread(fd,1,'float');
hpr.Q_1=fread(fd,1,'float');
hpr.Q_2=fread(fd,1,'float');
hpr.Q_3=fread(fd,1,'float');
hpr.B_N=fread(fd,1,'float');
hpr.B_E=fread(fd,1,'float');
hpr.B_D=fread(fd,1,'float');
hpr.X_N=fread(fd,1,'float');
hpr.X_E=fread(fd,1,'float');
hpr.X_D=fread(fd,1,'float');
hpr.Y_N=fread(fd,1,'float');
hpr.Y_E=fread(fd,1,'float');
hpr.Y_D=fread(fd,1,'float');


%calcuate pitch and roll for a down-looking transducer
tmp=sqrt(hpr.Y_N^2+hpr.Y_E^2);
vn=-hpr.Y_E/tmp;
ve=hpr.Y_N/tmp;
vd=0;

b_azim=atan2(hpr.Y_E,hpr.Y_N)*(180/pi);

if -hpr.Y_D>1
    b_elev=90;
elseif -hpr.Y_D<-1
    b_elev=-90;
else
    b_elev=asin(-hpr.Y_D)*(180/pi);
end

dotp=vn*hpr.X_N+ve*hpr.X_E+vd*hpr.X_D;

if dotp>1
    dotp=1;
elseif dotp<-1
    dotp=-1;
end

hpr.roll=(180/pi)*acos(dotp);
if hpr.X_D<=0
    hpr.roll=-hpr.roll;
end

if b_azim<0;
    hpr.heading=b_azim+360;
else
    hpr.heading =b_azim;
end

hpr.pitch=b_elev;


fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function [bot,pos]=rd_bot(fd,siz,pos)

bot.ch=fread(fd,1,'uint16');
bot.pn=fread(fd,1,'ulong');
bot.ptime=fread(fd,1,'ulong');
bot.flag=fread(fd,1,'uint16');
bot.sampnum=fread(fd,1,'ulong');
bot.range=fread(fd,1,'float');

fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function [nav,pos]=rd_gps(fd,siz,pos)

nav.ptime=fread(fd,1,'uint32');
fseek(fd,2,'cof');
nav.string=char(fread(fd,siz,'char')');

fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function [string,pos]=rd_gps_old(fd,siz,pos)

string=char(fread(fd,siz,'char')');
fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);

%--------------------------------------------------------------------------
function gps = decode_nmea(string)

data = textscan(string,'%s%[^\n]','delimiter',',');

%define codes and associated formats
codes={'$GPRMC';'$SDDPT';'$GPGGA';...
    '$GPVTG';'$GPZDA'};
formats={['%s %*s %f %*s %f %*s',...
    '%f %f %s %*[^\n]'];...
    '%f %*[^\n]';...
    ['%*s %f %*s %f %*s %f %f %f ',...
    '%f %*s %f %*s %f %*[^\n]'];...
    '%f %*s %f %*s %f %*s %f %*s';...
    '%s %f %f %f %f %*[^\n]'};

if isempty(intersect(data{1},codes));
    gps=[];
    return
else
    
    for i=1:length(codes);
        
        data2={data{2}(strcmpi(codes{i},data{1}))}';
        if ~isempty(data2{:})
            r=cellfun(@(x)(textscan(x,formats{i},...
                'delimiter',',')),...
                data2{:},'un',0);
            
            %replace empty cells with nan
            idx=find(cellfun(@(x)(isempty(x)),r{1}));
            nidx=num2cell(nan(1,numel(idx)));
            [r{1}{idx}]=deal(nidx{:});
            
            switch codes{i}
                case '$GPRMC'
                    times=cellfun(@(x)(str2double(x{1})),r);
                    
                    hr=fix(times./10000);
                    minute=fix((times-(hr*10000))/100);
                    sec=times-(hr*10000+minute*100);
                    
                    dates=cellfun(@(x)(textscan(char(x{6}),...
                        '%2.0f%2.0f%2.0f')),r,'un',0);
                    dmat=cell2mat(fliplr(cat(1,dates{:})));
                    gps.mtime=datenum(dmat(:,1)+2000,dmat(:,2),dmat(:,3),...
                        hr,minute,sec);
                    
                
                    %lat
                    lat=cellfun(@(x)(x{2}),r);
                    lat1=fix(lat/100);
                    lat2= (lat-(lat1*100))/60;
                    gps.latitude=lat1+lat2;
                    
                    %lon
                    lon=cellfun(@(x)(x{3}),r);
                    lon1=fix(lon/100);
                    lon2= (lon-(lon1*100))/60;
                    gps.longitude=-(lon1+lon2);
                case '$SDDPT'
                    gps.depth=cell2mat(cat(1,r{:}));
                    
                case '$GPGGA'
                    %lat
                    lat=cellfun(@(x)(x{1}),r);
                    lat1=fix(lat/100);
                    lat2= (lat-(lat1*100))/60;
                    gps.latitude=lat1+lat2;
                    
                    %lon
                    lon=cellfun(@(x)(x{2}),r);
                    lon1=fix(lon/100);
                    lon2= (lon-(lon1*100))/60;
                    gps.longitude=-(lon1+lon2);
                    
                    gps.quality=cellfun(@(x)(x{3}),r);
                    gps.nsats=cellfun(@(x)(x{4}),r);
                    gps.dilution=cellfun(@(x)(x{5}),r);
                    gps.altitude=cellfun(@(x)(x{6}),r); %msl height
                    gps.separation=cellfun(@(x)(x{7}),r); %geoid
                    gps.elevation=gps.altitude+gps.separation; %ellipsoid ht
                    gps.last_fix=cellfun(@(x)(x{8}),r);
                    
                case '$GPVTG'
                    gps.hdg_true=cellfun(@(x)(x{1}),r);
                    gps.hdg_mag=cellfun(@(x)(x{2}),r);
                    gps.spd_knots=cellfun(@(x)(x{3}),r);
                    gps.spd_kmh=cellfun(@(x)(x{4}),r);
                    
                case '$GPZDA'
                    times=cellfun(@(x)(str2double(x{1})),r);
                    
                    hr=fix(times./10000);
                    minute=fix((times-(hr*10000))/100);
                    sec=times-(hr*10000+minute*100);
                    gps.mtime=cellfun(@(x,y)(datenum(x{4},...
                        x{3},x{2},hr,minute,sec)),r);
                    
                    
            end
        end
    end
end

%--------------------------------------------------------------------------
function x = twoscvt( x, N )
%
% x = twoscvt( x, N )
%
% Converts N-byte integers in 2's complement form to numbers in the
% range [-(256^N)/2 : 256^N)/2-1].  N must be even, but is optional
% (the default value is 2 -i.e. 16-bit integers).
%
% For example:  [FFFF 8000 7FFF 0000] ---> [ -1  -32768  32767  0 ]


if( nargin < 2 ),  N = 2;  end         % use default if N is not specified

if( rem(N,2) )
    error('the number of bytes in the integers must be even')
end

M = 256^N;                             % FF....FF

i = find( x > M/2-1 );                 % x > 32767 for N = 2

x(i) = x(i) - M;
