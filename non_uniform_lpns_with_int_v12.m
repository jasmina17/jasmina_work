% Fix the total number of users, Nusers, dropped within each macro geographical area, 
%where Nusers is 30 or 60 in fading scenarios and 60 in non-fading scenarios.
%v11 - changed to original(macro cell). 
% Also the # of users is changed to 60.

length_sq=600;

%Macro
min_UE_dist_to_mac=35;
radius_macro=250;
small_mac_cir=min_UE_dist_to_mac;
big_mac_cir=radius_macro;

%RRH
min_UE_RRH_dist=10; %10
min_RRH_RRH_dist=40;
min_mac_RRH_dist=75; %75
dist_UE_in_RRH=40; % 40

%% General

no_snapshots=500;
Nusers=60; 
total_no_RRH=30;

% Number of interfering RRH

no_macro_interferers=6;
no_interfering_RRHs=20;


% Number of own RRHs
own_no_RRH_per_macro=total_no_RRH-no_interfering_RRHs;
  
Nusers_lpn=2;

cmap = hsv(own_no_RRH_per_macro);

Nrem=Nusers-own_no_RRH_per_macro*Nusers_lpn;
 

% Randomly and uniformly drop the configured number of low power nodes, N, ...
...within each macro geographical area (the same number N for every macro geographical area, where N may take values from {1, 2, 4, 10}).

tic
for i=1:no_snapshots
     
    
    no_fig=mod(i,10)+1;
        
drawSquare(no_fig,0,700)
hold all
circle(0,0,min_UE_dist_to_mac)
circle(0,0,radius_macro)
plot(0,0,'kx','MarkerSize', 12)
clear z count t;
count=0;
z=1;

% Create all RRHs

for RRH_index=1:total_no_RRH
    
 
    while true
                                           
             a=rand;
             b=rand;
             r = radius_macro* sqrt(a);
             theta = 2 * pi * b;


             
   % Step 1 - create positions for the first RRH
                    x_pos_RRH(i,RRH_index)=r*cos(theta);
                    y_pos_RRH(i,RRH_index)=r*sin(theta);
     
    % Step 2 - calculate the distance to macro cell                
    distance_RRH_mac(i,RRH_index)=distance(0,x_pos_RRH(i,RRH_index),0,y_pos_RRH(i,RRH_index)); %matrix - no_of_snapshots X no_RRH
    
    temp_RRH_mac= distance_RRH_mac(i,RRH_index);
    
    % Step 3 - if this is the first RRH, check only the minimum distance
    % requirement to macro and go back to the begining of RRH loop
    % otherwise create another RRH at different position
    
    if (RRH_index==1)& ((distance_RRH_mac(i,RRH_index))>=min_mac_RRH_dist)
           plot(x_pos_RRH(i,RRH_index),y_pos_RRH(i,RRH_index),'bs','MarkerSize', 12)
    break
    
    
    
    
    % Step 3 - Else, calculate the distance between the
    % RRHs
    
     elseif (RRH_index~=1)
         
          u=1;
        
       while(RRH_index-u)>0
           
           rrhs_2_rrhs{i,RRH_index,u}=distance(x_pos_RRH(i,RRH_index),x_pos_RRH(i,u),...
  y_pos_RRH(i,RRH_index),y_pos_RRH(i,u));
           
           u=u+1;
       end
       
       
        temp_rrh_rrh=cell2mat(rrhs_2_rrhs(i,RRH_index,1:(RRH_index-1)));
%     
      

% Then check if the distance between the nodes and to macro is OK. 
           
                      if ( temp_RRH_mac>=min_mac_RRH_dist)& ( temp_rrh_rrh>min_RRH_RRH_dist)
                 plot(x_pos_RRH(i,RRH_index), y_pos_RRH(i,RRH_index),'bs','MarkerSize', 12)
                           break % If yes, go to the start of the RRH loop

         end
        end
    end
       end
    

