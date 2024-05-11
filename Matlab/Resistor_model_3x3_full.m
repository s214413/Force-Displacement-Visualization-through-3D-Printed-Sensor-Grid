clear all;
clc;

% Declaring variables
syms eq I_s Vr1 Vr2 Vr3 Vc1 Vc2 Vc3
syms R11 R12 R13 R21 R22 R23 R31 R32 R33
syms Rx11 Rx12 Rx13 Rx21 Rx22 Rx23 Rx31 Rx32 Rx33

% The measured resistances for a 3 by 3 sensor grid
MR11 = 9658.43;
MR12 = 27496.3;
MR13 = 194177;
MR21 = 27496.3;
MR22 = 58406.6;
MR23 = 200271;
MR31 = 194177;
MR32 = 200271;
MR33 = 253233;

% Equations for the nodes made with Kirchhoff's current law
eqr1 = (Vr1 - Vc1) / R11 + (Vr1 - Vc2) / R12 + (Vr1 - Vc3) / R13;
eqr2 = (Vr2 - Vc1) / R21 + (Vr2 - Vc2) / R22 + (Vr2 - Vc3) / R23;
eqr3 = (Vr3 - Vc1) / R31 + (Vr3 - Vc2) / R32 + (Vr3 - Vc3) / R33;

eqc1 = (Vc1 - Vr1) / R11 + (Vc1 - Vr2) / R21 + (Vc1 - Vr3) / R31;
eqc2 = (Vc2 - Vr1) / R12 + (Vc2 - Vr2) / R22 + (Vc2 - Vr3) / R32;
eqc3 = (Vc3 - Vr1) / R13 + (Vc3 - Vr2) / R23 + (Vc3 - Vr3) / R33;

size = 3;
Is = [I_s 0 0];
% Prepare all equations for R11 to R33, where the current is put in the rows where the are connected to 5V
for j = 1:size
    for i = 1:size
        Req(i + size * (j - 1)) = eq == ['Vr', num2str(j)] / I_s;
        r1(i + size * (j - 1)) = Is(mod(j + 2, size) + 1) == eqr1;
        r2(i + size * (j - 1)) = Is(mod(j + 1, size) + 1) == eqr2;
        r3(i + size * (j - 1)) = Is(mod(j, size) + 1) == eqr3;
        c1(i + size * (j - 1)) = 0 == eqc1;
        c2(i + size * (j - 1)) = 0 == eqc2;
        c3(i + size * (j - 1)) = 0 == eqc3;
    end
end

% Equations for R11 to R33
for x = 1:size
    for y = 1:size
        i = y + size * (x - 1);
        MR = eval(['MR', num2str(x), num2str(y)]);
        eqr(i) = myfun(Req(i),r1(i),r2(i),r3(i),c1(i),c2(i),c3(i),x,y,MR,eq,Vr1,Vr2,Vr3,Vc1,Vc2,Vc3);
    end
end

% Custom options for the solve of nonlinear system of equations
options = optimoptions(@lsqnonlin, 'MaxFunctionEvaluations', 10000, 'MaxIterations', 10000, 'FunctionTolerance', 1e-7);
x0 = [1; 1; 1; 1; 1; 1; 1; 1; 1];
functions = matlabFunction([eqr(1);eqr(2);eqr(3);eqr(4);eqr(5);eqr(6);eqr(7);eqr(8);eqr(9)], 'Vars', {[R11;R12;R13;R21;R22;R23;R31;R32;R33]});

% Range in which a solution is acceptable for each variable
lb = [MR11, MR12, MR13, MR21, MR22, MR23, MR31, MR32, MR33];
max_value = 1e6;
ub = ones(1, 9) * max_value;

sol = lsqnonlin(functions, x0, lb, ub, options);

% Reshape the solution into a 3x3 matrix
sol_matrix = reshape(sol, [3, 3]);

% Display the matrix
disp(sol_matrix);

function [eqr] = myfun(Req, r1, r2, r3, c1, c2, c3, x, y, MR, eq, Vr1, Vr2, Vr3, Vc1, Vc2, Vc3)
    % Calculates the equation for the resistance at the measuring point from the KCL node equations

    R = sym(['R', num2str(x), num2str(y)]);  % Convert string to symbolic variable
    Rx = sym(['Rx', num2str(x), num2str(y)]); 
    Vc = ['Vc', num2str(y)];

    r1 = subs(r1, Vc, 0);    % Substitute the column voltage that is connected to ground with 0
    r2 = subs(r2, Vc, 0);
    r3 = subs(r3, Vc, 0); 
    c1 = subs(c1, Vc, 0);
    c2 = subs(c2, Vc, 0);   
    c3 = subs(c3, Vc, 0);  

    equations = [Req,r1,r2,r3,c1,c2,c3];
    equations(y + 4) = [];
    vars = [eq,Vr1,Vr2,Vr3,Vc1,Vc2,Vc3];
    vars(y + 4) = [];

    s1 = solve(equations,vars);
    Reqr = eq == s1.eq;

    Req = eq == R * Rx / (R + Rx);

    s2 = solve([Reqr,Req],[Rx,eq]);
    Rx = s2.(char(Rx));

    eqr = -R + MR * Rx / (Rx - MR);
end