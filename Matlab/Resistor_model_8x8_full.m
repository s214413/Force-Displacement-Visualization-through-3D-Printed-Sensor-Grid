clear all;
clc;

% Declaring variables
syms eq I_s Vr1 Vr2 Vr3 Vr4 Vr5 Vr6 Vr7 Vr8 Vc1 Vc2 Vc3 Vc4 Vc5 Vc6 Vc7 Vc8
for i = 1:8
    for j = 1:8
        eval(['syms R', num2str(i), num2str(j)]);
        eval(['syms Rx', num2str(i), num2str(j)]);
    end
end

% The measured resistances for a 8 by 8 sensor grid
MR11 = NaN; MR12 = NaN; MR13 = NaN; MR14 = NaN; MR15 = NaN; MR16 = NaN; MR17 = NaN; MR18 = NaN; 
MR21 = NaN; MR22 = NaN; MR23 = NaN; MR24 = NaN; MR25 = NaN; MR26 = NaN; MR27 = NaN; MR28 = NaN; 
MR31 = NaN; MR32 = NaN; MR33 = NaN; MR34 = NaN; MR35 = NaN; MR36 = NaN; MR37 = NaN; MR38 = NaN; 
MR41 = NaN; MR42 = NaN; MR43 = NaN; MR44 = NaN; MR45 = NaN; MR46 = NaN; MR47 = NaN; MR48 = NaN;
MR51 = NaN; MR52 = NaN; MR53 = NaN; MR54 = NaN; MR55 = NaN; MR56 = NaN; MR57 = NaN; MR58 = NaN;
MR61 = NaN; MR62 = NaN; MR63 = NaN; MR64 = NaN; MR65 = NaN; MR66 = NaN; MR67 = NaN; MR68 = NaN;
MR71 = NaN; MR72 = NaN; MR73 = NaN; MR74 = NaN; MR75 = NaN; MR76 = NaN; MR77 = NaN; MR78 = NaN;
MR81 = NaN; MR82 = NaN; MR83 = NaN; MR84 = NaN; MR85 = NaN; MR86 = NaN; MR87 = NaN; MR88 = NaN;

% Equations for the nodes made with Kirchhoff's current law
eqr1 = (Vr1 - Vc1) / R11 + (Vr1 - Vc2) / R12 + (Vr1 - Vc3) / R13 + (Vr1 - Vc4) / R14 + (Vr1 - Vc5) / R15 + (Vr1 - Vc6) / R16 + (Vr1 - Vc7) / R17 + (Vr1 - Vc8) / R18;
eqr2 = (Vr2 - Vc1) / R21 + (Vr2 - Vc2) / R22 + (Vr2 - Vc3) / R23 + (Vr2 - Vc4) / R24 + (Vr2 - Vc5) / R25 + (Vr2 - Vc6) / R26 + (Vr2 - Vc7) / R27 + (Vr2 - Vc8) / R28;
eqr3 = (Vr3 - Vc1) / R31 + (Vr3 - Vc2) / R32 + (Vr3 - Vc3) / R33 + (Vr3 - Vc4) / R34 + (Vr3 - Vc5) / R35 + (Vr3 - Vc6) / R36 + (Vr3 - Vc7) / R37 + (Vr3 - Vc8) / R38;
eqr4 = (Vr4 - Vc1) / R41 + (Vr4 - Vc2) / R42 + (Vr4 - Vc3) / R43 + (Vr4 - Vc4) / R44 + (Vr4 - Vc5) / R45 + (Vr4 - Vc6) / R46 + (Vr4 - Vc7) / R47 + (Vr4 - Vc8) / R48;
eqr5 = (Vr5 - Vc1) / R51 + (Vr5 - Vc2) / R52 + (Vr5 - Vc3) / R53 + (Vr5 - Vc4) / R54 + (Vr5 - Vc5) / R55 + (Vr5 - Vc6) / R56 + (Vr5 - Vc7) / R57 + (Vr5 - Vc8) / R58;
eqr6 = (Vr6 - Vc1) / R61 + (Vr6 - Vc2) / R62 + (Vr6 - Vc3) / R63 + (Vr6 - Vc4) / R64 + (Vr6 - Vc5) / R65 + (Vr6 - Vc6) / R66 + (Vr6 - Vc7) / R67 + (Vr6 - Vc8) / R68;
eqr7 = (Vr7 - Vc1) / R71 + (Vr7 - Vc2) / R72 + (Vr7 - Vc3) / R73 + (Vr7 - Vc4) / R74 + (Vr7 - Vc5) / R75 + (Vr7 - Vc6) / R76 + (Vr7 - Vc7) / R77 + (Vr7 - Vc8) / R78;
eqr8 = (Vr8 - Vc1) / R81 + (Vr8 - Vc2) / R82 + (Vr8 - Vc3) / R83 + (Vr8 - Vc4) / R84 + (Vr8 - Vc5) / R85 + (Vr8 - Vc6) / R86 + (Vr8 - Vc7) / R87 + (Vr8 - Vc8) / R88;