% In case there are interfering nodes, single out their xpos and ypos
    if no_interfering_RRHs~=0;
       for interferer_indx=1:no_interfering_RRHs
           xpos_int(i,interferer_indx)=x_pos_RRH(i,interferer_indx+own_no_RRH_per_macro);
           ypos_int(i,interferer_indx)=y_pos_RRH(i,interferer_indx+own_no_RRH_per_macro);
       end
    end
    
    %% Create macro interferers
    
    for k=1:no_macro_interferers
        
        x_pos_macro_int(k)=2*radius_macro*cos(pi/6+((k-1)*pi)/3);
        y_pos_macro_int(k)=2*radius_macro*sin(pi/6+((k-1)*pi)/3);
    end
    
    %% Calculate distance RRHs_to macro interferers
        
    for j=1:total_no_RRH
        for k=1:no_macro_interferers
    distance_RRH_2_mac_interferers(i,j,k)=distance(x_pos_macro_int(k),x_pos_RRH(i,j), y_pos_macro_int(k),y_pos_RRH(i,j));
        end
    end
    
%% Randomly and uniformly drop Nusers_lpn users within a 40 m radius of each operator's own low power node, where  with Photspot defined in 
...Table A.2.1.1.2-5, where  Photspot is the fraction of all hotspot users over the total number of users in the network.
    
for RRH_index_own=1:own_no_RRH_per_macro
    
    for user_index=1:Nusers_lpn
 
        while true
% 
                    f=rand;
                    g=rand;

                          
            r1=dist_UE_in_RRH*sqrt(f);
            theta1 = 2 * pi * g;
                    
                    % calculate x and y axis of these users

            x_pos_u_lpn(i,user_index,RRH_index_own)= x_pos_RRH(i,RRH_index_own)+r1*cos(theta1);
            y_pos_u_lpn(i,user_index,RRH_index_own) =y_pos_RRH(i,RRH_index_own)+r1*sin(theta1);
           
    
    
                    % calculate the distance of these users to macro
                    
          ues_rrh_2_own_macro(i,user_index,RRH_index_own)=distance(0,x_pos_u_lpn(i,user_index,RRH_index_own),...
              0,y_pos_u_lpn(i,user_index,RRH_index_own));
          
          %distance of these users to all (own) RRHs
%
                     
          for temp_RRH=1:own_no_RRH_per_macro
                   
                     
          ues_RRH_2_all_own_RRH{i,user_index,RRH_index_own,temp_RRH}=distance(x_pos_u_lpn(i,user_index,RRH_index_own),x_pos_RRH(i,temp_RRH),y_pos_u_lpn(i,user_index,RRH_index_own),y_pos_RRH(i,temp_RRH));
                    
            
          end
          
          ues_rrh_2_all_own_rrhs(i,user_index,RRH_index_own,:)=cell2mat(ues_RRH_2_all_own_RRH(i,user_index,RRH_index_own,:));
                    
            
           % in case there are interfering nodes, calculate the distance
           % between them and specific (40m) users
           
           if no_interfering_RRHs~=0;
           
           for interferer_indx=1:no_interfering_RRHs
               
               ues_RRH_2_interf(i,user_index,RRH_index_own,interferer_indx)=distance(x_pos_u_lpn(i,user_index,RRH_index_own),...
                   xpos_int(i,interferer_indx),y_pos_u_lpn(i,user_index,RRH_index_own),ypos_int(i,interferer_indx));
           end
           
%                    
           end

       
                   
        % % % % Check if these users are within the specified distance
        % limits

                    ...
            if  (ues_rrh_2_own_macro(i,user_index,RRH_index_own)>=min_UE_dist_to_mac)&(ues_rrh_2_own_macro(i,user_index,RRH_index_own)<=big_mac_cir)...
         &(  ues_rrh_2_all_own_rrhs(i,user_index,RRH_index_own,:)>=min_UE_RRH_dist);
     
     
