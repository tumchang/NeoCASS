function updateCPACSWrapper
%% Parrent Folder

    % Locations
    parrentPath='D:\Arbeit\Matlab\';
    sorceFolder='CPACSWrapper\';
    destFolder='EDGEstandAllone\CPACSWrapper\';
    from=[parrentPath,sorceFolder];
    to=[parrentPath,destFolder];
    disp(['From : ',from])
    disp(['To   : ',to])
    
    % File Names
    filenameList = {'aeroData2cpacs.m'      'initialize.m'          'runCPACSWrapper.m'...     
                    'aeroDataFromCpacs.m'   'tornadoWrapper.m'      'cpacsWrapper.m'...
                    'ISA.m'                 'loadCpacsFile.m'       };                   

    copyFileList(filenameList,from,to)

%% Sub Folder lib

    % Locations
    sorceFolder='CPACSWrapper\lib\';
    destFolder='EDGEstandAllone\CPACSWrapper\lib\';
    from=[parrentPath,sorceFolder];
    to=[parrentPath,destFolder];
    disp(['From : ',from])
    disp(['To   : ',to])
    
    % File Names
    filenameList = {'addAbsControls.m'    'coordSysTrans.m'        'rotVec.m'...               
                    'addWingSec.m'        'cpacsGeoReader.m'       'rotatePoints.m'...         
                    'arrow3D.m'           'eulerTrans.m'           'sphere3D.m'...             
                    'calcAbsVec.m'        'plotSurfaces.m'         'struct2xml.m' ...          
                    'coordSysPlot.m'      'plotWireFrames.m'       'xml2struct.m' ...          
                    'polygeom.m'          'readTrandformations.m'  'refGen.m'} ;           
    copyFileList(filenameList,from,to) 


%% copy Sub Function

function copyFileList(filenameList,from,to)

    for i=1:size(filenameList,2);
        filename=filenameList{1,i};

        dataFrom = dir([from,filename]);
        dnumFrom = datenum(dataFrom.date,'dd-mmm-yyyy HH:MM:SS');
        try 
            dataTo = dir([to,filename]);
            dnumTo = datenum(dataTo.date,'dd-mmm-yyyy HH:MM:SS');
        catch
            dnumTo=0;
        end

        if dnumFrom>=dnumTo
            copyfile([from,filename],[to,filename],'f')
            disp([' Copy: ',filename])
        else
            questAns=questdlg(['Source "',filename,'" is older then destination file.' ,' Are you sure to overwrite that file?']);
            if strcmp(questAns,'Yes')
                copyfile([from,filename],[to,filename],'f')
                disp([' Copy: ',filename,' (overwritten)'])
            else                
                questAns2=questdlg(['Copy from destination to Sorce? "',filename,'"']);
                if strcmp(questAns2,'Yes')   
                    copyfile([to,filename],[from,filename],'f')
                    disp([' Copy from Destination to Sorce: ',filename,' (overwritten)'])
                else
                    disp([' Not Copyed: ',filename,''])
                end
            end
        end
    end  