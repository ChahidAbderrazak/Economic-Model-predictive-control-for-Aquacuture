%% EMPC Optimal Controller

% Solve a non linear optimal  feeding, temperature, DO, and UIA to reach a 
% final target weight Xf within a specific time horizon Tf
% this optimization used a non linear  ODE model  defined in : dae()
% used solver: OpenOCL: https://openocl.github.io/api-docs/v7/#apiocl_variable
% Modified by: Abderrazak Chahid  |  abderrazak-chahid.com | abderrazak.chahid@gmail.com
%#######################################################################################

function [t, X, U]=optimal_growth_EMPC_OPenOCL(Tf, N, x0)

%% Formulate the optimal control 
ocp = ocl.Problem( ...
  Tf, ...
  'vars', @vars, ...
  'dae', @dae, ...
  'pathcosts', @pathcosts, ...
  'terminalcost', @terminalcost, ...
  'N', N,'d', 3);


ocp.setInitialState('x', x0);
ocp.solve();
 
[sol,times] = ocp.solve();


%% control vector
t=times.states;
X=sol.states.x.value
u1=sol.controls.F.value;
u2=sol.controls.T.value;
u3=sol.controls.DO.value;
u4=sol.controls.UIA.value;

U=[u1;u2;u3;u4];

% save('results/ocl_optimal','Xocl','Temp','Feed_Q','t','x0')%,'DO','UIA','Fd')
% 


end


function vars(vh)
global Tmin Tmax Fmin Fmax xf R DOmin DOcri UIAmax UIAcri
vh.addState('x');
vh.addControl('F', 'lb', Fmin, 'ub', Fmax);
vh.addControl('T', 'lb', Tmin, 'ub', Tmax);
vh.addControl('DO', 'lb', DOmin, 'ub', 2*DOcri);
vh.addControl('UIA', 'lb', UIAcri/2, 'ub', UIAmax);

end



function pathcosts(ch, x, z, u, p)
global xf  Fmax DOmin UIAmax

a1=2;
a2=10;
a3=1;

%Cost function 
ch.add( (x.x - xf)^2/xf);
ch.add(  a1*(u.F/Fmax)^2 ); 
ch.add(  a2*(u.DO/DOmin)^2 );
% ch.add(  a3*(u.UIA/UIAmax)^2 );

   

end


function terminalcost(ch, x, p)
global  xf
ch.add( (x.x - xf)^2  );

end




function dae(daeh,x,z,u,p)
global      cnt Vec_noise 
x = x.x; 
f = u.F;
T = u.T;
DO = u.DO;
UIA = u.UIA;

%% fish growth model
xdot=Fish_Growth_Model(x, f, T, DO, UIA);

daeh.setODE('x',  xdot);

end

