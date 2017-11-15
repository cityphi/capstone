function lab1

  disp('------------------------------------------------------');
  disp('------------------------------------------------------');
  disp('|                     Lab 1                          |');
  disp('------------------------------------------------------');
  disp('------------------------------------------------------');


  % Point we are using as x_i
  x = 5.0;

  % Delta x's that we will use in our finite-difference approximations
  dx1 = 0.5;
  dx2 = dx1/2;
  dx3 = dx2/2;
  dx4 = dx3/2;
  dx5 = dx4/2;

  % Exact derivative of y at x=5
  exact1 = dy(5.0);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Approximation of the first derivative
  
 approx11 = dyapprox(x, dx1);
 approx12 = dyapprox(x, dx2);
 approx13 = dyapprox(x, dx3);
 approx14 = dyapprox(x, dx4);
 approx15 = dyapprox(x, dx5);

  % Errors using first-order method
   disp('Errors for first-order finite-difference, (first column of table)')
   error11 = abs(exact1 -approx11)
   error12 = abs(exact1 -approx12)
   error13 = abs(exact1 -approx13)
   error14 = abs(exact1 -approx14)
   error15 = abs(exact1 -approx15)
  
  % Order of convergence
  disp('Actual order of convergence for first-order method, (second column of table)')
   order11 = log(error12/error11)/log(dx2/dx1)
   order12 = log(error13/error12)/log(dx3/dx2)
   order13 = log(error14/error13)/log(dx4/dx3)
   order14 = log(error15/error14)/log(dx5/dx4)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Approximation of the second derivative 
  
  %Exact second derivative of y at x=5
  exact2 = d2y(5.0);
  
 approx21 = d2yapprox(x, dx1);
 approx22 = d2yapprox(x, dx2);
 approx23 = d2yapprox(x, dx3);
 approx24 = d2yapprox(x, dx4);
 approx25 = d2yapprox(x, dx5);

  % Errors using first-order method
   disp('Errors for first-order finite-difference, (first column of table)')
   error21 = abs(exact2 -approx21)
   error22 = abs(exact2 -approx22)
   error23 = abs(exact2 -approx23)
   error24 = abs(exact2 -approx24)
   error25 = abs(exact2 -approx25)
  
  % Order of convergence
  disp('Actual order of convergence for first-order method, (second column of table)')
   order21 = log(error22/error21)/log(dx2/dx1)
   order22 = log(error23/error22)/log(dx3/dx2)
   order23 = log(error24/error23)/log(dx4/dx3)
   order24 = log(error25/error24)/log(dx5/dx4)
  
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Approximation of the third derivative 
  
  %Exact third derivative of y at x=5
  exact3 = d3y(5.0);
  
 approx31 = d3yapprox(x, dx1);
 approx32 = d3yapprox(x, dx2);
 approx33 = d3yapprox(x, dx3);
 approx34 = d3yapprox(x, dx4);
 approx35 = d3yapprox(x, dx5);

  % Errors using first-order method
   disp('Errors for first-order finite-difference, (first column of table)')
   error31 = abs(exact3 -approx31)
   error32 = abs(exact3 -approx32)
   error33 = abs(exact3 -approx33)
   error34 = abs(exact3 -approx34)
   error35 = abs(exact3 -approx35)
  
  % Order of convergence
  disp('Actual order of convergence for first-order method, (second column of table)')
   order31 = log(error32/error31)/log(dx2/dx1)
   order32 = log(error33/error32)/log(dx3/dx2)
   order33 = log(error34/error33)/log(dx4/dx3)
   order34 = log(error35/error34)/log(dx5/dx4)

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Produce plots
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 % Number of points in the plots
 %    - Adjust this to adjust how small Delta x gets.
 %      It starts at 1/2 and is divided by 2 "n" times
 n = 33;

 % Initialize Storage
 dxs = zeros(n,1);
 errors1 = zeros(n,1);
 errors2 = zeros(n,1);
 errors3 = zeros(n,1);

 % loop through, filling "dxs", "errors1", "errors2", and "errors3".
 for i = 1:n
   % Each time through the loop, Delta x is half as big
   dxs(i) = 0.5^i;
   errors1(i)=abs(exact1-dyapprox(x,dxs(i)));
   errors2(i)=abs(exact2-d2yapprox(x,dxs(i)));
   errors3(i)=abs(exact3-d3yapprox(x,dxs(i)));
 end

 % Compute the log of the inverse of delta x
 loginvdxs = log10(1./dxs);

 % Compute the log of the errors
 logerrors1 = log10(errors1);
 logerrors2 = log10(errors2);
 logerrors3 = log10(errors3);

 % Compute reference lines with the expected slope
 %    - the "-2" is just an offset so that the reference
 %      line does not intersect the error line.
 refline1 = -3*loginvdxs-2;
 refline2 = -2*loginvdxs-2;
 refline3 = -1*loginvdxs-2;

 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Make three figures
 figure(1);
 plot(loginvdxs,logerrors1,'-o',loginvdxs,refline1)
 legend('finite-difference','referemce, slope = -3')
 title('Third-order finite-difference error for the first derivative as a funtion of Delta x')
 xlabel('log10(1/Delta x)')
 ylabel('log10(error)')

 figure(2);
 plot(loginvdxs,logerrors2,'-o',loginvdxs,refline2)
 legend('finite-difference','reference, slope = -2')
 title('Second-order finite-difference error for the second derivative as a funtion of Delta x')
 xlabel('log10(1/Delta x)')
 ylabel('log10(error)')

 figure(3);
 plot(loginvdxs,logerrors3,'-o',loginvdxs,refline3)
 legend('finite-difference','reference, slope = -1')
 title('First-order finite-difference error for the third derivative as a funtion of Delta x')
 xlabel('log10(1/Delta x)')
 ylabel('log10(error)')

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   The function we are analysing evaluated at x
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = y(x)
  output = (x^3)*sin(x);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The exact derivative of the function we are analysing
%  evaluated at x.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = dy(x)
  output = 3*x^2*sin(x)+x^3*cos(x);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The exact second derivative of the function we are analysing
%  evaluated at x.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = d2y(x)
  output = 6*x^2*cos(x)+(6*x-x^3)*sin(x);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  The exact third derivative of the function we are analysing
%  evaluated at x.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = d3y(x)
  output = (18*x-x^3)*cos(x)+(6-9*x^2)*sin(x);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  A third-order approximation to the derivative of y
%  at x using a step size of "dx"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = dyapprox(x,dx)
  output = (1.0/(6*dx))*(-11*y(x)+18*y(x+dx)-9*y(x+2*dx)+2*y(x+3*dx));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  A second-order approximation to the second derivative of y
%  at x using a step size of "dx"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = d2yapprox(x,dx)
  output = 1.0/(dx*dx)*(2*y(x)-5*y(x+dx)+4*y(x+2*dx)-y(x+3*dx));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  A first-order approximation to the third derivative of y
%  at x using a step size of "dx"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function output = d3yapprox(x,dx)
  output = 1.0/(dx*dx*dx)*(-1*y(x)+3*y(x+dx)-3*y(x+2*dx)+y(x+3*dx));
end
