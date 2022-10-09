unit books;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
  Buttons, LCLType;

type

  { TfTable }

  TfTable = class(TForm)
    Panel1: TPanel;
    bAdd: TSpeedButton;
    bEdit: TSpeedButton;
    SG: TStringGrid;
    procedure bAddClick(Sender: TObject);
    procedure bEditClick(Sender: TObject);
    procedure bSortClick(Sender: TObject);
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
  fTable: TfTable;
  Rows: integer; // определяет количество строк в таблице при показе формы
  Focus: integer; // указывает, на что установить фокус в fEdit
  Mode: string; // указывает, какой режим окна fEdit выбрать: для добавления или для редактирования
  ISBN, BookName, Author, OriginalName, OriginalLanguage, PublisherName, Translator,
  IssueYear, Comment: string;
  PageCount, BookCount, BookPrice: integer;   // используются для проверки изменения данных в форме fEditBook
  OFRR: boolean;
  Surname, ReaderName, Patronymic, Birthdate, Address, PhoneNumber, Email: string;
  Saved: boolean; // проверяем, сохранены ли данные. Используется в формах редактирования

implementation
uses
  Autorisation, Edit, Sort, Main, EditBook, EditReader;

{$R *.lfm}

{ TfTable }

procedure TfTable.bEditClick(Sender: TObject);
var
  buf: boolean;
begin
  if SG.RowCount = 1 then exit;

  if MainFrom = 'Workers' then
  begin
    fEdit.eLogin.Text := SG.Cells[0, SG.Row];
    fEdit.ePassword.Text := '****';
    fEdit.eRole.Text := SG.Cells[2, SG.Row];
    fEdit.eSurname.Text := SG.Cells[3, SG.Row];
    fEdit.eName.Text := SG.Cells[4, SG.Row];
    fEdit.ePatronymic.Text := SG.Cells[5, SG.Row];
    fEdit.eBirthdate.Text := SG.Cells[6, SG.Row];
    fEdit.eGender.Text := SG.Cells[7, SG.Row];
    if SG.Cells[8, SG.Row] = 'Да' then
      buf := True
    else
      buf := False;
    fEdit.eEEA.Checked := buf;
    if SG.Cells[9, SG.Row] = 'Да' then
      buf := True
    else
      buf := False;
    fEdit.eEBA.Checked := buf;
    if SG.Cells[10, SG.Row] = 'Да' then
      buf := True
    else
      buf := False;
    fEdit.eActiveProfile.Checked := buf;

    Focus := SG.Col;
    Mode := 'Edit';
    fEdit.Caption := 'Редактировать';
    fEdit.ShowModal;
  end;

  if MainFrom = 'Books' then
  begin
    with fEditBook do
    begin
    bSave.Enabled := True;

    eIndex.Text := SG.Cells[0, SG.Row];
    eISBN.Text := SG.Cells[1, SG.Row];
    eBookName.Text := SG.Cells[2, SG.Row];
    eAuthor.Text := SG.Cells[3, SG.Row];
    eOriginalName.Text := SG.Cells[4, SG.Row];
    eOriginalLanguage.Text := SG.Cells[5, SG.Row];
    ePublisherName.Text := SG.Cells[6, SG.Row];
    eTranslator.Text := SG.Cells[7, SG.Row];
    eIssueYear.Text := SG.Cells[8, SG.Row];
    ePageCount.Value := strtoint(SG.Cells[9, SG.Row]);
    eBookCount.Value := strtoint(SG.Cells[10, SG.Row]);
    eBookPrice.Value := strtoint(SG.Cells[11, SG.Row]);
    eComment.Lines.Text := SG.Cells[13, SG.Row];

    if EditBookAbility = False then
      bSave.Enabled := False;
    end;

    ISBN := SG.Cells[1, SG.Row];
    BookName := SG.Cells[2, SG.Row];
    Author := SG.Cells[3, SG.Row];
    OriginalName := SG.Cells[4, SG.Row];
    OriginalLanguage := SG.Cells[5, SG.Row];
    PublisherName := SG.Cells[6, SG.Row];
    Translator := SG.Cells[7, SG.Row];
    IssueYear := SG.Cells[8, SG.Row];
    PageCount := strtoint(SG.Cells[9, SG.Row]);
    BookCount := strtoint(SG.Cells[10, SG.Row]);
    BookPrice := strtoint(SG.Cells[11, SG.Row]);
    Comment:= SG.Cells[13, SG.Row];

    if SG.Cells[12, SG.Row] = 'Да' then
      buf := True
    else
      buf := False;
    fEditBook.eOFRR.Checked := buf;

    OFRR := buf;

    Focus := SG.Col;
    Mode := 'Edit';
    fEditBook.Caption := 'Редактировать';
    fEditBook.ShowModal;
  end;

  if MainFrom = 'Readers' then
  begin
    with fEditReader do
    begin
      bSave.Enabled := True;

      eID.Text := SG.Cells[0, SG.Row];
      eSurname.Text := SG.Cells[1, SG.Row];
      eName.Text := SG.Cells[2, SG.Row];
      ePatronymic.Text := SG.Cells[3, SG.Row];
      eBirthdate.Text := SG.Cells[4, SG.Row];
      eAddress.Text := SG.Cells[5, SG.Row];
      ePhoneNumber.Text := SG.Cells[6, SG.Row];
      eEmail.Text := SG.Cells[7, SG.Row];
      eComment.Text := SG.Cells[8, SG.Row];

      if EditBookAbility = False then
        bSave.Enabled := False;
    end;

    Surname := SG.Cells[1, SG.Row];
    ReaderName := SG.Cells[2, SG.Row];
    Patronymic := SG.Cells[3, SG.Row];
    Birthdate := SG.Cells[4, SG.Row];
    Address := SG.Cells[5, SG.Row];
    PhoneNumber := SG.Cells[6, SG.Row];
    Email := SG.Cells[7, SG.Row];
    Comment := SG.Cells[8, SG.Row];

    Focus := SG.Col;
    Mode := 'Edit';
    fEditReader.Caption := 'Редактировать';
    fEditReader.ShowModal;
  end;
