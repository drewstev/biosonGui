function [env,pos]=rd_env(fd,siz,pos)

bits=fread(fd,siz,'uint8');
env.absorb      =        ( bits(1) + bits(2)*256 )/0.0001;
env.sv          =        ( bits(3) + bits(4)*256 )*.0025+1400;
env.temperature = twoscvt( bits(5) + bits(6)*256 )*.01;
env.salinity    =        ( bits(7) + bits(8)*256 )*.01;
env.power       = twoscvt( bits(8) + bits(10)*256 )*.1;
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