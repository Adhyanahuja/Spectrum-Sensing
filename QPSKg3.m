%QPSKg3
clc
clear all
close all

format long

N = 200;  
snr_dB =-8; %dB
snr = 10.^(snr_dB./10);
Pf = 0.01:0.01:1;
uc = 0.1;
%% QPSK Signal

L=1500;
data = round(rand(1,L));                               % Data sequence
uni2bip=2*data-1;                                      % Convert unipolar to bipolar
T=1;                                                   % Bit duration
Eb=T/2;                                                % This will result in unit amplitude waveforms
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
w=0.7071*sqrt(2*2*Eb/T)*cos(2*pi*fc*t + 3*pi/4);                         % carrier waveform
qpsk_w=bw.*w;                                          % modulated waveform


 %% Probabilty of double threshold
u=1000; 
Pfa = Pf;
for m=1:5
 for i =1:length(Pf)
              Dcv=0;
              Dps0=0;
              Dps1 = 0;
              K = 0;
              W=5-K;
              FC_E=0;
          for j = 1:1000

%      lambda(i)=gammaincinv(1-Pf(i),u)*2; %theshold
%      Pdth(i)=marcumq(sqrt(2*snr),sqrt(lambda(i)),u);

        %-----AWGN noise with mean 0 and variance -----%
         Noise = randn(1,N); 
         vn=var(Noise);
         %-----Real valued Gaussian Primary User Signal------% 

         Signal = sqrt(snr).*qpsk_w(1:200);
         vs=var(Signal);

         Recv_Sig = Signal + Noise; % Received signal at SU 1

         Energy = abs(Recv_Sig).^2; % Energy of received signal over N samples

         %------- Threshold-----------

         Threshold_0(i) = N*vn + qfuncinv(Pf(i))*sqrt(2*N*vn^2);
         Threshold_1(i) = (1-uc)*Threshold_0(i);
         Threshold_2(i) = (1+uc)*Threshold_0(i);

         %------------------------------------
%          Threshold =  N*vn + qfuncinv(Pf)*sqrt(2*N*vn^2);
%          Pdth = qfunc((Threshold -N*(vn+vs))./(sqrt(2*N*(vn+vs)^2)));
         %-----Computation of Test statistic for energy detection-----%
         X(m) =sum(Energy);

         %% ------------------Conventional---------------------
           if X(m) >= Threshold_0(i)
               Dcv = Dcv +1;
           end

        %% Proposed scheme

            if X(m) <= Threshold_1(i)
               %Pfa(i) = qfunc((Threshold_0(i)-N*vn)./(sqrt(2*N*vn^2)));
               FC(m) = 0;
               Dps0 = Dps0 +1 ;
               K=K+1;
               Lf(K)=FC(m);
           elseif  X(m) >= Threshold_2(i) 
              FC(m) = 1;
              %Pdsim(m,i) = qfunc((Threshold_2(i) -N*(vn+vs))./(sqrt(2*N*(vn+vs)^2))); 
              Dps1 = Dps1 + 1;
              K=K+1;
              Lf(K)=FC(m);
           else
               FC(m) = X(m);
               FC_E=FC_E+FC(m);
               if W~=0
    X_avg = FC_E/W;
    if (X_avg < Threshold_0(i))
        Lf(K+1) = 0;
    else
        Lf(K+1) = 1;
         
         
    end
end 
            end
            
        end      
     Pdcv(m,i) = Dcv/j;
     Pdps(m,i) = Dps1/j;
     Pfps(m,i) = Dps0/j;
     Pdps(K+1,i) = qfunc((Threshold_0(i) -N*(vn+vs))./(sqrt(2*N*(vn+vs)^2)));
  end

end

for i=1:100
     PdcvOR(i)=1-prod(1-Pdcv(:,i));
     PdpsOR(i)=1-prod(1-Pdps(:,i));
 end

plot(Pf,PdcvOR,'b-o',Pf,PdpsOR,'g-*');
grid on
axis([0.0001,1,0.0001,1]);
xlabel('Cooperative probability of False alarm (Q_{fa})');
ylabel('Cooperative Probability of  Detection (Q_d)');
legend('Conventional scheme','Proposed scheme');
title('QPSK ROC')
