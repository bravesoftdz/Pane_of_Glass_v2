unit PaneGlass;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Windows, Graphics, Dialogs, Menus,
  ExtCtrls, StdCtrls,  LCLIntf, LCLType, ComCtrls, Clipbrd, LResources, Crt;
// painGlassop;

type

  { Tpanefrm }

  Tpanefrm = class(TForm)
    exit1: TMenuItem;
    DisablePrank: TMenuItem;
    GhostMode: TMenuItem;
    prankImage: TImage;
    prankMode: TMenuItem;
    Ontop1: TMenuItem;
    Resize1: TMenuItem;
    Settings1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    ClickThrough1: TMenuItem;
    click1: TMenuItem;
    a1: TMenuItem;
    b1: TMenuItem;
    c1: TMenuItem;
    d1: TMenuItem;
    DClickMode: TMenuItem;
    e1: TMenuItem;
    f_b: TMenuItem;
    FSmode: TMenuItem;
    f1: TMenuItem;
    pane_PopupMenu: TPopupMenu;
    pane_TrayIcon: TTrayIcon;
    //procedure Button1Click(Sender: TObject);
    procedure DisablePrankClick(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
    procedure exit1Click(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GhostModeClick(Sender: TObject);
    procedure Ontop1Click(Sender: TObject);
    procedure prankImageResize(Sender: TObject);
    procedure prankModeClick(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ClickThrough1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure WMMove(var Message: TMessage) ; message WM_MOVE;
    procedure resizepanefrm();
    procedure panefrmsize();
    procedure ResizePaneForScreen(mode : integer);
    procedure a1Click(Sender: TObject);
    procedure b1Click(Sender: TObject);
    procedure c1Click(Sender: TObject);
    procedure d1Click(Sender: TObject);
    procedure ClickThroughMode_ED(Sender: TObject);
    procedure VHPopupMenuItems(value: boolean);
    procedure DClickModeClick(Sender: TObject);
    procedure e1Click(Sender: TObject);
    procedure SetBottom();
    procedure SetTop();
    procedure f_bClick(Sender: TObject);
    procedure HideAltTab(mode: integer);
    procedure FSmodeClick(Sender: TObject);
    procedure f1Click(Sender: TObject);
  private
    { private declarations }
    _positionT     : integer;
    _positionL     : integer;
    _positionW     : integer;
    _positionH     : integer;
    _clickWindowT  : integer;
    _ClickWindowL  : integer;
    _Rpane         : boolean;
    _OntopNow      : boolean;
    _ResizedDone   : boolean;
    _MultiMonitor  : boolean;
    _windowStyle   : integer;
    public
    { public declarations }
    _ClickThrough  : boolean;
    _onTop_CT      : boolean;
    _OriginalWindowState: TWindowState;
    _OriginalBounds: TRect;
    _old_transpancy_value : integer;
    //_old
    procedure SwitchReSizeable;
    procedure Start_PrankMode(Prank_type : integer);
    procedure Setup_PrankMode(Setup_Prank : Boolean; Prank_Mode : integer);

  end;
const
  f_txt = 'Bring Pane to Front';
  b_txt = 'Send Pane to Back';
var
  panefrm: Tpanefrm;

implementation

uses painGlassOP;

{$R *.lfm}

{ Tpanefrm }

function GetTaskBarSize: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, @Result, 0);
end;

procedure Tpanefrm.HideAltTab(mode: integer);
begin

if mode = 1 then
 begin
  _windowStyle := GetWindowLong(Self.Handle, GWL_EXSTYLE);
  SetWindowLong(Self.Handle, GWL_EXSTYLE, _windowStyle or WS_EX_TOOLWINDOW);
 end;
 if mode = 2 then
  SetWindowLong(Self.Handle, GWL_EXSTYLE, _windowStyle);

end;

function get_readyForScreenshot : Integer;
var
    i : integer;
begin
    Application.Minimize;
    Application.ProcessMessages;
    //need to hide from taskbar
    Application.MainFormOnTaskbar := False;
    panefrm.HideAltTab(1);
    i := 0;
    Delay(1000);
    while( i < 10 ) do
    begin
        //Sleep(1000);
        Delay(10);
        i := i + 1 ;
    end;
    
    get_readyForScreenshot := 1;
end;

procedure Tpanefrm.SetBottom();
begin
     SetWindowPos(Self.Handle,HWND_BOTTOM,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
     _onTop_CT := false;
     f_b.Caption := f_txt;
end;

procedure Tpanefrm.SetTop();
begin
SetWindowPos(Self.Handle,HWND_TOPMOST,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
_onTop_CT := true;
f_b.Caption := b_txt;
end;

procedure Tpanefrm.FormCreate(Sender: TObject);
begin
panefrm.show();
_MultiMonitor := false;
f1.Visible := false;
SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_LAYERED);
//SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_TRANSPARENT or WS_EX_LAYERED);
//SetLayeredWindowAttributes(Self.Handle, 0, 255, LWA_ALPHA);
_ClickThrough := false;
_onTop_CT := false;
_ResizedDone := false;
settings1.ShortCut := ShortCut(Word('S'), [ssAlt, ssShift]);
if screen.MonitorCount > 1 then
  begin
    _MultiMonitor := true;
    f1.Visible := true;
    f1.ShortCut := ShortCut(Word('A'), [ssCtrl]);
  end;
  _old_transpancy_value := 64;
end;


procedure paneresizeable();
begin
//panefrm.BorderStyle := bsNone;
if panefrm.BorderStyle <> bsNone then panefrm.SwitchReSizeable;
panefrm.resize1.Checked := false;
painGlassOPform.resize_cb.Checked := false;
end;


procedure Tpanefrm.FormDblClick(Sender: TObject);
begin
if not _ClickThrough then
begin
 if panefrm.BorderStyle = bssizeable then
     paneresizeable()
 else
  begin
   panefrm.BorderStyle := bssizeable;
   resize1.Checked := true;
   painGlassOPform.resize_cb.Checked := true;
  end;
 end;
end;

procedure Tpanefrm.DisablePrankClick(Sender: TObject);
begin
  prankImage.Visible := False;
  Application.MainFormOnTaskbar := True;

  Setup_PrankMode(False, 0);
  DClickModeClick(Sender);
end;

procedure Tpanefrm.exit1Click(Sender: TObject);
begin
if _ClickThrough then
   DClickModeClick(panefrm.DClickMode);
painGlassOPform.Button1Click(Sender);
end;

procedure Tpanefrm.resizepanefrm();
begin
   panefrm.Constraints.MinHeight:= 100;
   panefrm.Constraints.MinWidth := 100;
   panefrm.Top := panefrm._positionT;
   panefrm.Left := panefrm._positionL;
   panefrm.Width := panefrm._positionW;
   panefrm.Height := panefrm._positionH;
end;

procedure Tpanefrm.panefrmsize();
begin
   _positionT := panefrm.Top;
   _positionL := panefrm.Left;
   _positionW := panefrm.Width;
   _positionH := panefrm.Height;
end;

procedure moveform();
const
SL_DRAGMOVE=$F012;
begin
ReleaseCapture;
panefrm.Perform(WM_SYSCOMMAND, SL_DRAGMOVE,0);
end;

procedure Tpanefrm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if not _ClickThrough then
 begin
   if BUTTON = mbleft then
      moveform();
 end;
end;

procedure Tpanefrm.Ontop1Click(Sender: TObject);
begin
 if ontop1.Checked then
  begin
    ontop1.Checked := false;
    panefrm.FormStyle := fsNormal;
  end
 else
  begin
    ontop1.Checked := true;
    panefrm.FormStyle := fsStayOnTop;
    panefrm.BringToFront;
  end;
end;

procedure Tpanefrm.prankImageResize(Sender: TObject);
var
  M : TMonitor;
begin
  M := Screen.MonitorFromWindow(Handle);
  //Label1.caption :=IntToStr (panefrm.Top);
  //Label2.caption :=IntToStr (panefrm.Bottom);
  //Label3.caption :=IntToStr (panefrm.Right);
  //Label4.caption :=IntToStr (panefrm.Left);
end;

procedure Tpanefrm.Setup_PrankMode(Setup_Prank : Boolean; Prank_Mode : integer);
begin
 if Setup_Prank = True then
    begin
        _old_transpancy_value := panefrm.AlphaBlendValue;
    panefrm.AlphaBlendValue := Prank_Mode;
        pane_TrayIcon.Visible := False;
    end
 else
    begin
        panefrm.AlphaBlendValue := _old_transpancy_value;
        pane_TrayIcon.Visible := True;
        prankImage.Visible := False;
                prankImage.Picture.Clear;
    end;

end;

procedure Tpanefrm.Start_PrankMode(Prank_type : integer);
var
  MyBitmap: TBitmap;
  ScreenDC: HDC;
  WrkJpg: TJpegImage;
  mon_count : integer;
  Higest_mon : integer;
  offset_draw_y : integer;
  PictureAvailable : boolean;

  i: Integer;
  aMonitor, LeftMostMonitor: TMonitor;

begin

  _old_transpancy_value := panefrm.AlphaBlendValue;
  MyBitmap := TBitmap.Create;
  PictureAvailable := false;
  

{  if Screen.MonitorCount > 1 then
  begin}
       get_readyForScreenshot();
       Keybd_event(VK_SNAPSHOT, 0, 0, 0);
       Keybd_event(VK_SNAPSHOT, 0, KEYEVENTF_KEYUP, 0);
       Sleep(32);

       if Clipboard.HasFormat(PredefinedClipboardFormat(pcfDelphiBitmap)) then
       begin
          PictureAvailable:=true;
       end;
       if Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap)) then
       begin
          PictureAvailable:=true;
       end;

       if PictureAvailable then
       begin
            //ShowMessage('It is an image');
            //MyBitmap := TBitmap.Create;
            if Clipboard.HasFormat(PredefinedClipboardFormat(pcfDelphiBitmap)) then
               MyBitmap.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfDelphiBitmap));

            if Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap)) then
               MyBitmap.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));
       end;
{  end
  else
  begin
        Application.Minimize;
        Application.ProcessMessages;
        Application.MainFormOnTaskbar := False;
        sleep(32);
        ScreenDC := GetDC(0);
        MyBitmap.LoadFromDevice(ScreenDC);
  end;  }

      //{$DEFINE debugprank}
      //create jpg for debug
      {$ifdef debugprank}
      WrkJpg := TJpegImage.Create;
      try
        WrkJpg.CompressionQuality := 80;
        WrkJpg.Assign(MyBitmap);
        WrkJpg.SaveToFile('screen.jpg');
      finally
        FreeAndNil(WrkJpg);
      end;
      {$endif}

