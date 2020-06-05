program AsynchronousGrab;



uses
  Vcl.Forms,
  Main in 'Main.pas' {Form2},
  VimbaC in '..\..\Include\VimbaC.pas',
  VmbCommonTypes in '..\..\Include\VmbCommonTypes.Pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar:= True;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