%      

                if  no_interfering_RRHs~=0;
                    
                    if(ues_RRH_2_interf(i,user_index,RRH_index_own,1:no_interfering_RRHs)>=min_UE_RRH_dist);
                    
            plot(x_pos_u_lpn(i,user_index,RRH_index_own),y_pos_u_lpn(i,user_index,RRH_index_own),'r*') ;
            

            
                    break
            
                    end
                
                else
                
                plot(x_pos_u_lpn(i,user_index,RRH_index_own),y_pos_u_lpn(i,user_index,RRH_index_own),'r*') ;
                

                    break
                end
       
            else
                continue
    
            end
            
       end
        
 for k=1:no_macro_interferers
        ues_rrh_2_macro_int(i,user_index,RRH_index_own,k)=distance(x_pos_u_lpn(i,user_index,RRH_index_own),x_pos_macro_int(k), y_pos_u_lpn(i,user_index,RRH_index_own),y_pos_macro_int(k));
        end

 
 
%% Randomly and uniformly drop the remaining users, Nusers - Nusers_lpn*N, 
% ...to the entire macro geographical area of the given macro cell (including the low power node user dropping area)
%     still only within the operator's own RRHs
    
if Nrem~=0
for user_ind2=(own_no_RRH_per_macro*Nusers_lpn)+1:Nusers
    
    
    while true
        %
        k=rand;
        l=rand;
        
       
             r = radius_macro* sqrt(k);
             theta2 = 2 * pi * l;

        
        x_pos(i,user_ind2)= r*cos(theta2);
        y_pos(i,user_ind2)=r*sin(theta2);
        %
        other_ues_2_own_macro(i,user_ind2)=distance(0,x_pos(i,user_ind2),0,y_pos(i,user_ind2));
        
        
        % distance of these remaining users to the operator's own RRH
        for RRH_ind=1:own_no_RRH_per_macro
            
          
          other_ues_2_own_RRH_all(i,user_ind2,RRH_ind)=distance(x_pos_RRH(i,RRH_ind),x_pos(i,user_ind2),...
          y_pos_RRH(i,RRH_ind),y_pos(i,user_ind2));
          
            
       
        end
         
           
       
        if no_interfering_RRHs~=0;
            %calculate the distance of the remaining users to the
            %interfering nodes
           
           for interferer_indx=1:no_interfering_RRHs
               
               other_ues_2_other_interf(i,user_ind2,interferer_indx)=distance(x_pos(i,user_ind2),...
                   xpos_int(i,interferer_indx),y_pos(i,user_ind2),ypos_int(i,interferer_indx));
           end
           
           
           
        end
        
 
% % 
% % % % % % Check if in the correct zone

if ( (other_ues_2_own_macro(i,user_ind2) >=min_UE_dist_to_mac)& (other_ues_2_own_RRH_all(i,user_ind2,:)>=min_UE_RRH_dist));
    
    
    if no_interfering_RRHs~=0;
        if other_ues_2_other_interf(i,user_ind2,:)>=min_UE_RRH_dist;
%     
           plot(x_pos(i,user_ind2),y_pos(i,user_ind2),'g*') ;
           
                        
           break

        end
        
    else
        plot(x_pos(i,user_ind2),y_pos(i,user_ind2),'g*') ;
       
        break
    end
end
    
    end
    
   for k=1:no_macro_interferers
        other_ues_2_mac_int(i,user_ind2,k)=distance(x_pos(i,user_ind2),x_pos_macro_int(k),y_pos(i,user_ind2),y_pos_macro_int(k));
        
  end
  
  
end

end
end
end

    if no_fig==10
            
             close all;

         end
  disp('Snap-shot simulation loop finished');
                                disp('');
                                tfin = toc;
                                disp(strcat({'Snap-shot simulation: '},num2str(i),{' in time: '},num2str(tfin),{' s'})); 

    
end

%% Distance of all users to the closest RRH/LPN node

temp1=ues_rrh_2_all_own_rrhs;
ues_rrh_2_all_own_rrhs=reshape(ues_rrh_2_all_own_rrhs,no_snapshots,Nusers_lpn*own_no_RRH_per_macro,own_no_RRH_per_macro);
ues_rrh_2_own_corr_RRH=min(ues_rrh_2_all_own_rrhs,[],3); % distance to the closest node 


