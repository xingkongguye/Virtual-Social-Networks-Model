function [w]=social(n,N,sita,c)
% n:the number of nodes of the initial coupled network；N：final size of the network；sita；c：The length of the hobby |H|。
w=ones(n);                                                                 %%% initialize coupled network
for i=1:n
    w(i,i)=0;
end

x=randraw('yule',2,[n,c]);                                                 %initialize the hobby |H| for initial coupled network
while(n<N)
    p1=randraw('yule',2,[1,c]);                                            %%a new node, a new hobby vector
    x=[x;p1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Finding the nodes with similar hobbies%%%%%%%%%%%%%%%%%%%%
    for pi=1:n
         p2(pi)=sqrt(sum((x(pi,1:c)-p1(1:c)).^2));                         
    end
    [p22 hindex]=sort(p2);
    d_mean = mean(p2);
    interest = hindex(p22<d_mean);
    lengI = length(interest);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    os=sum(w');                                                            %%%computing the out strength
    is=sum(w);                                                             %%%computing the in strength
    s=os+is;                                                               %%%computing the strength
    ik=zeros(1,n);                                                         %%%the in degree
    ok=zeros(1,n);                                                         %%%the out degree
    
    for i=1:n                                                              %%%computing the degree
        ok(1,i)= sum(w(i,:)==1);
        ik(1,i)= sum(w(i,:)==1);
    end
    p=s/sum(s);                                                            
    w=[w,zeros(n,1)];
    w=[w;zeros(1,n+1)]; 
    Rf = [];
    NSi = [];
    for t=1:sita
        ns=0;
        oldnode=0;
        r=rand(1);
        if(t==1)
            q=0;
            for j=1:n    
                if(ismember(j,interest))
                    qi=p(j);
                    q=[q,qi];
                end
            end
            q=cumsum(q);
            q=q/(q(length(q)));
            for j=1:length(interest)
                if(q(j)<=r && q(j+1)>=r)
                    oldnode=interest(j);                    
                    break
                end
            end
            w(n+1,oldnode)=w(n+1,oldnode)+1;
            Rneighbor=find(w(oldnode,:));
            Lneighbor=find(w(:,oldnode));
            Rf = unique([Rneighbor Lneighbor']);
            Rf = setdiff(Rf, n+1);
            NSi = [NSi oldnode];
        else         %Cascading recommendation
            bp = 1 - (1/(length(Rf)+1));
            br=rand(1);
            if br < bp
                q = 0;
                for j=1:length(Rf)
                    qi=p(Rf(j));
                    q=[q,qi];                
                end
                q=cumsum(q);
                q=q/(q(length(q)));
                for j=1:length(Rf)
                    if(q(j)<=r && q(j+1)>=r)
                        oldnode=Rf(j);                    
                        break
                    end
                end
                w(n+1,oldnode)=w(n+1,oldnode)+1;
                w(oldnode,n+1)=w(oldnode,n+1)+1;
                NSi = [NSi oldnode];
                Rneighbor=find(w(oldnode,:));
                Lneighbor=find(w(:,oldnode));
                Rf_t = unique([Rneighbor Lneighbor']);
                Rf_t = setdiff(Rf_t, n+1);
                NSj = Rf_t;
                Rf = unique([Rf Rf_t]);
                Rf = setdiff(Rf,NSi);
                inter = intersect(NSi,NSj);
                for k=1:length(inter)
                    w(oldnode,inter(k)) = w(oldnode,inter(k)) + (w(oldnode,inter(k))+w(inter(k),oldnode))/s(oldnode);
                    w(inter(k),oldnode) = w(inter(k),oldnode) + (w(oldnode,inter(k))+w(inter(k),oldnode))/s(inter(k));
                end
            else
                q = 0;
                lefti = setdiff(interest,Rf);
                lefti = setdiff(lefti,NSi);
                if ~isempty(lefti)
                    for j=1:length(lefti)
                        qi=p(lefti(j));
                        q=[q,qi];                
                    end
                    q=cumsum(q);
                    q=q/(q(length(q)));
                    for j=1:length(lefti)
                        if(q(j)<=r && q(j+1)>=r)
                            oldnode=lefti(j);                    
                            break
                        end
                    end
                    w(n+1,oldnode)=w(n+1,oldnode)+1;
                    NSi = [NSi oldnode];
                    Rneighbor=find(w(oldnode,:));
                    Lneighbor=find(w(:,oldnode));
                    Rf_t = unique([Rneighbor Lneighbor']);
                    Rf_t = setdiff(Rf_t, n+1);
                    NSj = Rf_t;
                    Rf = unique([Rf Rf_t]);
                    Rf = setdiff(Rf,NSi);
                    inter = intersect(NSi,NSj);
                    for k=1:length(inter)
                    w(oldnode,inter(k)) = w(oldnode,inter(k)) + (w(oldnode,inter(k))+w(inter(k),oldnode))/s(oldnode);
                    w(inter(k),oldnode) = w(inter(k),oldnode) + (w(oldnode,inter(k))+w(inter(k),oldnode))/s(inter(k));
                    end  
                end
            end
        end
    end                                                                    %%%a new node have added to the network
    n=n+1; 
end
%save w.mat;
