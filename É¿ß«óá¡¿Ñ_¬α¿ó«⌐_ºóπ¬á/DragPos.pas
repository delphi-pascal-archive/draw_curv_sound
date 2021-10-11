unit DragPos;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, ExtCtrls,graphics;

type
  marker = record
  ypos,xpos,cxpos,cypos : word;
  moving : boolean;
  end;
  pmarker=^marker;
  dataarray = array[0..maxword] of word;
  pdataarray=^dataarray;

  TDragPos = class(tpanel)
  private
    { Déclarations privées }
    list : tlist;
    SPos,EPos : word;
    AMarker : pmarker;
    MDown : boolean;
    ArLength : word;
    procedure CalculArray;
    procedure WStartPos(val : word);
    procedure WEndPos(val : word);
    procedure SetArrayLength(val : word);
    procedure freelist;
  protected
    { Déclarations protégées }
    procedure MouseMove(Shift: TShiftState; X,Y: Integer);override;
    procedure MouseDown(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);override;
    procedure MouseUp(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);override;
    procedure paint; override;
  public
    { Déclarations publiques }
    Data : pdataarray;
    constructor Create(aOwner:TComponent); override;
    destructor destroy; override;
    procedure clear;
  published
    { Déclarations publiées }
    property startpos : word read spos write wstartpos default 32767;
    property EndPos : word read epos write WEndpos default 32767;
    property ArrayLength : word read ArLength write SetArrayLength default 1024;
  end;

procedure Register;

implementation
procedure Register;
begin
    RegisterComponents('MYCOMP', [TDragPos]);
end;
procedure tdragpos.freelist;
var b : integer;
begin
for B := 0 to (List.Count - 1) do
   begin
     amarker := List.Items[B];
     Dispose(amarker);
   end;
   List.Free;
   amarker:=nil;
end;
procedure tdragpos.clear;
begin
    while list.Count-1<>1 do list.Delete(list.Count-2);
    paint;
    calcularray;
end;
procedure tdragpos.WStartPos(val : word);
begin
spos:= val;
amarker:=list.Items[0];
amarker^.cypos:=height div 2;
amarker^.cxpos:=1;
end;
procedure tdragpos.WEndPos(val : word);
begin
epos:=val;
amarker:=list.Items[list.count-1];
amarker^.cypos:=height div 2;
amarker^.cxpos:=width;
end;
procedure tdragpos.SetArrayLength(val : word);
var i : integer;
begin
    amarker:=list.Items[list.count-1];
    if Data=nil then getmem(Data,val*2) else
    begin
        freemem(Data);
        getmem(data,val*2);
        for i := 1 to list.Count-2 do
        begin
            amarker:=list.Items[i];
        end;
        paint;
    end;
    Arlength:=val;
    //paint;
    calcularray;
end;
procedure tdragpos.CalculArray;
var i,i2 : integer;
    valx1,valx2,valy1,valy2 : word;
begin
    for i:= 0 to list.Count-2 do
    begin
        amarker:=list.Items[i];
        valx1:=round((arlength-1)/(width)*(amarker^.cxpos-1));
        valy1:=round(maxword/(height)*(amarker^.cypos-1));
        amarker:=list.Items[i+1];
        valx2:=round((arlength-1)/(width)*(amarker^.cxpos-1));
        valy2:=round(maxword/(height)*(amarker^.cypos-1));
        if i=0 then valx1:=0;
        if i=list.Count-2 then valx2:=arlength-1;
        for i2:=valx1 to valx2 do
        begin
            if valx2-valx1<>0 then Data^[i2]:=round(valy1+((valy2-valy1)/(valx2-valx1))*(i2-valx1))
            else data^[i2]:=data^[i2-1];
        end;
    end;
end;
procedure tdragpos.paint;
var i,x,y : integer;
begin
    //inherited paint;
    canvas.Pen.Color:=$ffffff;
    canvas.Brush.Color:=$ffffff;
    Canvas.Rectangle(rect(0,0,width,height));
    if list.Count<>0 then
    begin
        for i:=0 to list.count-1 do
        begin
            canvas.Pen.Color:=$0a0aff;
            amarker:=list.Items[i];
            x:=amarker^.cxpos;
            y:=amarker^.cypos;
            canvas.Arc(x-4,y-4,x+4,y+4,x-4,y-4,x-4,y-4);
            canvas.Pen.Color:=$00FF00;
            if i=0 then canvas.MoveTo(x,y) else canvas.LineTo(x,y);
        end;
    end;
end;
procedure tdragpos.MouseMove(Shift: TShiftState; X,Y: Integer);
var i : integer;
leftx,rightx : integer;
begin
    inherited mousemove(Shift, X,Y);
    for i:=0 to list.Count-1 do
    begin
        amarker:=list.Items[i];
        if amarker^.moving=true then
        begin
            if (i<>0) and (i<>list.Count-1) then
            begin
                amarker:=list.Items[i-1];
                leftx:=amarker^.cxpos;
                amarker:=list.Items[i+1];
                rightx:=amarker^.cxpos;
                amarker:=list.Items[i];
                amarker^.cxpos:=x;
                if x<=leftx then amarker^.cxpos:=leftx+1;
                if x>=rightx then amarker^.cxpos:=rightx-1;
                amarker^.cypos:=y;
            end else amarker^.cypos:=y;
            paint;
            calcularray;
        end;
    end;
end;
procedure tdragpos.MouseUp(Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
var i : integer;
begin
    inherited MouseUp(Button,Shift, X, Y);
    mdown:=false;
    for i := 0 to list.Count-1 do
    begin
        amarker:=list.Items[i];
        amarker^.moving:=false;
    end;
end;
procedure tdragpos.MouseDown( Button: TMouseButton;Shift: TShiftState; X, Y: Integer);
var i,i2 : integer;
    mark : pmarker;
  begin
      inherited mousedown( Button,Shift, X, Y);
      mdown:=true;
          for i:= 0 to list.Count-1 do
          begin
          mark:=list.Items[i];
          if (mark^.cxpos<=x+4)and(mark^.cypos<=y+4)and(mark^.cxpos>=x-4)and(mark^.cypos>=y-4)then
          begin
              mark^.moving:=true;
              exit;
          end else if i=list.Count-1 then
          begin
              for i2:= 0 to list.Count-1 do
              begin
                  mark:=list.Items[i2];
                  if mark^.cxpos>=x then break;
              end;
              mark:=list.Items[i2-1];
              if(mark^.cxpos=x)then break;
              mark:=list.Items[i2];
              if(mark.cxpos=x)then break;
              new(mark);
              mark^.cxpos:=x;
              mark^.cypos:=y;
              mark^.moving:=true;
              list.Insert(i2,mark);
              paint;
              calcularray;
          end;
          end;
  end;
constructor TDragPos.Create(aOwner:TComponent);
begin
    inherited Create(aOwner);
    mdown:=false;
    list:=tlist.Create;
    new(amarker);
    amarker^.cypos:=height div 2;
    amarker^.cxpos:=0;
    amarker.moving:=false;
    list.Add(amarker);
    new(amarker);
    amarker^.cypos:=height div 2;
    amarker^.cxpos:=width;
    amarker.moving:=false;
    list.Add(amarker);
end;
destructor tdragpos.destroy;
begin
    freelist;
    freemem(data);
    inherited destroy;
end;

end.
