unit changepassword;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls, LCLType, LazUTF8;

type

  { TfChangePass }

  TfChangePass = class(TForm)
    bSave: TButton;
    eOld: TEdit;
    eNew: TEdit;
    eNewAgain: TEdit;
    iHide1: TImage;
    iHide2: TImage;
    iSuccess: TImage;
    iShow1: TImage;
    iShow2: TImage;
    iCheck: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure bSaveClick(Sender: TObject);
    procedure eNewUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
    procedure iCheckClick(Sender: TObject);
    procedure iHide1Click(Sender: TObject);
    procedure iHide2Click(Sender: TObject);
    procedure iShow1Click(Sender: TObject);
    procedure iShow2Click(Sender: TObject);
  private

  public

  end;

var
  fChangePass: TfChangePass;
  Change: boolean; // изменен ли пароль. Если True, то изменен

implementation
uses
  Autorisation, Profile, Save, Edit;

{$R *.lfm}

{ TfChangePass }

procedure TfChangePass.iCheckClick(Sender: TObject);
begin
  if eOld.Text = '' then
  begin
    if From = 'Profile' then
      Application.MessageBox('Введите текущий пароль!', 'Ошибка', MB_ICONERROR + MB_OK);
    if From = 'Edit' then
      Application.MessageBox('Введите ВАШ пароль!', 'Ошибка', MB_ICONERROR + MB_OK);
    eOld.SetFocus;
    exit;
  end;

  fAuto.SQLQ.Close;
  fAuto.SQLQ.SQL.Text := 'select password from users where login = :L';
  fAuto.SQLQ.ParamByName('L').AsString := Login;
  fAuto.SQLQ.Open;

  if eOld.Text = fAuto.SQLQ.FieldByName('password').AsString then
  begin
    Application.MessageBox('Правильный пароль!', 'Успешно', MB_ICONINFORMATION + MB_OK);
    Label1.Enabled := False;
    eOld.Enabled := False;
    iSuccess.Enabled := False;
    Label2.Enabled := True;
    Label3.Enabled := True;
    eNew.Enabled := True;
    eNewAgain.Enabled := True;
    iShow1.Enabled := True;
    iShow2.Enabled := True;
    bSave.Enabled := True;
    eOld.Text := '';
    iCheck.Visible := False;
    iSuccess.Visible := True;
  end
  else
  begin
    Application.MessageBox('Неправильный пароль!', 'Ошибка', MB_ICONERROR + MB_OK);
    eOld.SetFocus;
    exit;
  end;

  fAuto.SQLQ.Close;
end;

procedure TfChangePass.bSaveClick(Sender: TObject);
begin
  if eNew.Text = '' then
  begin
    Application.MessageBox('Введите новый пароль!', 'Ошибка', MB_ICONERROR + MB_OK);
    eNew.SetFocus;
    exit;
  end;

  if UTF8Length(eNew.Text) < 8 then
  begin
    Application.MessageBox('Пароль не может быть меньше 8 символов!', 'Ошибка', MB_ICONERROR + MB_OK);
    eNew.SetFocus;
    exit;
  end;

  if eNewAgain.Text = '' then
  begin
    Application.MessageBox('Повторите новый пароль!', 'Ошибка', MB_ICONERROR + MB_OK);
    eNewAgain.SetFocus;
    exit;
  end;

  if eNew.Text = eNewAgain.Text then
  begin
    fAuto.SQLQ.Close;
    fAuto.SQLQ.SQL.Text := 'select password from users where login = :L';
    fAuto.SQLQ.ParamByName('L').AsString := Login;
    fAuto.SQLQ.Open;

    if eNew.Text = fAuto.SQLQ.FieldByName('password').AsString then
    begin
      Application.MessageBox('Новый пароль не может совпадать со старым!', 'Ошибка', MB_ICONERROR + MB_OK);
      exit;
    end;

    fAuto.SQLQ.Close;
    fAuto.SQLQ.SQL.Text := 'update users set password = :P where login = :L';
    fAuto.SQLQ.ParamByName('P').AsString := eNew.Text;
    if From = 'Profile' then
      fAuto.SQLQ.ParamByName('L').AsString := Login;
    if From = 'Edit' then
      fAuto.SQLQ.ParamByName('L').AsString := fEdit.eLogin.Text;
    fAuto.SQLQ.ExecSQL;
    fAuto.SQLTransaction.Commit;
    fAuto.SQLQ.Close;

    Application.MessageBox('Пароль успешно изменен!', 'Успешно', MB_ICONINFORMATION + MB_OK);
    if From = 'Profile' then
      fProfile.lChange.Visible := True;
    if From = 'Edit' then
      fEdit.lChange.Visible := True;
    Change := True;
    fChangePass.Close;
  end
  else
  begin
    Application.MessageBox('Пароли не совпадают!', 'Ошибка', MB_ICONERROR + MB_OK);
    eNewAgain.SetFocus;
    exit;
  end;
end;

procedure TfChangePass.eNewUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
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
    end;
end;

procedure TfChangePass.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  {if From = 'Profile' then
    fProfile.Show
  else
    fEdit.Show; }
end;

procedure TfChangePass.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if ((eNew.Text = '') and (eNewAgain.Text = '')) or Change then
  begin
    CanClose := True;
    Change := False;
    exit;
  end
  else
  begin
    fSave.Label1.Top := 32;
    fSave.Label1.Left := 50;
    fSave.Caption := 'Выход';
    fSave.Label1.Caption := 'Вы дейстительно хотите выйти,' + #13 + 'не сохранив данные?';
    fChangePass.ModalResult := mrNone;
    fSave.ShowModal;
    if (fChangePass.ModalResult = mrNo) or (fChangePass.ModalResult = mrNone) then
    begin
      CanClose := False;
      exit;
    end
    else
    CanClose := True;
  end;
end;

procedure TfChangePass.FormShow(Sender: TObject);
begin
  fChangePass.ModalResult := mrNone;
  Change := False;
  Label1.Enabled := True;
  Label2.Enabled := False;
  Label3.Enabled := False;
  eOld.Enabled := True;
  eNew.Enabled := False;
  eNewAgain.Enabled := False;
  eOld.Text := '';
  eNew.Text := '';
  eNewAgain.Text := '';
  eNew.PasswordChar := #42;
  eNewAgain.PasswordChar := #42;
  iSuccess.Visible := False;
  iCheck.Visible := True;
  iCheck.Enabled := True;
  iShow1.Enabled := False;
  iShow2.Enabled := False;
  iShow1.Visible := True;
  iShow2.Visible := True;
  iHide1.Visible := False;
  iHide2.Visible := False;
  bSave.Enabled := False;
end;

procedure TfChangePass.iHide1Click(Sender: TObject);
begin
  eNew.PasswordChar := #42; // #42 - звездочка
  iHide1.Visible := False;
  iShow1.Visible := True;
end;

procedure TfChangePass.iHide2Click(Sender: TObject);
begin
  eNewAgain.PasswordChar := #42;
  iHide2.Visible := False;
  iShow2.Visible := True;
end;

procedure TfChangePass.iShow1Click(Sender: TObject);
begin
  eNew.PasswordChar := #0;
  iShow1.Visible := False;
  iHide1.Visible := True;
end;

procedure TfChangePass.iShow2Click(Sender: TObject);
begin
  eNewAgain.PasswordChar := #0;
  iShow2.Visible := False;
  iHide2.Visible := True;
end;

end.

