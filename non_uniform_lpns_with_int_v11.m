
% Fix the total number of users, Nusers, dropped within each macro geographical area,
%where Nusers is 30 or 60 in fading scenarios and 60 in non-fading scenarios.
%v11 - Macro cell. Clustered distribution of users. Line of Sight
%Probabilities.
% (3GPP 36.814) Randomly and uniformly drop the configured number of low power nodes, N, ...
%...within each macro geographical area...
%...(the same number N for every macro geographical area, where N may take values from {1, 2, 4, 10}).



length_sq=600;
%Macro distance constraints
min_UE_dist_to_mac=35;
radius_macro=250;
small_mac_cir=min_UE_dist_to_mac;
big_mac_cir=radius_macro;
%RRH distance constraints
min_UE_RRH_dist=10;
min_RRH_RRH_dist=40;
min_mac_RRH_dist=75;
dist_UE_in_RRH=40;
%% General
no_snapshots=1500;
Nusers=60;
total_no_RRH=own_no_RRH_per_macro+no_interfering_RRHs;
cmap = hsv(own_no_RRH_per_macro);
%Users per cluster - differs from 3GPP as we want to explore more dense
%deployments than 10. Hence, instead of 4 we have 2 users per a cluster.
Nusers_lpn=2;
Nrem=Nusers-own_no_RRH_per_macro*Nusers_lpn;
%Macro interferers
no_macro_interferers=6;
tic
for i=1:no_snapshots
%     no_fig(i)=mod(i,30)+1;
%     drawSquare(no_fig(i),0,700)
%     hold all
%     circle(0,0,min_UE_dist_to_mac)
%     circle(0,0,radius_macro)
%     plot(0,0,'kx','MarkerSize', 12)
%% Create all RRHs
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
        distance_RRH_mac(i,RRH_index)=my_distance(0,x_pos_RRH(i,RRH_index),0,y_pos_RRH(i,RRH_index)); %matrix - no_of_snapshots X no_RRH
        temp_RRH_mac= distance_RRH_mac(i,RRH_index);

    % Step 3 - if this is the first RRH, check only the minimum distance
    % requirement to macro and go back to the begining of RRH loop.
    % Otherwise create another RRH at different position
                if (RRH_index==1)& ((distance_RRH_mac(i,RRH_index))>=min_mac_RRH_dist)
%                     plot(x_pos_RRH(i,RRH_index),y_pos_RRH(i,RRH_index),'bs','MarkerSize', 12)

                break
            % Step 3 - Else, calculate the distance between the RRHs
                elseif (RRH_index~=1)
                u=1;

                    while(RRH_index-u)>0
                        rrhs_2_rrhs{i,RRH_index,u}=my_distance(x_pos_RRH(i,RRH_index),x_pos_RRH(i,u),...
                        y_pos_RRH(i,RRH_index),y_pos_RRH(i,u));
                        u=u+1;
                    end
        temp_rrh_rrh=cell2mat(rrhs_2_rrhs(i,RRH_index,1:(RRH_index-1)));
    % Then check if the distance between the RRH nodes and from each RRH to macro is OK.
                    if ( temp_RRH_mac>=min_mac_RRH_dist)& ( temp_rrh_rrh>min_RRH_RRH_dist)
%                         plot(x_pos_RRH(i,RRH_index), y_pos_RRH(i,RRH_index),'bs','MarkerSize', 12)
                        break % If yes, create next RRH.
                    end

                end
    end
 end
% In case there are interfering nodes, single out their xpos and ypos. The
% last # of all randomly created RRHs.
        if no_interfering_RRHs~=0;
        for interferer_indx=1:no_interfering_RRHs
        xpos_int(i,interferer_indx)=x_pos_RRH(i,interferer_indx+own_no_RRH_per_macro);
        ypos_int(i,interferer_indx)=y_pos_RRH(i,interferer_indx+own_no_RRH_per_macro);
%         plot(xpos_int(i,interferer_indx),ypos_int(i,interferer_indx),'rs','MarkerSize', 12)
        end
        end
%% Create macro interferers
        for int_mac_ind=1:no_macro_interferers
            x_pos_macro_int(int_mac_ind)=2*radius_macro*cos(pi/6+((int_mac_ind-1)*pi)/3);
            y_pos_macro_int(int_mac_ind)=2*radius_macro*sin(pi/6+((int_mac_ind-1)*pi)/3);
        end
