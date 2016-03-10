function [C, eventStart, eventMean, eventEnd] = CurvatureOnNoldusData(Xnose,Ynose,TrialTime)
%Crego 02-2016 MattVDMeer Course VTE Project
%Adapted from 2016-01-14. JJS. Calculates curvature on a vector of timestamped x,y position data.
%For use on a single trial from Noldus, exported into Excel, and then the
%relevant variables copy-pasted into matlab variables.

%   Input variables
%       Xnose = x position of the rat's nose
%       Ynose = y position of the rat's nose
%       TrialTime = timestamps relative to some event marker
%   Output variables
%       C = tsd of curvature values 
%       eventStarts = timestamp 200ms before the mean of the curvature event
%       eventMeans = timestamp at mean of curvature event (usually very close to the highest value)
%       eventEnds = timestamp at end

%process_varargin(varargin);


%% Check size
assert(length(Xnose)==length(Ynose)); % xdata and ydata need to be same length
assert(length(Xnose)==length(TrialTime)); % # of timestamps needs to equal the length of the data

%% Remove strings % if > 0, then we need to remove the '-' strings that are inserted by noldus for missing timestamps with NaNs, which matlab can handle
assert(iscell(Xnose)==iscell(Ynose))
if iscell(Xnose);
    XstringIndex = cellfun(@isstr,Xnose); % index of elements in the array Xnose that are strings (i.e. '-' marks)
    YstringIndex = cellfun(@isstr,Ynose); % index of elements in the array Ynose that are strings (i.e. '-' marks)
    strcheck = XstringIndex==YstringIndex;
    assert(sum(strcheck)==length(Xnose)) % check to confirm that missing data points in Xposition are identical to those missing in Yposition
    T = TrialTime(XstringIndex==0); % Removes timestamps for the corresponding position samples that are indexed above
    temp1 = Xnose(XstringIndex==0); temp2 = cell2mat(temp1); x = tsd(T,temp2); % Removes elements of Xnose that are strings
    temp3 = Ynose(YstringIndex==0); temp4 = cell2mat(temp3); y = tsd(T,temp4); % Removes elements of Ynose that are strings
end
%% Get velocity and acceleration
dx = dxdt(x); dx = tsd(T, dx.data(T, 'extrapolate', nan)); % takes first derivate of x position. Creates tsd of xvelocity and time
dy = dxdt(y); dy = tsd(T, dy.data(T, 'extrapolate', nan)); % takes first derivate of y position. Creates tsd of yvelocity and time
ddx = dxdt(dx); ddx = tsd(T, ddx.data(T, 'extrapolate', nan)); % takes derviate of xvelocity. Creates tsd of xacceleration and time.
ddy = dxdt(dy); ddy = tsd(T, ddy.data(T, 'extrapolate', nan)); % takes derivate of yvelocity. Creates tsd of yacceleration and time.
%% Calculate curvature values of the trajectory
% dx, dy: velocity
% ddx, ddy: acceleration
% C: curvature, as defined by Hart 1999 (Int J Med Informatics)
% C(t) = (dx(t) * ddy(t) + dy(t) * ddx(t))*(dx(t)^2+dy(t)^2)^-3/2
% from code by ADR 2012 Nov
N = (dx.data .* ddy.data + dy.data .* ddx.data); % numerator in above equation
D = (dx.data.^2 + dy.data.^2).^(1.5); % denominator in above equation
C = tsd(T, N./D); % tsd of curvature values for each position sample in the trajectory
% v = tsd(sd.C.range, abs(RobustZ(sd.C.data))); % only applicable to data from an entire session
%%
% minV = 0;
% maxV = +3;

% f = find(v.data(T)>thresh);
% if ~isempty(f)
%     plot(-y0.data(T(f)),-x0.data(T(f)), 'ko', 'MarkerSize', 10);
%     
%     % find start, stop and meantime for curvature events
%     d = [nan; diff(T(f))];
%     f0 = find(d>1); % try w/ 1sec threshold
%     eventStart = [T(f(1)); T(f(f0))]-0.2;
%     eventStarts(iL,1:length(eventStart)) = eventStart;
%     
%     eventEnd = [T(f(f0-1)); T(f(end))]+0.2;
%     eventEnds(iL,1:length(eventEnd)) = eventEnd;
%     
%     plot(x0.data(eventStarts(iL)),y0.data(eventStarts(iL)), 'g*', 'MarkerSize',15); 
%     plot(x0.data(eventEnds(iL)),y0.data(eventEnds(iL)), 'r*', 'MarkerSize',15);
%     
%     eventMean = (eventEnds(iL)+eventStarts(iL))/2;
%     eventMeans(iL,1:length(eventMean)) = eventMean;
% end
