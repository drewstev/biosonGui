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