{      Application.Restore;
      Application.BringToFront;
}
      ResizePaneForScreen(7);
      prankImage.Align := alClient;
      prankImage.Visible := True;
      //need to set to full screen mode and enable click through with 255 transparancy.
      if Screen.MonitorCount > 1 then
      begin  //multi mointor set up}
        Higest_mon := 0;
        for mon_count := 1 to Screen.MonitorCount -1 do
          begin
              if Screen.Monitors[mon_count].Height > Screen.Monitors[Higest_mon].Height then
                 Higest_mon := mon_count;
          end;
        LeftMostMonitor := Screen.Monitors[0];
        for i := 1 to Screen.MonitorCount-1 do
        begin
            aMonitor := Screen.Monitors[i];
            if aMonitor.Left < LeftMostMonitor.Left then
               LeftMostMonitor := aMonitor;
        end;
        if Higest_mon <>  1 then
        begin
           offset_draw_y := Screen.Monitors[Higest_mon].Height - LeftMostMonitor.Height;
           prankImage.Canvas.Draw(0,offset_draw_y,MyBitmap);
        end
        else
            prankImage.Canvas.Draw(0,0,MyBitmap);
      end
      else
          prankImage.Canvas.Draw(0,0,MyBitmap);
 if Screen.MonitorCount = 1 then
      ReleaseDC(0, ScreenDC);

 Setup_PrankMode(True, Prank_type);

  MyBitmap.Destroy;
  Application.Restore;
  Application.BringToFront;
