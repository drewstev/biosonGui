function gps = decode_nmea(string,varargin)
%DECODE_NMEA - decode NMEA strings into a structure
% 
%   INPUT - NMEA strint
%   OPTIONAL INPUT - base date, string eg. '2019-01-23' is used 
%       to calculate time and date of strings that do not include the 
%       date.

data = textscan(string,'%s%[^\n]','delimiter',',');

if nargin>1 
    base_date=datenum(varargin{1});
end
    

%define codes and associated formats
codes={'$GPRMC';'$SDDPT';'$GPGGA';...
    '$GPVTG';'$GPZDA'};
formats={['%s %*s %f %*s %f %*s',...
    '%f %f %s %*[^\n]'];...
    '%f %*[^\n]';...
    ['%s %f %*s %f %*s %f %f %f ',...
    '%f %*s %f %*s %f %*[^\n]'];...
    '%f %*s %f %*s %f %*s %f %*s';...
    '%s %f %f %f %f %*[^\n]'};

if isempty(intersect(data{1},codes))
    gps=[];
    return
else
    
    for i=1:length(codes)
        
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
                    %time
                    times=cellfun(@(x)(textscan(char(x{1}),...
                        '%2.0f%2.0f%2.0f')),r,'un',0);
                    dates=cellfun(@(x)(textscan(char(x{6}),...
                        '%2.0f%2.0f%2.0f')),r,'un',0);
                    tmat=cell2mat(cat(2,fliplr(cat(1,dates{:})),...
                        cat(1,times{:})));
                    gps.mtime=datenum(tmat(:,1)+2000,tmat(:,2),tmat(:,3),...
                        tmat(:,4),tmat(:,5),tmat(:,6));
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
                    times=cellfun(@(x)(textscan(char(x{1}),...
                        '%2c%2c%5c')),r,'un',0);
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
                    
                    gps.quality=cellfun(@(x)(x{4}),r);
                    gps.nsats=cellfun(@(x)(x{5}),r);
                    gps.dilution=cellfun(@(x)(x{6}),r);
                    gps.altitude=cellfun(@(x)(x{7}),r);
                    gps.geoid=cellfun(@(x)(x{8}),r);
                    gps.last_fix=cellfun(@(x)(x{9}),r);
                    
                case '$GPVTG'
                    gps.hdg_true=cellfun(@(x)(x{1}),r);
                    gps.hdg_mag=cellfun(@(x)(x{2}),r);
                    gps.spd_knots=cellfun(@(x)(x{3}),r);
                    gps.spd_kmh=cellfun(@(x)(x{4}),r);
                    
                case '$GPZDA'
                    times=cellfun(@(x)(textscan(char(x{1}),...
                        '%2.0f%2.0f%2.0f')),r,'un',0);
                    gps.mtime=cellfun(@(x,y)(datenum(x{4},...
                        x{3},x{2},y{1},y{2},y{3})),r,times);
                    
                    
            end
        end
    end
end


