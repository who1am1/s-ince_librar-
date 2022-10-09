unit returnbook;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, ExtCtrls, Grids,
  Buttons, StdCtrls;

type

  { TfReturnBook }

  TfReturnBook = class(TForm)
    bReturn: TSpeedButton;
    eReturned: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    SG: TStringGrid;
    procedure bReturnClick(Sender: TObject);
    procedure eReturnedChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure SGCompareCells(Sender: TObject; ACol, ARow, BCol, BRow: Integer;
      var Result: integer);
    procedure SGPrepareCanvas(sender: TObject; aCol, aRow: Integer;
      aState: TGridDrawState);
  private

  public

  end;

var
  fReturnBook: TfReturnBook;
  Rows: integer; // определяет количество строк в таблице при показе формы

implementation
uses
  Main, Autorisation, EnterID, ConfirmReturn;

{$R *.lfm}

{ TfReturnBook }

procedure TfReturnBook.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  fMain.Show;
end;

procedure TfReturnBook.bReturnClick(Sender: TObject);
var
  bbuf: boolean;
  buf: string;
begin
  if SG.RowCount = 1 then exit;

  with fConfirmReturn do
  begin
    eID.Text := SG.Cells[0,SG.Row];
    eBorrowDate.Text := SG.Cells[3,SG.Row];
    eReturnDate.Text := SG.Cells[4,SG.Row];
    if SG.Cells[5,SG.Row] = 'Да' then
      bbuf := True
    else
      bbuf := False;
    eRR.Checked := bbuf;
    eUser.Text := SG.Cells[6,SG.Row];
    with fAuto.SQLQ do
    begin
      Close;
      SQL.Text := 'select * from readers where id=:I';
      ParamByName('I').AsString := SG.Cells[1,SG.Row];
      Open;
      eReader.Clear;
      eReader.Lines.BeginUpdate;
      eReader.Lines.Add(FieldByName('id').AsString);
      buf := FieldByName('surname').AsString + ' ' + FieldByName('name').AsString + ' ' + FieldByName('patronymic').AsString;
      eReader.Lines.Add(buf);
      eReader.Lines.Add(FieldByName('birthdate').AsString);
      eReader.Lines.Add(FieldByName('address').AsString);
      buf := FieldByName('phone_number').AsString;
      if buf <> '' then
        eReader.Lines.Add(buf);
      buf := FieldByName('email').AsString;
      if buf <> '' then
        eReader.Lines.Add(buf);
      buf := FieldByName('comment').AsString;
      if buf <> '' then
        eReader.Lines.Add(buf);
      Close;
      eReader.Lines.EndUpdate;

      SQL.Text := 'select * from books where id=:I';
      ParamByName('I').AsString := copy(SG.Cells[2,SG.Row], 1, pos(' ', SG.Cells[2,SG.Row]) - 1);
      Open;
      eBook.Clear;
      with eBook.Lines do
      begin
        BeginUpdate;
        if FieldByName('only_for_reading_room').AsBoolean then
          begin
            buf := 'Только для читательского зала!';
            Add(buf);
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
      eBook.Lines.EndUpdate;
    end;
  end;

  fConfirmReturn.ShowModal;
end;

procedure TfReturnBook.eReturnedChange(Sender: TObject);
var
  buf: string;
  i: integer;
begin
  SG.Clear;
  SG.ColCount := 9;
  SG.RowCount := 1;
  Rows := 1;

  SG.Cells[0,0] := 'ID';
  SG.Cells[1,0] := 'Номер читателя';
  SG.Cells[2,0] := 'Номер и имя книги';
  SG.Cells[3,0] := 'Дата выдачи';
  SG.Cells[4,0] := 'Дата сдачи';
  SG.Cells[5,0] := 'Читательский зал';
  SG.Cells[6,0] := 'Кто выдал книгу';
  SG.Cells[7,0] := 'Книга возвращена';
  SG.Cells[8,0] := 'Возвращена вовремя';

  SG.ColWidths[0] := 50;
  SG.ColWidths[2] := 150;
  SG.ColWidths[7] := 150;
  SG.ColWidths[8] := 170;

  with fAuto.SQLQ do
  begin
    Close;
    if eReturned.Checked then
      SQL.Text := 'select * from borrow_history where reader=:R'
    else
      SQL.Text := 'select * from borrow_history where reader=:R and book_returned=0';
    ParamByName('R').AsInteger := ReaderID;
    Open;
    First;
    while not EOF do
    begin
      inc(Rows);
      SG.RowCount := Rows;
      SG.Cells[0, Rows-1] := FieldByName('id').AsString;
      SG.Cells[1, Rows-1] := FieldByName('reader').AsString;
      SG.Cells[2, Rows-1] := FieldByName('book').AsString;
      SG.Cells[3, Rows-1] := FieldByName('borrow_date').AsString;
      SG.Cells[4, Rows-1] := FieldByName('return_date').AsString;
      if FieldByName('reading_room').AsBoolean then
        buf := 'Да'
      else
        buf := 'Нет';
      SG.Cells[5, Rows-1] := buf;
      SG.Cells[6, Rows-1] := FieldByName('user').AsString;
      if FieldByName('book_returned').AsBoolean then
        buf := 'Да'
      else
        buf := 'Нет';
      SG.Cells[7, Rows-1] := buf;
      if FieldByName('returned_on_time').AsBoolean then
        buf := 'Да'
      else
        buf := 'Нет';
      SG.Cells[8, Rows-1] := buf;
      Next;
    end;
    Close;

    i := 1;
    while i < SG.RowCount do
    begin
      SQL.Text := 'select book_name from books where id=:I';
      ParamByName('I').AsString := SG.Cells[2, i];
      Open;
      SG.Cells[2,i] := SG.Cells[2,i] + ' | ' + FieldByName('book_name').AsString;
      Close;
      inc(i);
    end;
  end;
