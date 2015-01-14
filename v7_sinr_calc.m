%% v5(1) - new path-loss model for LPNs, antenna gain and noise figure added
%% v6 - adapted for v10 of the macro site simulation - excluded impossible scenario (number of own int nodes==0) and macro calculations
%% Frequency
% cases 626 MHz, or 2.32 GHz for the common band

tic
% f_comm=626*10^6;
f_comm=2.32*10^9;
f_exc=2.31*10^9;
common_ch_frequency=f_comm/10^6;

%% Bandwidth 
% bandwidth for common channel 5 and 8 MHz for 626 MHz, and 5 MHz for 2.32
% GHz
w=[5*10^6 10*10^6 15*10^6 20*10^6];
% Wcom=8*10^6;
Wcom=5*10^6;
common_ch_width=Wcom/10^6;


%% Power (dBm)
% Power in the commonly shared band - 36,31,26,11,6,1

P_exc_dbm=37;
P_comm_dbm=1;


%% Antenna gain (dBi)
antGain_exc=5;
antGain_comm=0;


%% Noise (dBm)
NF=9; % noise figure (dB)
noise_exc_dbm= -173.9325+NF+10*log10(w);
noise_exc_lin=10.^((noise_exc_dbm-30)/10);
noise_comm_dbm=-173.9325+NF+10*log10(Wcom);
noise_comm_lin=10^((noise_comm_dbm-30)/10);

% we will not consider macro cell here - use already obtained SINR
% distribution


%% Number of LPNs and interferers
number_of_own_lpns_per_cell=[2,4,10,20];

number_of_interfs_per_cell=[0,3,10,20,30];


%% Start of script

for u=4:4

for v=3:3
    
    load(strcat('v11_dist_non_uniform_RRH_',num2str(number_of_own_lpns_per_cell(u)),'_with_',num2str(number_of_interfs_per_cell(v)),'_int.mat')); 
    
        
%% Received signal RRH/LPN
% distance_all_ues_2_closest_RRH(snapshots x users)

%% Exclusive band
   for i=1:size(distance_all_ues_2_closest_RRH,1)
    for j=1:size(distance_all_ues_2_closest_RRH,2)
        
        % changed from Extended Hata model to ITU Urban microcell
        % using 10m cells
         
%            [PL_exc_all_serving_RRH(i,j),stdMtx_exc_serving(i,j)]= ExtendedHata(distance_all_ues_2_closest_RRH(i,j)/1000,f_exc/10^6,1.5,5,6);

            if probLoS_all_ues_closest_RRH(i,j)==1
           [PL_exc_all_serving_RRH(i,j),stdMtx_exc_serving(i,j)]= UrbanMicroLoS(distance_all_ues_2_closest_RRH(i,j),f_exc/10^9,1.5,10);
           signal_exc_all_ues(i,j)=P_exc_dbm + antGain_exc -PL_exc_all_serving_RRH(i,j)- normrnd(0,stdMtx_exc_serving(i,j));
           
            else
            [PL_exc_all_serving_RRH(i,j),stdMtx_exc_serving(i,j)]= UrbanMi_NonLoS(distance_all_ues_2_closest_RRH(i,j),f_exc/10^9,1.5,10);
           signal_exc_all_ues(i,j)=P_exc_dbm + antGain_exc - PL_exc_all_serving_RRH(i,j) - normrnd(0,stdMtx_exc_serving(i,j));
           
            end
    end
   end
   

signal_exc_lin=10.^((signal_exc_all_ues-30)/10);

%% Common 
% distance_all_ues_2_closest_RRH(snapshots x users)

switch common_ch_frequency
    
    case 626
   
        % Extended Hata

for i=1:size(distance_all_ues_2_closest_RRH,1)
    for j=1:size(distance_all_ues_2_closest_RRH,2)
      
          
            [PL_comm_all_serving_RRH(i,j),stdMtx_comm_serving(i,j)]= ExtendedHata(distance_all_ues_2_closest_RRH(i,j)/1000,f_comm/10^6,1.5,10,6);
            signal_comm_all_ues(i,j)=P_comm_dbm + antGain_comm-PL_comm_all_serving_RRH(i,j) - normrnd(0,stdMtx_comm_serving(i,j));
    
    end
