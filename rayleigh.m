% Comparitive study between rayleigh fading and AWGN channel
clc;
clear all;
close all;


% Initialisation of data sequence matrices
data_sequence1 = [];            
data_sequence2 = [];  

% Total bits
N = 10^5;

for i = 1:N 
data_sequence1 = [data_sequence1 (-1+2*round(rand(1,1)))];    % inphase part
data_sequence2 = [data_sequence2 (-1+2*round(rand(1,1)))];    % quarature part
end
% Final combined data sequence    
final_Data = [data_sequence1; data_sequence2];     
% SNR range
SNR_dB = [-15:20]; 

for i = 1:length(SNR_dB)
   
   sig = sqrt(1/10^(SNR_dB(i)/10));
   % AWGN
   n = sig*(randn(2,N) + 1i*randn(2,N));  
   % Rayleigh channel
   h = randn(2,N) + 1i*randn(2,N); 
   y = h.*final_Data + n; 
   % equalization of received data by channel information at the receiver
   y_rcv = y./h;
   % Threshold comparison
   Data_rcv = [Clean(real(y_rcv(1,:))); Clean(real(y_rcv(2,:)))]; 
   % BER calculation
   Err(i) = sum(sum(round(final_Data) ~= round(Data_rcv))); 

end  
 
SNR_lin = 10.^(SNR_dB/10);
% BER for AWGN channel using QPSK
AWGN_Ber = 0.5*erfc(sqrt(SNR_lin/2)); 
% BER for Rayleigh channel using QPSK
Ray_Ber = Err/(2*N);

% plot
semilogy(SNR_dB,AWGN_Ber,'b-o');
hold on
semilogy(SNR_dB,Ray_Ber,'g-*');
axis([-15 20 10^-5 0.5])
legend('AWGN channel','Rayleigh channel');
xlabel('SNR (dB)');
ylabel('Bit Error Rate');
title('Bit error rate plot for QPSK');   