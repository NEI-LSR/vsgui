function s = fitGaussian2(x,y,R,w,varargin)

% [rho, sigx, sigy, x0, y0, A, B]

%param_init = [0, 5, 5, 0, 0, 1,0];

if nargin == 3
    w = [];
end

for i=1:length(varargin)/2
    par_name = lower(varargin{(i-1)*2+1});
    par_val = lower(varargin{i*2});
    switch par_name
        case 'plot_opt'
            plot_opt = par_val;
        case 'init'
            param_init = par_val;
        otherwise
    end
end

%opts = optimset('TolX',1e-12,'TolFun',1e-12,'MaxIter',10000,...
%    'Display','off','MaxFunEvals',5000);
opts = optimoptions('lsqnonlin','MaxIter',400,...
    'Display','off');
%{
x = dat.x;
y = dat.y;
R = dat.g;
%}
    
R_prime = NaN(size(R));


Au = max(R(:)) * 2;
Al = 0;

Bu = max(R(:));
Bl = 0;
% after 10.3.2018
% [rho, sigx, sigy, x0, y0, A, B]

if ~exist('param_init','var')
    [~,idx] = max(R);
    param_init = [0, 5, 5, x(idx), y(idx), max(R) - min(R), min(R)];
end

lb = [-1, 0, 0, min(x), min(y), Al, Bl]';
ub = [1, max(x)-min(x), max(y)-min(y), max(x), max(y), Au, Bu]';

if isempty(w)
    [param, sse, res, exitflag, output] = ...
        lsqnonlin(@errfun, param_init, lb, ub, opts);
else
    [param, sse, res, exitflag, output] = ...
        lsqnonlin(@errfun_weighted, param_init, lb, ub, opts);
end
%[param, fval, exitflag, output] = fminsearch(@errfun, param_init, opts);

sse = sum((R(:) - R_prime(:)).^2);
ssTotal = sum((R(:) - mean(R(:))).^2);
Rsqr = 1 - sse/ssTotal;

s.param.rho = param(1);
s.param.sigx = param(2);
s.param.sigy = param(3);
s.param.x0 = param(4);
s.param.y0 = param(5);
s.param.A = param(6);
s.param.B = param(7);
s.Rsqr = Rsqr;
s.exitflag = exitflag;
s.output = output;
s.g = R_prime;

    function err = errfun(param)
        R_prime = gaussian2(param,x,y);
        err = R - R_prime;
    end

    function err = errfun_weighted(param)
        R_prime = gaussian2(param,x,y);
        err = (R - R_prime).*w;
    end

end


function g = gaussian2(param,X,Y)

rho = param(1);
sigx = param(2);
sigy = param(3);
x0 = param(4);
y0 = param(5);
A = param(6);
B = param(7);

g = A * (exp(-1*((X-x0).^2/sigx^2 + (Y-y0).^2/sigy^2 - ...
    2*rho*(X-x0).*(Y-y0)/(sigx*sigy))/(2*(1-rho^2)))) + B;

end

