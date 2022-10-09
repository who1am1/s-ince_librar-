unit profile;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn,
  ActnList, CheckLst, Spin, ComboEx, LCLType, ExtCtrls, Buttons, LazUTF8;

type

  { TfProfile }

  TfProfile = class(TForm)
    bSave: TButton;
    eGender: TComboBox;
    eBirthdate: TDateEdit;
    eLogin: TEdit;
    ePassword: TEdit;
    eRole: TEdit;
    eSurname: TEdit;
    eName: TEdit;
    ePatronymic: TEdit;
    iEdit: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    lChange: TLabel;
    procedure bSaveClick(Sender: TObject);
    procedure eSurnameUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure iEditClick(Sender: TObject);
  private

  public

  end;

var
  fProfile: TfProfile;
  From: String; // используется в fChangePass и указывает, какая форма вызвала fChangePass

implementation
uses
  Autorisation, Main, Save, ChangePassword;

{$R *.lfm}

{ TfProfile }

procedure TfProfile.eSurnameUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char
  );
begin
  if UTF8Length(TEdit(Sender).Text) < 30 then
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
  else
    case UTF8Key of
    #8: UTF8Key := UTF8Key;
    else UTF8Key := #0;
    end;
end;

procedure TfProfile.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  fMain.Show;
  lChange.Visible := False;
end;

procedure TfProfile.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  fAuto.SQLQ.Close;
  fAuto.SQLQ.SQL.Text := 'select * from users where login = :L';
  fAuto.SQLQ.ParamByName('L').AsString := Login;
  fAuto.SQLQ.Open;
  if (fAuto.SQLQ.FieldByName('surname').AsString<>eSurname.Text) or (fAuto.SQLQ.FieldByName('name').AsString<>eName.Text) or
  (fAuto.SQLQ.FieldByName('patronymic').AsString<>ePatronymic.Text) or (fAuto.SQLQ.FieldByName('birthdate').AsString<>eBirthdate.Text) or
  (fAuto.SQLQ.FieldByName('gender').AsString<>eGender.Text) then
  begin
    fSave.Label1.Top := 48;
    fSave.Label1.Left :=40;
    fSave.Caption := 'Сохранение данных';
    fSave.Label1.Caption := 'Сохранить измененные данные?';
    fProfile.ModalResult := mrNone;
    fSave.ShowModal;
    if fProfile.ModalResult = mrYes then
    begin

      if eSurname.Text = '' then
      begin
        Application.MessageBox('Не введена фамилия!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
        eSurname.SetFocus;
        CanClose := False;
        exit;
      end;

      if eName.Text = '' then
      begin
        Application.MessageBox('Не введено имя!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
        eName.SetFocus;
        CanClose := False;
        exit;
      end;

      if eBirthdate.Text = '  .  .    ' then
      begin
        Application.MessageBox('Не введена дата рождения!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
        eBirthdate.SetFocus;
        CanClose := False;
        exit;
      end;

      with fAuto.SQLQ do
      begin
      Close;
      SQL.Text := 'update users set surname=:S, name=:N, patronymic=:P, birthdate=:B, gender=:G where login=:L';
      ParamByName('S').AsString := eSurname.Text;
      ParamByName('N').AsString := eName.Text;
      ParamByName('P').AsString := ePatronymic.Text;
      ParamByName('B').AsString := eBirthdate.Text;
      ParamByName('G').AsString := eGender.Text;
      ParamByName('L').AsString := Login;
      ExecSQL;
      end;
      fAuto.SQLTransaction.Commit;
      fAuto.SQLQ.Close;
      CanClose := True;
    end
    else if fProfile.ModalResult = mrNo then
      CanClose := True
    else CanClose := False;
  end;
end;

procedure TfProfile.FormHide(Sender: TObject);
begin
  lChange.Visible := False;
end;

procedure TfProfile.bSaveClick(Sender: TObject);
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

  with fAuto.SQLQ do
  begin
  Close;
  SQL.Text := 'update users set surname=:S, name=:N, patronymic=:P, birthdate=:B, gender=:G where login=:L';
  ParamByName('S').AsString := eSurname.Text;
  ParamByName('N').AsString := eName.Text;
  ParamByName('P').AsString := ePatronymic.Text;
  ParamByName('B').AsString := eBirthdate.Text;
  ParamByName('G').AsString := eGender.Text;
  ParamByName('L').AsString := Login;
  ExecSQL;
  end;
  fAuto.SQLTransaction.Commit;
  fAuto.SQLQ.Close;
  fProfile.Hide;
  fMain.Show;
end;

procedure TfProfile.FormShow(Sender: TObject);
begin
  fProfile.ModalResult := mrNone;
  eSurname.SetFocus;
  fAuto.SQLQ.Close;
  fAuto.SQLQ.SQL.Text := 'select * from users where login = :L';
  fAuto.SQLQ.ParamByName('L').AsString := Login;
  fAuto.SQLQ.Open;
  eLogin.Text := fAuto.SQLQ.FieldByName('login').AsString;
  eRole.Text := fAuto.SQLQ.FieldByName('role').AsString;
  eSurname.Text := fAuto.SQLQ.FieldByName('surname').AsString;
  eName.Text := fAuto.SQLQ.FieldByName('name').AsString;
  ePatronymic.Text := fAuto.SQLQ.FieldByName('patronymic').AsString;
  eBirthdate.Text := fAuto.SQLQ.FieldByName('birthdate').AsString;
  eGender.Text := fAuto.SQLQ.FieldByName('gender').AsString;
  fAuto.SQLQ.Close;
end;

procedure TfProfile.iEditClick(Sender: TObject);
begin
  From := 'Profile';
  fChangePass.Label1.Caption := 'Введите текущий пароль:';
  fChangePass.ShowModal;
end;

end.