eqc1 = (Vc1 - Vr1) / R11 + (Vc1 - Vr2) / R21 + (Vc1 - Vr3) / R31 + (Vc1 - Vr4) / R41 + (Vc1 - Vr5) / R51 + (Vc1 - Vr6) / R61 + (Vc1 - Vr7) / R71 + (Vc1 - Vr8) / R81;
eqc2 = (Vc2 - Vr1) / R12 + (Vc2 - Vr2) / R22 + (Vc2 - Vr3) / R32 + (Vc2 - Vr4) / R42 + (Vc2 - Vr5) / R52 + (Vc2 - Vr6) / R62 + (Vc2 - Vr7) / R72 + (Vc2 - Vr8) / R82;
eqc3 = (Vc3 - Vr1) / R13 + (Vc3 - Vr2) / R23 + (Vc3 - Vr3) / R33 + (Vc3 - Vr4) / R43 + (Vc3 - Vr5) / R53 + (Vc3 - Vr6) / R63 + (Vc3 - Vr7) / R73 + (Vc3 - Vr8) / R83;
eqc4 = (Vc4 - Vr1) / R14 + (Vc4 - Vr2) / R24 + (Vc4 - Vr3) / R34 + (Vc4 - Vr4) / R44 + (Vc4 - Vr5) / R54 + (Vc4 - Vr6) / R64 + (Vc4 - Vr7) / R74 + (Vc4 - Vr8) / R84;
eqc5 = (Vc5 - Vr1) / R15 + (Vc5 - Vr2) / R25 + (Vc5 - Vr3) / R35 + (Vc5 - Vr4) / R45 + (Vc5 - Vr5) / R55 + (Vc5 - Vr6) / R65 + (Vc5 - Vr7) / R75 + (Vc5 - Vr8) / R85;
eqc6 = (Vc6 - Vr1) / R16 + (Vc6 - Vr2) / R26 + (Vc6 - Vr3) / R36 + (Vc6 - Vr4) / R46 + (Vc6 - Vr5) / R56 + (Vc6 - Vr6) / R66 + (Vc6 - Vr7) / R76 + (Vc6 - Vr8) / R86;
eqc7 = (Vc7 - Vr1) / R17 + (Vc7 - Vr2) / R27 + (Vc7 - Vr3) / R37 + (Vc7 - Vr4) / R47 + (Vc7 - Vr5) / R57 + (Vc7 - Vr6) / R67 + (Vc7 - Vr7) / R77 + (Vc7 - Vr8) / R87;
eqc8 = (Vc8 - Vr1) / R18 + (Vc8 - Vr2) / R28 + (Vc8 - Vr3) / R38 + (Vc8 - Vr4) / R48 + (Vc8 - Vr5) / R58 + (Vc8 - Vr6) / R68 + (Vc8 - Vr7) / R78 + (Vc8 - Vr8) / R88;

size = 8;
Is = [I_s zeros(1, size-1)];
% Prepare all equations for R11 to R33, where the current is put in the rows where the are connected to 5V
for j = 1:size
    for i = 1:size
        Req(i + size * (j - 1)) = eq == ['Vr', num2str(j)] / I_s;
        r1(i + size * (j - 1)) = Is(mod(j + 7, size) + 1) == eqr1;
        r2(i + size * (j - 1)) = Is(mod(j + 6, size) + 1) == eqr2;
        r3(i + size * (j - 1)) = Is(mod(j + 5,size) + 1) == eqr3;
        r4(i + size * (j - 1)) = Is(mod(j + 4, size) + 1) == eqr4;
        r5(i + size * (j - 1)) = Is(mod(j + 3, size) + 1) == eqr5;
        r6(i + size * (j - 1)) = Is(mod(j + 2, size) + 1) == eqr6;
        r7(i + size * (j - 1)) = Is(mod(j + 1, size) + 1) == eqr7;
        r8(i + size * (j - 1)) = Is(mod(j, size) + 1) == eqr8;

        c1(i + size * (j - 1)) = 0 == eqc1;
        c2(i + size * (j - 1)) = 0 == eqc2;
        c3(i + size * (j - 1)) = 0 == eqc3;
        c4(i + size * (j - 1)) = 0 == eqc4;
        c5(i + size * (j - 1)) = 0 == eqc5;
        c6(i + size * (j - 1)) = 0 == eqc6;
        c7(i + size * (j - 1)) = 0 == eqc7;
        c8(i + size * (j - 1)) = 0 == eqc8;
    end
end

