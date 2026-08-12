function [CPACSgeo]=addAbsControls(CPACSgeo)

%% Conditions
% The point order is from root to tip
% No definition over a king

%% Calc Positions
for compNum=1:size(CPACSgeo.wings.component)     

    lePoints=[];
    tePoints=[];
    for n=1:size(CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys)   
        lePoints(:,n)=CPACSgeo.wings.component{compNum,1}.sectionDef.point{n,1};
        tePoints(:,n)=CPACSgeo.wings.component{compNum,1}.sectionDef.point{n,1}+CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys{n,1}*[1 0 0]';
    end

    spVec=[];
    area=[];
    sw=[];
    for n=1:size(CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys)-1            
        chordVec1=CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys{n,1}*[1;0;0];
        chordVec2=CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys{n+1,1}*[1;0;0];
        chordLenth1=sqrt(chordVec1(1,1)^2+chordVec1(2,1)^2+chordVec1(3,1)^2);
        chordLenth2=sqrt(chordVec2(1,1)^2+chordVec2(2,1)^2+chordVec2(3,1)^2);
        spVec(:,n)=CPACSgeo.wings.component{compNum,1}.sectionDef.point{n+1,1}-CPACSgeo.wings.component{compNum,1}.sectionDef.point{n,1};
        loacalSpan(compNum,n)=sqrt(spVec(2,n)^2+spVec(3,n)^2);
        area(n,1)=loacalSpan(compNum,n)*(chordLenth1+chordLenth2)/2;
        sw(compNum,n)=tan(spVec(1,n)/loacalSpan(compNum,n));
    end
    
    % If the leading edge point is not the outer point
    etaMaxVec=spVec;
    etaMaxVecGlob=lePoints;
    
    % In te the innerst or outers point
    lastSecNum=size(CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys,1);
    tipVec=CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys{lastSecNum,1}*[1 0 0]';
    if abs(tipVec(2))>0 && sign(tipVec(2,1))==sign(spVec(2,end))
        etaMaxVec=[spVec,tipVec];
        etaMaxVecGlob=[etaMaxVecGlob,tePoints(:,end)];
    end   
    
    rootVec=CPACSgeo.wings.component{compNum,1}.sectionDef.coorsSys{1,1}*[1 0 0]';
    if abs(rootVec(2))>0 && sign(rootVec(2,1))==sign(spVec(2,1))
        etaMaxVec=[rootVec,etaMaxVec];
        etaMaxVecGlob=[tePoints(1,1),etaMaxVecGlob];
    end
    
    etaMaxAbsGlobal(compNum,1)=0;
    for i=1:size(etaMaxVec,2)
        etaMaxAbsLocal(compNum,i)=sqrt(etaMaxVec(2,i)^2+etaMaxVec(3,i)^2);
        etaMaxAbsGlobal(compNum,i+1)=sum(etaMaxAbsLocal(compNum,1:i));
    end
    % maximum absolut eta coordinat
    etaMax=sum(etaMaxAbsLocal(compNum,:));
    
    %% 
    for flNum=1:size(CPACSgeo.wings.component{compNum,1}.controlSurfaces.definition.trailingEdgeDevices,1)
        
        % Get FlapInformation
        
        try etaLEVec=CPACSgeo.wings.component{compNum,1}.controlSurfaces.definition.trailingEdgeDevices{flNum,1}.etaLE ;end
        try etaTEVec=CPACSgeo.wings.component{compNum,1}.controlSurfaces.definition.trailingEdgeDevices{flNum,1}.etaTE ;end
        try ksiLEVec=CPACSgeo.wings.component{compNum,1}.controlSurfaces.definition.trailingEdgeDevices{flNum,1}.ksiLE ;end
        try ksiTEVec=CPACSgeo.wings.component{compNum,1}.controlSurfaces.definition.trailingEdgeDevices{flNum,1}.ksiTE ;end
        
        
        relPos(1,1)=etaLEVec(1,1);        
        relPos(1,2)=ksiLEVec(1,1);
        
        try relPos(2,1)=etaTEVec(1,1); catch relPos(2,1)=relPos(1,1);end
        try relPos(2,2)=ksiTEVec(1,1); catch relPos(2,2)=1;         end
        
        relPos(3,1)=etaLEVec(1,2);        
        relPos(3,2)=ksiLEVec(1,2);
        
        try relPos(4,1)=etaTEVec(1,2); catch relPos(4,1)=relPos(3,1);end
        try relPos(4,2)=ksiTEVec(1,2); catch relPos(4,2)=1;         end
             
        count=0;
        flapCornerPoints=[];
        for corner=[1,2,4,3]
            count=count+1;
            etaPos=relPos(corner,1);
            xiPos=relPos(corner,2);

            % Find Eta Position in segmants
            outerboarderSection = min(find(((etaMaxAbsGlobal(compNum,:)/etaMax-etaPos)>0)==1));
            inerboarderSection  = min(find(((etaPos-etaMaxAbsGlobal(compNum,:)/etaMax)>=0)==0))-1;

            % Local eta of a segment
            secionLocalEta=(etaPos-etaMaxAbsGlobal(compNum,inerboarderSection)/etaMax)*etaMax/etaMaxAbsLocal(compNum,inerboarderSection);
            localVectorToEta=secionLocalEta*etaMaxVec(:,inerboarderSection);

            % Cut Surface
            plEta=(etaMaxVecGlob(:,inerboarderSection)+localVectorToEta);
            ex=[1;0;0];
            normalVec=cross(localVectorToEta,ex);
            normalVec=normalVec/sqrt(normalVec(1,1)^2+normalVec(2,1)^2+normalVec(3,1)^2);

            if min(localVectorToEta==zeros(3,1))==0
                for i=1:size(tePoints,2)-1
                    % Te Vector
                    PT1=tePoints(:,i);
                    PT2=tePoints(:,i+1);
                    % Cross point between 
                    A = [ ex(1,1), normalVec(1,1), -(PT2(1,1)-PT1(1,1));...
                          ex(2,1) ,normalVec(2,1), -(PT2(2,1)-PT1(2,1));...
                          ex(3,1), normalVec(3,1), -(PT2(3,1)-PT1(3,1))];
                    B = [PT1(1,1)-plEta(1,1); PT1(2,1)-plEta(2,1) ;PT1(3,1)-plEta(3,1)];
                    c=inv(A)*B;
                    PtEtaLocal=PT1+c(3)*(PT2-PT1);
                    %Proving if the PtEta between PT1 PT2
                    d1=PT1-PtEtaLocal;
                    d1=d1(find(d1~=0));
                    d2=PtEtaLocal-PT2;
                    d2=d2(find(d2~=0));
                    if size(unique(sign(d1)),1)==1 && size(unique(sign(d2)),1)==1
                        if unique(sign(d1))==-1 && unique(sign(d2))==-1
                            PtEta=PT1+c(3)*(PT2-PT1);
                        end
                    end  
                    if isempty(d1)
                        PtEta=PT1;
                    elseif isempty(d2)
                        PtEta=PT2;
                    end
                end
            else % If the localVectorToEta Vector is zero
                PtEta=PT1;
            end

            % Point position on wing
            Pxi=plEta+(PtEta-plEta)*xiPos;
            flapCornerPoints(:,count)=Pxi;            
            
        end
        
        % Save all conerpoints
        % flapCornerPoints(:,count+1)=flapCornerPoints(:,1);
        CPACSgeo.wings.component{compNum,1}.controlSurfaces.definition.trailingEdgeDevices{flNum,1}.flapAbsCornerPoints=flapCornerPoints;
           
    end
