program PaneOfGlass;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, PaneGlass, painGlassop
  { you can add units after this };

{$R *.res}

begin
  {if not CheckPrevious.RestoreIfRunning(Application.Handle) then
  begin
    RequireDerivedFormResource := True;}
    Application.Initialize;
    Application.CreateForm(TpainGlassOPform, painGlassOPform);
    Application.CreateForm(Tpanefrm, panefrm);

    Application.Run;
//  end;
end.

