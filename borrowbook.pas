unit borrowbook;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, EditBtn, DateUtils, LCLType;

type

  { TfBorrowBook }

  TfBorrowBook = class(TForm)
    bSave: TButton;
    eBorrowDate: TDateEdit;
    eRR: TCheckBox;
    eReturnDate: TDateEdit;
    eReaderInfo: TMemo;
    eBookInfo: TMemo;
    eReader: TComboBox;
    eBook: TComboBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure bSaveClick(Sender: TObject);
    procedure eBookChange(Sender: TObject);
    procedure eRRChange(Sender: TObject);
    procedure eReaderChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  fBorrowBook: TfBorrowBook;

implementation
uses
  Autorisation;

{$R *.lfm}

{ TfBorrowBook }

procedure TfBorrowBook.FormShow(Sender: TObject);
var
  buf: string;
begin
  eReader.Items.Clear;
  eBook.Items.Clear;
  eReaderInfo.Text := '';
  eBookInfo.Text := '';

  with fAuto.SQLQ do
  begin
    Close;
    SQL.Text := 'select * from readers';
    Open;
    First;
    while not EOF do
    begin
      buf := FieldByName('id').AsString + ' ' + FieldByName('surname').AsString + ' ' + FieldByName('name').AsString;
      eReader.Items.Add(buf);
      Next;
    end;
    Close;

    SQL.Text := 'select * from books';
    Open;
    First;
    while not EOF do
    begin
      buf := FieldByName('id').AsString + ' ' + FieldByName('book_name').AsString + ' ' + FieldByName('author').AsString;
      eBook.Items.Add(buf);
      Next;
    end;
    Close;
  end;

  eBorrowDate.Text := DatetoStr(Now);
  eReturnDate.Text := DatetoStr(IncDay(Now, 30)); // прибавляем к дате 30 дней
end;

procedure TfBorrowBook.eReaderChange(Sender: TObject);
var
  buf: string;
begin
  with fAuto.SQLQ do
  begin
    Close;
    SQL.Text := 'select * from readers where id=:I';
    ParamByName('I').AsString := copy(eReader.Text, 1, pos(' ', eReader.Text) - 1);
    Open;
    First;
    eReaderInfo.Clear;
    eReaderInfo.Lines.BeginUpdate; // пишем, чтобы курсор после выполнения всего кода оставался в начале строки в TMemo
    eReaderInfo.Lines.Add(FieldByName('id').AsString);
    buf := FieldByName('surname').AsString + ' ' + FieldByName('name').AsString + ' ' + FieldByName('patronymic').AsString;
    eReaderInfo.Lines.Add(buf);
    eReaderInfo.Lines.Add(FieldByName('birthdate').AsString);
    eReaderInfo.Lines.Add(FieldByName('address').AsString);
    buf := FieldByName('phone_number').AsString;
    if buf <> '' then
      eReaderInfo.Lines.Add(buf);
    buf := FieldByName('email').AsString;
    if buf <> '' then
      eReaderInfo.Lines.Add(buf);
    buf := FieldByName('comment').AsString;
    if buf <> '' then
      eReaderInfo.Lines.Add(buf);
    Close;

    eReaderInfo.Lines.EndUpdate;
  end;
end;

procedure TfBorrowBook.eBookChange(Sender: TObject);
var
  buf: string;
begin
  with fAuto.SQLQ do
  begin
    Close;
    SQL.Text := 'select * from books where id=:I';
    ParamByName('I').AsString := copy(eBook.Text, 1, pos(' ', eBook.Text) - 1);
    Open;
    First;
    eBookInfo.Clear;
    with eBookInfo.Lines do
    begin
      BeginUpdate;
      if FieldByName('only_for_reading_room').AsBoolean then
      begin
        buf := 'Только для читательского зала!';
        Label4.Enabled := False;
        eRR.Enabled := False;
        eRR.Checked := True;
        eReturnDate.Text := DatetoStr(Now);
        Add(buf);
      end
      else
      begin
        Label4.Enabled := True;
        eRR.Enabled := True;
        eRR.Checked := False;
        eReturnDate.Text := DatetoStr(IncDay(Now, 30));
      end;
      Add('ID ' + FieldByName('id').AsString);
      Add('"' + FieldByName('book_name').AsString + '"');
      Add('Автор: ' + FieldByName('author').AsString);
      buf := FieldByName('ISBN').AsString;
      if buf <> '' then
        Add('ISBN ' + buf);
      buf := FieldByName('original_name').AsString;
      if buf <> '' then
        Add(buf);
      Add(FieldByName('original_language').AsString + ' язык');
      Add('Издательство "' + FieldByName('publisher_name').AsString + '"');
      buf := FieldByName('translator').AsString;
      if buf <> '' then
        Add('Переводчик: ' + buf);
      Add(FieldByName('issue_year').AsString + ' год');
      Add(FieldByName('page_count').AsString + ' страниц');
      Add(FieldByName('book_count').AsString + ' книг');
      Add(FieldByName('book_price').AsString + ' руб');

      buf := FieldByName('comment').AsString;
      if buf <> '' then
        Add(buf);
    end;
    Close;

    eBookInfo.Lines.EndUpdate;
  end;
end;

procedure TfBorrowBook.bSaveClick(Sender: TObject);
begin
  if eReader.Text = '' then
  begin
    Application.MessageBox('Выберите читателя!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eReader.SetFocus;
    exit;
  end;

  if eBook.Text = '' then
  begin
    Application.MessageBox('Выберите книгу!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eBook.SetFocus;
    exit;
  end;

  if eBorrowDate.Text = '  .  .    ' then
  begin
    Application.MessageBox('Введите дату выдачи книги!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eBorrowDate.SetFocus;
    exit;
  end;

  if eReturnDate.Text = '  .  .    ' then
  begin
    Application.MessageBox('Введите дату сдачи книги!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eReturnDate.SetFocus;
    exit;
  end;

  if (CompareDate(StrToDate(eReturnDate.Text), StrToDate(eBorrowDate.Text)) = -1) then
  begin
    Application.MessageBox('Дата сдачи не может быть раньше даты выдачи!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eReturnDate.SetFocus;
    exit;
  end;

  with fAuto.SQLQ do
  begin
    Close;
    SQL.Text := 'insert into borrow_history(reader,book,user,borrow_date,return_date,reading_room) values(:R,:B,:U,:BD,:RD,:RR)';
    ParamByName('R').AsString := copy(eReader.Text, 1, pos(' ', eReader.Text) - 1);
    ParamByName('B').AsString := copy(eBook.Text, 1, pos(' ', eBook.Text) - 1);
    ParamByName('U').AsString := Login;
    ParamByName('BD').AsString := eBorrowDate.Text;
    ParamByName('RD').AsString := eReturnDate.Text;
    ParamByName('RR').AsBoolean := eRR.Checked;
    ExecSQL;
  end;
  fAuto.SQLTransaction.Commit;
  fAuto.SQLQ.Close;

  Application.MessageBox('Книга успешно выдана!', 'Успешно', MB_ICONINFORMATION + MB_OK);
  fBorrowBook.Close;
end;

procedure TfBorrowBook.eRRChange(Sender: TObject);
begin
  if eRR.Checked then
    eReturnDate.Text := DatetoStr(Now)
  else
    eReturnDate.Text := DatetoStr(IncDay(Now, 30));
end;

end.

