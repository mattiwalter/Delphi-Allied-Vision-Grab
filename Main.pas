unit Main;

(*=============================================================================
  Copyright (C) 2014 Allied Vision Technologies.  All Rights Reserved.

  Redistribution of this file, in original or modified form, without
  prior written consent of Allied Vision Technologies is prohibited.

-------------------------------------------------------------------------------

  File:        AsynchronousGrab.c

  Description: The AsynchronousGrab example will grab images asynchronously
               using VimbaC.

-------------------------------------------------------------------------------

  THIS SOFTWARE IS PROVIDED BY THE AUTHOR "AS IS" AND ANY EXPRESS OR IMPLIED
  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF TITLE,
  NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR A PARTICULAR  PURPOSE ARE
  DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED
  AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
  TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
=============================================================================
  This Program was ported in 2020 to Delphi by Matthias Walter.
  I have tested it with Rad Studio 10.2. and FreePascal(Lazarus 2.0.6)
  matthias.walter@listrik.de      https://listrik.de
  Use it at your own risk!!
=============================================================================*)

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  {$ifdef fpc}
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
    Forms, Dialogs, StdCtrls, StrUtils, SyncObjs, ExtCtrls, Math,
  {$else}
    Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
    System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
    Vcl.StdCtrls, System.StrUtils, System.SyncObjs, Vcl.ExtCtrls,
    Vcl.Imaging.jpeg, System.Math,
  {$endif}

  VimbaC, VmbCommonTypes;

const
  NUM_FRAMES  = 2;
  MyMsg       = WM_USER + 1;

type
  FrameInfos = (FrameInfos_Off, FrameInfos_Show, FrameInfos_Automatic);

  TForm2 = class(TForm)
    Memo1: TMemo;
    GroupBox1: TGroupBox;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    LabeledEdit3: TLabeledEdit;
    LabeledEdit4: TLabeledEdit;
    LabeledEdit5: TLabeledEdit;
    LabeledEdit6: TLabeledEdit;
    LabeledEdit7: TLabeledEdit;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    ScrollBar1: TScrollBar;
    Edit1: TEdit;
    Label2: TLabel;
    ScrollBar2: TScrollBar;
    Edit2: TEdit;
    Label7: TLabel;
    ScrollBar5: TScrollBar;
    Edit3: TEdit;
    Button1: TButton;
    Image1: TImage;
    GroupBox3: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    Timer1: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ScrollBar1Change(Sender: TObject);
    procedure ScrollBar2Change(Sender: TObject);
    procedure ScrollBar5Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure OnThreadMsg(var M: TMessage); message MyMsg;
    procedure Edit1to3KeyPress(Sender: TObject; var Key: Char);
    procedure Edit1to3Exit(Sender: TObject);

  private
    Procedure DisplayStatus;
    Procedure ClearCanvas(clr: Tcolor);
    Procedure PaintCross(TextColor : TColor;
                         CrossColor: TColor;
                         S         : String);
    Procedure AddMessage(Msg: String);
    Function SetupCamera: Boolean;
    Procedure StartContinuousImageAcquisition;
    Procedure StopContinuousImageAcquisition(completeShutdown: Boolean);
    Procedure DrawBitmap;
  public
    //
  end;

var
  Form2: TForm2;

  g_bStreaming,                                                                 //Remember if Vimba is streaming
  FirstRun,
  g_bAcquiring            : Boolean;                                            //Remember if Vimba is acquiring
  g_CameraHandle          : vmbHandle_t;                                        //A handle to our camera
  g_Frames                : Array[0..(NUM_FRAMES - 1)] of VmbFrame_t;           //The frames we capture into
  FrameInfo               : VmbFrame_t;
  g_bFrameIDValid,                                                              //Remember if there was a last ID
  g_bFrameTimeValid,                                                            //Remember if there was a last timestamp
  g_bRGBValue,                                                                  //Show RGB values
  g_bEnableColorProcessing: Boolean;                                            //Enables color processing for frames
  g_eFrameInfos           : FrameInfos;                                         //Remember if we should print out frame infos
  g_dFrameTime            : TDateTime;                                          //Timestamp of last frame
  gg_dFrameTime           : Integer;
  g_nFrameID              : VmbUint64_t;                                        //ID of last frame
  FrameBitmap             : TBitmap;
  pCameraID               : pANSIchar;
  dFPS                    : Single;                                             //frames per second calculated
  pPixelFormat            : PANSIchar;                                          //The pixel format we use for acquisition
  ToutCtr                 : Integer;
  GigEBuffEmpty,
  CrossIsDrawn            : Boolean;

Function DiscoverGigECameras(var RetStr: String; var IsGigE: Boolean): VmbError_t;
Function PrintVimbaVersion: String;

implementation

{$R *.dfm}

procedure Make8BitPal(pal: PLogPalette);
var
  i, j: Integer;
  k   : Array[0..3] of Byte absolute j;
