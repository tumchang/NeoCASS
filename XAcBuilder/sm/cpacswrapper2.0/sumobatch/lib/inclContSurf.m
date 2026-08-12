function [NewS] = inclContSurf(NewS,CPACSgeo,wingNum)

%% Describtion %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                                  n = Number of control
% NewS.Assembly.ControlSystem.ControlSrf{1, n }.Attributes.name='UndefinedFlap1';  % Flap name  
% NewS.Assembly.ControlSystem.ControlSrf{1, n }.Attributes.type='LEF';             % Defintiton of flap type (LED or TEF)
% NewS.Assembly.ControlSystem.ControlSrf{1, n }.Attributes.wing='Wing1';           % Referenc wing name  
% 
%                                                    k = contol edge number
% NewS.Assembly.ControlSystem.ControlSrf{1, n  }.Hingepoint{1, k }.Attributes.chordpos='0.75';    % xi chord position of flap (0=leading edge, 1=trailing edge) 
% NewS.Assembly.ControlSystem.ControlSrf{1, n  }.Hingepoint{1, k  }.Attributes.spanpos='0.05';    % eta span position of flap (0=right wing tip, 1=left wing tip)
% 
% NewS.Assembly.ControlSystem.ControlSrf{1, n  }.Hingepoint{1, k+1  }.Attributes.chordpos='0.75';
% NewS.Assembly.ControlSystem.ControlSrf{1, n  }.Hingepoint{1, k+1  }.Attributes.spanpos='0.25';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% set Counter

try
    count=size(NewS.Assembly.ControlSystem.ControlSrf,2);
catch
    count=0;
end

%% Cose Flap Type

controlSurfaces=CPACSgeo.wings.component{wingNum,1}.controlSurfaces.definition;
type=fieldnames(controlSurfaces);
switch type{1,1}
    case 'trailingEdgeDevices'
        
%% Stet Basic settings
        for i=1:size(controlSurfaces.trailingEdgeDevices,1)
            count=count+1;
            NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.name=[controlSurfaces.trailingEdgeDevices{i,1}.TEDname,'_L'];
            NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.type='TEF';  
            NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.wing=CPACSgeo.wings.component{wingNum,1}.name;           

            for ii=1:size(controlSurfaces.trailingEdgeDevices{1,1}.etaLE,2)
                etaLE=controlSurfaces.trailingEdgeDevices{i,1}.etaLE(1,ii);
                if CPACSgeo.wings.component{wingNum,1}.symmetry==1;
                    etaLE1=0.5-etaLE/2;
                else
                    etaLE1=etaLE;
                end
                NewS.Assembly.ControlSystem.ControlSrf{1,count}.Hingepoint{1,ii}.Attributes.chordpos = num2str(controlSurfaces.trailingEdgeDevices{i,1}.ksiLE(1,ii));
                NewS.Assembly.ControlSystem.ControlSrf{1,count}.Hingepoint{1,ii}.Attributes.spanpos  = etaLE1;
            end
            
            if CPACSgeo.wings.component{wingNum,1}.symmetry==1;
                count=count+1;
                NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.name=[controlSurfaces.trailingEdgeDevices{i,1}.TEDname,'_R'];
                NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.type='TEF';  
                NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.wing=CPACSgeo.wings.component{wingNum,1}.name;
                
                for ii=1:size(controlSurfaces.trailingEdgeDevices{1,1}.etaLE,2)
                    etaLE=controlSurfaces.trailingEdgeDevices{i,1}.etaLE(1,ii);                
                    etaLE1=etaLE/2+0.5;
                    NewS.Assembly.ControlSystem.ControlSrf{1,count}.Hingepoint{1,ii}.Attributes.chordpos = num2str(controlSurfaces.trailingEdgeDevices{i,1}.ksiLE(1,ii));
                    NewS.Assembly.ControlSystem.ControlSrf{1,count}.Hingepoint{1,ii}.Attributes.spanpos  = etaLE1;
                end
                
            end            
        end

    case 'leadingEdgeDevices'
%% Leading Edge flap (#Not tested)
        for i=1:size(controlSurfaces.leadingEdgeDevices,1)        
        count=count+1;
            NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.name=controlSurfaces.leadingEdgeDevices{i,1}.TEDname;
            NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.type='LEF';  
            NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.wing=['Wing',num2str(wingNum)];           

            for ii=1:size(controlSurfaces.leadingEdgeDevices{1,1}.etaLE,2)
                etaLE=controlSurfaces.leadingEdgeDevices{i,1}.etaLE(1,ii);                
                etaLE1=0.5-etaLE/2;
                NewS.Assembly.ControlSystem.ControlSrf{1,count}.Hingepoint{1,ii}.Attributes.chordpos = num2str(controlSurfaces.leadingEdgeDevices{i,1}.ksiLE(1,ii));
                NewS.Assembly.ControlSystem.ControlSrf{1,count}.Hingepoint{1,ii}.Attributes.spanpos  = etaLE1;
            end
            
            if CPACSgeo.wings.component{wingNum,1}.symmetry==1;
                count=count+1;
                NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.name=controlSurfaces.leadingEdgeDevices{i,1}.TEDname;
                NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.type='LEF';  
                NewS.Assembly.ControlSystem.ControlSrf{1,count}.Attributes.wing=['Wing',num2str(wingNum)];
                
                for ii=1:size(controlSurfaces.leadingEdgeDevices{1,1}.etaLE,2)
                    etaLE=controlSurfaces.leadingEdgeDevices{i,1}.etaLE(1,ii);                
                    etaLE1=etaLE/2+0.5;
                    NewS.Assembly.ControlSystem.ControlSrf{1,count}.Hingepoint{1,ii}.Attributes.chordpos = num2str(controlSurfaces.leadingEdgeDevices{i,1}.ksiLE(1,ii));
                    NewS.Assembly.ControlSystem.ControlSrf{1,count}.Hingepoint{1,ii}.Attributes.spanpos  = etaLE1;
                end
                
            end            
        end        
    otherwise
        % do nothing (spoilers)
end