end;

procedure TfTable.bSortClick(Sender: TObject);
begin
  if SG.RowCount >1 then
    fSort.ShowModal;
end;

procedure TfTable.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  fMain.Show;
end;

procedure TfTable.bAddClick(Sender: TObject);
begin
  if (MainFrom <> 'Workers') and (EditBookAbility = False) then
  begin
    Application.MessageBox('Нельзя добавить новую запись!', 'Стоит ограничение', MB_ICONERROR + MB_OK);
    exit;
  end;

  if MainFrom = 'Workers' then
  begin
    with fEdit do
    begin
    Label1.Enabled := True;
    Label2.Enabled := False;
    Label3.Enabled := False;
    Label4.Enabled := False;
    Label5.Enabled := False;
    Label6.Enabled := False;
    Label7.Enabled := False;
    Label8.Enabled := False;
    Label9.Enabled := False;
    Label10.Enabled := False;
    Label11.Enabled := False;

    eLogin.Enabled := True;
    ePassword.Enabled := False;
    eRole.Enabled := False;
    eSurname.Enabled := False;
    eName.Enabled := False;
    ePatronymic.Enabled := False;
    eBirthdate.Enabled := False;
    eGender.Enabled := False;
    eEEA.Enabled := False;
    eEBA.Enabled := False;
    eActiveProfile.Enabled := False;

    iCheck.Visible := True;
    iSuccess.Visible := False;
    iEdit.Visible := False;
    lChange.Visible := False;
    iShow.Visible := True;
    iHide.Visible := False;
    iShow.Enabled := False;
    iHide.Enabled := True;
    bSave.Enabled := False;

    eLogin.Text := '';
    ePassword.Text := '';
    eRole.Text := '';
    eSurname.Text := '';
    eName.Text := '';
    ePatronymic.Text := '';
    eBirthdate.Text := '';
    eGender.Text := 'Мужской';
    eEEA.Checked := False;
    eEBA.Checked := True;
    eActiveProfile.Checked := True;
    end;

    Mode := 'Add';
    fEdit.Caption := 'Добавить';
    fEdit.ShowModal;
  end;

  if MainFrom = 'Books' then
  begin
    with fEditBook do
    begin
      eIndex.Text := '';
      eISBN.Text := '';
      eBookName.Text := '';
      eAuthor.Text := '';
      eOriginalName.Text := '';
      eOriginalLanguage.Text := '';
      ePublisherName.Text := '';
      eTranslator.Text := '';
      eIssueYear.Text := '';
      eBookPrice.Value := 500;
      ePageCount.Value := 1;
      eBookCount.Value := 1;
      eOFRR.Checked := False;
      eComment.Lines.Text := '';
    end;

    Mode := 'Add';
    fEditBook.Caption := 'Добавить';
    fEditBook.ShowModal;
  end;

  if MainFrom = 'Readers' then
  begin
    with fEditReader do
    begin
      eID.Text := '';
      eSurname.Text := '';
      eName.Text := '';
      ePatronymic.Text := '';
      eBirthdate.Text := '';
      eAddress.Text := '';
      ePhoneNumber.Text := '';
      eEmail.Text := '';
      eComment.Text := '';
    end;

    Mode := 'Add';
    fEditReader.Caption := 'Добавить';
    fEditReader.ShowModal;
  end;