begin
  pal^.palVersion:= $300;
  pal^.palNumEntries:= 256;
 {$R-}
  for i:= 0 to 255 do
  begin
    j:= i; k[1]:= i; k[2]:= i;
    pal^.palPalEntry[i]:= TPaletteEntry(j);
  end;
 {$R+}
end;

Procedure PostMainMessage(Msg: String);
var
 MsgStrPtr: PString;
begin
 New(MsgStrPtr);
 MsgStrPtr^:= 'WA_' + Msg;
 PostMessage(Form2.Handle, MyMsg, Integer(MsgStrPtr), 0);
end;

procedure TForm2.Button1Click(Sender: TObject);
var
 Res  : VmbError_t;
 Df   : Double;
 I64  : VmbInt64_t;

begin
  //---------- Write Info to camera ----------
  try
    Df:= ScrollBar1.Position; //uS
    Res:= VmbFeatureFloatSet(g_CameraHandle, 'ExposureTimeAbs', Df);
    If Res = Ord(VmbErrorSuccess)
    then
      AddMessage('(Apply Settings) "ExposureTimeAbs" succeeded')
    else
      AddMessage(Format('Set "ExposureTimeAbs" failed with Error: %d ==> %s',
                             [Res, VmbErrorStr[(Res)]]));

    StopContinuousImageAcquisition(false);

    I64:= ScrollBar2.Position;
    Res:= VmbFeatureIntSet(g_CameraHandle, 'GainRaw', I64);
    If Res = Ord(VmbErrorSuccess)
    then
      AddMessage('(Apply Settings) "GainRaw" succeeded')
    else
      AddMessage(Format('Set "GainRaw" failed with Error: %d ==> %s',
                             [Res, VmbErrorStr[(Res)]]));

    Df:= ScrollBar5.Position;
    Res:= VmbFeatureFloatSet(g_CameraHandle, 'AcquisitionFrameRateAbs', Df);
    If Res = Ord(VmbErrorSuccess)
    then
      AddMessage('(Apply Settings) "AcquisitionFrameRateAbs" succeeded')
    else
      AddMessage(Format('Set "AcquisitionFrameRateAbs" failed with Error: %d ==> %s',
                             [Res, VmbErrorStr[(Res)]]));
  finally
    StartContinuousImageAcquisition;
  end;
end;

Procedure TForm2.DisplayStatus;
var
 SS: String;
begin
  LabelEdEdit1.Text:= IntToStr(FrameInfo.frameID);

  SS:= '';
  Case FrameInfo.ReceiveStatus of
    Ord(VmbFrameStatusComplete): SS:= SS + 'Complete';
    Ord(VmbFrameStatusIncomplete): SS:= SS + 'Incomplete';
    Ord(VmbFrameStatusTooSmall): SS:= SS + 'Too small';
    Ord(VmbFrameStatusInvalid): SS:= SS + 'Invalid'
  else
    SS:= SS + '?';
  end;
  LabelEdEdit2.Text:= SS;
  Labelededit5.Text:= Format('%0.1f', [dFPS]);

  if FrameInfo.pixelFormat = $1080001
    then LabelEdEdit4.Text:= 'Mono8'
    else LabelEdEdit4.Text:= Format('Format:$%08X', [FrameInfo.pixelFormat]);

  LabelEdEdit3.Text:= Format(' %u', [FrameInfo.bufferSize]);
  LabelEdEdit6.Text:= Format(' %ux%u', [FrameInfo.width, FrameInfo.height]);
end;

procedure TForm2.Edit1to3Exit(Sender: TObject);
begin
  If Sender = Edit1
    then ScrollBar1.Position:= StrToInt(Edit1.Text)
    else If Sender = Edit2
      then ScrollBar2.Position:= StrToInt(Edit2.Text)
      else If Sender = Edit3
        then ScrollBar5.Position:= StrToInt(Edit3.Text)
end;

procedure TForm2.Edit1to3KeyPress(Sender: TObject; var Key: Char);
begin
  Case ord(Key) of
    Ord('0')..Ord('9'):
     begin
       //OK
     end;

    VK_Back, VK_Return:
     begin
       If Sender = Edit1
       then ScrollBar1.Position:= StrToInt(Edit1.Text)
       else If Sender = Edit2
         then ScrollBar2.Position:= StrToInt(Edit2.Text)
         else If Sender = Edit3
           then ScrollBar5.Position:= StrToInt(Edit3.Text)
     end
    else
      Key:= Chr(0);
   end;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Timer1.Enabled:= false;
  g_bAcquiring:= false;

  StopContinuousImageAcquisition(true);
  VmbShutdown;

  Application.Terminate;
end;

Procedure TForm2.StopContinuousImageAcquisition(CompleteShutdown: Boolean);
var
  i  : Integer;
  Res: VmbError_t;