% %RRH (40m) users
ues_rrh_2_own_corr_RRH=reshape(ues_rrh_2_own_corr_RRH,no_snapshots,Nusers_lpn*own_no_RRH_per_macro);

if Nrem~=0
% remaining users
other_ues_2_own_RRH_original = other_ues_2_own_RRH_all;
other_ues_2_own_RRH_all(:,1:own_no_RRH_per_macro*Nusers_lpn,:)=[];
other_ues_2_closest_RRH=min(other_ues_2_own_RRH_all,[],3);

% all users
distance_all_ues_2_closest_RRH=horzcat(other_ues_2_closest_RRH,ues_rrh_2_own_corr_RRH);

else
distance_all_ues_2_closest_RRH=ues_rrh_2_own_corr_RRH;
end

probLoS_all_ues_closest_RRH = min(18./distance_all_ues_2_closest_RRH,ones(size(distance_all_ues_2_closest_RRH,1),...
    size(distance_all_ues_2_closest_RRH,2))).*(1-exp(-distance_all_ues_2_closest_RRH/36))+exp(-distance_all_ues_2_closest_RRH/36);
    
%% Distance of all users to serving macro 

%reshaping rrh ues
ues_rrh_2_own_macro_resh=reshape(ues_rrh_2_own_macro,no_snapshots,own_no_RRH_per_macro*Nusers_lpn);

%all users

if Nrem~=0
%other ues to serving macro - taking out 0s 

other_ues_2_own_macro(:,1:own_no_RRH_per_macro*Nusers_lpn)=[];

distance_all_ues_2_own_macro=horzcat(other_ues_2_own_macro,ues_rrh_2_own_macro_resh);

else
   distance_all_ues_2_own_macro=ues_rrh_2_own_macro_resh; 
    
end
probLoS_all_ues_2_own_mac=min(18./distance_all_ues_2_own_macro,ones).*(1-exp(-distance_all_ues_2_own_macro/63))+exp(-distance_all_ues_2_own_macro/63);


%% Distance to own interferes
% 
% %distance of rrh users to own interfering nodes

if own_no_RRH_per_macro>1
rrh_ues_2_own_int_orig=ues_rrh_2_all_own_rrhs;
rrh_ues_2_own_int_orig=sort(rrh_ues_2_own_int_orig,3);

rrh_ues_2_own_int=rrh_ues_2_own_int_orig;
rrh_ues_2_own_int(:,:,1)=[];

if Nrem~=0
% %distance of remaining users to own interfering nodes (take out the
% closes ones)
other_ues_2_own_int=sort(other_ues_2_own_RRH_all,3);
other_ues_2_own_int(:,:,1)=[];

% all users
distance_all_ues_2_own_interf=horzcat(rrh_ues_2_own_int,other_ues_2_own_int);

else 
    
distance_all_ues_2_own_interf=rrh_ues_2_own_int;
    
end

probLoS_all_ues_own_int =min(18./distance_all_ues_2_own_interf,ones).*(1-exp(-distance_all_ues_2_own_interf/36))+exp(-distance_all_ues_2_own_interf/36);

end


    
%% Distance to other interferes
if no_interfering_RRHs~=0;
% distance of rrh users to other operators interferers
ues_rrh_2_other_int= ues_RRH_2_interf;
ues_rrh_2_other_int=reshape(ues_rrh_2_other_int,no_snapshots,Nusers_lpn*own_no_RRH_per_macro,no_interfering_RRHs);

if Nrem~=0
% % distance of remaining users to other interferers - taking out 0s 
 
other_ues_2_other_interf(:,1:own_no_RRH_per_macro*Nusers_lpn,:)=[];

distance_all_ues_2_other_interf=horzcat(ues_rrh_2_other_int,other_ues_2_other_interf);

else
    
distance_all_ues_2_other_interf=ues_rrh_2_other_int;    
end
% 

probLoS_all_ues_other_int = min(18./distance_all_ues_2_other_interf,ones).*(1-exp(-distance_all_ues_2_other_interf/36))...
    +exp(-distance_all_ues_2_other_interf/36); 

end



