unit editreader;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn, LCLType, LazUTF8;

type

  { TfEditReader }

  TfEditReader = class(TForm)
    bSave: TButton;
    eBirthdate: TDateEdit;
    eComment: TMemo;
    eAddress: TMemo;
    eID: TEdit;
    eSurname: TEdit;
    eName: TEdit;
    ePatronymic: TEdit;
    ePhoneNumber: TEdit;
    eEmail: TEdit;
    Label1: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure bSaveClick(Sender: TObject);
    procedure ePhoneNumberUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure eSurnameUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  fEditReader: TfEditReader;

implementation
uses Main, Autorisation, Books, Save;

{$R *.lfm}

{ TfEditReader }

procedure TfEditReader.FormShow(Sender: TObject);
begin
  Saved := False;
  fEditReader.ModalResult := mrNone;
  if Mode = 'Edit' then
    case Focus of
    0..1: eSurname.SetFocus;
    2: eName.SetFocus;
    3: ePatronymic.SetFocus;
    4: eBirthdate.SetFocus;
    5: eAddress.SetFocus;
    6: ePhoneNumber.SetFocus;
    7: eEmail.SetFocus;
    8: eComment.SetFocus;
    end;

  if Mode = 'Add' then
    eSurname.SetFocus;
end;

procedure TfEditReader.bSaveClick(Sender: TObject);
begin
  if eSurname.Text = '' then
  begin
    Application.MessageBox('Не введена фамилия!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eSurname.SetFocus;
    exit;
  end;

  if eName.Text = '' then
  begin
    Application.MessageBox('Не введено имя!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eName.SetFocus;
    exit;
  end;

  if eBirthdate.Text = '  .  .    ' then
  begin
    Application.MessageBox('Не введена дата рождения!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eBirthdate.SetFocus;
    exit;
  end;

  if eAddress.Text = '' then
  begin
    Application.MessageBox('Не введен адрес проживания!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eAddress.SetFocus;
    exit;
  end;

  if Mode = 'Edit' then
  begin
    with fAuto.SQLQ do
    begin
      Close;
      SQL.Clear;
      SQL.Text := 'update readers set surname=:S, name=:N, patronymic=:P, birthdate=:B, address=:A, phone_number=:PN, email=:E, comment=:C where id=:I';
      ParamByName('S').AsString := eSurname.Text;
      ParamByName('N').AsString := eName.Text;
      ParamByName('P').AsString := ePatronymic.Text;
      ParamByName('B').AsString := eBirthdate.Text;
      ParamByName('A').AsString := eAddress.Text;
      ParamByName('PN').AsString := ePhoneNumber.Text;
      ParamByName('E').AsString := eEmail.Text;
      ParamByName('C').AsString := eComment.Text;
      ParamByName('I').AsString := eID.Text;
      ExecSQL;
    end;
    fAuto.SQLTransaction.Commit;
    fAuto.SQLQ.Close;

    with fTable.SG do
    begin
    Cells[1,Row] := eSurname.Text;
    Cells[2,Row] := eName.Text;
    Cells[3,Row] := ePatronymic.Text;
    Cells[4,Row] := eBirthdate.Text;
    Cells[5,Row] := eAddress.Text;
    Cells[6,Row] := ePhoneNumber.Text;
    Cells[7,Row] := eEmail.Text;
    Cells[8,Row] := eComment.Text;
    end;
  end;

  if Mode = 'Add' then
  begin
    with fAuto.SQLQ do
    begin
      Close;
      SQL.Clear;
      SQL.Text := 'insert into readers(surname,name,patronymic,birthdate,address,phone_number,email,comment) values(:S,:N,:P,:B,:A,:PN,:E,:C)';
      ParamByName('S').AsString := eSurname.Text;
      ParamByName('N').AsString := eName.Text;
      ParamByName('P').AsString := ePatronymic.Text;
      ParamByName('B').AsString := eBirthdate.Text;
      ParamByName('A').AsString := eAddress.Text;
      ParamByName('PN').AsString := ePhoneNumber.Text;
      ParamByName('E').AsString := eEmail.Text;
      ParamByName('C').AsString := eComment.Text;
      ExecSQL;
    end;
    fAuto.SQLTransaction.Commit;
    fAuto.SQLQ.Close;

    fAuto.SQLQ.SQL.Text := 'select MAX(id) from readers';
    fAuto.SQLQ.Open;

    with fTable.SG do
    begin
      RowCount := RowCount + 1;

      Cells[0,RowCount - 1] := fAuto.SQLQ.FieldByName('MAX(id)').AsString;
      Cells[1,RowCount - 1] := eSurname.Text;
      Cells[2,RowCount - 1] := eName.Text;
      Cells[3,RowCount - 1] := ePatronymic.Text;
      Cells[4,RowCount - 1] := eBirthdate.Text;
      Cells[5,RowCount - 1] := eAddress.Text;
      Cells[6,RowCount - 1] := ePhoneNumber.Text;
      Cells[7,RowCount - 1] := eEmail.Text;
      Cells[8,RowCount - 1] := eComment.Text;
    end;
    fAuto.SQLQ.Close;
  end;

  Saved := True;
  fEditReader.Close;
end;

procedure TfEditReader.ePhoneNumberUTF8KeyPress(Sender: TObject;
  var UTF8Key: TUTF8Char);
begin
  if UTF8Length(TEdit(Sender).Text) > 0 then
    case UTF8Key of
      '0'..'9': UTF8Key := UTF8Key;
      #8: UTF8Key := UTF8Key; // backspace
      else UTF8Key := #0;
    end
  else
    case UTF8Key of
      '0'..'9': UTF8Key := UTF8Key;
      #43: UTF8Key := UTF8Key; // плюс
      #8: UTF8Key := UTF8Key; // backspace
      else UTF8Key := #0;
    end;
end;

procedure TfEditReader.eSurnameUTF8KeyPress(Sender: TObject;
  var UTF8Key: TUTF8Char);
begin
  case UTF8Key of
    'a'..'z': UTF8Key := UTF8Key;
    'A'..'Z': UTF8Key := UTF8Key;
    'а'..'я': UTF8Key := UTF8Key;
    'А'..'Я': UTF8Key := UTF8Key;
    'ё': UTF8Key := UTF8Key;
    'Ё': UTF8Key := UTF8Key;
    #8: UTF8Key:=UTF8Key; // backspace
    #45: UTF8Key := UTF8Key; // тире
    else UTF8Key := #0;
    end
end;

procedure TfEditReader.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Saved then
  begin
    CanClose := True;
    exit;
  end;

  if EditBookAbility = False then
  begin
    CanClose := True;
    exit;
  end;

  if Mode = 'Edit' then
  begin
    if (Surname<>eSurname.Text) or (ReaderName<>eName.Text) or (Patronymic<>ePatronymic.Text) or
    (Birthdate<>eBirthdate.Text) or (Address<>eAddress.Text) or (PhoneNumber<>ePhoneNumber.Text) or
    (Email<>eEmail.Text) or (Comment<>eComment.Text) then
    begin
      fSave.Label1.Top := 32;
      fSave.Label1.Left := 50;
      fSave.Caption := 'Выход';
      fSave.Label1.Caption := 'Вы дейстительно хотите выйти,' + #13 + 'не сохранив данные?';
      fEditReader.ModalResult := mrNone;
      fSave.ShowModal;
      if (fEditReader.ModalResult = mrNo) or (fEditReader.ModalResult = mrNone) then
      begin
        CanClose := False;
        exit;
      end
      else
        CanClose := True;
    end;
  end;

  if Mode = 'Add' then
  begin
    if (eSurname.Text<>'') or (eName.Text<>'') or (ePatronymic.Text<>'') or
    (eBirthdate.Text<>'  .  .    ') or (eAddress.Text<>'') or (ePhoneNumber.Text<>'') or
    (eEmail.Text<>'') or (eComment.Text<>'') then
    begin
      fSave.Label1.Top := 32;
      fSave.Label1.Left := 50;
      fSave.Caption := 'Выход';
      fSave.Label1.Caption := 'Вы дейстительно хотите выйти,' + #13 + 'не сохранив данные?';
      fEditReader.ModalResult := mrNone;
      fSave.ShowModal;
      if (fEditReader.ModalResult = mrNo) or (fEditReader.ModalResult = mrNone) then
      begin
        CanClose := False;
        exit;
      end
      else
        CanClose := True;
    end;
  end;
end;

end.

