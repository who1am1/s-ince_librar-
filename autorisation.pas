unit autorisation;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, DBGrids,
  DB, SQLite3Conn, SQLDB, LCLType;

type

  { TfAuto }

  TfAuto = class(TForm)
    bSend: TButton;
    eLogin: TEdit;
    ePassword: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    SQLConnection: TSQLite3Connection;
    SQLQ: TSQLQuery;
    SQLQ1: TSQLQuery;
    SQLTransaction: TSQLTransaction;
    procedure bSendClick(Sender: TObject);
  private

  public

  end;

var
  fAuto: TfAuto;
  Login: string; // сюда записывается логин вошедшего сотрудника
  EditEmpAbility: boolean; // храним возможность просмотра сотрудников
  EditBookAbility: boolean; // храним возможность редактирования книг и читателей

implementation
uses
  Main;

{$R *.lfm}

{ TfAuto }

procedure TfAuto.bSendClick(Sender: TObject);
begin
  try
    SQLQ.Close;
    SQLQ.SQL.Text := 'select * from users where login = :L and password = :P and active_profile =1';
    SQLQ.ParamByName('L').AsString := eLogin.Text;
    SQLQ.ParamByName('P').AsString := ePassword.Text;
    SQLQ.Open;
    if SQLQ.EOF then
      Application.MessageBox('Неправильный логин или пароль!', 'Ошибка входа', MB_ICONERROR + MB_OK)
    else
    begin
      Login := eLogin.Text;
      EditEmpAbility := SQLQ.FieldByName('edit_emp_ability').AsBoolean;
      EditBookAbility := SQLQ.FieldByName('edit_book_ability').AsBoolean;
      fAuto.Hide;
      fMain.Show;
    end;
    SQLQ.Close;
  except
    ShowMessage('Ошибка подключения к базе');
    exit;
  end;
end;

end.

