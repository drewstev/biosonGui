function geoid=read_geoid(fname)
fid=fopen(fname,'r');

slat=fread(fid,1,'double'); %southernmost latitude
wlon=fread(fid,1,'double'); %westernmost long
dlat=fread(fid,1,'double'); %spacing
dlon=fread(fid,1,'double');

nlat=fread(fid,1,'long'); % nrows
nlon=fread(fid,1,'long'); % ncol
ikind=fread(fid,1,'long');

geoid.file=fname;
geoid.desc='geoid12A';
geoid.lon=(wlon:dlon:wlon+(nlon-1)*dlon)-360;
geoid.lat=slat:dlat:slat+(nlat-1)*dlat;
geoid.data=zeros(nlat,nlon);
for i=1:nlat
    for j=1:nlon
        geoid.data(i,j)=fread(fid,1,'float');
    end
end
fclose(fid);