end;

procedure TfTable.FormShow(Sender: TObject);
var
  buf: String;
begin
  if MainFrom = 'Workers' then
  begin
    fTable.Caption := 'Сотрудники';
    SG.Clear;
    SG.ColCount := 11;
    SG.RowCount := 1;
    Rows := 1;

    SG.Cells[0,0] := 'Логин';
    SG.Cells[1,0] := 'Пароль';
    SG.Cells[2,0] := 'Роль';
    SG.Cells[3,0] := 'Фамилия';
    SG.Cells[4,0] := 'Имя';
    SG.Cells[5,0] := 'Отчество';
    SG.Cells[6,0] := 'Дата рождения';
    SG.Cells[7,0] := 'Пол';
    SG.Cells[8,0] := 'Возможность редактирования сотрудников';
    SG.Cells[9,0] := 'Возможность редактирования книг';
    SG.Cells[10,0] := 'Профиль активен?';

    SG.ColWidths[6] := 130;
    SG.ColWidths[8] := 320;
    SG.ColWidths[9] := 290;
    SG.ColWidths[10] := 150;

    fAuto.SQLQ.Close;
    fAuto.SQLQ.SQL.Text := 'select * from users';
    fAuto.SQLQ.Open;
    fAuto.SQLQ.First;
    while not fAuto.SQLQ.EOF do
    begin
      inc(Rows);
      SG.RowCount := Rows;
      SG.Cells[0, Rows-1] := fAuto.SQLQ.FieldByName('login').AsString;
      SG.Cells[1, Rows-1] := '****';
      SG.Cells[2, Rows-1] := fAuto.SQLQ.FieldByName('role').AsString;
      SG.Cells[3, Rows-1] := fAuto.SQLQ.FieldByName('surname').AsString;
      SG.Cells[4, Rows-1] := fAuto.SQLQ.FieldByName('name').AsString;
      SG.Cells[5, Rows-1] := fAuto.SQLQ.FieldByName('patronymic').AsString;
      SG.Cells[6, Rows-1] := fAuto.SQLQ.FieldByName('birthdate').AsString;
      SG.Cells[7, Rows-1] := fAuto.SQLQ.FieldByName('gender').AsString;
      if fAuto.SQLQ.FieldByName('edit_emp_ability').AsBoolean = True then
        buf := 'Да'
      else
        buf := 'Нет';
      SG.Cells[8, Rows-1] := buf;
      if fAuto.SQLQ.FieldByName('edit_book_ability').AsBoolean = True then
        buf := 'Да'
      else
        buf := 'Нет';
      SG.Cells[9, Rows-1] := buf;
      if fAuto.SQLQ.FieldByName('active_profile').AsBoolean = True then
        buf := 'Да'
      else
        buf := 'Нет';
      SG.Cells[10, Rows-1] := buf;
      fAuto.SQLQ.Next;
    end;
  end;

  if MainFrom = 'Books' then
  begin
    fTable.Caption := 'Книги';
    SG.Clear;
    SG.ColCount := 14;
    SG.RowCount := 1;
    Rows := 1;

    SG.Cells[0,0] := 'Номер';
    SG.Cells[1,0] := 'ISBN';
    SG.Cells[2,0] := 'Название книги';
    SG.Cells[3,0] := 'Автор';
    SG.Cells[4,0] := 'Оригинальное название книги';
    SG.Cells[5,0] := 'Язык книги';
    SG.Cells[6,0] := 'Название издательства';
    SG.Cells[7,0] := 'Переводчик';
    SG.Cells[8,0] := 'Год выпуска';
    SG.Cells[9,0] := 'Количество страниц';
    SG.Cells[10,0] := 'Количество книг';
    SG.Cells[11,0] := 'Цена книги';
    SG.Cells[12,0] := 'Только для читательского зала?';
    SG.Cells[13,0] := 'Комментарий';

    SG.ColWidths[4] := 240;
    SG.ColWidths[6] := 200;
    SG.ColWidths[9] := 180;
    SG.ColWidths[12] := 240;

    fAuto.SQLQ.Close;
    fAuto.SQLQ.SQL.Text := 'select * from books';
    fAuto.SQLQ.Open;
    fAuto.SQLQ.First;
    while not fAuto.SQLQ.EOF do
    begin
      inc(Rows);
      SG.RowCount := Rows;
      SG.Cells[0, Rows-1] := fAuto.SQLQ.FieldByName('id').AsString;
      SG.Cells[1, Rows-1] := fAuto.SQLQ.FieldByName('ISBN').AsString;
      SG.Cells[2, Rows-1] := fAuto.SQLQ.FieldByName('book_name').AsString;
      SG.Cells[3, Rows-1] := fAuto.SQLQ.FieldByName('author').AsString;
      SG.Cells[4, Rows-1] := fAuto.SQLQ.FieldByName('original_name').AsString;
      SG.Cells[5, Rows-1] := fAuto.SQLQ.FieldByName('original_language').AsString;
      SG.Cells[6, Rows-1] := fAuto.SQLQ.FieldByName('publisher_name').AsString;
      SG.Cells[7, Rows-1] := fAuto.SQLQ.FieldByName('translator').AsString;
      SG.Cells[8, Rows-1] := fAuto.SQLQ.FieldByName('issue_year').AsString;
      SG.Cells[9, Rows-1] := fAuto.SQLQ.FieldByName('page_count').AsString;
      SG.Cells[10, Rows-1] := fAuto.SQLQ.FieldByName('book_count').AsString;
      SG.Cells[11, Rows-1] := fAuto.SQLQ.FieldByName('book_price').AsString;
      if fAuto.SQLQ.FieldByName('only_for_reading_room').AsBoolean = True then
        buf := 'Да'
      else
        buf := 'Нет';
      SG.Cells[12, Rows-1] := buf;
      SG.Cells[13, Rows-1] := fAuto.SQLQ.FieldByName('comment').AsString;

      fAuto.SQLQ.Next;
    end;
    fAuto.SQLQ.Last;
  end;

  if MainFrom = 'Readers' then
  begin
    fTable.Caption := 'Читатели';
    SG.Clear;
    SG.ColCount := 9;
    SG.RowCount := 1;
    Rows := 1;

    SG.Cells[0,0] := 'Номер';
    SG.Cells[1,0] := 'Фамилия';
    SG.Cells[2,0] := 'Имя';
    SG.Cells[3,0] := 'Отчество';
    SG.Cells[4,0] := 'Дата рождения';
    SG.Cells[5,0] := 'Адрес проживания';
    SG.Cells[6,0] := 'Номер телефона';
    SG.Cells[7,0] := 'e-mail';
    SG.Cells[8,0] := 'Комментарий';

    SG.ColWidths[5] := 150;

    fAuto.SQLQ.Close;
    fAuto.SQLQ.SQL.Text := 'select * from readers';
    fAuto.SQLQ.Open;
    fAuto.SQLQ.First;
    while not fAuto.SQLQ.EOF do
    begin
      inc(Rows);
      SG.RowCount := Rows;
      SG.Cells[0, Rows-1] := fAuto.SQLQ.FieldByName('id').AsString;
      SG.Cells[1, Rows-1] := fAuto.SQLQ.FieldByName('surname').AsString;
      SG.Cells[2, Rows-1] := fAuto.SQLQ.FieldByName('name').AsString;
      SG.Cells[3, Rows-1] := fAuto.SQLQ.FieldByName('patronymic').AsString;
      SG.Cells[4, Rows-1] := fAuto.SQLQ.FieldByName('birthdate').AsString;
      SG.Cells[5, Rows-1] := fAuto.SQLQ.FieldByName('address').AsString;
      SG.Cells[6, Rows-1] := fAuto.SQLQ.FieldByName('phone_number').AsString;
      SG.Cells[7, Rows-1] := fAuto.SQLQ.FieldByName('email').AsString;
      SG.Cells[8, Rows-1] := fAuto.SQLQ.FieldByName('comment').AsString;

      fAuto.SQLQ.Next;
    end;

    fAuto.SQLQ.Last;
  end;

  fAuto.SQLQ.Close;
end;

procedure TfTable.SGCompareCells(Sender: TObject; ACol, ARow, BCol,
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

procedure TfTable.SGPrepareCanvas(sender: TObject; aCol, aRow: Integer;
  aState: TGridDrawState);
var MyTextStyle: TTextStyle;
begin
  MyTextStyle := SG.Canvas.TextStyle;
  MyTextStyle.Alignment := taCenter; // в данном случае все ячейки будут выровнены по центру
  SG.Canvas.TextStyle := MyTextStyle;
end;

end.