%% Calculate distance RRHs_to macro interferers
for ind_rrh=1:total_no_RRH
    for mac_int_indx=1:no_macro_interferers
        distance_RRH_2_mac_interferers(i,ind_rrh,mac_int_indx)=my_distance(x_pos_macro_int(mac_int_indx),...
            x_pos_RRH(i,ind_rrh), y_pos_macro_int(mac_int_indx),y_pos_RRH(i,ind_rrh));
    end
end
%% Randomly and uniformly drop Nusers_lpn users within a 40 m radius of each operator's own low power node.
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

                    usr_indx_new=2*(RRH_index_own-1)+user_index;

                    x_pos_u_lpn_new(i,usr_indx_new)= x_pos_u_lpn(i,user_index,RRH_index_own);
                    y_pos_u_lpn_new(i,usr_indx_new)= y_pos_u_lpn(i,user_index,RRH_index_own);

                    % calculate the distance of these users to macro

                    ues_rrh_2_own_macro(i,usr_indx_new)=my_distance(0,x_pos_u_lpn_new(i,usr_indx_new),...
                    0,y_pos_u_lpn_new(i,usr_indx_new));

                    %distance of these users to all (own) RRHs

                    for temp_RRH=1:own_no_RRH_per_macro
                    ues_RRH_2_all_own_RRH{i,usr_indx_new,temp_RRH}=my_distance(x_pos_u_lpn_new(i,usr_indx_new),...
                        x_pos_RRH(i,temp_RRH),y_pos_u_lpn_new(i,usr_indx_new),y_pos_RRH(i,temp_RRH));
                    end
                    ues_rrh_2_all_own_rrhs(i,usr_indx_new,:)=cell2mat(ues_RRH_2_all_own_RRH(i,usr_indx_new,:));

                    % in case there are interfering nodes, calculate the distance
                    % between them and specific (40m) users

                    if no_interfering_RRHs~=0;
                    for interferer_indx=1:no_interfering_RRHs
                    ues_RRH_2_interf(i,usr_indx_new,interferer_indx)=my_distance(x_pos_u_lpn_new(i,usr_indx_new),...
                    xpos_int(i,interferer_indx),y_pos_u_lpn_new(i,usr_indx_new),ypos_int(i,interferer_indx));
                    end
                    %
                    end
                    % Check if these users are within the specified distance limits
                    ...
                    if (ues_rrh_2_own_macro(i,usr_indx_new)>=min_UE_dist_to_mac)&(ues_rrh_2_own_macro(i,usr_indx_new)<=big_mac_cir)...
                    &( ues_rrh_2_all_own_rrhs(i,usr_indx_new,:)>min_UE_RRH_dist);

                        if no_interfering_RRHs~=0;
                            if(ues_RRH_2_interf(i,usr_indx_new,1:no_interfering_RRHs)>min_UE_RRH_dist);
%                                 plot(x_pos_u_lpn_new(i,usr_indx_new),y_pos_u_lpn_new(i,usr_indx_new),'r*') ;
                                break
                            end
                        else
%                             plot(x_pos_u_lpn_new(i,usr_indx_new),y_pos_u_lpn_new(i,usr_indx_new),'r*') ;
                        break
                        end
                    else
                    continue
                    end
                end
                for ak=1:no_macro_interferers
                ues_rrh_2_macro_int(i,usr_indx_new,ak)=my_distance(x_pos_u_lpn_new(i,usr_indx_new),...
                    x_pos_macro_int(ak), y_pos_u_lpn_new(i,usr_indx_new),y_pos_macro_int(ak));
                end
end
end
%% Randomly and uniformly drop the remaining users, Nusers - Nusers_lpn*N,
% ...to the entire macro geographical area of the given macro cell (including the low power node user dropping area)
% still only within the operator's own RRHs
        if Nrem~=0
        for user_ind2=1:Nusers-(Nusers_lpn*own_no_RRH_per_macro)
        while true

        k=rand;
        l=rand;
        r = radius_macro* sqrt(k);
        theta2 = 2 * pi * l;
        x_pos(i,user_ind2)= r*cos(theta2);
        y_pos(i,user_ind2)=r*sin(theta2);
        %
        other_ues_2_own_macro(i,user_ind2)=my_distance(0,x_pos(i,user_ind2),0,y_pos(i,user_ind2));
        % distance of these remaining users to the operator's own RRH
        
        for RRH_ind=1:own_no_RRH_per_macro
        other_ues_2_own_RRH_all(i,user_ind2,RRH_ind)=my_distance(x_pos_RRH(i,RRH_ind),x_pos(i,user_ind2),...
        y_pos_RRH(i,RRH_ind),y_pos(i,user_ind2));
        end
        
        if no_interfering_RRHs~=0;
        %calculate the distance of these users to the
        %interfering nodes
        
            for interferer_indx=1:no_interfering_RRHs
            other_ues_2_other_interf(i,user_ind2,interferer_indx)=my_distance(x_pos(i,user_ind2),...
            xpos_int(i,interferer_indx),y_pos(i,user_ind2),ypos_int(i,interferer_indx));
            end
        end
        % Check if in the correct zone
            if ( (other_ues_2_own_macro(i,user_ind2) >=min_UE_dist_to_mac)& (other_ues_2_own_RRH_all(i,user_ind2,:)>min_UE_RRH_dist));
            if no_interfering_RRHs~=0;
            if other_ues_2_other_interf(i,user_ind2,:)>min_UE_RRH_dist;