end;

procedure TfReturnBook.FormShow(Sender: TObject);
var
  buf: string;
  i: integer;
begin
  eReturned.Checked := False;

  SG.Clear;
  SG.ColCount := 9;
  SG.RowCount := 1;
  Rows := 1;

  SG.Cells[0,0] := 'ID';
  SG.Cells[1,0] := 'Номер читателя';
  SG.Cells[2,0] := 'Номер и имя книги';
  SG.Cells[3,0] := 'Дата выдачи';
  SG.Cells[4,0] := 'Дата сдачи';
  SG.Cells[5,0] := 'Читательский зал';
  SG.Cells[6,0] := 'Кто выдал книгу';
  SG.Cells[7,0] := 'Книга возвращена';
  SG.Cells[8,0] := 'Возвращена вовремя';

  SG.ColWidths[0] := 50;
  SG.ColWidths[2] := 150;
  SG.ColWidths[7] := 150;
  SG.ColWidths[8] := 170;

  with fAuto.SQLQ do
  begin
    Close;
    SQL.Text := 'select * from borrow_history where reader=:R and book_returned=0';
    ParamByName('R').AsInteger := ReaderID;
    Open;
    First;
    while not EOF do
    begin
      inc(Rows);
      SG.RowCount := Rows;
      SG.Cells[0, Rows-1] := FieldByName('id').AsString;
      SG.Cells[1, Rows-1] := FieldByName('reader').AsString;
      SG.Cells[2, Rows-1] := FieldByName('book').AsString;
      SG.Cells[3, Rows-1] := FieldByName('borrow_date').AsString;
      SG.Cells[4, Rows-1] := FieldByName('return_date').AsString;
      if FieldByName('reading_room').AsBoolean then
        buf := 'Да'
      else
        buf := 'Нет';
      SG.Cells[5, Rows-1] := buf;
      SG.Cells[6, Rows-1] := FieldByName('user').AsString;
      if FieldByName('book_returned').AsBoolean then
        buf := 'Да'
      else
        buf := 'Нет';
      SG.Cells[7, Rows-1] := buf;
      if FieldByName('returned_on_time').AsBoolean then
        buf := 'Да'
      else
        buf := 'Нет';
      SG.Cells[8, Rows-1] := buf;
      Next;
    end;
    Close;

    i := 1;
    while i < SG.RowCount do
    begin
      SQL.Text := 'select book_name from books where id=:I';
      ParamByName('I').AsString := SG.Cells[2, i];
      Open;
      SG.Cells[2,i] := SG.Cells[2,i] + ' | ' + FieldByName('book_name').AsString;
      Close;
      inc(i);
    end;

    SQL.Text := 'select surname,name,patronymic from readers where id=:I';
    ParamByName('I').AsInteger := ReaderID;
    Open;
    Label2.Caption := inttostr(ReaderID) + ' | ' + FieldByName('surname').AsString + ' ' + FieldByName('name').AsString + ' ' + FieldByName('patronymic').AsString;
    Close;
  end;
end;

procedure TfReturnBook.SGCompareCells(Sender: TObject; ACol, ARow, BCol,
  BRow: Integer; var Result: integer);
var
  n, buf: integer;
begin
  if pos('Дата',SG.Cells[ACol,0])<>0 then // если дата
    result := StrToIntDef(copy(SG.Cells[ACol,ARow],7,4)+copy(SG.Cells[ACol,ARow],4,2)+copy(SG.Cells[ACol,ARow],1,2),0)-StrToIntDef(copy(SG.Cells[BCol,BRow],7,4)+copy(SG.Cells[BCol,BRow],4,2)+copy(SG.Cells[BCol,BRow],1,2),0)
  else
    begin
      val(SG.Cells[ACol,ARow],n,buf);
      if buf = 0 then // если число (0 значит, что преобразовалось в целое число без ошибок)
        result := StrToIntDef(SG.Cells[ACol,ARow],0)-StrToIntDef(SG.Cells[BCol,BRow],0)
      else // если строка
        if SG.Cells[ACol,ARow] > SG.Cells[BCol,BRow] then
          result := 1
        else
          if SG.Cells[ACol,ARow] < SG.Cells[BCol,BRow] then
            result := -1
          else
            result := 0;
    end;
  if SG.SortOrder = soDescending then // если порядок по убыванию
    result := -result;
end;

procedure TfReturnBook.SGPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
var MyTextStyle: TTextStyle;
begin
  MyTextStyle := SG.Canvas.TextStyle;
  MyTextStyle.Alignment := taCenter; // в данном случае все ячейки будут выровнены по центру
  SG.Canvas.TextStyle := MyTextStyle;
end;

end.

