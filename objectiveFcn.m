%%this function is called ineach iteration and defines the objevtive to
%%minimise for cluster head selection
%%
function objval=objectiveFcn(nodeTable,x,nodes,clusterno,nodepos,sinknode)
% clusterheadpos=reshape(clusterheadpos,numel(clusterheadpos)/2,2);
clusterheadpos=nodepos(x,:);
sink=sinknode;  % sink node
%% calculate the distance of each clusterhead from each node
for ii=1:clusterno
    % every CH to each node
    dist(ii,:) = sqrt((clusterheadpos(ii,1).*ones(100,1)-nodepos(:,1)).^2+...
                                      (clusterheadpos(ii,2).*ones(100,1)-nodepos(:,2)).^2);
    % base Station to every CH
    CHdistance(ii)=pdist([sink;clusterheadpos(ii,:)],'euclidean');  
end
for ii=1:nodes
     [D(ii),idx(ii)]=min(dist(:,ii));
end
% [idx,C,sumd,D] = kmeans(nodepos,clusterno,'Start',clusterheadpos);

%% energy residual after each cluster head to sink node communication
CHenergy=CHtoSinkEnergy(nodeTable,CHdistance,nodes,clusterno,x);

%% energy residual after each cluster head to sensor node communication
for ii=1:clusterno
    clusternodeID=nodeTable.nodeID(idx==ii);
    nodedistance=D(idx==ii);
    Clusternodes=numel(nodedistance);
    if Clusternodes~=0
    [NodeEnergy,~,~,~]=nodetoCHEnergy(nodeTable,nodedistance,Clusternodes,clusternodeID);
    nodeTable.energy(clusternodeID)= NodeEnergy;
    end
end
%% objval calculation
alpha1=0.4;
alpha2=0.4;
for ii=1:clusterno
    nodedistance=D(idx==ii);
    FirstTerm(ii)=alpha1*(sum(nodedistance)/numel(find(idx==ii)));
    secondTerm(ii)=alpha2*(sum(nodeTable.energy(idx==ii))/CHenergy(ii));
    thirdTerm(ii)=(1-alpha1-alpha2)*(1/numel(find(idx==ii)));
    addTerms(ii)=FirstTerm(ii)+secondTerm(ii)+thirdTerm(ii);
end
objval=mean(addTerms);

end