%                 plot(x_pos(i,user_ind2),y_pos(i,user_ind2),'g*') ;                    
                break
            end
            else
%                 plot(x_pos(i,user_ind2),y_pos(i,user_ind2),'g*') ;
                break
            end
            end
        end
        
        
        for bk=1:no_macro_interferers
        other_ues_2_mac_int(i,user_ind2,bk)=my_distance(x_pos(i,user_ind2),x_pos_macro_int(bk),y_pos(i,user_ind2),y_pos_macro_int(bk));
        end
        end
        
       end
% if no_fig(i)==30
% close all;
% end
disp('Snap-shot simulation loop finished');
disp('');
tfin = toc;
disp(strcat({'Snap-shot simulation: '},num2str(i),{' in time: '},num2str(tfin),{' s'}));
end

%% Rearranging the variables and saving
% Distance of all users to the closest RRH/LPN node
ues_rrh_2_own_corr_RRH=min(ues_rrh_2_all_own_rrhs,[],3); % distance to the closest node

% Remaining users
other_ues_2_closest_RRH=min(other_ues_2_own_RRH_all,[],3);% distance to the closest node

% All users
if Nrem~=0
distance_all_ues_2_closest_RRH=horzcat(other_ues_2_closest_RRH,ues_rrh_2_own_corr_RRH);
else
distance_all_ues_2_closest_RRH=ues_rrh_2_own_corr_RRH;
end
probLoS_all_ues_closest_RRH = min(18./distance_all_ues_2_closest_RRH,ones(size(distance_all_ues_2_closest_RRH,1),...
size(distance_all_ues_2_closest_RRH,2))).*(1-exp(-distance_all_ues_2_closest_RRH/36))+exp(-distance_all_ues_2_closest_RRH/36);
%% Distance of all users to serving macro
if Nrem~=0
distance_all_ues_2_own_macro=horzcat(other_ues_2_own_macro,ues_rrh_2_own_macro);
else
distance_all_ues_2_own_macro=ues_rrh_2_own_macro_resh;
end
probLoS_all_ues_2_own_mac=min(18./distance_all_ues_2_own_macro,ones).*(1-exp(-distance_all_ues_2_own_macro/63))+...
exp(-distance_all_ues_2_own_macro/63);
%% Distance to own interferes
%distance of rrh users to own interfering nodes
 if own_no_RRH_per_macro>1
rrh_ues_2_own_int=sort(ues_rrh_2_all_own_rrhs,3);
rrh_ues_2_own_int(:,:,1)=[];
if Nrem~=0
%distance of remaining users to own interfering nodes (take out the
% % closes ones)
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

if Nrem~=0
% % % distance of remaining users to other interferers 
distance_all_ues_2_other_interf=horzcat(ues_rrh_2_other_int,other_ues_2_other_interf);
else
distance_all_ues_2_other_interf=ues_rrh_2_other_int;
end

probLoS_all_ues_other_int = min(18./distance_all_ues_2_other_interf,ones).*(1-exp(-distance_all_ues_2_other_interf/36))...
+exp(-distance_all_ues_2_other_interf/36);
end
%% Distance to macro interferers
%distance of remaining users to macro interferers

if Nrem~=0
distance_all_ues_2_macro_int=horzcat(ues_rrh_2_macro_int,other_ues_2_mac_int);
else
distance_all_ues_2_macro_int=ues_rrh_2_macro_int;
end
probLoS_all_ues_mac_int=min(18./distance_all_ues_2_macro_int,ones).*(1-exp(-distance_all_ues_2_macro_int/63))...
+exp(-distance_all_ues_2_macro_int/63);



save(strcat('v3_',num2str(own_no_RRH_per_macro),'_',num2str(no_interfering_RRHs)));
