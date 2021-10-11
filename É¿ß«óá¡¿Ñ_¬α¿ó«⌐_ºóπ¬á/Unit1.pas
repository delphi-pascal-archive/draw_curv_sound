unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,dragpos,rtoobj, ComCtrls, ExtCtrls, StdCtrls, Mask;

type
  TForm1 = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    TrackBar1: TTrackBar;
    GroupBox2: TGroupBox;
    TrackBar2: TTrackBar;
    MaskEdit1: TMaskEdit;
    CheckBox1: TCheckBox;
    MaskEdit2: TMaskEdit;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure TrackBar2Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure MaskEdit1Change(Sender: TObject);
    procedure MaskEdit2Change(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
    markers : tdragpos;
  end;
var
  Form1: TForm1;
  sound : soundgen;

implementation
{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
markers:=tdragpos.Create(self);
markers.ParentWindow:=form1.Handle;
markers.Width:=792;
markers.Height:=380;
markers.startpos:=maxword div 2;
markers.EndPos:=maxword div 2;
markers.ArrayLength:=820;
markers.DoubleBuffered:=true;
sound:=soundgen.create;
sound.start;
//sound.vo:=true;
markers.ArrayLength:=trackbar1.Position;
sound.vfreq:=trackbar2.Position/100;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
sound.stop;
sound.destroy;
markers.destroy;
end;

function getgoodstr(bar : byte;val : integer) : string;
begin
    case bar of
       0:  case val of
            0..9     : result:='000'+inttostr(val);
            10..99   : result:='00'+inttostr(val);
            100..999 : result:='0'+inttostr(val);
       else result:=inttostr(val) end;
       1:  case val of
            0..9        : result:='00000'+inttostr(val);
            10..99      : result:='0000.'+inttostr(val);
            100..999    : result:='000'+inttostr(val);
            1000..9999  : result:='00'+inttostr(val);
            10000..99999: result:='0'+inttostr(val);
       else result:=inttostr(val) end;
    end;
end;

procedure TForm1.TrackBar1Change(Sender: TObject);
begin
markers.ArrayLength:=trackbar1.Position;
maskedit1.Text:=getgoodstr(0,trackbar1.position);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
markers.clear;
end;

procedure TForm1.TrackBar2Change(Sender: TObject);
begin
sound.vfreq:=trackbar2.Position/100;
maskedit2.Text:=getgoodstr(1,trackbar2.Position);
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
begin
sound.vo:=checkbox1.Checked;
end;

procedure TForm1.MaskEdit1Change(Sender: TObject);
begin
trackbar1.Position:=strtoint(maskedit1.Text);
end;

procedure TForm1.MaskEdit2Change(Sender: TObject);
begin
trackbar2.Position:=strtoint(maskedit2.Text);
end;

end.
