unit rtoobj;

interface
uses classes,windows,messages,mmsystem,sysutils;

const
memBlockLength = 1000;

type
    Tmemblock = array[0..memblocklength-2] of byte;
    PmemBlock = ^TmemBlock;

        soundgen = class
              protected
              time : cardinal;
             soundhwnd : hwnd;
             HwaveIn:PHWaveIn;
             HWaveOut:PHWaveOut;
             close_invoked,close_complete:boolean;
             out_count:integer;
             done : boolean;
             public
             p:pwordarray;
             anum : word;
             play,vo  : boolean;
             vfreq : single;
             procedure WndProc(var Msg: TMessage);
             procedure start;
             procedure stop;
        constructor create;
        destructor destroy;//override;
        end;

implementation
uses unit1;
constructor soundgen.create;
begin
 soundhwnd :=  AllocateHWnd(WndProc);
 out_count:=0;
 done:=true;
 anum:=0;
end;
destructor soundgen.destroy;
var i : integer;
begin
  play:=false;
  if done=false then begin
  WaveOutClose(HWaveOut^);
  HwaveOut:=nil;
  end;

  DeallocateHWnd(soundhwnd);
end;
procedure soundgen.WndProc(var Msg: TMessage);
var
   Header:PWaveHdr;
   memBlock:PmemBlock;
   number : real;
   i : integer;
begin
with Msg do if Msg = MM_WOM_DONE then begin
  dec(out_count);


  if play=true then begin
    p:=pointer(pwavehdr(lparam)^.lpdata);
        for i:=0 to 499 do begin
        //////////////here/////////////////
        inc(time);
        inc (anum);
        if anum>=form1.markers.ArrayLength then anum:=0;
        if  not vo then
        begin
             p^[i]:=form1.markers.data^[anum]-(maxword div 2);
        end else
        begin
            number:=sin(pi*(vfreq)*time/44100);
            p^[i]:=round((form1.markers.data^[anum]-(maxword div 2))*number);
        end;
        end;
    Header:=PWaveHdr(lparam);
    if not(close_invoked) then
     begin
          waveOutPrepareHeader(HWaveOut^,Header,sizeof(TWavehdr));
          waveOutWrite(HWaveOut^,Header,sizeof(TWaveHdr));
          inc(out_count);

          memBlock:=new(PmemBlock);

          Header:=new(PwaveHdr);
          with header^ do
          begin
               lpdata:=pointer(memBlock);
               dwbufferlength:=memblocklength;
               dwbytesrecorded:=0;
               dwUser:=0;
               dwflags:=0;
               dwloops:=0;
          end;
     end;
    end;
 if (out_count=0) then
     begin
          WaveOutClose(HWaveOut^);
          HwaveOut:=nil;
          done:=true;
     end;
end else Result := DefWindowProc(soundhwnd, Msg, wParam, lParam);
end;

procedure soundgen.start;
var
   WaveFormat:PWaveFormatex;
   Header:PWaveHdr;
   memBlock:PmemBlock;
   i:integer;
begin
    done:=false;
    play:=true;
    WaveFormat:=new(PwaveFormatex);
    waveformat.wFormatTag:= WAVE_FORMAT_PCM;
    waveformat.nChannels:=1;
    waveformat.nSamplesPerSec:=44100;
    waveformat.nAvgBytesPerSec:=44100*(16 div 8);
    waveformat.nBlockAlign:=16 div 8;
    waveformat.wBitsPerSample:=16;
    HwaveOut:=new(PHwaveOut);
    waveOutOpen(HWaveOut,WAVE_MAPPER,WaveFormat,soundhwnd,0,CALLBACK_WINDOW);
     out_count:=0;
     for i:= 0 to 8 do
     begin
          memBlock:=new(PmemBlock);
          Header:=new(PwaveHdr);
          with header^ do
          begin
               lpdata:=pointer(memBlock);
               dwbufferlength:=memblocklength;
               dwbytesrecorded:=0;
               dwUser:=0;
               dwflags:=0;
               dwloops:=0;
          end;

          waveOutPrepareHeader(HWaveOut^,Header,sizeof(TWavehdr));
          waveOutWrite(HWaveOut^,Header,sizeof(TWaveHdr));
          inc(out_count);
     end;
     close_invoked:=false;
     close_complete:=false;
end;
procedure soundgen.stop;
begin
//
play:=false;
end;
end.