end;

procedure Tpanefrm.prankModeClick(Sender: TObject);
begin
    Start_PrankMode(250);
end;

procedure Tpanefrm.GhostModeClick(Sender: TObject);
begin
  Start_PrankMode(160);
end;

procedure Tpanefrm.Settings1Click(Sender: TObject);
begin
painGlassOPform.Show;
end;


procedure Tpanefrm.FormShow(Sender: TObject);
begin
painGlassOPform.BringToFront
end;

procedure ClickThroughMode(Sender: TObject);
begin
panefrm._Rpane := false;
panefrm._OntopNow := false;
 if panefrm.BorderStyle = bssizeable then
   begin
     //panefrm.BorderStyle := bsNone;
     //paneresizeable();
     panefrm._Rpane := true;
   end;

if panefrm.Ontop1.checked then
  begin
    panefrm._OntopNow := true;
    panefrm.Ontop1Click(panefrm.Ontop1);
  end;
end;

procedure Tpanefrm.VHPopupMenuItems(value: boolean);
begin
ontop1.Visible := value;
resize1.Visible := value;
ClickThrough1.Visible := value;
DClickMode.Visible := not value;
f_b.Visible := not value;
click1.Visible := value;
e1.Visible := value;
painGlassOPform.resize_cb.Enabled := value;
painGlassOPform.SpeedClick.Enabled := value;
FSmode.Visible := value;
if _MultiMonitor then
  f1.Visible := value;

