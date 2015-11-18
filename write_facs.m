function write_facs(filename,lon,lat,z,mtime,varargin)
%WRITE_FACS - write nav file in facs format

if ~isempty(varargin)
    method=varargin{1};
else
    method='interp';
end

fprintf('Writing file: %s \n',filename);

%loose the nans
ind=(isfinite(lon)==1 & ...
    isfinite(lat)==1 & ...
    isfinite(z)==1 & ...
    isfinite(mtime)==1);
xr=lon(ind);
yr=lat(ind);
zr=z(ind);
dn=mtime(ind);

%limit output to 1 s intervals
dni=dn(1):(1/86400):max(dn);
switch method
    case 'interp'
        [dnu,ui]=unique(dn);
        xc=interp1(dnu,xr(ui),dni);
        yc=interp1(dnu,yr(ui),dni);
        zc=interp1(dnu,zr(ui),dni);
    case 'none'
        [dni,ui]=unique(dn);
        xc=xr(ui);
        yc=yr(ui);
        zc=zr(ui);
end

%config the times
[year,month,day,hr,mini,sec]=datevecfix(dni,'precision',2);
doy=(datenum(year,month,day)-datenum(year,1,1))+1;
secr=floor(sec);
tsec=floor((sec-secr).*10);

%write the file
fid=fopen(filename,'wt');
for i=1:length(xc)
    fprintf(fid,'%d%0.3d%0.2d%0.2d%0.2d%d\t',...
        year(i),doy(i),hr(i),mini(i),secr(i),tsec(i));
    fprintf(fid,'%.6f\t',yc(i));
    fprintf(fid,'%.6f\t',xc(i));
    fprintf(fid,'%.2f\n',zc(i));
end
fclose(fid);
