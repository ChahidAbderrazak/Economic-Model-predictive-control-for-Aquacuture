%% Fish growth model
% Author: Abderrazak Chahid  |  abderrazak-chahid.com | abderrazak.chahid@gmail.com
% @2020, King Abdullah University of Science and Technology 

function [xdot]=Fish_Growth_Model(x, f, T, DO, UIA)
global   m n a b s R Tmin Tmax Topt  kmin DOcri DOmin UIAmax UIAcri j noise  disturbance 

%% generate noise
Max=1;
Min=0;
nz = noise*((Max-Min).*rand(1,1) + Min ) + (1-noise);
%% save generated noise

% consider the optimal value
%  tau=(1-Gstar)*tau + Gstar*1;

%% Apply heating if needed
if disturbance==1

%     T= T+0.02*(rand-0.5);
    f= f+0.2*(rand-0.5);

end


%% Compute (tau): the effects of temperature on food consumption and therefore anabolism using the function
tau=1;
if T>Topt
     tau= exp( -4.6*((Topt-T)/(Topt-Tmin))^4 );
   
else
     tau= exp( -4.6*((T-Topt)/(Tmax-Topt))^4 );

end

%% coefficient of catabolism (k) increases  with temperature.     
% k= kmin;%;   % (g^(1-n)/ day)
 
k= kmin*exp(j*(T-Tmin) );   % (g^(1-n)/ day)
% k=(1-noise)*k + noise*rand_vec(1,0,kmin);

% consider the optimal value
% k=(1-Gstar)*k + Gstar*kmin;

%% Photoperiod factor (ru) 0< ru < 2: many cultured fish species including tilapias tended  to feed only during daylight hours.
d = datetime('now');
Day=day(d,'dayofyear');
Lat_jeddah=21.4858;
Photoperiod_jeddah=day_length(Day,Lat_jeddah);
ru=Photoperiod_jeddah/12; 

% consider the optimal value
% ru=(1-Gstar)*ru + Gstar*1;

%% the coefficient of food consumption
h=0.8; 

% consider the optimal value
% h=(1-Gstar)*h + Gstar*1;

%% food consumption  affected when DO
sigma=1;

if DO>DOcri
     sigma=1;
   
elseif DO>DOmin
     sigma= (DO-DOmin)/(DOcri-DOmin);
     
else
    
    sigma=0;
end


% consider the optimal value
% sigma=(1-Gstar)*sigma + Gstar*1;

%% food consumption  affected when UIA
v=1;

if UIA<UIAcri
     v=1;   
elseif UIA<UIAmax
     v= (UIAmax-UIA)/(UIAmax-UIAcri);
     
else
    
    v=0;
end

 
%% Equation 1 : relative feeding level f(r)   
   % r is the actual daily ration (g/day), 
   % R is the maximal daily ration (g/day),
% f=F;%r/R;
% 
% %% Equation 2 : relative feeding level f(T, Ph, DIP, DIN,...)  
% 
% %%  P is concentration of natural food ( g/m3)
%    % lamba is the efficiency of carbon fixation (dimensionless),
%    % A is the alkalinity (mg l1 CaCO3),
%    % Hplus is the hydrogen ion concentration   (mol/L),
%    % k1the first dissociation constant for carbonate:bicarbonate system
%    % k2 is the the second dissociation constant for carbonate:bicarbonate system
%    % T is the water temperature (�C).
%    % The constants of 12 and 50  are gram equivalent weights of C and CaCO3
% 
% k1=(T/15 + 2.6)*10^-7;
% k2=(T/10 + 2.2)*10^-11;
% 
% Pc=12*lamba*(A/50)*( (Hplus^2)/k1 +  Hplus + k2)/( Hplus + 2*k2 );
% 
% %% Pn is the PNPP derived from total dissolved inorganic nitrogen DIN [ g/(m3*day*C) ]
%     % Dn is the DIN (mg/L*N), 
% Pn=40*Dn/7;
% 
% %% Pp is the PNPP derived from total dissolved inorganic phosphorus DIP (mg/L*N), 
%     % Dp is the  DIP (mg/L*N),
% Pp=40*Dp;
% 
% %% relative feeding level ( f ) with potential net primary productivity (PNPP) [ g/(m3*day*C) ]
% P= min([Pc, Pn, Pp]);      
% 
% %% relative feeding level ( f )  Equation 1
%     % s is the proportionality coefficient of PNPP to natural food (dimensionless) was estimated 
% f=1-exp(-s*(P/B));
 


%% fish growth rate

%% DOE system
C1=b*(1-a)*ru*tau;
% xdot =0.7658*f*x^m - 0.0013*x^n;
xdot =C1*f*x^m - k*x^n ;

end

