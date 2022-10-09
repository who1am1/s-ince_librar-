unit edit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons,
  EditBtn, ExtCtrls, LCLType, LazUTF8;

type

  { TfEdit }

  TfEdit = class(TForm)
    bSave: TButton;
    eEEA: TCheckBox;
    eEBA: TCheckBox;
    eActiveProfile: TCheckBox;
    eBirthdate: TDateEdit;
    eGender: TComboBox;
    eLogin: TEdit;
    eName: TEdit;
    ePassword: TEdit;
    ePatronymic: TEdit;
    eRole: TEdit;
    eSurname: TEdit;
    iCheck: TImage;
    iEdit: TImage;
    iHide: TImage;
    iShow: TImage;
    iSuccess: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    lChange: TLabel;
    procedure bSaveClick(Sender: TObject);
    procedure eLoginUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure ePasswordUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure eRoleUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormHide(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure iCheckClick(Sender: TObject);
    procedure iEditClick(Sender: TObject);
    procedure iHideClick(Sender: TObject);
    procedure iShowClick(Sender: TObject);
  private

  public

  end;

var
  fEdit: TfEdit;

implementation
uses
  Books, ChangePassword, Profile, Autorisation, Save;

{$R *.lfm}

{ TfEdit }

procedure TfEdit.FormShow(Sender: TObject);
begin
  Saved := False;
  fEdit.ModalResult := mrNone;
  if Mode = 'Edit' then
    case Focus of
    0..2: eRole.SetFocus;
    3: eSurname.SetFocus;
    4: eName.SetFocus;
    5: ePatronymic.SetFocus;
    6: eBirthdate.SetFocus;
    7: eGender.SetFocus;
    8: eEEA.SetFocus;
    9: eEBA.SetFocus;
    10: eActiveProfile.SetFocus;
    end;
end;

procedure TfEdit.iCheckClick(Sender: TObject);
begin
  if eLogin.Text = '' then
    begin
    Application.MessageBox('Введите новый логин!', 'Ошибка', MB_ICONERROR + MB_OK);
    exit;
    end;
  if UTF8Length(eLogin.Text) < 4 then
    begin
    Application.MessageBox('Логин не может быть меньше 4-х символов!', 'Ошибка', MB_ICONERROR + MB_OK);
    exit;
    end;
  fAuto.SQLQ.Close;
  fAuto.SQLQ.SQL.Text := 'select login from users';
  fAuto.SQLQ.Open;
  fAuto.SQLQ.First;
  while not fAuto.SQLQ.EOF do
  begin
    if eLogin.Text = fAuto.SQLQ.FieldByName('login').AsString then
      begin
      Application.MessageBox('Логин уже занят! Введите новый!', 'Ошибка', MB_ICONERROR + MB_OK);
      eLogin.SetFocus;
      exit;
      end;
    fAuto.SQLQ.Next;
  end;

  Application.MessageBox('Логин свободен!', 'Успешно', MB_ICONINFORMATION + MB_OK);

  fAuto.SQLQ.Close;
  Label1.Enabled := False;
  Label2.Enabled := True;
  Label3.Enabled := True;
  Label4.Enabled := True;
  Label5.Enabled := True;
  Label6.Enabled := True;
  Label7.Enabled := True;
  Label8.Enabled := True;
  Label9.Enabled := True;
  Label10.Enabled := True;
  Label11.Enabled := True;

  eLogin.Enabled := False;
  ePassword.Enabled := True;
  eRole.Enabled := True;
  eSurname.Enabled := True;
  eName.Enabled := True;
  ePatronymic.Enabled := True;
  eBirthdate.Enabled := True;
  eGender.Enabled := True;
  eEEA.Enabled := True;
  eEBA.Enabled := True;
  eActiveProfile.Enabled := True;

  iCheck.Visible := False;
  iSuccess.Visible := True;
  iShow.Enabled := True;
  bSave.Enabled := True;
end;

procedure TfEdit.iEditClick(Sender: TObject);
begin
  From := 'Edit';
  fChangePass.Label1.Caption := 'Введите ВАШ пароль:';
  fChangePass.ShowModal;
  fEdit.ModalResult := mrNone;
end;

procedure TfEdit.iHideClick(Sender: TObject);
begin
  ePassword.PasswordChar := #42; // #42 - звездочка
  iHide.Visible := False;
  iShow.Visible := True;
end;

procedure TfEdit.iShowClick(Sender: TObject);
begin
  ePassword.PasswordChar := #0;
  iShow.Visible := False;
  iHide.Visible := True;
end;

procedure TfEdit.eRoleUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
begin
  if UTF8Length(TEdit(Sender).Text) < 100 then
    case UTF8Key of
    'a'..'z': UTF8Key := UTF8Key;
    'A'..'Z': UTF8Key := UTF8Key;
    'а'..'я': UTF8Key := UTF8Key;
    'А'..'Я': UTF8Key := UTF8Key;
    'ё': UTF8Key := UTF8Key;
    'Ё': UTF8Key := UTF8Key;
    #8: UTF8Key := UTF8Key; // backspace
    #45: UTF8Key := UTF8Key; // тире
    else UTF8Key := #0;
    end
  else
    case UTF8Key of
    #8: UTF8Key := UTF8Key;
    else UTF8Key := #0;
    end;
end;

procedure TfEdit.bSaveClick(Sender: TObject);
var
  buf: string;
begin

    if ePassword.Text = '' then
      begin
        Application.MessageBox('Не введен пароль!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
        ePassword.SetFocus;
        exit;
      end;

    if eRole.Text = '' then
      begin
        Application.MessageBox('Не введена роль!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
        eRole.SetFocus;
        exit;
      end;

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

      if Mode = 'Edit' then
      begin
        with fAuto.SQLQ do
        begin
        Close;
        SQL.Text := 'update users set role=:R, surname=:S, name=:N, patronymic=:P, birthdate=:B, gender=:G, edit_emp_ability=:EEA, edit_book_ability=:EBA, active_profile=:AF where login=:L';
        ParamByName('R').AsString := eRole.Text;
        ParamByName('S').AsString := eSurname.Text;
        ParamByName('N').AsString := eName.Text;
        ParamByName('P').AsString := ePatronymic.Text;
        ParamByName('B').AsString := eBirthdate.Text;
        ParamByName('G').AsString := eGender.Text;
        ParamByName('EEA').AsBoolean := eEEA.Checked;
        ParamByName('EBA').AsBoolean := eEBA.Checked;
        ParamByName('AF').AsBoolean := eActiveProfile.Checked;
        ParamByName('L').AsString := eLogin.Text;
        ExecSQL;
        end;
        fAuto.SQLTransaction.Commit;
        fAuto.SQLQ.Close;
        fTable.SG.Cells[2,fTable.SG.Row] := eRole.Text;
        fTable.SG.Cells[3,fTable.SG.Row] := eSurname.Text;
        fTable.SG.Cells[4,fTable.SG.Row] := eName.Text;
        fTable.SG.Cells[5,fTable.SG.Row] := ePatronymic.Text;
        fTable.SG.Cells[6,fTable.SG.Row] := eBirthdate.Text;
        fTable.SG.Cells[7,fTable.SG.Row] := eGender.Text;
        if eEEA.Checked then
          buf := 'Да'
        else
          buf := 'Нет';
        fTable.SG.Cells[8,fTable.SG.Row] := buf;
        if eEBA.Checked then
          buf := 'Да'
        else
          buf := 'Нет';
        fTable.SG.Cells[9,fTable.SG.Row] := buf;
        if eActiveProfile.Checked then
          buf := 'Да'
        else
          buf := 'Нет';
        fTable.SG.Cells[10,fTable.SG.Row] := buf;
      end;

      if Mode = 'Add' then
      begin
        if UTF8Length(ePassword.Text) < 8 then
        begin
          Application.MessageBox('Пароль не может быть меньше 8 символов!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
          ePassword.SetFocus;
          exit;
        end;

        with fAuto.SQLQ do
        begin
        Close;
        SQL.Text := 'insert into users values(:L, :PW, :R, :EEA, :EBA, :S, :N, :P, :B, :G, :AP)';
        ParamByName('L').AsString := eLogin.Text;
        ParamByName('PW').AsString := ePassword.Text;
        ParamByName('R').AsString := eRole.Text;
        ParamByName('EEA').AsBoolean := eEEA.Checked;
        ParamByName('EBA').AsBoolean := eEBA.Checked;
        ParamByName('S').AsString := eSurname.Text;
        ParamByName('N').AsString := eName.Text;
        ParamByName('P').AsString := ePatronymic.Text;
        ParamByName('B').AsString := eBirthdate.Text;
        ParamByName('G').AsString := eGender.Text;
        ParamByName('AP').AsBoolean := eActiveProfile.Checked;
        ExecSQL;
        end;
        fAuto.SQLTransaction.Commit;
        fAuto.SQLQ.Close;

        fTable.SG.RowCount := fTable.SG.RowCount + 1;
        fTable.SG.Cells[0, fTable.SG.RowCount - 1] := eLogin.Text;
        fTable.SG.Cells[1, fTable.SG.RowCount - 1] := '****';
        fTable.SG.Cells[2, fTable.SG.RowCount - 1] := eRole.Text;
        fTable.SG.Cells[3, fTable.SG.RowCount - 1] := eSurname.Text;
        fTable.SG.Cells[4, fTable.SG.RowCount - 1] := eName.Text;
        fTable.SG.Cells[5, fTable.SG.RowCount - 1] := ePatronymic.Text;
        fTable.SG.Cells[6, fTable.SG.RowCount - 1] := eBirthdate.Text;
        fTable.SG.Cells[7, fTable.SG.RowCount - 1] := eGender.Text;
        if eEEA.Checked then
          buf := 'Да'
        else
          buf := 'Нет';
        fTable.SG.Cells[8, fTable.SG.RowCount - 1] := buf;
        if eEBA.Checked then
          buf := 'Да'
        else
          buf := 'Нет';
        fTable.SG.Cells[9, fTable.SG.RowCount - 1] := buf;
        if eActiveProfile.Checked then
          buf := 'Да'
        else
          buf := 'Нет';
        fTable.SG.Cells[10, fTable.SG.RowCount - 1] := buf;
      end;

      Saved := True;
      fEdit.Close;
end;

procedure TfEdit.eLoginUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
begin
  if UTF8Length(TEdit(Sender).Text) < 30 then
    case UTF8Key of
    '0'..'9': UTF8Key := UTF8Key;
    'a'..'z': UTF8Key := UTF8Key;
    'A'..'Z': UTF8Key := UTF8Key;
    #95: UTF8Key := UTF8Key; // нижнее подчеркивание
    #8: UTF8Key := UTF8Key; //BackSpace
    else UTF8Key := #0;
    end
  else
    case UTF8Key of
    #8: UTF8Key := UTF8Key;
    else UTF8Key := #0;
    end;
end;

procedure TfEdit.ePasswordUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
begin
  if UTF8Length(TEdit(Sender).Text) < 30 then
    case UTF8Key of
    'а'..'я': UTF8Key := UTF8Key;
    'А'..'Я': UTF8Key := UTF8Key;
    'ё': UTF8Key := UTF8Key;
    'Ё': UTF8Key := UTF8Key;
    #32..#126: UTF8Key := UTF8Key;
    #8: UTF8Key := UTF8Key; //BackSpace
    else UTF8Key := #0;
    end
  else
    case UTF8Key of
    #8: UTF8Key := UTF8Key;
    else UTF8Key := #0;
    end
end;

procedure TfEdit.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Label1.Enabled := False;
  Label2.Enabled := False;
  Label3.Enabled := True;
  Label4.Enabled := True;
  Label5.Enabled := True;
  Label6.Enabled := True;
  Label7.Enabled := True;
  Label8.Enabled := True;
  Label9.Enabled := True;
  Label10.Enabled := True;
  Label11.Enabled := True;

  eLogin.Enabled := False;
  ePassword.Enabled := False;
  eRole.Enabled := True;
  eSurname.Enabled := True;
  eName.Enabled := True;
  ePatronymic.Enabled := True;
  eBirthdate.Enabled := True;
  eGender.Enabled := True;
  eEEA.Enabled := True;
  eEBA.Enabled := True;
  eActiveProfile.Enabled := True;

  iCheck.Visible := False;
  iSuccess.Visible := False;
  iEdit.Visible := True;
  lChange.Visible := False;
  iShow.Visible := False;
  iHide.Visible := False;
  bSave.Enabled := True;

  ePassword.PasswordChar := #42; // #42 - звездочка
end;

procedure TfEdit.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Saved then
  begin
    CanClose := True;
    exit;
  end;

  if Mode = 'Edit' then
  begin
    fAuto.SQLQ.Close;
    fAuto.SQLQ.SQL.Text := 'select * from users where login = :L';
    fAuto.SQLQ.ParamByName('L').AsString := eLogin.Text;
    fAuto.SQLQ.Open;
    if (fAuto.SQLQ.FieldByName('role').AsString<>eRole.Text) or
    (fAuto.SQLQ.FieldByName('surname').AsString<>eSurname.Text) or (fAuto.SQLQ.FieldByName('name').AsString<>eName.Text) or
    (fAuto.SQLQ.FieldByName('patronymic').AsString<>ePatronymic.Text) or (fAuto.SQLQ.FieldByName('birthdate').AsString<>eBirthdate.Text) or
    (fAuto.SQLQ.FieldByName('gender').AsString<>eGender.Text) or (fAuto.SQLQ.FieldByName('edit_emp_ability').AsBoolean<>eEEA.Checked) or
    (fAuto.SQLQ.FieldByName('edit_book_ability').AsBoolean<>eEBA.Checked) or
    (fAuto.SQLQ.FieldByName('active_profile').AsBoolean<>eActiveProfile.Checked) then
    begin
      fSave.Label1.Top := 32;
      fSave.Label1.Left := 50;
      fSave.Caption := 'Выход';
      fSave.Label1.Caption := 'Вы дейстительно хотите выйти,' + #13 + 'не сохранив данные?';
      fEdit.ModalResult := mrNone;
      fSave.ShowModal;
      if (fEdit.ModalResult = mrNo) or (fEdit.ModalResult = mrNone) then
      begin
        CanClose := False;
        exit;
      end
      else
        CanClose := True;
    end
    else
      CanClose := True;
  end;

  if Mode = 'Add' then
  begin
    if not eLogin.Enabled then
    begin
      fSave.Label1.Top := 32;
      fSave.Label1.Left := 50;
      fSave.Caption := 'Выход';
      fSave.Label1.Caption := 'Вы дейстительно хотите выйти,' + #13 + 'не сохранив данные?';
      fEdit.ModalResult := mrNone;
      fSave.ShowModal;
      if (fEdit.ModalResult = mrNo) or (fEdit.ModalResult = mrNone) then
      begin
        CanClose := False;
        exit;
      end
      else
        CanClose := True;
    end
    else
      CanClose := True;
  end;
end;

procedure TfEdit.FormHide(Sender: TObject);
begin
  lChange.Visible := False;
end;

end.

