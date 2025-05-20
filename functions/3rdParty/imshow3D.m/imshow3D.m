function imshow3D(Img, disprange, voltages, LOGpath, LOGfile)
%IMSHOW3D displays 3D grayscale or RGB images in a slice by slice fashion
%with mouse-based slice browsing and window and level adjustment control,
%and auto slice browsing control.
%
% Usage:
% imshow3D(Image)
% imshow3D(Image, [LOW HIGH])
% imshow3D(Image, [], voltages)
% imshow3D(Image, [], voltages, LOGpath, LOGfile)
%
%    Image:      3D image MxNxKxC (K slices of MxN images) C is either 1
%                (for grayscale images) or 3 (for RGB images)
%    [LOW HIGH]: display range that controls the display intensity range of
%                a grayscale image (default: the broadest available range)
%    voltages:   Voltage vector (column) for slice labels (default: 1:sno)
%    LOGpath:    Path to log file (for capture logging)
%    LOGfile:    Log file name (for capture logging)
%
% Edited by James May 2025 to add capture button, set logging.

sno = size(Img,3);  % number of slices
S = round(sno/2);
PlayFlag = false;
Tinterv = 100;

global InitialCoord;

MinV = 0;
MaxV = max(Img(:));
LevV = (double(MaxV) + double(MinV)) / 2;
Win = double(MaxV) - double(MinV);
WLAdjCoe = (Win + 1)/1024;
FineTuneC = [1 1/16];

if isa(Img,'uint8')
    MaxV = uint8(Inf);
    MinV = uint8(-Inf);
    LevV = (double(MaxV) + double(MinV)) / 2;
    Win = double(MaxV) - double(MinV);
    WLAdjCoe = (Win + 1)/1024;
elseif isa(Img,'uint16')
    MaxV = uint16(Inf);
    MinV = uint16(-Inf);
    LevV = (double(MaxV) + double(MinV)) / 2;
    Win = double(MaxV) - double(MinV);
    WLAdjCoe = (Win + 1)/1024;
elseif isa(Img,'uint32')
    MaxV = uint32(Inf);
    MinV = uint32(-Inf);
    LevV = (double(MaxV) + double(MinV)) / 2;
    Win = double(MaxV) - double(MinV);
    WLAdjCoe = (Win + 1)/1024;
elseif isa(Img,'uint64')
    MaxV = uint64(Inf);
    MinV = uint64(-Inf);
    LevV = (double(MaxV) + double(MinV)) / 2;
    Win = double(MaxV) - double(MinV);
    WLAdjCoe = (Win + 1)/1024;
elseif isa(Img,'int8')
    MaxV = int8(Inf);
    MinV = int8(-Inf);
    LevV = (double(MaxV) + double(MinV)) / 2;
    Win = double(MaxV) - double(MinV);
    WLAdjCoe = (Win + 1)/1024;
elseif isa(Img,'int16')
    MaxV = int16(Inf);
    MinV = int16(-Inf);
    LevV = (double(MaxV) + double(MinV)) / 2;
    Win = double(MaxV) - double(MinV);
    WLAdjCoe = (Win + 1)/1024;
elseif isa(Img,'int32')
    MaxV = int32(Inf);
    MinV = int32(-Inf);
    LevV = (double(MaxV) + double(MinV)) / 2;
    Win = double(MaxV) - double(MinV);
    WLAdjCoe = (Win + 1)/1024;
elseif isa(Img,'int64')
    MaxV = int64(Inf);
    MinV = int64(-Inf);
    LevV = (double(MaxV) + double(MinV)) / 2;
    Win = double(MaxV) - double(MinV);
    WLAdjCoe = (Win + 1)/1024;
elseif isa(Img,'logical')
    MaxV = 0;
    MinV = 1;
    LevV = 0.5;
    Win = 1;
    WLAdjCoe = 0.1;
end    

SFntSz = 9;
txtFntSz = 10;
LVFntSz = 9;
WVFntSz = 9;
BtnSz = 10;

% Handle voltages
if nargin < 3 || isempty(voltages)
    voltages = 1:sno;
else
    if length(voltages) ~= sno
        error('Length of voltages (%d) must match number of slices (%d)', length(voltages), sno);
    end
end

% Handle LOGpath, LOGfile
if nargin < 4
    LOGpath = '';
    LOGfile = '';
end

if nargin < 2 || isempty(disprange)
    [Rmin Rmax] = WL2R(Win, LevV);
else
    LevV = (double(disprange(2)) + double(disprange(1))) / 2;
    Win = double(disprange(2)) - double(disprange(1));
    WLAdjCoe = (Win + 1)/1024;
    [Rmin Rmax] = WL2R(Win, LevV);
end

