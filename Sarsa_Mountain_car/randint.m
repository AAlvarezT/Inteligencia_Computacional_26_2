function out = randint(varargin)
%
%
%WARNING: This is an obsolete function and may be removed in the future.
%         Please use RANDI instead.
%
%
%RANDINT Generate matrix of uniformly distributed random integers.
%   OUT = RANDINT generates a "0" or "1" with equal probability.
%
%   OUT = RANDINT(M) generates an M-by-M matrix of random binary numbers.
%   "0" and "1" occur with equal probability.
%
%   OUT = RANDINT(M,N) generates an M-by-N matrix of random binary numbers.
%   "0" and "1" occur with equal probability.
%
%   OUT = RANDINT(M,N,IRANGE) generates an M-by-N matrix of random integers.
%
%   IRANGE can be either a scalar or a two-element vector:
%   Scalar : If IRANGE is a positive integer, then the output integer
%            range is [0, IRANGE-1].  If IRANGE is a negative integer,
%            then the output integer range is [IRANGE+1, 0].
%   Vector : If IRANGE is a two-element vector, then the output
%            integer range is [IRANGE(1), IRANGE(2)].
%
%   OUT = RANDINT(M,N,IRANGE,STATE) causes RAND to use the generator
%   determined by the 'state' method, and initializes the state of that
%   generator using the value of STATE.
%
%   Examples:
%       r1 = randint(2,3)                 
%       r2 = randint(2,3,4)
%       r3 = randint(2,3,-4)              
%       r4 = randint(2,3,[-2 2])
%
%   See also RAND, RANDSRC, RANDERR.

%   Copyright 1996-2012 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $ $Date: 2012/04/14 03:45:37 $

%warning(message('comm:system:warnobsolete:obsoleteReplace', 'RANDI'));

% Basic function setup.
error(nargchk(0,4,nargin,'struct'));

% --- Placeholder for the signature string.
sigStr = '';
m = [];
n = [];
range = [];
state = [];

% --- Identify string and numeric arguments
for i=1:nargin
   if(i>1)
      sigStr(size(sigStr,2)+1) = '/';
   end;
   % --- Assign the string and numeric flags
   if(isnumeric(varargin{i}))
      sigStr(size(sigStr,2)+1) = 'n';
   else
      error(message('comm:randint:InvalidArg'));
   end;
end;

% --- Identify parameter signatures and assign values to variables
switch sigStr
   % --- randint
   case ''

   % --- randint(m)
   case 'n'
      m		= varargin{1};

	% --- randint(m, n)
	case 'n/n'
      m		= varargin{1};
      n		= varargin{2};

	% --- randint(m, n, range)
	case 'n/n/n'
      m		= varargin{1};
      n  	= varargin{2};
      range = varargin{3};

	% --- randint(m, n, range, state)
	case 'n/n/n/n'
      m		= varargin{1};
      n		= varargin{2};
      range = varargin{3};
      state = varargin{4};

   % --- If the parameter list does not match one of these signatures.
   otherwise
      error(message('comm:randint:InvalidSyntax'));
end;

if isempty(m)
   m = 1;
end
if isempty(n)
   n = m;
end
if isempty(range)
   range = [0, 1];
end

len_range = size(range,1) * size(range,2);

% Typical error-checking.
if all(length(m) > 1) || all(length(n) > 1)
   error(message('comm:randint:InvalidMatrixDims'));
elseif (floor(m) ~= m) || (floor(n) ~= n) || (~isreal(m)) || (~isreal(n))
   error(message('comm:randint:NonIntegerMatrixDims'));
elseif (m < 0) || (n < 0)
   error(message('comm:randint:NonPositiveMatrixDims'));
elseif (~isfinite(m)) || (~isfinite(n))
   error(message('comm:randint:NonFiniteMatrixDims'));
elseif len_range > 2
   error(message('comm:randint:InvalidIrange'));
elseif max(max(floor(range) ~= range)) || (~isreal(range)) || all(~isfinite(range))
   error(message('comm:randint:NonIntIrange'));
end

% If the IRANGE is specified as a scalar.
if len_range < 2
    if range < 0
        range = [range+1, 0];
    elseif range > 0
        range = [0, range-1];
    else
        range = [0, 0];    % Special case of zero range.
    end
end

% Make sure IRANGE is ordered properly.
range = sort(range);

% Calculate the range the distance for the random number generator.
distance = range(2) - range(1);

% Set the initial state if specified.
if ~isempty(state)
   rand('state', state);
end

% Generate the random numbers.
r = floor(rand(m, n) * (distance+1));

% Offset the numbers to the specified value.
out = ones(m,n)*range(1);
out = out + r;

% [EOF] randint.m