begin
  if g_CameraHandle <> nil then
  begin
    if g_bAcquiring then
    begin
      Res:= VmbFeatureCommandRun(g_CameraHandle, 'AcquisitionStop');
      If Res = Ord(VmbErrorSuccess)
      then
        AddMessage('"StopContinuousImageAcquisition" succeeded')
      else
        AddMessage(Format('"StopContinuousImageAcquisition" failed with Error: %d ==> %s',
                          [Res, VmbErrorStr[(Res)]]));

      g_bAcquiring:= False;
    end;

    if not CompleteShutdown then Exit;

    if g_bStreaming then
    begin
      VmbCaptureEnd(g_CameraHandle);                                            //Stop Capture Engine
      g_bStreaming:= False;
    end;

    VmbCaptureQueueFlush(g_CameraHandle);                                       //Flush the capture queue

    for i:= 0 to NUM_FRAMES - 1 do
    begin
      if g_Frames[i].buffer <> nil then
      begin
        VmbFrameRevoke(g_CameraHandle, g_Frames[i]);
        freemem(g_Frames[i].buffer);
      end;
    end;
    VmbCameraClose(g_CameraHandle);
    g_CameraHandle:= Nil;
  end;
  pCameraID:= nil;
  VmbShutdown;
end;

Procedure TForm2.StartContinuousImageAcquisition;
var
  Res: VmbError_t;
begin
  Res:= VmbFeatureCommandRun(g_CameraHandle, 'AcquisitionStart');
  If Res = Ord(VmbErrorSuccess)
  then
    AddMessage('(Apply Settings) "AcquisitionStart" succeeded')
  else
    AddMessage(Format('"AcquisitionStart" failed with Error: %d ==> %s',
                           [Res, VmbErrorStr[(Res)]]));
end;

// Method: FrameCallback
//
// Purpose: called from Vimba if a frame is ready for user processing
//
// Parameters:
//
// [in] handle to camera that supplied the frame
// [in] pointer to frame structure that can hold valid data
Procedure FrameCallback(cameraHandle: VmbHandle_t;
                        pFrame      : VmbFrame_t);
var
  //from here on the frame is under user control until returned to Vimba by re queuing it
  //if you want to have smooth streaming keep the time you hold the frame short
  bShowFrameInfos : Boolean;
  ddTimeDiff,
  ddframetime     : Integer;
  nFramesMissing  : VmbUint64_t;                                                // number of missing frames
  HH, lw, H       : Integer;
  P               : Pointer;

begin
  dFPS:= 0.0;
  nFramesMissing:= 0;
  ToutCtr:= 0;
  g_bAcquiring:= true;

  if(g_eFrameInfos <> FrameInfos.FrameInfos_Off) then
  begin
    bShowFrameInfos:= (FrameInfos_Show = g_eFrameInfos);
    if ((pFrame.receiveFlags and ord(VmbFrameFlagsFrameID)) > 0) then
    begin
      g_nFrameID:= pFrame.frameID;                                              //store current frame id to calculate missing frames in the next calls
      g_bFrameIDValid:= True;
      ddframetime:= Gettickcount;

      if((g_bFrameTimeValid) and                                                //only if the last time was valid
         (nFramesMissing = 0) and                                               //and the frame is not missing
         (GigEBuffEmpty)) then                                                  //and display buffer ready
      begin
        lw:= FrameBitmap.Width * 1;                                                       //1Byte pro Bit ==> Mono8
        HH:= 0;
        H:= FrameBitmap.Height;
        While HH < H do                                                             //copy grabbed picture to Buffers[]
        begin
          P:= FrameBitmap.ScanLine[HH];
          CopyMemory(P, Pointer(NativeInt(pFrame.buffer) + (HH * lw)), lw);
          Inc(HH);
        end;
      end;
      GigEBuffEmpty:= false;
      gg_dFrameTime:= ddframetime;
      g_bFrameTimeValid:= True;

      ddTimeDiff:= ddFrameTime - gg_dFrameTime;
      if ddTimeDiff > 0
        then dFPS:= 1000 / ddTimeDiff
        else bShowFrameInfos:= True;
    end
    else
    begin
      bShowFrameInfos:= True;
      g_bFrameIDValid:= False;
      g_bFrameTimeValid:= False;
    end;

    if((pFrame.receiveStatus and Ord(VmbFrameStatusComplete)) > 0)              //test if the frame is complete
      then bShowFrameInfos:= True;

    if bShowFrameInfos then FrameInfo:= pFrame;                                 //update frame info
  end;

  VmbCaptureFrameQueue(g_CameraHandle,                                          //requeue the frame so it can be filled again
                       g_Frames[0],
                       @FrameCallback);
end;

procedure TForm2.FormCreate(Sender: TObject);
var
  Tout: Boolean;
  Tm  : Cardinal;
