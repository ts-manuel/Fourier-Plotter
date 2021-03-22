%LOADSVG Load points from svg file
%
%   Read points from layer0.
%   Each layer can contain more than one path,
%   points from each path are returned in a
%   separate element of the array.
%
%   out{i}.s = vector of points
%   out{i}.n = number of points
%   out{i}.t = time vector
%

function [out] = loadSVG(file)

    % Read xml file
    xml = xmlread(file);

    % Read leyer 0
    layer = xml.getElementsByTagName('g').item(0);

    % Read all paths in layer 0
    paths = layer.getElementsByTagName('path');

    % Read Points
    out = cell(paths.getLength);
    for k = 1:paths.getLength

        %Read path
        pts = readPath(paths.item(k-1));

        if ~isempty(pts)
            % Convert points to complex numbers
            s = pts(1,:) - 1i*pts(2,:);
            n = length(s);
            t = 0:1/n:1-1/n;

            out{k} = struct();
            out{k}.s = s;
            out{k}.n = n;
            out{k}.t = t;
        else
          warning('Unable to import path %d in layer 0\n',k-1)  
        end
    end
end

% Read points from path
function [pts] = readPath(item)

    if (~isempty(item))
        if ~item.hasAttribute('d')
            item.getParentNode().removeChild(item)
            return
        end

        % Extract and split string with points into individual elements
        str = char(item.getAttribute('d'));
        str_array = strsplit(strip(str),{' ',','},'CollapseDelimiters',true);
        
        % Read one attribute at a time
        str_ptr = 1;
        pnt_cnt = 1;
        x = 0;
        y = 0;
        while str_ptr < length(str_array)
            % Read next attribute
            a = str_array{str_ptr};
            la = lower(a);
            str_ptr = str_ptr+1;
           
            % Parse one parameter attribute
            if (la == 'v') || (la == 'h')
                while str_ptr <= length(str_array) && ~isnan(str2double(str_array{str_ptr}))
                    p0 = str2double(str_array{str_ptr});
                    str_ptr = str_ptr+1;
                    
                    switch a
                        case 'V'
                            y = p0;
                        case 'v'
                            y = y+p0;
                        case 'H'
                            x = p0;
                        case 'h'
                            x = x+p0;
                    end
                    
                    pts(:,pnt_cnt) = [x, y];
                    pnt_cnt = pnt_cnt+1;
                end
            
            % Parse two parameters attribute
            elseif (la == 'm') || (la == 'l')
                while str_ptr <= length(str_array) && ~isnan(str2double(str_array{str_ptr}))
                    p0 = str2double(str_array{str_ptr});
                    p1 = str2double(str_array{str_ptr+1});
                    str_ptr = str_ptr+2;
                    
                    switch a
                        case {'M','L'}
                             x = p0;
                             y = p1;
                        case {'m','l'}
                             x = x+p0;
                             y = y+p1;
                    end
                    
                    pts(:,pnt_cnt) = [x, y];
                    pnt_cnt = pnt_cnt+1;
                end
                
            % Uninplemented attributes
            else
                error('Uninplemented attribute %c\n',a);
            end
        end
    end
end