% Use current figure
clf
axes('position',[0,0.2,1,0.8]), imshow(squeeze(Img(:,:,S,:)), [Rmin Rmax])

FigPos = get(gcf,'Position');
S_Pos = [30 45 uint16(FigPos(3)-100)+1 20];
Stxt_Pos = [30 65 uint16(FigPos(3)-100)+1 15];
Wtxt_Pos = [20 18 60 20];
Wval_Pos = [75 20 50 20];
Ltxt_Pos = [130 18 45 20];
Lval_Pos = [170 20 50 20];
Btn_Pos = [240 20 70 20];
ChBx_Pos = [320 20 80 20];
Play_Pos = [uint16(FigPos(3)-100)+40 45 30 20];
Time_Pos = [uint16(FigPos(3)-100)+35 20 40 20];
Ttxt_Pos = [uint16(FigPos(3)-100)-50 18 90 20];
Capture_Pos = [uint16(FigPos(3)-200)+1 65 80 20]; % Next to Stxt_Pos

% W/L Button styles
WL_BG = ones(Btn_Pos(4),Btn_Pos(3),3)*0.85;
WL_BG(1,:,:) = 1; WL_BG(:,1,:) = 1; WL_BG(:,end-1,:) = 0.4; WL_BG(:,end,:) = 0.2; WL_BG(end,:,:) = 0.2;

% Play Button styles
Play_BG = ones(Play_Pos(4),Play_Pos(3),3)*0.85;
Play_BG(1,:,:) = 1; Play_BG(:,1,:) = 1; Play_BG(:,end-1,:) = 0.4; Play_BG(:,end,:) = 0.2; Play_BG(end,:,:) = 0.2;
Play_Symb = [0,0,1,1,1,1,1,1,1,1,1,1,1,1; 0,0,0,0,1,1,1,1,1,1,1,1,1,1; 0,0,0,0,0,0,1,1,1,1,1,1,1,1;...
             0,0,0,0,0,0,0,0,1,1,1,1,1,1; 0,0,0,0,0,0,0,0,0,0,1,1,1,1; 0,0,0,0,0,0,0,0,0,0,0,0,1,1;...
             0,0,0,0,0,0,0,0,0,0,0,0,0,0; 0,0,0,0,0,0,0,0,0,0,0,0,1,1; 0,0,0,0,0,0,0,0,0,0,1,1,1,1;...
             0,0,0,0,0,0,0,0,1,1,1,1,1,1; 0,0,0,0,0,0,1,1,1,1,1,1,1,1; 0,0,0,0,1,1,1,1,1,1,1,1,1,1;...
             0,0,1,1,1,1,1,1,1,1,1,1,1,1];
Play_BG(floor((Play_Pos(4)-13)/2)+1:floor((Play_Pos(4)-13)/2)+13,floor(Play_Pos(3)/2)-7:floor(Play_Pos(3)/2)+6,:) = ...
    repmat(Play_Symb,1,1,3) .* Play_BG(floor((Play_Pos(4)-13)/2)+1:floor((Play_Pos(4)-13)/2)+13,floor(Play_Pos(3)/2)-7:floor(Play_Pos(3)/2)+6,:);
Pause_BG = ones(Play_Pos(4),Play_Pos(3),3)*0.85;
Pause_BG(1,:,:) = 1; Pause_BG(:,1,:) = 1; Pause_BG(:,end-1,:) = 0.4; Pause_BG(:,end,:) = 0.2; Pause_BG(end,:,:) = 0.2;
Pause_Symb = repmat([0,0,0,1,1,1,1,0,0,0],13,1);
Pause_BG(floor((Play_Pos(4)-13)/2)+1:floor((Play_Pos(4)-13)/2)+13,floor(Play_Pos(3)/2)-5:floor(Play_Pos(3)/2)+4,:) = ...
    repmat(Pause_Symb,1,1,3) .* Pause_BG(floor((Play_Pos(4)-13)/2)+1:floor((Play_Pos(4)-13)/2)+13,floor(Play_Pos(3)/2)-5:floor(Play_Pos(3)/2)+4,:);

% Capture Button styles
Capture_BG = ones(Capture_Pos(4),Capture_Pos(3),3)*0.6; % Light blue base
Capture_BG(:,:,1) = 0.6; Capture_BG(:,:,2) = 0.8; Capture_BG(:,:,3) = 1;
Capture_BG(1,:,:) = 1; Capture_BG(:,1,:) = 1; Capture_BG(:,end-1,:) = 0.4; Capture_BG(:,end,:) = 0.2; Capture_BG(end,:,:) = 0.2;

