function [ts,sv]=calcTsSv(dtx,varargin)
% [sv,ts]=calcTs(dtx): calculates volume
% backscattering strength (sv) and target strength
% (ts) in dB using equations found in Biosonics' DT4
% Data file format specification document 
% (sec. 6.3.1, document dated Dec. 2004)
%
% Input: dtx is the data structure output by Rich
% Palowicsz's rddtx program.
%
% Option: [sv,ts]=calcTs(dtx,'plotit'): produces
% simple plots of volume scattering and target strength
%
% A.Stevens @ USGS 01/25/2007
% astevens@usgs.gov


%Backwards compatibility with 
%Rich's original code (eprom image was not read)
if isnumeric(dtx.snd.rxee);
    dtx.snd.rxee=rd_eprom(dtx.snd);
end

%calculate absorption coefficient assuming depth=0
%and pH=8. Temp and sal from values in DT4 file.
absC=calcAlpha(dtx.env.salinity,dtx.env.temperature,...
    dtx.snd.rxee.frequency/1000,0,8)/1000;

%calculate 2-way beam angle
psi=(dtx.snd.rxee.bwx/20)*(dtx.snd.rxee.bwy/20)*10.^(-3.16);


[m,n]=size(dtx.vals);
ts=zeros(m,n);
sv=zeros(m,n);
dtx.vals(dtx.vals==0)=1;

for i=1:m
    %equation 4a in Biosonics document
    ts(i,1:n)=(20.*dtx.vals(i,1:n))- ...
        (dtx.snd.rxee.sl+dtx.snd.rxee.rs+(dtx.env.power*10))./10+...
        (40.*log10(dtx.range(i)))+...
        (2*absC*dtx.range(i))+...
        (dtx.snd.ccor./100);
    
    %equation 4b in Biosonics document 
    sv(i,1:n)=(20.*dtx.vals(i,1:n))- ... 
        (dtx.snd.rxee.sl+dtx.snd.rxee.rs+(dtx.env.power*10))./10+...
        (20.*log10(dtx.range(i)))+...
        (2*absC*dtx.range(i))-...
        (10*log10(dtx.env.sv*(dtx.snd.pulselen/1000)*(psi/2)))+...
        (dtx.snd.ccor./100);
end

if any(strcmpi(varargin,'plotit'))==1;
    figure
    imagesc(dtx.pingnum,-dtx.range,ts)
    set(gca,'ydir','normal')
    ylabel('Range (m)','fontsize',14)
    xlabel('Ping #','fontsize',14)

    c1=colorbar;
    set(get(c1,'ylabel'),'string','Target Strength (dB)',...
        'fontsize',14)
    
    orient landscape
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', [0.25 1.5 10.5  5.5]);
    
    figure
    imagesc(dtx.pingnum,-dtx.range,sv)
    set(gca,'ydir','normal')
    ylabel('Range (m)','fontsize',14)
    xlabel('Ping #','fontsize',14)

    c1=colorbar;
    set(get(c1,'ylabel'),'string','Volume Scattering Strength (dB)',...
        'fontsize',14)
    
    orient landscape
    set(gcf, 'PaperPositionMode', 'manual');
    set(gcf, 'PaperUnits', 'inches');
    set(gcf, 'PaperPosition', [0.25 1.5 10.5  5.5]);
end

%--------------------------------------------------------------------------

function alpha=calcAlpha(sal,temp,freq,depth,pH)
% CALCALPHA(sal,temp,freq,depth,pH): calculates
% sound absorption coefficient in dB/km based on the 
% equation of Francois and Garrison,
% 1982, J. Acoust. Soc. Am 17 (6) pp. 1879-????.
%
% Inputs:  sal:   salinity, psu
%         temp:   temperature, degC
%         freq:   transducer frequency, kHz
%        depth:   depth, m
%           pH:   pH, don't know units 
%
% A.Stevens @ USGS 01/25/2007
% astevens@usgs.gov

phi=temp+273;
svel=sw_svel(sal,temp,depth); %sound velocity, see subfunction from 
                              %seawater tookit below

