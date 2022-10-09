unit enterid;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLType;

type

  { TfEnterID }

  TfEnterID = class(TForm)
    bSave: TButton;
    eID: TEdit;
    Label1: TLabel;
    procedure bSaveClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  fEnterID: TfEnterID;
  ReaderID: integer; // сохраняем ID читателя и используем в модуле ReturnBook

implementation
uses
  Autorisation, Main;

{$R *.lfm}

{ TfEnterID }

procedure TfEnterID.FormShow(Sender: TObject);
begin
  eID.Text := '';
end;

procedure TfEnterID.bSaveClick(Sender: TObject);
begin
  if (eID.Text = '') or (strtoint(eID.Text) = 0) then
  begin
    Application.MessageBox('Введите значение!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eID.SetFocus;
    exit;
  end;

  with fAuto.SQLQ do
  begin
    Close;
    SQL.Text := 'select * from readers where id=:I';
    ParamByName('I').AsString := eID.Text;
    Open;
    First;
    if EOF then
    begin
      Close;
      Application.MessageBox('Читатель не найден!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
      exit;
    end;
    Close;
  end;
  fMain.ModalResult := mrYes;
  ReaderID := strtoint(eID.Text);
  Close;
end;

end.