begin
  Memo1.Clear;
  Self.Show;
  Self.Caption:= 'AsynchronousGrab by M. Walter (2020)';
  SetupCamera;       //Speeds up the first connect. Not necessarily required
  Timer1.Enabled:= True;
  while Timer1.Enabled do
  begin
    Tm:= GetTickCount;
    Repeat                                                                      //wait until next field has been grabbed
      try
        Tout:= ((GetTickCount - Tm) > 3);
      except
        Tout:= True;                                                            //catches "Integer Overflow" when GetTickCount has rolled over
      end;
      If (not Tout) and                                                         //Wait for next frame or Timeout
         (not GigEBuffEmpty) then Break;                                        //Cam has a new frame
    Until Tout;

    If Tout and (ToutCtr > 2) then
    begin
      ClearCanvas(clBtnFace);
      PaintCross(clRed, clBlack, 'Timeout');
      CrossIsDrawn:= true;

      SetupCamera;

      Application.ProcessMessages;
    end
    else
    begin
      if g_bAcquiring then
      begin
        g_bAcquiring:= False;
        if not GigEBuffEmpty then
        begin
          DrawBitmap;
          GigEBuffEmpty:= true;
        end;
        DisplayStatus;
      end
      else
        Tm:= GetTickCount;
    end;
    Application.ProcessMessages;
  end;
  Self.Close;
end;

// Purpose: Discovers GigE cameras if GigE TL is present.
Function DiscoverGigECameras(var RetStr: String; var IsGigE: Boolean): VmbError_t;
var
  Res: VmbError_t;
begin
  isGigE:= False;
  RetStr:= '';
  Res:= VmbFeatureBoolGet(gVimbaHandle, 'GeVTLIsPresent', @isGigE);             //Is Vimba connected to a GigE transport layer?
  if Res = Integer(VmbErrorSuccess) then
  begin
    if(isGigE) then
    begin
      Res:= VmbFeatureIntSet(gVimbaHandle, 'GeVDiscoveryAllDuration', 250);     //Default is 150ms
      if Res = Ord(VmbErrorSuccess) then
      begin
        //Discovery is switched on only once so that the API can detect all
        //currently connected cameras. Wait 250 ms for an answer
        Res:= VmbFeatureCommandRun(gVimbaHandle, 'GeVDiscoveryAllOnce');
        if  Res <> Ord(VmbErrorSuccess) then
          RetStr:= format('Could not ping GigE cameras over the network. Reason: %d', [Res]);
      end
      else
        RetStr:= format('Could not set the discovery waiting duration. Reason: %d', [Res]);
    end
  end
  else
    RetStr:= Format('DiscoverGigECameras failed with reason: %d ==> %s',
                    [Res, VmbErrorStr[(Res)]]);
  Result:= Res;
end;

Function PrintVimbaVersion: String;
var
  version_info: VmbVersionInfo_t;
  res         : VmbError_t;
begin
  res:= VmbVersionQuery(version_info, sizeof(version_info));
  case res of
    Ord(VmbErrorSuccess):
      Result:= Format('%u.%u.%u',
                   [version_info.major, version_info.minor,version_info.patch]);
    Ord(VmbErrorStructSize):
      Result:= Format('VmbVersionQuery Error: %d Struct size is invalid ' +
                      'for this version', [res]);
    Ord(VmbErrorBadParameter):
      Result:= Format('VmbVersionQueryError: %d One of the parameters ' +
                      'is invalid', [res]);
    else
      Result:= Format('VmbVersionQuery failed with Reason: %d', [res]);
  end;
end;

Procedure TForm2.ClearCanvas(clr: Tcolor);
begin
  image1.canvas.brush.color:= clr;
  image1.canvas.rectangle(0, 0, image1.width-1, image1.height-1);
end;

Procedure TForm2.PaintCross(TextColor : TColor;
                            CrossColor: TColor;
                            S         : String);
var
  OK:Boolean;
begin
  With Image1 do
  begin
    Canvas.Font.Size:= 34;
    Repeat                                                                      //limit Text height to accomodate Text to Imahe width
      Canvas.Font.Size:= Canvas.Font.Size - 2;
      OK:= ((Image1.width - Canvas.TextWidth(s)) > 0);
    Until (Canvas.Font.Size < 10) or OK;
    If OK then
    With Canvas do
    begin
      Clearcanvas(clBtnFace);
      Pen.Width:= 2;                                                            //fat
      Pen.Color:= CrossColor;
      MoveTo(0, 0);
      LineTo(ClientWidth , ClientHeight);
      MoveTo(0, ClientHeight);
      LineTo(ClientWidth, 0);
      Font.Color:= TextColor;
      Font.Name:= 'arial';
      TextOut((Image1.ClientWidth - Textwidth(s)) div 2,
              (Image1.ClientHeight - TextHeight(s)) div 2, S);
      Pen.Color:= clBlack;
      Brush.Style:= bsClear;                                                    //transparent background
      //Start at 1,1 to allow Pen.width of 2
      Rectangle(1, 1, ClientWidth, ClientHeight);                               //draw rectangle
    end;
  end;
End;

Procedure TForm2.DrawBitmap;
var
  T: Trect;