if value then
  exit1.ShortCut := ShortCut(Word('X'), [ssAlt])
else
    exit1.ShortCut := 0;
end;

procedure Tpanefrm.ClickThroughMode_ED(Sender: TObject);
var
  h :THandle;
begin
h := FindWindow('Window', PChar(Application.Title));
if _ClickThrough then
    begin //enable clicktrhough mode

       ClickThroughMode(sender); //sets pane to none resizeable and on ontop
       // sets click throughable
       SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_TRANSPARENT or WS_EX_LAYERED);
       //ShowWindow(Self.Handle, SW_HIDE);
       ShowWindow(h, SW_HIDE);
       //hides popup menu functions menu function
       VHPopupMenuItems(false);
       if painGlassOPform.Visible then
         painGlassOPform.Hide;
       //sets window as top screen mode
       SetWindowPos(Self.Handle,HWND_TOPMOST,0,0,0,0, SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE );
       painGlassOPform.SetTop();
       _onTop_CT := true;
       panefrm.FormStyle:=fsSystemStayOnTop;
       HideAltTab(1);
    end
else
    begin //disable click through
     //disable top most window.
     HideAltTab(2);
     SetWindowPos(Self.Handle,HWND_BOTTOM,0,0,0,0,SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
     painGlassOPform.OffTop();
     //stops click throught mode
     SetWindowLong(Self.Handle, GWL_EXSTYLE, WS_EX_LAYERED);
     //ShowWindow(Application.Handle, SW_SHOW);
     ShowWindow(h, SW_SHOW) ;
     panefrm.WindowState := wsNormal;
     VHPopupMenuItems(true);
     resizepanefrm();
     _onTop_CT := false;
     panefrm.FormStyle:=fsNormal;;
    end;
end;

procedure Tpanefrm.ClickThrough1Click(Sender: TObject);
begin
ResizePaneForScreen(ClickThrough1.Tag);
end;


{*procedure Tpanefrm.WMGetMinMaxInfo(var Msg: TWMGetMinMaxInfo);
begin
     msg.MinMaxInfo.ptMaxSize.X := Screen.WorkAreaWidth;
     msg.MinMaxInfo.ptMaxSize.Y := Screen.WorkAreaHeight;
   // msg.MinMaxInfo.ptMaxSize.X :=     * 1440 div Screen.PixelsPerInch;
   inherited
end;*}


procedure Tpanefrm.WMMove(var Message: TMessage) ;
begin
if _ClickThrough and _ResizedDone then
   begin
     panefrm.Top  := _ClickWindowT;
     panefrm.Left := _ClickWindowL;
 end;
end; (*WMMove*)

{procedure MoveFormToTopOfRightmostMonitor(Form: TForm);
var
  i: Integer;
  Monitor, RightMostMonitor: TMonitor;
begin
  RightMostMonitor := Screen.Monitors[0];
  for i := 1 to Screen.MonitorCount-1 do
  begin
    Monitor := Screen.Monitors[i];
    if Monitor.Left+Monitor.Width > RightMostMonitor.Left+RightMostMonitor.Width then
      Monitor := RightMostMonitor;
  end;
  Form.Left := Monitor.Left+Monitor.Width-Form.Left;
  Form.Top := Monitor.Top;
end;
var MaxFormHeight: Integer;
    NewFormHeight: Integer;
    M: TMonitor;
begin
  // Get the monitor that's hosting the form
  M := M := Screen.MonitorFromWindow(Handle);
  MaxFormHeight := M.WorkAreaRect.Bottom - M.WorkAreaRect.Top - Top; // Take into account actual available monitor space and the Top of the window
  // Do your stuff to calculate NewFormHeight
  if NewFormHeight > MaxFormHeight then
    NewFormHeight := MaxFormHeight;
  Height := NewFormHeight;
end;}


procedure Tpanefrm.ResizePaneForScreen(mode : integer);
var Mver,Mhor : integer;
    Mwidth, Mheight, Mtop, Mleft : integer;
    i : integer;
    //MontInfo,
    MonitorInfo : TMonitor;
begin
//0 horizonal left
//1 horizonal right
//2 vertical top
//3 vertical bottom
//4 full work area
//5 click through mode
//6 Full screen
//7 Full screens, all displays.

//even number base at (0,0)

MonitorInfo := Screen.MonitorFromWindow(Handle);

{Mheight :=  Screen.Height;
Mheight := Screen.WorkAreaHeight;
Mwidth := Screen.WorkAreaWidth;
Mtop := Screen.WorkAreaTop;
Mleft := Screen.WorkAreaLeft;

if Screen.MonitorCount > 1 then
  begin  //multi mointor set up}
    Mwidth := MonitorInfo.WorkareaRect.Right - MonitorInfo.WorkareaRect.Left;
    Mheight:= MonitorInfo.WorkareaRect.Bottom - MonitorInfo.WorkareaRect.Top;
    //Mtop := MonitorInfo.WorkareaRect.Top;
    Mtop := MonitorInfo.Top;
    //Label3.Caption := inttostr(MonitorInfo.Top);
    //Label2.Caption := inttostr(MonitorInfo.LEFt);
    Mleft := MonitorInfo.WorkareaRect.Left;
    //Mleft :=  MonitorInfo.Left+MonitorInfo.Width-panefrm.Left;
//  end;
Mhor := Mwidth div 2;
Mver := Mheight div 2;

//saves current size
panefrmsize();
//ClickWindowT := Screen.WorkAreaTop;
_ClickWindowT := Mtop;
_ClickWindowL := Mleft;
_ClickThrough := true;

//this need to be done before moving form overwise form end in middle of screen.
//11/21/2015 09:49:19 JHWF
paneresizeable();
case mode of
0: begin
     panefrm.Width := Mhor;
     panefrm.Height := Mheight;
     panefrm.Top := Mtop;
     panefrm.Left := Mleft;
   end;
1: begin
     panefrm.Width := Mhor;
     panefrm.Height := Mheight;
     panefrm.Top := Mtop;
     panefrm.Left := Mhor + Mleft;
     _ClickWindowL := panefrm.Left;
   end;
2: begin
     panefrm.Width := Mwidth;
     panefrm.Height := Mver;
     panefrm.Top := MTop;
     panefrm.Left := MLeft;
   end;
3: begin
    panefrm.Width :=Mwidth;
    panefrm.Height := Mver;
    panefrm.Top := Mver + Mtop;
    panefrm.Left := Mleft;
    _ClickWindowT := panefrm.Top;
   end;
4: begin
      panefrm.Width := Mwidth;
      panefrm.Height := MHeight;
      panefrm.Top := MTop;
      panefrm.Left := Mleft;
   end;
5: begin
    _ClickWindowT := panefrm.Top;
    _ClickWindowL := panefrm.Left;
   end;
6: begin
     panefrm.Width := MonitorInfo.Width;
     panefrm.Height := MonitorInfo.Height;
     panefrm.Top := MonitorInfo.Top;
     panefrm.Left := MonitorInfo.left;
   end;
7: begin
     panefrm.Width := Screen.DesktopWidth;
     panefrm.Height := Screen.DesktopHeight;
     panefrm.Top := Screen.DesktopTop;
     panefrm.Left := Screen.DesktopLeft;
   end;
else null;
end;//case
ClickThroughMode_ED(panefrm);
panefrm.Constraints.MinHeight := panefrm.Height;
panefrm.Constraints.MinWidth := panefrm.Width;
_ResizedDone := true;
end;

procedure Tpanefrm.a1Click(Sender: TObject);
begin
ResizePaneForScreen(a1.Tag);
end;

procedure Tpanefrm.b1Click(Sender: TObject);
begin
ResizePaneForScreen(b1.Tag);
end;

procedure Tpanefrm.c1Click(Sender: TObject);
begin
ResizePaneForScreen(c1.Tag);
end;

procedure Tpanefrm.d1Click(Sender: TObject);
begin
ResizePaneForScreen(d1.Tag);
end;

procedure Tpanefrm.DClickModeClick(Sender: TObject);
begin
_ClickThrough := false;
_ResizedDone := false;
ClickThroughMode_ED(Sender);
if _Rpane then
   FormDblClick(panefrm.Resize1);
if _OntopNow then
   Ontop1Click(panefrm.Ontop1);
end;

procedure Tpanefrm.e1Click(Sender: TObject);
begin
ResizePaneForScreen(e1.Tag);
end;

procedure Tpanefrm.f_bClick(Sender: TObject);
begin
if _onTop_CT then
  SetBottom()
else
 SetTop();
end;



procedure Tpanefrm.FSmodeClick(Sender: TObject);
begin
ResizePaneForScreen(FSmode.Tag);
end;

procedure Tpanefrm.f1Click(Sender: TObject);
begin
ResizePaneForScreen(f1.Tag);
end;

procedure Tpanefrm.SwitchReSizeable;
begin
  if BorderStyle <> bsNone then
  begin
    // To full screen
    _OriginalWindowState := WindowState;
    _OriginalBounds := BoundsRect;

    BorderStyle := bsNone;
    //BoundsRect := Screen.MonitorFromWindow(Handle).BoundsRect;
  end
  else
  begin
    // From full screen
    {$IFDEF MSWINDOWS}
    BorderStyle := bsSizeable;
    {$ENDIF}
    if _OriginalWindowState = wsMaximized then
      WindowState := wsMaximized
    else
      BoundsRect := _OriginalBounds;
  end;
end;
end.