%% Distance to macro interferers
% %distance of remaining users to macro interferers - taking out 0s 

temp2=ues_rrh_2_macro_int;

ues_rrh_2_macro_int=reshape(ues_rrh_2_macro_int,no_snapshots,own_no_RRH_per_macro*Nusers_lpn,no_macro_interferers);


if Nrem~=0
other_ues_2_mac_int(:,1:own_no_RRH_per_macro*Nusers_lpn,:)=[];

distance_all_ues_2_macro_int=horzcat(ues_rrh_2_macro_int,other_ues_2_mac_int);

else
    
 distance_all_ues_2_macro_int=ues_rrh_2_macro_int;
 
end

probLoS_all_ues_mac_int=min(18./distance_all_ues_2_macro_int,ones).*(1-exp(-distance_all_ues_2_macro_int/63))+exp(-distance_all_ues_2_macro_int/63);

% %  

if Nrem~=0

save(strcat('v12_dist_non_uniform_RRH_',num2str(own_no_RRH_per_macro),'_with_',num2str(no_interfering_RRHs),'_int.mat'),'distance_RRH_mac',...
    'distance_all_ues_2_closest_RRH','distance_all_ues_2_own_macro', 'distance_RRH_2_mac_interferers','distance_all_ues_2_macro_int','ues_rrh_2_macro_int','other_ues_2_mac_int','other_ues_2_closest_RRH'...
    ,'ues_rrh_2_own_corr_RRH','other_ues_2_own_macro','ues_rrh_2_own_macro_resh','probLoS_all_ues_closest_RRH','probLoS_all_ues_mac_int','probLoS_all_ues_2_own_mac');
% % 
if (total_no_RRH)>1
save(strcat('v12_dist_non_uniform_RRH_',num2str(own_no_RRH_per_macro),'_with_',num2str(no_interfering_RRHs),'_int.mat'),'rrhs_2_rrhs','-append');
end

if (own_no_RRH_per_macro)>1
save(strcat('v12_dist_non_uniform_RRH_',num2str(own_no_RRH_per_macro),'_with_',num2str(no_interfering_RRHs),'_int.mat'),'distance_all_ues_2_own_interf','rrh_ues_2_own_int','other_ues_2_own_int',...
    'probLoS_all_ues_own_int','-append');
end
% 
if  no_interfering_RRHs~0
save(strcat('v12_dist_non_uniform_RRH_',num2str(own_no_RRH_per_macro),'_with_',num2str(no_interfering_RRHs),'_int.mat'),'distance_all_ues_2_other_interf','ues_rrh_2_other_int','other_ues_2_other_interf',...
    'probLoS_all_ues_other_int','-append');
end

else
    
 save(strcat('v12_dist_non_uniform_RRH_',num2str(own_no_RRH_per_macro),'_with_',num2str(no_interfering_RRHs),'_int.mat'),'distance_RRH_mac',...
    'distance_all_ues_2_closest_RRH','distance_all_ues_2_own_macro', 'distance_RRH_2_mac_interferers','distance_all_ues_2_macro_int','ues_rrh_2_macro_int',...
  'ues_rrh_2_own_corr_RRH','ues_rrh_2_own_macro_resh');
% % 
if (total_no_RRH)>1
save(strcat('v12_dist_non_uniform_RRH_',num2str(own_no_RRH_per_macro),'_with_',num2str(no_interfering_RRHs),'_int.mat'),'rrhs_2_rrhs','-append');
end

if (own_no_RRH_per_macro)>1
save(strcat('v12_dist_non_uniform_RRH_',num2str(own_no_RRH_per_macro),'_with_',num2str(no_interfering_RRHs),'_int.mat'),'distance_all_ues_2_own_interf','rrh_ues_2_own_int','-append');
end
% 
if  no_interfering_RRHs~0
save(strcat('v12_dist_non_uniform_RRH_',num2str(own_no_RRH_per_macro),'_with_',num2str(no_interfering_RRHs),'_int.mat'),'distance_all_ues_2_other_interf','ues_rrh_2_other_int','-append');
end   

end
    