if sno > 1
    shand = uicontrol('Style', 'slider','Min',1,'Max',sno,'Value',S,'SliderStep',[1/(sno-1) 10/(sno-1)],'Position', S_Pos,'Callback', {@SliceSlider, Img});
    stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String',sprintf('Slice# %d (V = %.4f) / %d',S, voltages(S), sno), 'FontSize', SFntSz);
    playhand = uicontrol('Style', 'pushbutton','Position', Play_Pos, 'Callback', @Play);
    set(playhand, 'cdata', Play_BG)
    ttxthand = uicontrol('Style', 'text','Position', Ttxt_Pos,'String','Interval (ms): ',  'FontSize', txtFntSz);
    timehand = uicontrol('Style', 'edit','Position', Time_Pos,'String',sprintf('%d',Tinterv), 'BackgroundColor', [1 1 1], 'FontSize', LVFntSz,'Callback', @TimeChanged);
    capturehand = uicontrol('Style', 'pushbutton','Position', Capture_Pos,'String','Capture', 'FontSize', BtnSz, 'FontWeight', 'bold', 'CData', Capture_BG, 'Callback', @CaptureSlice);
else
    stxthand = uicontrol('Style', 'text','Position', Stxt_Pos,'String','2D image', 'FontSize', SFntSz);
end    
ltxthand = uicontrol('Style', 'text','Position', Ltxt_Pos,'String','Level: ',  'FontSize', txtFntSz);
wtxthand = uicontrol('Style', 'text','Position', Wtxt_Pos,'String','Window: ',  'FontSize', txtFntSz);
lvalhand = uicontrol('Style', 'edit','Position', Lval_Pos,'String',sprintf('%6.0f',LevV), 'BackgroundColor', [1 1 1], 'FontSize', LVFntSz,'Callback', @WinLevChanged);
wvalhand = uicontrol('Style', 'edit','Position', Wval_Pos,'String',sprintf('%6.0f',Win), 'BackgroundColor', [1 1 1], 'FontSize', WVFntSz,'Callback', @WinLevChanged);
Btnhand = uicontrol('Style', 'pushbutton','Position', Btn_Pos,'String','Auto W/L', 'FontSize', BtnSz, 'Callback', @AutoAdjust);
set(Btnhand, 'cdata', WL_BG)
ChBxhand = uicontrol('Style', 'checkbox','Position', ChBx_Pos,'String','Fine-tune', 'FontSize', txtFntSz);

set(gcf, 'WindowScrollWheelFcn', @mouseScroll);
set(gcf, 'ButtonDownFcn', @mouseClick);
set(get(gca,'Children'),'ButtonDownFcn', @mouseClick);
set(gcf,'WindowButtonUpFcn', @mouseRelease)
set(gcf,'ResizeFcn', @figureResized)

% -=< Figure resize callback function >=-
    function figureResized(object, eventdata)
        FigPos = get(gcf,'Position');
        S_Pos = [30 45 uint16(FigPos(3)-100)+1 20];
        Stxt_Pos = [30 65 uint16(FigPos(3)-100)+1 15];
        Play_Pos = [uint16(FigPos(3)-100)+40 45 30 20];
        Time_Pos = [uint16(FigPos(3)-100)+35 20 40 20];
        Ttxt_Pos = [uint16(FigPos(3)-100)-50 18 90 20];
        Capture_Pos = [uint16(FigPos(3)-200)+1 65 80 20];
        if sno > 1
            set(shand,'Position', S_Pos);
            set(playhand, 'Position', Play_Pos)
            set(ttxthand, 'Position', Ttxt_Pos)
            set(timehand, 'Position', Time_Pos)
            set(capturehand, 'Position', Capture_Pos)
        end
        set(stxthand,'Position', Stxt_Pos);
        set(ltxthand,'Position', Ltxt_Pos);
        set(wtxthand,'Position', Wtxt_Pos);
        set(lvalhand,'Position', Lval_Pos);
        set(wvalhand,'Position', Wval_Pos);
        set(Btnhand,'Position', Btn_Pos);
        set(ChBxhand,'Position', ChBx_Pos);
    end

% -=< Slice slider callback function >=-
    function SliceSlider(hObj, event, Img)
        S = round(get(hObj,'Value'));
        set(get(gca,'children'),'cdata',squeeze(Img(:,:,S,:)))
        caxis([Rmin Rmax])
        if sno > 1
            set(stxthand, 'String', sprintf('Slice# %d (V = %.4f) / %d', S, voltages(S), sno));
        else
            set(stxthand, 'String', '2D image');
        end
    end

% -=< Mouse scroll wheel callback function >=-
    function mouseScroll(object, eventdata)
        UPDN = eventdata.VerticalScrollCount;
        S = S - UPDN;
        if (S < 1)
            S = 1;
        elseif (S > sno)
            S = sno;
        end
        if sno > 1
            set(shand,'Value',S);
            set(stxthand, 'String', sprintf('Slice# %d (V = %.4f) / %d', S, voltages(S), sno));
        else
            set(stxthand, 'String', '2D image');
        end
        set(get(gca,'children'),'cdata',squeeze(Img(:,:,S,:)))
    end