end
    case 2320
        
        % ITU Urban micro-cell 2-6 GHz
        
        for i=1:size(distance_all_ues_2_closest_RRH,1)
        for j=1:size(distance_all_ues_2_closest_RRH,2)
                    
                    
                    if probLoS_all_ues_closest_RRH(i,j)==1
         
            [PL_comm_all_serving_RRH(i,j),stdMtx_comm_serving(i,j)]= UrbanMicroLoS(distance_all_ues_2_closest_RRH(i,j),f_comm/10^9,1.5,10);
            signal_comm_all_ues(i,j)=P_comm_dbm + antGain_comm -PL_comm_all_serving_RRH(i,j) - normrnd(0,stdMtx_comm_serving(i,j)) ;
            
                    else
                
            [PL_comm_all_serving_RRH(i,j),stdMtx_comm_serving(i,j)]= UrbanMi_NonLoS(distance_all_ues_2_closest_RRH(i,j),f_comm/10^9,1.5,10);
            signal_comm_all_ues(i,j)=P_comm_dbm + antGain_comm -PL_comm_all_serving_RRH(i,j) - normrnd(0,stdMtx_comm_serving(i,j));
                
                
                    end
        end
        end
end       
        
signal_comm_lin=10.^((signal_comm_all_ues-30)/10);


%% Interference from own LPNs/RRHs
% distance_all_ues_2_own_interf (snapshots x users x (own_RRH-1))
if number_of_own_lpns_per_cell(u)~=1 
    
    %exclusive band

    for i=1:size(distance_all_ues_2_own_interf,1)
    for j=1:size(distance_all_ues_2_own_interf,2)

     for k=1:size(distance_all_ues_2_own_interf,3)
         
            if probLoS_all_ues_own_int(i,j,k)==1
         
          [PL_int_own_exc(i,j,k),stdMtx_own_int_exc(i,j,k)]=UrbanMicroLoS(distance_all_ues_2_own_interf(i,j,k),f_exc/10^9,1.5,10);
          interferer_own_exc(i,j,k)= P_exc_dbm + antGain_exc - PL_int_own_exc(i,j,k)- normrnd(0,stdMtx_own_int_exc(i,j,k));
          
            else
                
          [PL_int_own_exc(i,j,k),stdMtx_own_int_exc(i,j,k)]=UrbanMi_NonLoS(distance_all_ues_2_own_interf(i,j,k),f_exc/10^9,1.5,10);
          interferer_own_exc(i,j,k)= P_exc_dbm + antGain_exc - PL_int_own_exc(i,j,k) - normrnd(0,stdMtx_own_int_exc(i,j,k));
          
            end
          
     end
    end
    end
   % common band

   % distance_all_ues_2_own_interf (snapshots x users x (own_RRH-1))
   
    switch common_ch_frequency
    
    case 626
    
         for i=1:size(distance_all_ues_2_own_interf,1)
            for j=1:size(distance_all_ues_2_own_interf,2)

             for k=1:size(distance_all_ues_2_own_interf,3)

                  [PL_int_own_com(i,j,k),stdMtx_own_int_comm(i,j,k)]=ExtendedHata(distance_all_ues_2_own_interf(i,j,k)/1000,f_comm/10^6,1.5,10,6);
                  interferer_own_comm(i,j,k)=P_comm_dbm + antGain_comm - PL_int_own_com(i,j,k) - normrnd(0,stdMtx_own_int_comm(i,j,k));


             end

            end
        end

    case 2320
        
           for i=1:size(distance_all_ues_2_own_interf,1)
            for j=1:size(distance_all_ues_2_own_interf,2)

             for k=1:size(distance_all_ues_2_own_interf,3)

                  if probLoS_all_ues_own_int(i,j,k)==1

                 [PL_int_own_com(i,j,k),stdMtx_own_int_comm(i,j,k)]=UrbanMicroLoS(distance_all_ues_2_own_interf(i,j,k),f_comm/10^9,1.5,10);
                 interferer_own_comm(i,j,k)=P_comm_dbm+antGain_comm-PL_int_own_com(i,j,k)-normrnd(0,stdMtx_own_int_comm(i,j,k));

                  else

                      [PL_int_own_com(i,j,k),stdMtx_own_int_comm(i,j,k)]=UrbanMi_NonLoS(distance_all_ues_2_own_interf(i,j,k),f_comm/10^9,1.5,10);
                 interferer_own_comm(i,j,k)=P_comm_dbm+antGain_comm-PL_int_own_com(i,j,k)-normrnd(0,stdMtx_own_int_comm(i,j,k));

                  end

             end
            end
          end
  end