%boric acid contribution
a1=(8.86/svel)*10^((0.78*pH)-5);
p1=1;
f1=(2.8.*(sal/35)).^0.5*10.^(4-(1245/phi));

%magnesium sulfate contribution
a2=21.44*(sal/svel)*(1+(0.025*temp));
p2=(1-(1.37e-4*depth))+(6.2e-9.*depth.^2);
f2=(8.17.*10.^(8-(1990/phi)))./(1+(0.0018*(sal-35)));

%pure water contribution
if temp<20
    a3=4.937e-4-(2.59e-5.*temp)+(9.11e-7.*temp.^2)-...
        (1.50e-8.*temp.^3);
else
    a3=3.964e-4-(1.146e-5.*temp)+(1.45e-7.*temp.^2)-...
        (6.5e-10.*temp.^3);
end

p3=(1-(3.83e-5.*depth))+(4.9e-10.*depth.^2);

alpha=(((a1*p1*f1*freq.^2)./(freq.^2+f1.^2)) + ...
    ((a2*p2*f2*freq.^2)/(freq.^2+f2.^2)) + (a3*p3*freq.^2));



%--------------------------------------------------------------------------
function eprom=rd_eprom(snd)
%rd_eprom: reads details of the eprom image from
%the channel descriptor tuple. Input "snd" is an
%output from rd_snd subroutine in the rddtx
%program.


eprom.ssn=char(snd.rxee(3:10))'; %transducer serial number
calDateSec=(snd.rxee(37)+snd.rxee(38)*256+snd.rxee(38)*65536 + ...
    snd.rxee(38)*16777216);
eprom.calDateNum=datenum(1970,1,1,0,0,0)+(calDateSec/86400);
eprom.calDateStr=datestr(eprom.calDateNum); %datestring of calibration date
eprom.calTech=char(snd.rxee(53:56))'; %initials of calibration technician
eprom.sl=(snd.rxee(59)+snd.rxee(60)*256); % source level 0.1 dB @ 1 m
eprom.rs=twoscvt(snd.rxee(65)+snd.rxee(66)*256); %0.1 dB(counts/microPa)
eprom.rsw=(snd.rxee(77)+snd.rxee(78)*256); %0.1 dB(counts/microPa)
eprom.pdpy=snd.rxee(81)/255; %sign of split beam y-axis 
                             %separation (zero=positive, nonzero=negative);
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
eprom.frequency=(snd.rxee(87)+snd.rxee(88)*256+snd.rxee(89)*65536 +...
    snd.rxee(90)*16777216); %Hz
eprom.pdy=(snd.rxee(91)+snd.rxee(92)*256); %y-axis element separation (mm)
eprom.pdx=(snd.rxee(93)+snd.rxee(94)*256); %x-axis element separation (mm)
eprom.phpy=snd.rxee(95)/255; %split beam y-axis element polarity
eprom.phpx=snd.rxee(96)/255; %split beam y-axis element polarity
eprom.aoy=(snd.rxee(97)+snd.rxee(98)*256);  %0.01 degrees
eprom.aox=(snd.rxee(99)+snd.rxee(100)*256);  %0.01 degrees
eprom.bwy=(snd.rxee(101)/255); %minor axis(y) -3dB one-way beam width,
                               %narrow beam(0.1 degrees)
eprom.bwx=(snd.rxee(102)/255); %major axis(x) -3dB one-way beam width,narrow beam (0.1 degrees)
eprom.sampleRate=(snd.rxee(103)+snd.rxee(104)*256+snd.rxee(105)*65536 +...
    snd.rxee(106)*16777216); %hz
eprom.bwwy=(snd.rxee(107)/255); %minor axis(y) -3dB one-way beam width, wide beam(0.01 degrees)
eprom.bwwx=(snd.rxee(108)/255); %minor axis(x) -3dB one-way beam width, wide beam(0.01 degrees)
eprom.phy=(snd.rxee(109)+snd.rxee(110)*256); %y-axis phase aperture (0.1 degrees)
eprom.phx=(snd.rxee(111)+snd.rxee(112)*256); %x-axis phase aperture (0.1 degrees)