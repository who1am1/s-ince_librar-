unit sort;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TfSort }

  TfSort = class(TForm)
    bSave: TButton;
    Label1: TLabel;
    RG: TRadioGroup;
    procedure bSaveClick(Sender: TObject);
  private

  public

  end;

var
  fSort: TfSort;

implementation
uses
  Books;

{$R *.lfm}

{ TfSort }

procedure TfSort.bSaveClick(Sender: TObject);
var
  buf: integer;
begin
  case RG.ItemIndex of
  0: buf:= 0;
  else buf:= RG.ItemIndex + 1;
  end;
  fTable.SG.SortColRow(True, buf);
  fSort.Close;
end;

end.