interferer_own_comm_lin=10.^((interferer_own_comm-30)/10);
interferer_own_com_lin_all=sum(interferer_own_comm_lin,3);
interferer_own_exc_lin=10.^((interferer_own_exc-30)/10);
interferer_own_exc_lin_all=sum(interferer_own_exc_lin,3);

end
%% Interference by the other operator's LPN/RRHs

% distance_all_ues_2_other_interf (snapshots x users x (other interfers))
if (number_of_interfs_per_cell(v)~=0)
    
    switch common_ch_frequency
    
    case 626
        
        
 for i=1:size(distance_all_ues_2_other_interf,1)
    for j=1:size(distance_all_ues_2_other_interf,2)
         for k=1:size(distance_all_ues_2_other_interf,3)

            [PL_com_int_others(i,j,k),stdMtx_other_int_comm_(i,j,k)]=ExtendedHata(distance_all_ues_2_other_interf(i,j,k)/1000,f_comm/10^6,1.5,10,6);
            interferer_other_comm(i,j,k)=P_comm_dbm + antGain_comm -PL_com_int_others(i,j,k)-normrnd(0,stdMtx_other_int_comm_(i,j,k));
         end
    end
end

        case 2320
  for i=1:size(distance_all_ues_2_other_interf,1)
    for j=1:size(distance_all_ues_2_other_interf,2)
         for k=1:size(distance_all_ues_2_other_interf,3)
             
             if probLoS_all_ues_other_int(i,j,k)==1
                 
                 [PL_com_int_others(i,j,k),stdMtx_other_int_comm_(i,j,k)]=UrbanMicroLoS(distance_all_ues_2_other_interf(i,j,k),f_comm/10^9,1.5,10);
                 interferer_other_comm(i,j,k)=P_comm_dbm + antGain_comm -PL_com_int_others(i,j,k)-normrnd(0,stdMtx_other_int_comm_(i,j,k));
             else
                 [PL_com_int_others(i,j,k),stdMtx_other_int_comm_(i,j,k)]=UrbanMi_NonLoS(distance_all_ues_2_other_interf(i,j,k),f_comm/10^9,1.5,10);
                 interferer_other_comm(i,j,k)=P_comm_dbm + antGain_comm -PL_com_int_others(i,j,k)-normrnd(0,stdMtx_other_int_comm_(i,j,k));
             end

         end
    end
  end
  
 end
            
interferer_other_comm_lin=10.^((interferer_other_comm-30)/10);

interferer_other_com_lin_all=sum(interferer_other_comm_lin,3);


end


%% Total interference in the commonly and exclusively shared band

if (number_of_interfs_per_cell(v)==0) % no other operators interferers
    
    interference_comm=interferer_own_com_lin_all;
    interference_exc=interferer_own_exc_lin_all;
    
      
else
    
   interference_comm=interferer_other_com_lin_all+interferer_own_com_lin_all;
   interference_exc=interferer_own_exc_lin_all;
         

end

%% Signal to Noise Ratio - LPNs/RRHs

% Exclusively shared band


 for i=1:size(distance_all_ues_2_closest_RRH,1)
    for j=1:size(distance_all_ues_2_closest_RRH,2)
        for k=1:length(w)
        
       if interference_exc==0
           SINR_exc_lin(i,j,k)=signal_exc_lin(i,j)/noise_exc_lin(k);
       else    
           SINR_exc_lin(i,j,k)=signal_exc_lin(i,j)/(noise_exc_lin(k)+interference_exc(i,j)); 
       end
        end
    
    end
    
