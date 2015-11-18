function [nav,pos]=rd_pos(fd,siz,pos)

nav.latitude=fread(fd,1,'long')/6e6;
nav.longitude=fread(fd,1,'long')/6e6;
fseek(fd,2,'cof')
nav.ptime=fread(fd,1,'ulong');
nav.altitude=fread(fd,1,'float');

fseek(fd,siz+2+pos-ftell(fd),'cof');
pos=ftell(fd);



