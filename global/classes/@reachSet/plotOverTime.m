function han = plotOverTime(R,varargin)
% plotOverTime - plots the reachable set over time
%
% Syntax:  
%    han = plotOverTime(R)
%    han = plotOverTime(R,dims)
%    han = plotOverTime(R,dims,type)
%
% Inputs:
%    R - reachSet object
%    dims - (optional) dimensions for projection
%    type - (optional) plot settings (LineSpec and Name-Value pairs)
%        for plotting, including added pairs:
%          'Unify', <true/false> compute union of all reachable sets
%          'Set', <whichset> corresponding to
%                   ti ... time-interval reachable set (default)
%                   tp ... time-point reachable set (default if no ti)
%                   y  ... time-interval algebraic set
%
% Outputs:
%    han - handle to the graphics object
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: plot, reachSet

% Author:       Niklas Kochdumper
% Written:      02-June-2020
% Last update:  15-July-2020 (MW, handling of plot options)
%               01-July-2021 (MP, adding improved unify algorithm)
% Last revision:---

%------------- BEGIN CODE --------------

% default values for the optional input arguments
dims = setDefaultValues({1},varargin);

% check input arguments
inputArgsCheck({{R,'att',{'reachSet'},{''}};
                {dims,'att',{'numeric'},{'nonempty','scalar','integer','positive'}}});

% parse input arguments
NVpairs = readPlotOptions(varargin(2:end),'reachSet');
[NVpairs,unify] = readNameValuePair(NVpairs,'Unify','islogical',false);
[NVpairs,whichset] = readNameValuePair(NVpairs,'Set','ischar','ti');

% check which set has to be plotted
whichset = checkSet(R,whichset);

% check if the reachable sets should be unified to reduce the storage size
% of the resulting figure
if unify
    
    pgon = [];
    warOrig = warning;
    warning('off','all');
    
    % lists for saving corner coordinates for faster plotting algorithm
    x_list = [];
    y_list = [];
    
    % flag checking if the fast unified plotting algorithm can be used 
    % (only enabled if the time intervals are disjoint)
    
    fastUnify = false;
        
    if any(strcmp(whichset,{'ti','y'}))
        
        % assume true, check for counterexample
        fastUnify = true;
        
        for i = 1:size(R,1)

            Rset = R(i,1).timeInterval;
            
            if ~isempty(Rset)

                % check if intervals are disjoint
                disjoint_check = cellfun(@(x,y){x.supremum-y.infimum},...
                    Rset.time(1:end-1),Rset.time(2:end));
                disjoint_check = cell2mat(disjoint_check);
                disjoint_check = unique(disjoint_check);
                if length(disjoint_check) ~= 1 || disjoint_check(1) ~= 0
                    fastUnify = false;
                    break;
                end
            end
            
        end
    end
    
    % loop over all reachable sets
    for i = 1:size(R,1)
        
        % get desired set
        switch whichset
            case 'ti'
                Rset = R(i,1).timeInterval.set;
                Rtime = R(i,1).timeInterval.time;
            case 'tp'
                Rset = R(i,1).timePoint.set;
                Rtime = R(i,1).timePoint.time;
            case 'y'
                Rset = R(i,1).timeInterval.algebraic;
                Rtime = R(i,1).timeInterval.time;
        end
        
        for j = 1:length(Rset)

            % get intervals
            intX = interval(project(Rset{j},dims));
            intT = Rtime{j};

            int = cartProd(intT,intX);
            
            % check flag
            if fastUnify
                % use fast unification plotting algorithm
                % add coordinates of interval corners into lists, while
                % iterating through corners of individual intervals
                % clockwise (upper-left corner, upper-right corner,
                % lower-right corner, lower-left corner);
                % add new polygons in the middle to maintain order
                % (up_corner_p1 up_corner_p2 low_corner_p2 low_corner_p1)
                if i == 1 && j == 1
                    mid_index = 2;
                    x_list = [infimum(int(1)),supremum(int(1)),...
                        supremum(int(1)),infimum(int(1))];
                    y_list = [supremum(int(2)),supremum(int(2)),...
                        infimum(int(2)),infimum(int(2))];
                else
                    x_list = [x_list(1:mid_index),infimum(int(1)),...
                        supremum(int(1)),supremum(int(1)),infimum(int(1)),...
                        x_list(mid_index+1:end)];
                    y_list = [y_list(1:mid_index),supremum(int(2)),...
                        supremum(int(2)),infimum(int(2)),infimum(int(2)),...
                        y_list(mid_index+1:end)];
                    mid_index = mid_index + 2;
                end
                
            % Use regular unification plot algorithm
            else
            	% convert to polygon and unite with previous sets
                V = [infimum(int(1)),infimum(int(1)),...
                    supremum(int(1)),supremum(int(1));...
                    infimum(int(2)),supremum(int(2)),...
                    supremum(int(2)),infimum(int(2))];
                temp = polygon(V(1,:),V(2,:));
                pgon = pgon | temp;
            end

        end  
    end
    
    if fastUnify
        % create final polygon
        pgon = polygon(x_list,y_list);
    end
    
    % plot the resulting set
    han = plot(pgon,[1 2],NVpairs{:});
    
    warning(warOrig);
    
else
    hold on;
    
    % loop over all reachable sets
    for i = 1:size(R,1)
        
        % get desired set
        switch whichset
            case 'ti'
                Rset = R(i,1).timeInterval.set;
                Rtime = R(i,1).timeInterval.time;
            case 'tp'
                Rset = R(i,1).timePoint.set;
                Rtime = R(i,1).timePoint.time;
            case 'y'
                Rset = R(i,1).timeInterval.algebraic;
                Rtime = R(i,1).timeInterval.time;
        end
        
        for j = 1:length(Rset)

            % get intervals
            intX = interval(project(Rset{j},dims));
            if ~isa(Rtime{j},'interval')
                % time-point solution
                intT = interval(Rtime{j});
            else
                intT = Rtime{j};
            end
            int = cartProd(intT,intX);

            % plot interval
            han = plot(int,[1,2],NVpairs{:});
        end
    end
end

if nargout == 0
    clear han;
end

end


% Auxiliary function ------------------------------------------------------

function whichset = checkSet(R,whichset)

% must be character vector for switch-expression
if isempty(whichset)
    whichset = '';
end

switch whichset
    case 'ti'
        if isempty(R(1).timeInterval)
            warning("No time-interval reachable set. Time-point reachable set plotted instead.");
            whichset = 'tp';
        end
        
    case 'tp'
        % no issues (should always be computed)

    case 'y'
        if isempty(R(1).timeInterval.algebraic)
            throw(CORAerror('CORA:emptyProperty'));
        end

    otherwise
        % default value
        if isempty(whichset)
            whichset = 'ti';
            if isempty(R(1).timeInterval) 
                if ~isempty(R(1).timePoint)
                    whichset = 'tp';
                else
                    throw(CORAerror('CORA:emptySet'));
                end
            end
        else
            % has to be one of the above three cases...
            throw(CORAerror('CORA:wrongValue','Set',...
                'has to be ''ti'', ''tp'' or ''y''.'));
        end
end

end

%------------- END OF CODE --------------