end
        
    
% % Commonly shared band
% 
for i=1:size(distance_all_ues_2_closest_RRH,1)
    for j=1:size(distance_all_ues_2_closest_RRH,2)
        if interference_comm==0
        
            SINR_comm_lin(i,j)=signal_comm_lin(i,j)/noise_comm_lin; 
            
        else  
       SINR_comm_lin(i,j)=signal_comm_lin(i,j)/(noise_comm_lin+interference_comm(i,j)); 
        
        end
    end
end
    

% 
% % 
SINR_exc_dB=10.*log10(SINR_exc_lin);
SINR_comm_dB=10.*log10(SINR_comm_lin);

[yz2,xz2]=ecdf(SINR_comm_dB(:));
[c,d]=min(abs(xz2-(-5)));
outage_perc_comm=yz2(d);

SINR_comm_dB_coverage=SINR_comm_dB(:);
SINR_comm_dB_coverage(SINR_comm_dB_coverage<-5)=[];
SINR_comm_lin_coverage=SINR_comm_lin(:);
SINR_comm_lin_coverage(SINR_comm_lin_coverage<10^(-0.5))=[];


SE_comm_lin=shannonMkI(SINR_comm_lin_coverage)/.75;

SE_comm_lin_mean=mean(SE_comm_lin);
SE_comm_lin_edge=prctile(SE_comm_lin,5);
SE_comm_lin_median=prctile(SE_comm_lin,50);


%% SINR for the exclusive band

SINR_exc_dB_5=SINR_exc_dB(:,:,1);
SINR_exc_dB_10=SINR_exc_dB(:,:,2);
SINR_exc_dB_15=SINR_exc_dB(:,:,3);
SINR_exc_dB_20=SINR_exc_dB(:,:,4);


[y5,x5]=ecdf(SINR_exc_dB_5(:));
[y10,x10]=ecdf(SINR_exc_dB_10(:));
[y15,x15]=ecdf(SINR_exc_dB_15(:));
[y20,x20]=ecdf(SINR_exc_dB_20(:));


[a5,b5]=min(abs(x5-(-5)));
outage_perc_exc_5=y5(b5);

[a10,b10]=min(abs(x10-(-5)));
outage_perc_exc_10=y10(b10);

[a15,b15]=min(abs(x15-(-5)));
outage_perc_exc_15=y15(b15);

[a20,b20]=min(abs(x20-(-5)));
outage_perc_exc_20=y20(b20);

%first one just a trick to avoid 0/0
outage_perc_exc=horzcat(.91,outage_perc_exc_5,outage_perc_exc_10,outage_perc_exc_15,outage_perc_exc_20);



% 5 MHz channel (users within the coverage)
SINR_exc_dB_coverage_5=SINR_exc_dB_5(:);
SINR_exc_dB_coverage_5(SINR_exc_dB_coverage_5<-5)=[];
SINR_exc_lin_coverage_5=SINR_exc_lin(:,:,1);
SINR_exc_lin_coverage_5=SINR_exc_lin_coverage_5(:);
SINR_exc_lin_coverage_5(SINR_exc_lin_coverage_5<10^(-0.5))=[];

% 10 MHz channel (users within the coverage)
SINR_exc_dB_coverage_10=SINR_exc_dB_10(:);
SINR_exc_dB_coverage_10(SINR_exc_dB_coverage_10<-5)=[];
SINR_exc_lin_coverage_10=SINR_exc_lin(:,:,2);
SINR_exc_lin_coverage_10=SINR_exc_lin_coverage_10(:);
SINR_exc_lin_coverage_10(SINR_exc_lin_coverage_10<10^(-0.5))=[];

% 15 MHz channel (users within the coverage)
SINR_exc_dB_coverage_15=SINR_exc_dB_15(:);
SINR_exc_dB_coverage_15(SINR_exc_dB_coverage_15<-5)=[];
SINR_exc_lin_coverage_15=SINR_exc_lin(:,:,3);
SINR_exc_lin_coverage_15=SINR_exc_lin_coverage_15(:);
SINR_exc_lin_coverage_15(SINR_exc_lin_coverage_15<10^(-0.5))=[];

