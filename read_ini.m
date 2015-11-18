function ini=read_ini(fname)
% READ_INI - read GUI parameter file

if ~exist(fname,'file')
        error('File not found.')
end



fid=fopen(fname);
names = textscan(fid,'%s%*[^\n]');
names=names{1};
frewind(fid);
data=textscan(fid,'%*s =%[^\n]');
data=data{1};

params={'filename','%s';...
    'pathname','%s';...
    'outpath','%s';...
    'avgint','%f';...
    'blanking','%f';...
    'smoothing','%f';...
    'channel','%f';...
    'gpsOffset','%f';...
    'maxdepth','%f';...
    'mindepth','%f';...
    'quantity','%s',;...
    'sal','%f';...
    'temp','%f',;...
    'threshold','%f';...
    'vegHeight','%f'};

for i=1:length(names);
    ind=find(strcmpi(names{i},params(:,1)), 1);
    
    if ~isempty(ind)
        if ~isempty(data{i})
            data2=textscan(data{i},params{ind,2},'delimiter','\t');
            switch params{ind,2}
                case '%s'
                    ini.(names{i})=data2{:}{1};
                case '%f'
                    ini.(names{i})=data2{:};
            end
                    
        else
            ini.(names{i})=[];
        end
    else
        errordlg(sprintf('Unknown keyword encountered: %s',...
            names{i}),'modal');       
        error('ASTEVENS:read_ini:badString',...
            'Unknown keyword encountered: %s',...
            names{i})

    end
end

fclose(fid);