begin
  If Radiobutton1.Checked then                                                  //50%
  begin
    T:= Rect(0, 0, Image1.Width div 2, Image1.Height div 2);
    ClearCanvas(clBtnFace);
    Image1.Canvas.StretchDraw(T, FrameBitmap);
  end
  else If Radiobutton2.Checked then                                             //100%
  begin
    Image1.Canvas.Draw(0, 0, FrameBitmap);
  end
  else If Radiobutton3.Checked then                                             //200%
  begin
    T:= Rect(0, 0, Image1.Width * 2, Image1.Height * 2);
    Image1.Canvas.StretchDraw(T, FrameBitmap);
  end;
end;

procedure TForm2.Timer1Timer(Sender: TObject);
begin
  Inc(ToutCtr);
(*
  If (ToutCtr > 10) then
  begin
    ClearCanvas(clBtnFace);
    PaintCross(clRed, clBlack, 'Timeout');
    CrossIsDrawn:= true;

    SetupCamera;

    Application.ProcessMessages;
  end;
 *)
end;

procedure TForm2.ScrollBar1Change(Sender: TObject);
begin
  Edit1.Text:= IntToStr(ScrollBar1.Position);
end;

procedure TForm2.ScrollBar2Change(Sender: TObject);
begin
  Edit2.Text:= IntToStr(ScrollBar2.Position);
end;

procedure TForm2.ScrollBar5Change(Sender: TObject);
begin
  Edit3.Text:= IntToStr(ScrollBar5.Position);
end;

Procedure TForm2.OnThreadMsg(var M: TMessage);
var
  MsgStrPtr: PString;
begin
  MsgStrPtr:= ptr(M.wparam);
  try
    If LeftStr(MsgStrPtr^, 3) = 'WA_' then AddMessage(Copy(MsgStrPtr^ , 4, 255));
  except
    //
  end;
  Dispose(MsgStrPtr);
end;

Procedure TForm2.AddMessage(Msg: String);
begin
  Memo1.Lines.Insert(0, DateTimeToStr(Now) + '  ' + Msg);
  Memo1.Lines.Move(0, 0);                                                       //Point to top of list
end;

Function TForm2.SetupCamera: Boolean;
var
  Res             : VmbError_t;
  Ptr             : PByte;
  pCameras        : VmbCameraInfo_t;                                            // A list of camera details
  nCount,                                                                       // Number of found cameras
  nFoundCount     : VmbUint32_t;                                                // Change of found cameras
  cameraAccessMode: VmbAccessMode_t;
  bIsCommandDone  : Boolean;
  nPayloadSize,                                                                 // The size of one frame
  I64, I64_1      : VmbInt64_t;
  i               : Integer;
  SS              : String;
  IsGigE          : Boolean;
  Df              : Double;
 pPal             : PLogPalette;

