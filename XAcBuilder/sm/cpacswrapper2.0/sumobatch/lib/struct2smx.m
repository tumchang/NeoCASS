function [ ] = struct2smx( s, file )
%Convert a MATLAB structure into a xml file 
% [ ] = struct2xml( s, file )
%
% A structure containing:
% s.XMLname.Attributes.attrib1 = "Some value";
% s.XMLname.Element.Text = "Some text";
% s.XMLname.DifferentElement{1}.Attributes.attrib2 = "2";
% s.XMLname.DifferentElement{1}.Text = "Some more text";
% s.XMLname.DifferentElement{2}.Attributes.attrib3 = "2";
% s.XMLname.DifferentElement{2}.Attributes.attrib4 = "1";
% s.XMLname.DifferentElement{2}.Text = "Even more text";
%
% Will produce:
% <XMLname attrib1="Some value">
%   <Element>Some text</Element>
%   <DifferentElement attrib2="2">Some more text</Element>
%   <DifferentElement attrib3="2" attrib4="1">Even more text</DifferentElement>
% </XMLname>
%
% Written by W. Falkena, ASTI, TUDelft, 27-08-2010
% Modify by T. Pfeiffer, DLR, Hamburg, 06-05-2011
    
%Code
    if (nargin < 2)
        clc;
        help struct2smx
        return
    end
    
    if (~isstruct(s) || isempty(file))
        clc;
        help struct2smx
        return
    end
    
    if (isempty(strfind(file,'.smx')))
        file = [file '.smx'];
    end
    
    if (length(fieldnames(s)) > 1)
        error(['Error processing the structure:' sprintf('\n') 'There should be a single field in the main structure.']);
    end
    xmlname = fieldnames(s);
    xmlname = xmlname{1};
    
    %create xml structure
    docNode = com.mathworks.xml.XMLUtils.createDocument(xmlname);
    
    %process the rootnode   
    docRootNode = docNode.getDocumentElement;
        
    %append childs
    parseStruct(s.(xmlname),docNode,docRootNode,[inputname(1) '.' xmlname '.']);
    
    %save xml file
    xmlwrite(file,docNode);    
end

% ----- Subfunction parseStruct -----
function [] = parseStruct(s,docNode,curNode,pName)

    % Settings % mod T.P.
    set=1; 
    
    fnames = fieldnames(s);
    for i = 1:length(fnames)
        curfield = fnames{i};
        
        if (strcmp(curfield,'Attributes'))
            %Attribute data
            if (isstruct(s.(curfield)))
                attr_names = fieldnames(s.Attributes);
                for a = 1:length(attr_names)
                    cur_attr = attr_names{a};
                    [cur_str] = val2str(s.Attributes.(cur_attr));
                    if (~isempty(cur_str))
                        curNode.setAttribute(cur_attr,cur_str);
                    else
                        if set >= 0
                           curNode.setAttribute(cur_attr,'') 
                        else
                            disp(['Warning. The text in ' pName curfield '.' cur_attr ' could not be processed.']);
                        end
                    end
                end
            else
                disp(['Warning. The attributes in ' pName curfield ' could not be processed.']);
                disp(['The correct syntax is: ' pName curfield '.attribute_name = ''Some text''.']);
            end
        elseif (strcmp(curfield,'Text'))
            %Text data
            [txt] = val2str(s.Text);
            if (~isempty(txt))
                curNode.appendChild(docNode.createTextNode(txt));
            else
                if set > 1
                    curNode.appendChild(docNode.createTextNode(''));
                else
                    disp(['Warning. The text in ' pName curfield ' could not be processed.']);
                end
            end
        else
            %Sub-element
            if (isstruct(s.(curfield)))
                %single element
                curElement = docNode.createElement(curfield);
                curNode.appendChild(curElement);
                parseStruct(s.(curfield),docNode,curElement,[pName curfield '.'])
            elseif (iscell(s.(curfield)))
                %multiple elements
                for c = 1:length(s.(curfield))
                    curElement = docNode.createElement(curfield);
                    curNode.appendChild(curElement);
                    parseStruct(s.(curfield){c},docNode,curElement,[pName curfield '.'])
                end
            else
                %eventhough the fieldname is not text, the field could
                %contain text. Create a new element and use this text
                curElement = docNode.createElement(curfield);
                curNode.appendChild(curElement);
                [txt] = val2str(s.(curfield));
                if (~isempty(txt))
                    curElement.appendChild(docNode.createTextNode(txt));
                else
                    if set > 2
                        curElement.appendChild(docNode.createTextNode(''));
                    else
                        disp(['Warning. The text in ' pName curfield ' could not be processed.']);
                    end
                end
            end
        end
    end
end

% ----- Subfunction val2str -----
function [str] = val2str(val)
    
    str = [];
    
    if (ischar(val))
        str = val;
    elseif (isnumeric(val))
        tmp = num2str(val);
        for i = 1:size(tmp,1) %multiline string
            str = [str regexprep(tmp(i,:),'[ ]*', ' ') sprintf('\n')];
        end
        str = str(1:end-1); %skip last enter
    end
end