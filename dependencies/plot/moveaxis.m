function moveaxis(varargin)
%MOVEAXIS Used to grab and move legend axis.
%   To use, click and hold down a mouse button while
%   the cursor is near the lower left corner of the
%   axis you want to move. Wait for the cursor to change
%   to a fleur (4 way arrows), then drag the legend or axis
%   to the desired location and release the mouse button.
%
%   To enable, set the figure window's WINDOWBUTTONDOWNFCN
%   property to 'moveaxis'. For example,
%
%            set(gcf,'WindowButtonDownFcn','moveaxis')

%   10/5/93  D.Thomas
%   Copyright (c) 1984-98 by The MathWorks, Inc.
%   $Revision: 5.10 $  $Date: 1998/05/12 22:40:34 $
%
%   4/5/01 A.Hastings
%   Modified so that it will move the axis specifed by MOVETAG
%   To use this modified version set the tag of the Axes to a
%   known: textAxis = axes('tag','TextAxis') then modify
%   the "ButtonDownFcn" of a child on the axes to be "moveaxis(''TextAxis'')"
%   text(0,0,"Some Text", 'ButtonDownFcn','moveaxis(''TextAxis'')');
%   This will allow you to move any axis with function not just the Legend.

global OLDCA DELTA HL FIGUTS MOVETAG;
arg=0;
if nargin == 0
    MOVETAG='legend';
end

for i=1:nargin
    if isstr(varargin{i})
        MOVETAG = varargin{i};
    else
        arg = varargin{i};
    end
end

if arg==0,
    fig = gcf;
    st=get(fig,'SelectionType');
    if (strcmp(st,'normal'))
        AHmoveaxis(1);
    elseif strcmp(st,'open'),
        if strcmp(get(gco,'Type'),'text') & ...
                strcmp(get(get(gco,'parent'),'tag'),MOVETAG)
            legend('EditLegend',gco)
        end
    end
elseif arg==1,
    fig = gcf;
    FIGUTS = get(fig,'units');
    set(fig,'pointer','fleur');
    if strcmp(FIGUTS,'normalized'),
        pnt = get(fig,'currentpoint');
        set(fig,'units','pixels');
        pos = get(fig,'position');
        pnt = [pnt(1) * pos(3) pnt(2) * pos(4)];
    else,
        set(fig,'units','pixels');
        pnt=get(fig,'currentpoint');
    end
    Kids=get(fig,'children');
    [n,tmp]=size(Kids);
    mn=1e20;
    mi=1;
    for i=1:n,
        if strcmp(get(Kids(i),'type'),'axes') & ...
                strcmp(get(Kids(i),'tag'),MOVETAG)
            units=get(Kids(i),'units');
            set(Kids(i),'units','pixels')
            cap=get(Kids(i),'position');
            if sum((pnt-cap(1:2)).^2)<mn,
                mn=sum((pnt-cap(1:2)).^2);
                mi=i;
                DELTA=cap(1:2)-pnt;
            end
            set(Kids(i),'units',units);
        end
    end
    ud = get(Kids(mi),'userdata');
    OLDCA=gca;
    set(fig,'currentobject',Kids(mi));
    HL=[Kids(mi) abs(get(Kids(mi),'units'))];
    set(Kids(mi),'units','pixels');
    set(fig,'windowbuttonmotionfcn','AHmoveaxis(2)')
    set(fig,'windowbuttonupfcn','AHmoveaxis(3)');
elseif arg==2,
    fig = gcf;
    pos=get(get(fig,'currentobject'),'position');
    set(get(fig,'currentobject'),'units','pixels','drawmode','fast',...
                      'position',[get(fig,'currentpoint')+DELTA pos(3:4)]);
elseif arg==3,
    fig = gcf;
    set(fig,'WindowButtonMotionfcn','', ...
            'pointer','arrow','currentaxes',OLDCA, ...
            'windowbuttonupfcn','');
    set(HL(1),'units',setstr(HL(2:length(HL))));
    set(fig,'units',FIGUTS);
    if strcmp(get(gca,'tag'),MOVETAG)
        %      legend('ShowLegendPlot')
    end
end