% -=< Mouse button released callback function >=-
    function mouseRelease(object, eventdata)
        set(gcf, 'WindowButtonMotionFcn', '')
    end

% -=< Mouse click callback function >=-
    function mouseClick(object, eventdata)
        MouseStat = get(gcbf, 'SelectionType');
        if (MouseStat(1) == 'a')  % RIGHT CLICK
            InitialCoord = get(0,'PointerLocation');
            set(gcf, 'WindowButtonMotionFcn', @WinLevAdj);
        end
    end

% -=< Window and level mouse adjustment >=-
    function WinLevAdj(varargin)
        PosDiff = get(0,'PointerLocation') - InitialCoord;
        Win = Win + PosDiff(1) * WLAdjCoe * FineTuneC(get(ChBxhand,'Value')+1);
        LevV = LevV - PosDiff(2) * WLAdjCoe * FineTuneC(get(ChBxhand,'Value')+1);
        if (Win < 1)
            Win = 1;
        end
        [Rmin, Rmax] = WL2R(Win, LevV);
        caxis([Rmin Rmax])
        set(lvalhand, 'String', sprintf('%6.0f',LevV));
        set(wvalhand, 'String', sprintf('%6.0f',Win));
        InitialCoord = get(0,'PointerLocation');
    end

% -=< Window and level text adjustment >=-
    function WinLevChanged(varargin)
        LevV = str2double(get(lvalhand, 'string'));
        Win = str2double(get(wvalhand, 'string'));
        if (Win < 1)
            Win = 1;
        end
        [Rmin, Rmax] = WL2R(Win, LevV);
        caxis([Rmin Rmax])
    end

% -=< Window and level to range conversion >=-
    function [Rmn Rmx] = WL2R(W, L)
        Rmn = L - (W/2);
        Rmx = L + (W/2);
        if (Rmn >= Rmx)
            Rmx = Rmn + 1;
        end
    end

% -=< Window and level auto adjustment callback function >=-
    function AutoAdjust(object, eventdata)
        Win = double(max(Img(:))-min(Img(:)));
        Win(Win < 1) = 1;
        LevV = double(min(Img(:)) + (Win/2));
        [Rmin, Rmax] = WL2R(Win, LevV);
        caxis([Rmin Rmax])
        set(lvalhand, 'String', sprintf('%6.0f',LevV));
        set(wvalhand, 'String', sprintf('%6.0f',Win));
    end

% -=< Play button callback function >=-
    function Play(hObj, event)
        PlayFlag = ~PlayFlag;
        if PlayFlag
            set(playhand, 'cdata', Pause_BG)
        else
            set(playhand, 'cdata', Play_BG)
        end            
        while PlayFlag
            S = S + 1;
            if (S > sno)
                S = 1;
            end
            set(shand,'Value',S);
            set(stxthand, 'String', sprintf('Slice# %d (V = %.4f) / %d', S, voltages(S), sno));
            set(get(gca,'children'),'cdata',squeeze(Img(:,:,S,:)))
            pause(Tinterv/1000)
        end
    end

% -=< Time interval adjustment callback function >=-
    function TimeChanged(varargin)
        Tinterv = str2double(get(timehand, 'string'));
    end

% -=< Capture slice callback function >=-
    function CaptureSlice(~, ~)
        % Load or initialize data.grid
        if evalin('base', 'exist(''data'', ''var'')')
            data = evalin('base', 'data');
        else
            data.grid = struct();
        end
        
        % Initialize or append to arrays
        if ~isfield(data.grid, 'selectedSlice')
            data.grid.selectedSlice = [];
            data.grid.selectedVoltage = [];
            data.grid.selectedSliceData = [];
        end
        
        % Append current slice
        data.grid.selectedSlice = [data.grid.selectedSlice; S];
        data.grid.selectedVoltage = [data.grid.selectedVoltage; voltages(S)];
        data.grid.selectedSliceData = cat(3, data.grid.selectedSliceData, squeeze(Img(:,:,S,:)));
        
        % Save to base workspace
        assignin('base', 'data', data);
        
        % Confirmation message
        fprintf('Captured Slice# %d (V = %.4f)\n', S, voltages(S));
        
        % Log capture
        if ~isempty(LOGpath) && ~isempty(LOGfile) && ischar(LOGpath) && ischar(LOGfile)
            LOGcomment = sprintf('Captured Slice# %d (V = %.4f)', S, voltages(S));
            logUsedBlocks(LOGpath, LOGfile, '  ^  ', LOGcomment, 0);
        else
            warning('Logging skipped: LOGpath or LOGfile invalid or undefined.');
        end
    end
end