begin
  //----------------StartContinuousImageAcquisition-----------------
  // initialize global state
  g_bStreaming:= False;
  g_bAcquiring:= False;
  g_CameraHandle:= Nil;
  ZeroMemory(@g_Frames, sizeof(g_Frames));
  g_dFrameTime:= 0.0;
  g_bFrameTimeValid:= False;
  g_nFrameID:= 0;
  g_bFrameIDValid:= False;
  g_eFrameInfos:= FrameInfos_Show;
  g_bRGBValue:= false;
  g_bEnableColorProcessing:= false;
  bIsCommandDone:= false;
  nPayloadSize:= 0;
  cameraAccessMode:= ord(VmbAccessModeFull);                                    // We open the camera with full access
  ncount:= 0;
  nFoundCount:= 0;
  FirstRun:= True;
  ToutCtr:= 0;
  CrossIsDrawn:= false;
  if FrameBitmap = nil then
  begin
    FrameBitmap:= TBitmap.Create;                                               //sets mono8 palette
    GetMem(pPal, 1028);
    try
      FrameBitmap.PixelFormat:= pf8bit;
      Make8BitPal(pPal);
      FrameBitmap.Palette:= CreatePalette(pPal^);
    finally
      FreeMem(pPal);
    end;
  end;
  Result:= false;

  StopContinuousImageAcquisition(true);
  pPixelFormat:= nil;
  Res:= VmbStartup;                                                             //Startup Vimba
  if Res = Ord(VmbErrorSuccess) then
  begin
    AddMessage('VmbStartup succeeded');
    LabeledEdit7.Text:= PrintVimbaVersion;                                      //Print the version of Vimba
  end
  else
    if (Ord(VmbErrorSuccess) <> Res) and (Integer(VmbErrorMoreData) <> Res) then
      AddMessage(Format('"vmbStartup" failed with Error: %d ==> %s',
                                   [Res, VmbErrorStr[(Res)]]));

  If DiscoverGigECameras(SS, IsGigE) <> 0 then                                  //Is Vimba connected to a GigE transport layer?
  begin
    with Application do
    begin
      // Allow MessageBox to be shown topmost...
      NormalizeTopMosts;
      MessageBox(PWideChar(Format('DiscoverGigECameras failed with ' +
                                  'reason: %d %s || %s',
                                  [Ord(Res), VmbErrorStr[Res], SS])),
                                  'Message', MB_OK);
      RestoreTopMosts;

      AddMessage(SS);
      AddMessage('Exiting program');
      Exit;
    end;
  end;

  try
    if pCameraID = nil  then                                                    //If no camera ID was provided use the first camera found
    begin
      //After connecting a camera to power, it will take some seconds until it is ready
      //This may several retries here because retry is every 5 seconds
      Res:= VmbCamerasList(Nil, 0, nCount, sizeof(pCameras));                   //Get known cameras
      if (Res = Ord(VmbErrorSuccess)) and (nCount > 0) then
      begin
        getMem(Ptr, nCount * sizeof(VmbCameraInfo_t));
        try
          if Ptr <> nil then
          begin
            // Actually query all static details of all known cameras without
            //having to open the cameras. If a new camera was connected since
            //we queried the amount of cameras (nFoundCount > nCount) we can ignore that one
            Res:= VmbCamerasList(Ptr, nCount, nFoundCount, sizeof(pCamera));
            if (Ord(VmbErrorSuccess) <> Res) and (Integer(VmbErrorMoreData) <> Res) then
            begin
              AddMessage(Format('Could not get camera details. Error: %d ==> %s',
                                     [Res, VmbErrorStr[(Res)]]));
              Exit;
            end
            else
            begin
              if nFoundCount > 0
              then
              begin
                copymemory(@pCameras, Ptr + (0 * sizeof(VmbCameraInfo_t)),
                           sizeof(VmbCameraInfo_t));
                pCameraID:= pCameras.cameraIdString;                            //select first camera per default
                AddMessage(Format('Found: %s, %s, %s, %s, %d, %s',
                                                    [pCameras.cameraIdString,
                                                     pCameras.cameraName,
                                                     pCameras.modelName,
                                                     pCameras.serialString,
                                                     pCameras.permittedAccess,
                                                     pCameras.interfaceIdString]));
              end
              else
              begin
                Res:= Integer(VmbErrorNotFound);
                AddMessage(Format('camera lost. Error: %d ==> %s',
                                       [Res, VmbErrorStr[(Res)]]));
                pCameraID:= '';
              end;
            end;
          end
          else
            AddMessage('Could not allocate camera list.');
        finally
          FreeMemory(Ptr);
        end;
      end
      else
        AddMessage(Format('Could not list cameras or no cameras present. ' +
                          'Error code: %d %s',
                          [Res, VmbErrorStr[(Res)]]));
    end;

    if pCameraID <> nil then
    begin
      Res:= VmbCameraOpen(pCameraID, cameraAccessMode, @g_CameraHandle);
      if Res = Ord(VmbErrorSuccess) then
      begin
        AddMessage(Format('Camera with ID: %s is opened', [pCameraID]));

        // Try to set the GeV packet size to the highest possible value
        // We have already tested whether this cam actually is a GigE cam)
        if Integer(VmbErrorSuccess) = VmbFeatureCommandRun(g_CameraHandle,
                                                   'GVSPAdjustPacketSize') then
        Repeat
          Res:= VmbFeatureCommandIsDone(g_CameraHandle, 'GVSPAdjustPacketSize',
                                        bIsCommandDone);
          if Ord(VmbErrorSuccess) <> Res then Break;
        until bIsCommandDone;

        if Res = Ord(VmbErrorSuccess) then
        begin
          Res:= VmbFeatureEnumSet(g_cameraHandle, 'AcquisitionMode', 'Continuous');
          If Res = Ord(VmbErrorSuccess)
            then
              AddMessage('Set "AcquisitionMode" to Continuous succeeded')
            else
              AddMessage(Format(
                          'Set "AcquisitionMode" failed with Error: %d ==> %s',
                          [Res, VmbErrorStr[Res]]));

          Res:= VmbFeatureEnumSet(g_cameraHandle, 'ExposureMode', 'Timed');
          if Res = Ord(VmbErrorSuccess) then
            AddMessage('Set "ExposureMode" to Timed succeeded')
          else
          begin
            ScrollBar1Change(Self);
            AddMessage(Format('Set "ExposureMode" failed with Error: %d ==> %s',
                                   [Res, VmbErrorStr[(Res)]]));
          end;

          Df:= 30000; //uS
          Res:= VmbFeatureFloatSet(g_CameraHandle, 'ExposureTimeAbs', Df);
          If Res = Ord(VmbErrorSuccess) then
          begin
            EnsureRange(Df, ScrollBar1.Min, ScrollBar1.Max);
            ScrollBar1.Position:= Round(Df);
            AddMessage(Format('Set "ExposureTimeAbs" to %0.0f succeeded', [Df]))
          end
          else
          begin
            ScrollBar1Change(Self);
            AddMessage(Format('Set "ExposureTimeAbs" failed with Error: %d ==> %s',
                              [Res, VmbErrorStr[(Res)]]));
          end;

          Res:= VmbFeatureEnumSet(g_cameraHandle, 'ExposureAuto', 'Off');
          if Res = Ord(VmbErrorSuccess)
          then
            AddMessage('Set "ExposureAuto" to Auto succeeded')
          else
          begin
            ScrollBar1Change(Self);
            AddMessage(Format('Set "ExposureAuto" failed with Error: %d ==> %s',
                              [Res, VmbErrorStr[(Res)]]));
          end;

          Res:= VmbFeatureEnumSet(g_cameraHandle, 'TriggerSource', 'FixedRate');
          If Res = Ord(VmbErrorSuccess)
            then
              AddMessage('Set "TriggerSource" to Fixed Rate succeeded')
            else
              AddMessage(Format('Set "TriggerSource" failed with Error: %d ==> %s',
                                     [Res, VmbErrorStr[(Res)]]));

          Df:= 30000;                                                           //Default
          Res:= VmbFeatureFloatSet(g_CameraHandle, 'ExposureTimeAbs', Df);
          If Res = Ord(VmbErrorSuccess) then
          begin
            EnsureRange(Df, ScrollBar2.Min, ScrollBar2.Max);
            ScrollBar2.Position:= Round(Df);
            AddMessage(Format('Set "ExposureTimeAbs" to: %0.0f', [Df]));
          end
          else
          begin
            ScrollBar2Change(Self);
            AddMessage(Format('Set "ExposureTimeAbs" failed with Error: %d ==> %s',
                                   [Res, VmbErrorStr[(Res)]]));
          end;

          Df:= 8.0;
          Res:= VmbFeatureFloatSet(g_CameraHandle, 'AcquisitionFrameRateAbs', Df);
          If Res = Ord(VmbErrorSuccess) then
          begin
            AddMessage(Format('Set "Acquisition Frame Rate Abs": %0.1f', [Df]));
            ScrollBar5.Position:= Round(Df);
          end
          else
            AddMessage(Format('Set "AcquisitionFrameRateAbs" failed with Error: %d ==> %s',
                                   [Res, VmbErrorStr[(Res)]]));

          //This feature is always Off on Prosilica GE. Can not be changed
          Res:= VmbFeatureEnumSet(g_CameraHandle, 'GainAuto', 'Off');
          If Res = Ord(VmbErrorSuccess)
          then
            AddMessage('Set "GainMode" to Off')
          else
            AddMessage(Format('"Set GainAuto" failed with Error: %d ==> %s',
                                   [Res, VmbErrorStr[(Res)]]));

          I64:= 0;                                                              //Default
          Res:= VmbFeatureIntSet(g_CameraHandle, 'GainRaw', I64);
          If Res = Ord(VmbErrorSuccess) then
          begin
            AddMessage(Format('Set "GainRaw" to: %d succeeded', [I64]));
            EnsureRange(I64, ScrollBar2.Min, ScrollBar2.Max);
            ScrollBar2.Position:= I64;
          end
          else
          begin
            ScrollBar2Change(Self);
            AddMessage(Format('Set "GainRaw" failed with Error: %d ==> %s',
                                   [Res, VmbErrorStr[(Res)]]));
          end;

          //---------- Get camera parameters ----------

          Res:= VmbFeatureIntGet(g_CameraHandle, 'Width', I64);
          If Res = Ord(VmbErrorSuccess)
          then
            AddMessage(Format('Get "Width" to: %d', [I64]))
          else
          begin
            AddMessage(Format('Get "Width" failed with Error: %d ==> %s',
                                   [Res, VmbErrorStr[(Res)]]));
            I64:= 640;                                                          //Default
          end;

          I64_1:= 0;                                                            //just to please compiler
          Res:= VmbFeatureIntGet(g_CameraHandle, 'Height', I64_1);
          If Res = Ord(VmbErrorSuccess)
          then
            AddMessage(Format('Get "Height" to: %d', [I64_1]))
          else
          begin
            AddMessage(Format('Get "Height" failed with Error: %d ==> %s',
                                   [Res, VmbErrorStr[(Res)]]));
            I64_1:= 480;                                                        //Default
          end;

          //Mako-G30 frame size is slightly larger than 640x480, limit camera
          //frame size to 640x480
          if I64 > 640 then                                                     //Width
          begin
            I64:= 640;
            Res:= VmbFeatureIntSet(g_CameraHandle, 'Width', I64);
            If Res = Ord(VmbErrorSuccess)
            then
              AddMessage(Format('Set "Width" to: %d', [I64]))
            else
              AddMessage(Format('Set "Width" failed with Error: %d ==> %s',
                                     [Res, VmbErrorStr[(Res)]]));
          end;
          FrameBitmap.Width:= I64;

          if I64_1 > 480 then                                                   //Height
          begin
            I64:= 480;
            Res:= VmbFeatureIntSet(g_CameraHandle, 'Height', I64);
            If Res = Ord(VmbErrorSuccess)
            then
              AddMessage(Format('Set "Height" to: %d', [I64]))
            else
              AddMessage(Format('Set "Height" failed with Error: %d ==> %s',
                                     [Res, VmbErrorStr[(Res)]]));
          end;
          FrameBitmap.Height:= I64_1;

          Df:= 0.0;
          Res:= VmbFeatureFloatGet(g_CameraHandle, 'AcquisitionFrameRateAbs', Df);
          If Res = Ord(VmbErrorSuccess) then
          begin
            AddMessage(Format('Get "AcquisitionFrameRateAbs": %0.1f succeeded', [Df]));
            ScrollBar5.Position:= Round(Df);
          end
          else
            AddMessage(Format('Get "AcquisitionFrameRateAbs" failed with Error: %d ==> %s',
                                   [Res, VmbErrorStr[(Res)]]));

          if Res = Integer(VmbErrorSuccess) then
          begin
            Res:= VmbFeatureIntGet(g_CameraHandle, 'PayloadSize', nPayloadSize);  // Evaluate frame size
            if Res = Integer(VmbErrorSuccess) then
            begin
              for i:= 0 to (NUM_FRAMES - 1) do
              begin
                GetMem(g_Frames[i].buffer, nPayloadSize);
                if g_Frames[i].buffer = nil then
                begin
                  Res:= Ord(VmbErrorResources);
                  break;
                end
                else
                  g_Frames[i].bufferSize:= VmbUint32_t(nPayloadSize);

                // Announce Frame
                Res:= VmbFrameAnnounce(g_CameraHandle, g_Frames[i], VmbUint32_t(sizeof(VmbFrame_t)));
                if Res <> Ord(VmbErrorSuccess) then
                begin
                  freemem(g_Frames[i].buffer);
                  ZeroMemory(@g_Frames[i], sizeof(VmbFrame_t));
                  AddMessage(Format('"VmbFrameAnnounce" for frame buffer #%d failed with Error: %d ==> %s',
                                     [i, Res, VmbErrorStr[(Res)]]));
                  Res:= 0;
                  break;
                end;
              end;

              if Res <> 0 then
                AddMessage(Format('Getmem for frame buffer[%d] failed with Error: %d ==> %s',
                                     [Res, VmbErrorStr[(Res)]]));

              //---------- Get Some Info from camera ----------
              Res:= VmbFeatureFloatGet(g_CameraHandle, 'AcquisitionFrameRateLimit', Df);
              If Res = Ord(VmbErrorSuccess) then
              begin
                AddMessage(Format('Get "AcquisitionFrameRateLimit" is: %0.1f', [Df]));
                ScrollBar5.Min:= 0;
                ScrollBar5.Max:= Round(Df);
              end
              else
                AddMessage(Format('Get "AcquisitionFrameRateLimit" failed with Error: %d ==> %s',
                                       [Res, VmbErrorStr[(Res)]]));

              Res:= VmbCaptureStart(g_CameraHandle);                            // Start Capture Engine
              if Res = Ord(VmbErrorSuccess) then
              begin
                AddMessage('"VmbCaptureStart" succeeded');
                g_bStreaming:= True;

                for i:= 0 to (NUM_FRAMES) - 1 do
                begin
                  Res:= VmbCaptureFrameQueue(g_CameraHandle,
                                             g_Frames[i],
                                             @FrameCallback);                   // Queue Frames
                  if Res = Ord(VmbErrorSuccess) then
                    AddMessage(Format('"VmbCaptureFrameQueue" ' +
                                           'succeeded for Frame #%d', [i]));
                end;

                if Res = Ord(VmbErrorSuccess) then
                begin
                  Res:= VmbFeatureCommandRun(g_CameraHandle, 'AcquisitionStart');
                  if Res = Ord(VmbErrorSuccess) then
                    AddMessage('"AcquisitionStart" succeeded')
                  else
                    AddMessage(Format('"AcquisitionStart" failed with Error: %d ==> %s',
                                           [Res, VmbErrorStr[(Res)]]));
                end
                else
                  if Res <> 0 then
                    AddMessage(Format('"VmbCaptureFrameQueue" failed with error: %d ==> %s',
                                           [Res, VmbErrorStr[(Res)]]));
              end
              else
                AddMessage(Format('"VmbCaptureStart" failed with Error: %d ==> %s',
                                       [Res, VmbErrorStr[(Res)]]))
            end
            else
              AddMessage(Format('"PayloadSize" failed with Error: %d ==> %s',
                                     [Res, VmbErrorStr[(Res)]]))
          end
          else
            AddMessage(Format('"GetPixelFormat" failed with Error: %d ==> %s',
                                   [Res, VmbErrorStr[(Res)]]))
        end
        else
          AddMessage(Format('"GVSPAdjustPacketSize" failed with Error: %d ==> %s',
                                 [Res, VmbErrorStr[(Res)]]))
      end
      else
        AddMessage(Format('"VmbCameraOpen" with ID: %s failed with Error: %d ==> %s',
                                 [pCameraID, Res, VmbErrorStr[(Res)]]));
    end;
  finally
    //
  end;
end;

end.
