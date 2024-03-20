function S = uminus(S)
% uminus - overloads the unary '-' operator
%
% Syntax:
%    res = -S
%    res = uminus(S)
%
% Inputs:
%    S - contSet object
%
% Outputs:
%    S - negated set 
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: -

% Authors:       Tobias Ladner
% Written:       06-April-2023
% Last update:   ---
% Last revision: ---

% ------------------------------ BEGIN CODE -------------------------------

S = -1 * S;

% ------------------------------ END OF CODE ------------------------------
