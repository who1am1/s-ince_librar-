unit confirmreturn;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn, LCLType;

type

  { TfConfirmReturn }

  TfConfirmReturn = class(TForm)
    bSave: TButton;
    eBorrowDate: TDateEdit;
    eID: TEdit;
    eUser: TEdit;
    eRR: TCheckBox;
    eOnTime: TCheckBox;
    eReader: TMemo;
    eBook: TMemo;
    eReturnDate: TDateEdit;
    Label1: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    procedure bSaveClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  fConfirmReturn: TfConfirmReturn;
  FormShowed: boolean;

implementation
uses
  Autorisation, Save, ReturnBook;

{$R *.lfm}

{ TfConfirmReturn }

procedure TfConfirmReturn.bSaveClick(Sender: TObject);
var
  buf: string;
begin
  fSave.Label1.Top := 48;
  fSave.Label1.Left :=40;
  fSave.Label1.Caption := 'Пометить книгу как сданную?';
  fConfirmReturn.ModalResult := mrNone;
  FormShowed := True;
  fSave.ShowModal;
  if (fConfirmReturn.ModalResult = mrNone) or (fConfirmReturn.ModalResult = mrNo) then
    exit;
  with fAuto.SQLQ do
  begin
    Close;
    SQL.Text := 'update borrow_history set book_returned=:BR, returned_on_time=:ROT where id=:I';
    ParamByname('I').AsString := eID.Text;
    ParamByname('BR').AsBoolean := True;
    ParamByname('ROT').AsBoolean := eOnTime.Checked;
    ExecSQL;
  end;
  fAuto.SQLTransaction.Commit;
  fAuto.SQLQ.Close;

  Application.MessageBox('Книга успешно сдана!', 'Успешно', MB_ICONINFORMATION + MB_OK);

  if fReturnBook.eReturned.Checked = False then              // если сданные книги в таблице не отображаются, то удаляем строку
    fReturnBook.SG.DeleteRow(fReturnBook.SG.Row)
  else                                              // иначе изменяем данные
  begin
    fReturnBook.SG.Cells[7,fReturnBook.SG.Row] := 'Да';
    if eOnTime.Checked then
      buf := 'Да'
    else
      buf := 'Нет';
    fReturnBook.SG.Cells[8,fReturnBook.SG.Row] := buf;
  end;

  FormShowed := False;
  fConfirmReturn.Close;
end;

procedure TfConfirmReturn.FormCloseQuery(Sender: TObject; var CanClose: Boolean
  );
begin
  if FormShowed then // если была показана форма Save, то не выходим
  begin
    FormShowed := False;
    if fConfirmReturn.ModalResult = mrYes then
      CanClose := True
    else
      CanClose := False;
  end
  else
    CanClose := True;
end;

procedure TfConfirmReturn.FormShow(Sender: TObject);
var
  buf: boolean;
begin
  fConfirmReturn.ModalResult := mrNone;
  with fReturnBook.SG do
  begin
    if Cells[7,Row] = 'Да' then // если книга уже сдана, запрещаем сдать ее заново
    begin
      eOnTime.Enabled := False;
      if Cells[8,Row] = 'Да' then // проверяем, сдана ли книга вовремя
        buf := True
      else
        buf := False;
      eOnTime.Checked := buf;
      bSave.Enabled := False;
    end
    else
    begin
      eOnTime.Enabled := True;
      eOnTime.Checked := True;
      bSave.Enabled := True;
    end;
  end;
end;

end.