% 20 MHz channel (users within the coverage)
SINR_exc_dB_coverage_20=SINR_exc_dB_10(:);
SINR_exc_dB_coverage_20(SINR_exc_dB_coverage_20<-5)=[];
SINR_exc_lin_coverage_20=SINR_exc_lin(:,:,4);
SINR_exc_lin_coverage_20=SINR_exc_lin_coverage_20(:);
SINR_exc_lin_coverage_20(SINR_exc_lin_coverage_20<10^(-0.5))=[];


% Spectral efficiency for each channel width
SE_exc_lin_5=shannonMkI(SINR_exc_lin_coverage_5)/.75;
SE_exc_lin_10=shannonMkI(SINR_exc_lin_coverage_10)/.75;
SE_exc_lin_15=shannonMkI(SINR_exc_lin_coverage_15)/.75;
SE_exc_lin_20=shannonMkI(SINR_exc_lin_coverage_20)/.75;

% Mean spectral efficiency
SE_exc_lin_mean_5=mean(SE_exc_lin_5);
SE_exc_lin_mean_10=mean(SE_exc_lin_10);
SE_exc_lin_mean_15=mean(SE_exc_lin_15);
SE_exc_lin_mean_20=mean(SE_exc_lin_20);

SE_exc_lin_mean=horzcat(0,SE_exc_lin_mean_5,SE_exc_lin_mean_10,SE_exc_lin_mean_15,SE_exc_lin_mean_20);

% Edge SE
SE_exc_lin_edge_5=prctile(SE_exc_lin_5,5);
SE_exc_lin_edge_10=prctile(SE_exc_lin_10,5);
SE_exc_lin_edge_15=prctile(SE_exc_lin_15,5);
SE_exc_lin_edge_20=prctile(SE_exc_lin_20,5);

SE_exc_lin_edge=horzcat(0,SE_exc_lin_edge_5,SE_exc_lin_edge_10,SE_exc_lin_edge_15,SE_exc_lin_edge_20);

% Median SE
SE_exc_lin_median_5=prctile(SE_exc_lin_5,50);
SE_exc_lin_median_10=prctile(SE_exc_lin_10,50);
SE_exc_lin_median_15=prctile(SE_exc_lin_15,50);
SE_exc_lin_median_20=prctile(SE_exc_lin_20,50);

SE_exc_lin_median=horzcat(0,SE_exc_lin_median_5,SE_exc_lin_median_10,SE_exc_lin_median_15,SE_exc_lin_median_20);




save(strcat('v7_SINR_cdfs_freq_',num2str(common_ch_frequency),'_bw_',num2str(common_ch_width), '_power_case_',num2str(P_comm_dbm),'_lpns_',num2str(number_of_own_lpns_per_cell(u)),...
    '_with_',num2str(number_of_interfs_per_cell(v)),'_int'),'SINR_exc_dB','SINR_exc_lin','SINR_comm_dB','SINR_comm_lin','outage_perc_exc','outage_perc_comm','SINR_exc_dB_coverage_5','SINR_exc_lin_coverage_5',...
    'SINR_comm_dB_coverage','SINR_comm_lin_coverage','SE_exc_lin_mean','SE_exc_lin_edge','SE_comm_lin_mean','SE_comm_lin_edge','SE_exc_lin_5','SE_comm_lin','SE_exc_lin_median','SE_comm_lin_median');



end
end
 
  
%% Backup for macro
SINR_macro_dB=[-5:.5:40];
SINR_macro_lin=10.^(SINR_macro_dB./10);
SE_macro_lin=shannonMkI(SINR_macro_lin)/.75;

SINR_mac_dB_coverage=SINR_macro_dB(:);
SINR_mac_dB_coverage(SINR_mac_dB_coverage<-5)=[];

%% Saving macro
SE_macro_mean_lin=mean(SE_macro_lin);
SE_macro_edge_lin=prctile(SE_macro_lin,5);
SE_macro_median_lin=prctile(SE_macro_lin,50);
save(strcat('v7_SINR_cdfs_freq_',num2str(common_ch_frequency),'_bw_',num2str(common_ch_width), '_power_case_',num2str(P_comm_dbm),'_lpns_',num2str(number_of_own_lpns_per_cell(u)),...
    '_with_',num2str(number_of_interfs_per_cell(v)),'_int'),'SE_macro_mean_lin','SE_macro_edge_lin','SE_macro_median_lin','-append');



clear all;
toc