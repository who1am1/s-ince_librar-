unit main;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, LCLType;

type

  { TfMain }

  TfMain = class(TForm)
    bBorrow: TButton;
    bReaders: TButton;
    bProfile: TButton;
    bReturn: TButton;
    bWorkers: TButton;
    procedure bBooksClick(Sender: TObject);
    procedure bBorrowClick(Sender: TObject);
    procedure bProfileClick(Sender: TObject);
    procedure bReadersClick(Sender: TObject);
    procedure bReturnClick(Sender: TObject);
    procedure bWorkersClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  fMain: TfMain;
  MainFrom: String; // используется в модуле Books, чтобы выводить информацию из нужных таблиц

implementation
uses
  Books, Profile, BorrowBook, EnterID, ReturnBook, Autorisation;

{$R *.lfm}

{ TfMain }

procedure TfMain.bBooksClick(Sender: TObject);
begin
  MainFrom := 'Books';
  fMain.Hide;
  fTable.Show;
end;

procedure TfMain.bBorrowClick(Sender: TObject);
begin
  fBorrowBook.Show;
end;

procedure TfMain.bProfileClick(Sender: TObject);
begin
  fMain.Hide;
  fProfile.Show;
end;

procedure TfMain.bReadersClick(Sender: TObject);
begin
  MainFrom := 'Readers';
  fMain.Hide;
  fTable.Show;
end;

procedure TfMain.bReturnClick(Sender: TObject);
begin
  fMain.ModalResult := mrNone;
  fEnterID.ShowModal;
  if fMain.ModalResult = mrYes then
  begin
    fMain.Hide;
    fReturnBook.Show;
  end;
end;

procedure TfMain.bWorkersClick(Sender: TObject);
begin
  if EditEmpAbility then
  begin
    MainFrom := 'Workers';
    fMain.Hide;
    fTable.Show;
  end
  else
    Application.MessageBox('Нет доступа!', 'Ошибка', MB_ICONERROR + MB_OK);
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  fMain.ModalResult := mrNone;
end;

end.

