function res = testLongDuration_conZonotope_isFullDim
% testLongDuration_conZonotope_isFullDim - unit test function of isFullDim
%
% Syntax:  
%    res = testLongDuration_conZonotope_isFullDim
%
% Inputs:
%    -
%
% Outputs:
%    res - true/false
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: -

% Author:       Mark Wetzlinger
% Written:      14-March-2021
% Last update:  ---
% Last revision:---

%------------- BEGIN CODE --------------

res = true;

% check empty conZonotope
cZ = conZonotope();
if isFullDim(cZ)
    res = false;
end


% number of tests
nrOfTests = 1000;

for i=1:nrOfTests
    % random dimension
    n = randi([1,50]);
    % random center
    c = randn(n,1);
    % random generator matrix (at least n generators)
    G = randn(n,n+randi(10));
    nrGens = size(G,2);
    
    % instantiate conZonotope without constraints
    cZ = conZonotope(c,G);
    
    % assert correctness
    if ~isFullDim(cZ)
        res = false; break;
    end
    
    % random constraints so that conZonotope represents just a point
    % as A being diagional forces each independent factor to one value
    A = diag(1+rand(nrGens,1));
    b = sign(randn(nrGens,1));
    % instantiate conZonotope with constraints
    cZ = conZonotope(c,G,A,b);
    
    % assert correctness
    if isFullDim(cZ)
        res = false; break;
    end
    
end


if ~res
    path = pathFailedTests(mfilename());
    save(path,'n','c','G','A','b');
end

%------------- END OF CODE --------------