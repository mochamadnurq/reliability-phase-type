% Reliability & Hazard Function of Standby System Imperfect Switch
% with 8 identical components using 2-Erlang distribution
% Comparing Matrix and Scalar approach

clear all; addpath('..\lib');

%% INPUT: PH Representation of Components Lifetime
n = 2;
N = 8;
lamda = 0.01;
T     = fcn_T_nErlang_matrix(n,lamda,N);

%% MAIN PROGRAM
syms x
K = [0.85,0.9,0.95,1]; % Probability of success switching
for j = 1:length(K)
    j
    % Generate matrix representation of system
    tic
    Ts    = phaddsys(T,K(j)*ones(N,1));
    t1(j) = toc;

    % Calculate R(t) and h(t) values using matrix approach
    tic
    tmax = 3000;
    s    = 21;
    t    = linspace(0,tmax,s);
    u    = sparse(ones(Ts.n,1));
    for i = 1:length(t)
        i
        e  = expmq(Ts.A*t(i));
        eu = e*u;
        rsph(i,j) = Ts.a*eu;    
        hsph(i,j) = -Ts.a*Ts.A*eu/rsph(i,j);
    end
    t2(j) = toc;

    % Derive R(t) and h(t) system
    tic
    R     = fcn_R_nErlang_symbolic(n,lamda)*ones(N,1);
    Rs(x) = fcn_Rs_standby_imperfect_symbolic(K(j),R);
    Hs(x) = -diff(Rs)/Rs;
    ta(j) = toc;
    
    % Calculate R(t) and h(t) values using scalar symbolic approach
    tic
    for i = 1:length(t)
        rssym(i,j) = double(Rs(t(i)));
        hssym(i,j) = double(Hs(t(i)));
    end
    tb(j) = toc;
end

% Smoothing
rsph = full(rsph);
hsph = full(hsph);
rs = full(rssym);
hs = full(hssym);
xx = linspace(0,tmax,5*s);
for i = 1:length(K)
    z1(:,i) = interp1(t',rsph(:,i),xx,'pchip');
    z3(:,i) = interp1(t',hsph(:,i),xx,'pchip');
end

K  = K';
t1 = t1';
t2 = t2';
ta = ta';
tb = tb';
save 'data_fig_standby_imperfect_Rs_Hs.mat';

%% OUTPUT: Table of Computing Time
disp('Computing Time of Standby System with Imperfect Switching')
disp('K  : probability of success switching')
disp('t1 : time to compute PH representation of the system')
disp('t2 : time to compute 21 points of R(t) and h(t) of the system using Matrix approach')
disp('ta : time to compute scalar symbolic function of the system')
disp('tb : time to compute 21 points of R(t) and h(t) of the system using Scalar approach')
Table = table(K,t1,t2,ta,tb)

%% OUTPUT: Plot Reliability Function
figure('Name','Reliability Function');
PHLines = plot(xx,z1,'k','LineWidth',1.5);hold on;
ScLines = plot(t,rs,'ko','LineWidth',1);hold off;
PHGroup = hggroup;
ScGroup = hggroup;
set(gca,'FontName','Times New Roman','FontSize',14);
set(PHLines,'Parent',PHGroup);
set(ScLines,'Parent',ScGroup);
set(get(get(PHGroup,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
set(get(get(ScGroup,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
xlabel('\it t','FontSize',14);
ylabel('\it R(t)','FontSize',14);
title('Reliability Function','FontWeight','normal','FontSize',14);
legend('Matrix Approach','Scalar Approach');
text(60,0.06,'8 Components','FontName','Times New Roman','FontSize',14,'EdgeColor','black');
text(t(8)+40,rs(8,1),'p = 0.85','FontName','Times New Roman','FontAngle','italic','FontSize',14);
text(t(8)+40,rs(8,2),'p = 0.9','FontName','Times New Roman','FontAngle','italic','FontSize',14);
text(t(8)+40,rs(8,3),'p = 0.95','FontName','Times New Roman','FontAngle','italic','FontSize',14);
text(t(8)+40,rs(8,4),'p = 1','FontName','Times New Roman','FontAngle','italic','FontSize',14);

%% OUTPUT: Plot Hazard Function
figure('Name','Hazard Function');
PHLines = plot(xx,z3,'k');hold on;
ScLines = plot(t,hs,'ko');hold off;
PHGroup = hggroup;
ScGroup = hggroup;
set(gca,'FontName','Times New Roman','FontSize',14);
set(PHLines,'Parent',PHGroup);
set(ScLines,'Parent',ScGroup);
set(get(get(PHGroup,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
set(get(get(ScGroup,'Annotation'),'LegendInformation'),'IconDisplayStyle','on');
xlabel('Time','FontSize',14);
ylabel('h(t)','FontSize',14);
title('Hazard Function','FontWeight','normal','FontSize',14);
legend('Matrix Approach','Scalar Approach','Location','northwest');
axis([0 tmax 0 0.006]);
text(2100,0.0057,'8 Components','FontName','Times New Roman','FontSize',14,'EdgeColor','black');
text(t(10),hs(10,1),'\leftarrow p = 0.85','FontName','Times New Roman','FontAngle','italic','FontSize',14);
text(t(9),hs(9,2),'\leftarrow p = 0.9','FontName','Times New Roman','FontAngle','italic','FontSize',14);
text(t(8),hs(8,3),'\leftarrow p = 0.95','FontName','Times New Roman','FontAngle','italic','FontSize',14);
text(t(7),hs(7,4),'\leftarrow p = 1','FontName','Times New Roman','FontAngle','italic','FontSize',14);