end

%% Plot Flaps
for compNum=1:size(CPACSgeo.wings.component) 
    for flNum=1:size(CPACSgeo.wings.component{compNum,1}.controlSurfaces.definition.trailingEdgeDevices,1)

        flapAbsCornerPoints=CPACSgeo.wings.component{compNum,1}.controlSurfaces.definition.trailingEdgeDevices{flNum,1}.flapAbsCornerPoints;
        order=[2,1,4,3];
        plot3(flapAbsCornerPoints(1,order),flapAbsCornerPoints(2,order),flapAbsCornerPoints(3,order),'Color','k','LineWidth',1)
        
        cornerp(1,:)= flapAbsCornerPoints(:,1);
        cornerp(2,:)= flapAbsCornerPoints(:,2);
        cornerp(3,:)= flapAbsCornerPoints(:,3);
        cornerp(4,:)= flapAbsCornerPoints(:,4); 

        vec1(1,:)=cornerp(1,:);
        vec1(2,:)=cornerp(2,:);
        vec1(3,:)=cornerp(3,:);
        vec1(4,:)=cornerp(4,:);

        vert = [  vec1(1,:);  vec1(2,:);  vec1(3,:);  vec1(4,:)];
        fac = [1 2 3;1 3 4];
        col=[0.2,0.2,0.2];
        tcolor = [col; col];
        h=patch('Faces',fac,'Vertices',vert,'FaceVertexCData',tcolor,...
              'FaceColor','flat','EdgeColor','none');
        set(h,'EdgeAlpha',0)
        hold on
        
        % Plot Symetry
        if CPACSgeo.wings.component{compNum,1}.symmetry;
            flapAbsCornerPoints(2,:)=-flapAbsCornerPoints(2,:);
            plot3(flapAbsCornerPoints(1,order),flapAbsCornerPoints(2,order),flapAbsCornerPoints(3,order),'Color','k','LineWidth',1)
            cornerp(1,:)= flapAbsCornerPoints(:,1);
            cornerp(2,:)= flapAbsCornerPoints(:,2);
            cornerp(3,:)= flapAbsCornerPoints(:,3);
            cornerp(4,:)= flapAbsCornerPoints(:,4); 

            vec1(1,:)=cornerp(1,:);
            vec1(2,:)=cornerp(2,:);
            vec1(3,:)=cornerp(3,:);
            vec1(4,:)=cornerp(4,:);

            vert = [  vec1(1,:);  vec1(2,:);  vec1(3,:);  vec1(4,:)];
            fac = [1 2 3;1 3 4];
            tcolor = [col; col];
            h=patch('Faces',fac,'Vertices',vert,'FaceVertexCData',tcolor,...
                  'FaceColor','flat','EdgeColor','none');
            set(h,'EdgeAlpha',0)
            hold on
        end
        
    end
end