% Equations for R11 to R88
for x = 1:size
    for y = 1:size
        i = y + size * (x - 1);
        MR = eval(['MR', num2str(x), num2str(y)]);
        eqr(i) = myfun(Req(i),r1(i),r2(i),r3(i),r4(i),r5(i),r6(i),r7(i),r8(i),c1(i),c2(i),c3(i),c4(i),c5(i),c6(i),c7(i),c8(i), ...
            x,y,MR,eq,Vr1,Vr2,Vr3,Vr4,Vr5,Vr6,Vr7,Vr8,Vc1,Vc2,Vc3,Vc4,Vc5,Vc6,Vc7,Vc8);
    end
end

% Custom options for the solve of nonlinear system of equations
options = optimoptions(@lsqnonlin, 'MaxFunctionEvaluations', 10000, 'MaxIterations', 10000, 'FunctionTolerance', 1e-7);
x0 = ones(size^2, 1);
R = [R11; R12; R13; R14; R15; R16; R17; R18; 
     R21; R22; R23; R24; R25; R26; R27; R28; 
     R31; R32; R33; R34; R35; R36; R37; R38; 
     R41; R42; R43; R44; R45; R46; R47; R48; 
     R51; R52; R53; R54; R55; R56; R57; R58; 
     R61; R62; R63; R64; R65; R66; R67; R68; 
     R71; R72; R73; R74; R75; R76; R77; R78; 
     R81; R82; R83; R84; R85; R86; R87; R88];
functions = matlabFunction(eqr, 'Vars', {R});

% Range in which a solution is acceptable for each variable
lb = [MR11, MR12, MR13, MR14, MR15, MR16, MR17, MR18, ...
      MR21, MR22, MR23, MR24, MR25, MR26, MR27, MR28, ...
      MR31, MR32, MR33, MR34, MR35, MR36, MR37, MR38, ...
      MR41, MR42, MR43, MR44, MR45, MR46, MR47, MR48, ...
      MR51, MR52, MR53, MR54, MR55, MR56, MR57, MR58, ...
      MR61, MR62, MR63, MR64, MR65, MR66, MR67, MR68, ...
      MR71, MR72, MR73, MR74, MR75, MR76, MR77, MR78, ...
      MR81, MR82, MR83, MR84, MR85, MR86, MR87, MR88];
max_value = 1e6;
ub = ones(1, size^2) * max_value;

sol = lsqnonlin(functions, x0, lb, ub, options);

% Reshape the solution into a 8x8 matrix
sol_matrix = reshape(sol, [size, size]);

% Display the matrix
disp(sol_matrix);

function [eqr] = myfun(Req,r1,r2,r3,r4,r5,r6,r7,r8,c1,c2,c3,c4,c5,c6,c7,c8,x,y,MR,eq,Vr1,Vr2,Vr3,Vr4,Vr5,Vr6,Vr7,Vr8,Vc1,Vc2,Vc3,Vc4,Vc5,Vc6,Vc7,Vc8)
% Calculates the equation for the resistance at the measuring point from the KCL node equations

    R = sym(['R', num2str(x), num2str(y)]);  % Convert string to symbolic variable
    Rx = sym(['Rx', num2str(x), num2str(y)]); 
    Vc = ['Vc', num2str(y)];

    r1 = subs(r1, Vc, 0);    % Substitute the column voltage that is connected to ground with 0
    r2 = subs(r2, Vc, 0);
    r3 = subs(r3, Vc, 0); 
    r4 = subs(r4, Vc, 0); 
    r5 = subs(r5, Vc, 0); 
    r6 = subs(r6, Vc, 0); 
    r7 = subs(r7, Vc, 0); 
    r8 = subs(r8, Vc, 0); 

    c1 = subs(c1, Vc, 0);
    c2 = subs(c2, Vc, 0);    
    c3 = subs(c3, Vc, 0);   
    c4 = subs(c4, Vc, 0);   
    c5 = subs(c5, Vc, 0);   
    c6 = subs(c6, Vc, 0);   
    c7 = subs(c7, Vc, 0); 
    c8 = subs(c8, Vc, 0);   

    equations = [Req,r1,r2,r3,r4,r5,r6,r7,r8,c1,c2,c3,c4,c5,c6,c7,c8];
    equations(y + 9) = [];
    vars = [eq,Vr1,Vr2,Vr3,Vr4,Vr5,Vr6,Vr7,Vr8,Vc1,Vc2,Vc3,Vc4,Vc5,Vc6,Vc7,Vc8];
    vars(y + 9) = [];

    s1 = solve(equations,vars);
    Reqr = eq == s1.eq;

    Req = eq == R * Rx / (R + Rx);

    s2 = solve([Reqr,Req],[Rx,eq]);
    Rx = s2.(char(Rx));

    eqr = -R + MR * Rx / (Rx - MR);
end