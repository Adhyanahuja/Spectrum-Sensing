%QAMg2
clc
clear all
close all
format long

N = 200;  
snr_dB =-5; %dB
snr = 10.^(snr_dB./10);
Pf = 0.01:0.01:1;
uc = 0.1;
%% BPSK Signal

m = 64;                                                % 64-QAM
k = log2(m);                                           % Number of bits per symbol
AmI = 0.53945;                                         % amplitude level corresponding to phi1
AmQ = 0.53945;                                         % amplitude level corresponding to phi2
L=1500;
data = round(rand(1,L));                               % Data sequence
uni2bip=2*data-1;                                      % Convert unipolar to bipolar
T=1;                                                   % Bit duration
Eb=T/2;                                                % This will result in unit amplitude waveforms
Ep = sqrt(Eb * (2^k - 1) * 1.5);                       % Peak energy value
fc=3/T;                                                % Carrier frequency
t=linspace(0,5,1500);                                  % discrete time sequence between 0 and 5*T (15000 samples)
K=length(t);                                           % Number of samples
Nsb=K/length(data);                                    % Number of samples per bit
dd=repmat(data',1,Nsb);                                % replicate each bit Nsb times
bb=repmat(uni2bip',1,Nsb); dw=dd';                     % Transpose the rows and columns
dw=dw(:)'; 

%------ Convert dw to a column vector (colum by column) and convert to a row vector
bw=bb';
bw=bw(:)';                                             % Data sequence samples
w=sqrt(Ep/2)*AmI*cos(2*pi*fc*t + pi/4) + sqrt(Ep/2)*AmQ*sin(2*pi*fc*t + pi/4);                        % carrier waveform
bpsk_w=bw.*w;                                          % modulated waveform

 %% Probabilty of single and double threshold
Pf2 = Pf;
 hwait = waitbar(0,'Please wait....');
 for i =1:length(Pf)
   D_sg=0;
   D_db=0;
   for j=1:10000
        %-----AWGN noise with mean 0 and variance -----%
         Noise = randn(1,N); 
         vn=var(Noise);
         %-----Real valued Gaussian Primary User Signal------% 

         Signal = sqrt(snr).*bpsk_w(1:200);
         vs=var(Signal);

         Recv_Sig = Signal + Noise; % Received signal at SU 1

         Energy = abs(Recv_Sig).^2; % Energy of received signal over N samples

         %------- Threshold-----------

         Threshold_0(i) = N*vn + qfuncinv(Pf(i))*sqrt(2*N*vn^2);
         Threshold_1(i) = (1-uc)*Threshold_0(i);
         Threshold_2(i) = (1+uc)*Threshold_0(i);

         %------------------------------------

         %-----Computation of Test statistic for energy detection-----%
         X =sum(Energy);

         %---------------------------------------

         if ( X > Threshold_0(i) )
             Pd_sg(i) = qfunc((Threshold_0(i) -N*(vn+vs))./(sqrt(2*N*(vn+vs)^2)));
             D_sg = D_sg +1;
         end        
         if ( X > Threshold_1(i) )
             Pd2(i) = qfunc((Threshold_1(i) -N*(vn+vs))./(sqrt(2*N*(vn+vs)^2)));
             D_db = D_db +1;
         end

   end
      Pd_sg(i) = D_sg/j;
      Pd2(i) = D_db/j;
      waitbar(i/length(Pf),hwait);
 end
 close(hwait);
plot(Pf,Pd_sg,'b-o')
grid on
hold on
plot(Pf,Pd2,'g-*') 
axis([0.0001,1,0.0001,1]);
legend('single threshold','double threshold')
ylabel('Probability of Detection (P_d)');
xlabel('Probability of false alarm (P_{fa})');
title('QAM ROC')
