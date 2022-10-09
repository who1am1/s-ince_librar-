unit editbook;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Spin, LCLType;

type

  { TfEditBook }

  TfEditBook = class(TForm)
    bSave: TButton;
    eAuthor: TEdit;
    eBookPrice: TSpinEdit;
    eOFRR: TCheckBox;
    eBookCount: TSpinEdit;
    ePublisherName: TEdit;
    eOriginalName: TEdit;
    eIndex: TEdit;
    eISBN: TEdit;
    eBookName: TEdit;
    eOriginalLanguage: TEdit;
    eTranslator: TEdit;
    eIssueYear: TEdit;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    ePageCount: TSpinEdit;
    eComment: TMemo;
    procedure bSaveClick(Sender: TObject);
    procedure eISBNUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  fEditBook: TfEditBook;

implementation
uses
  Books, Autorisation, Save;

{$R *.lfm}

{ TfEditBook }

procedure TfEditBook.FormShow(Sender: TObject);
begin
  Saved := False;
  fEditBook.ModalResult := mrNone;
  if Mode = 'Edit' then
    case Focus of
    0..1: eISBN.SetFocus;
    2: eBookName.SetFocus;
    3: eAuthor.SetFocus;
    4: eOriginalName.SetFocus;
    5: eOriginalLanguage.SetFocus;
    6: ePublisherName.SetFocus;
    7: eTranslator.SetFocus;
    8: eIssueYear.SetFocus;
    9: ePageCount.SetFocus;
    10: eBookCount.SetFocus;
    11: eBookPrice.SetFocus;
    12: eOFRR.SetFocus;
    13: eComment.SetFocus;
    end;

  if Mode = 'Add' then
    eISBN.SetFocus;
end;

procedure TfEditBook.eISBNUTF8KeyPress(Sender: TObject; var UTF8Key: TUTF8Char);
begin
  case UTF8Key of
  '0'..'9': UTF8Key := UTF8Key;
  #45: UTF8Key := UTF8Key; // тире
  #8: UTF8Key := UTF8Key; //BackSpace
  else UTF8Key := #0;
  end;
end;

procedure TfEditBook.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
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
    if (ISBN<>eISBN.Text) or (BookName<>eBookName.Text) or (Author<>eAuthor.Text) or
    (OriginalName<>eOriginalName.Text) or (OriginalLanguage<>eOriginalLanguage.Text) or (PublisherName<>ePublisherName.Text) or
    (Translator<>eTranslator.Text) or (IssueYear<>eIssueYear.Text) or (PageCount<>ePageCount.Value) or
    (BookCount<>eBookCount.Value) or (BookPrice<>eBookPrice.Value) or (OFRR<>eOFRR.Checked) or
    (Comment<>eComment.Lines.Text) then
    begin
      fSave.Label1.Top := 32;
      fSave.Label1.Left := 50;
      fSave.Caption := 'Выход';
      fSave.Label1.Caption := 'Вы дейстительно хотите выйти,' + #13 + 'не сохранив данные?';
      fEditBook.ModalResult := mrNone;
      fSave.ShowModal;
      if (fEditBook.ModalResult = mrNo) or (fEditBook.ModalResult = mrNone) then
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
    if (eISBN.Text<>'') or (eBookName.Text<>'') or (eAuthor.Text<>'') or (eOriginalName.Text<>'') or (eOriginalLanguage.Text<>'') or
    (ePublisherName.Text<>'') or (eTranslator.Text<>'') or (eIssueYear.Text<>'') or (ePageCount.Value<>1) or (eBookCount.Value<>1) or
    (eBookPrice.Value<>500) or (eOFRR.Checked<>False) or (eComment.Lines.Text<>'') then
    begin
      fSave.Label1.Top := 32;
      fSave.Label1.Left := 50;
      fSave.Caption := 'Выход';
      fSave.Label1.Caption := 'Вы дейстительно хотите выйти,' + #13 + 'не сохранив данные?';
      fEditBook.ModalResult := mrNone;
      fSave.ShowModal;
      if (fEditBook.ModalResult = mrNo) or (fEditBook.ModalResult = mrNone) then
      begin
        CanClose := False;
        exit;
      end
      else
        CanClose := True;
    end;
  end;
end;

procedure TfEditBook.bSaveClick(Sender: TObject);
var
  buf: String;
begin
  if eBookName.Text = '' then
  begin
    Application.MessageBox('Не введено название книги!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eBookName.SetFocus;
    exit;
  end;

  if eAuthor.Text = '' then
  begin
    Application.MessageBox('Не введен автор!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eAuthor.SetFocus;
    exit;
  end;

  if eOriginalLanguage.Text = '' then
  begin
    Application.MessageBox('Не введен язык оригинала!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eOriginalLanguage.SetFocus;
    exit;
  end;

  if ePublisherName.Text = '' then
  begin
    Application.MessageBox('Не введено название издательства!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    ePublisherName.SetFocus;
    exit;
  end;

  if eIssueYear.Text = '' then
  begin
    Application.MessageBox('Не введен год выпуска!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eIssueYear.SetFocus;
    exit;
  end;

  if eIssueYear.Text[1] = '0' then
  begin
    Application.MessageBox('Неправильный формат года!', 'Ошибка ввода данных', MB_ICONERROR + MB_OK);
    eIssueYear.SetFocus;
    exit;
  end;

  if Mode = 'Edit' then
  begin
    with fAuto.SQLQ do
    begin
    Close;
    SQL.Clear;
    SQL.Text := 'update books set ISBN=:ISBN, book_name=:BN, author=:A, original_name=:ON, original_language=:OL, publisher_name=:PN, translator=:T, issue_year=:IY, page_count=:PC, book_count=:BC, book_price=:BP, only_for_reading_room=:OFRR, comment=:C where id=:I';
    ParamByName('ISBN').AsString := eISBN.Text;
    ParamByName('BN').AsString := eBookName.Text;
    ParamByName('A').AsString := eAuthor.Text;
    ParamByName('ON').AsString := eOriginalName.Text;
    ParamByName('OL').AsString := eOriginalLanguage.Text;
    ParamByName('PN').AsString := ePublisherName.Text;
    ParamByName('T').AsString := eTranslator.Text;
    ParamByName('IY').AsString := eIssueYear.Text;
    ParamByName('PC').AsInteger := ePageCount.Value;
    ParamByName('BC').AsInteger := eBookCount.Value;
    ParamByName('BP').AsInteger := eBookPrice.Value;
    ParamByName('OFRR').AsBoolean := eOFRR.Checked;
    ParamByName('C').AsString := eComment.Lines.Text;
    ParamByName('I').AsInteger := strtoint(eIndex.Text);
    ExecSQL;
    end;
    fAuto.SQLTransaction.Commit;
    fAuto.SQLQ.Close;

    with fTable.SG do
    begin
    Cells[1,Row] := eISBN.Text;
    Cells[2,Row] := eBookName.Text;
    Cells[3,Row] := eAuthor.Text;
    Cells[4,Row] := eOriginalName.Text;
    Cells[5,Row] := eOriginalLanguage.Text;
    Cells[6,Row] := ePublisherName.Text;
    Cells[7,Row] := eTranslator.Text;
    Cells[8,Row] := eIssueYear.Text;
    Cells[9,Row] := inttostr(ePageCount.Value);
    Cells[10,Row] := inttostr(eBookCount.Value);
    Cells[11,Row] := inttostr(eBookPrice.Value);
    end;
    if eOFRR.Checked then
      buf := 'Да'
    else
      buf := 'Нет';
    fTable.SG.Cells[12,fTable.SG.Row] := buf;
    fTable.SG.Cells[13,fTable.SG.Row] := eComment.Lines.Text;
  end;

  if Mode = 'Add' then
  begin
    with fAuto.SQLQ do
    begin
      Close;
      SQL.Clear;
      SQL.Text := 'insert into books(ISBN,book_name,author,original_name,original_language,publisher_name,translator,issue_year,page_count,book_count,book_price,only_for_reading_room,comment) values(:ISBN,:BN,:A,:ON,:OL,:PN,:T,:IY,:PC,:BC,:BP,:OFRR,:C)';
      ParamByName('ISBN').AsString := eISBN.Text;
      ParamByName('BN').AsString := eBookName.Text;
      ParamByName('A').AsString := eAuthor.Text;
      ParamByName('ON').AsString := eOriginalName.Text;
      ParamByName('OL').AsString := eOriginalLanguage.Text;
      ParamByName('PN').AsString := ePublisherName.Text;
      ParamByName('T').AsString := eTranslator.Text;
      ParamByName('IY').AsString := eIssueYear.Text;
      ParamByName('PC').AsInteger := ePageCount.Value;
      ParamByName('BC').AsInteger := eBookCount.Value;
      ParamByName('BP').AsInteger := eBookPrice.Value;
      ParamByName('OFRR').AsBoolean := eOFRR.Checked;
      ParamByName('C').AsString := eComment.Lines.Text;
      ExecSQL;
    end;
    fAuto.SQLTransaction.Commit;
    fAuto.SQLQ.Close;

    fAuto.SQLQ.SQL.Text := 'select MAX(id) from books';
    fAuto.SQLQ.Open;

    with fTable.SG do
    begin
      RowCount := RowCount + 1;

      Cells[0,RowCount - 1] := fAuto.SQLQ.FieldByName('MAX(id)').AsString;
      Cells[1,RowCount - 1] := eISBN.Text;
      Cells[2,RowCount - 1] := eBookName.Text;
      Cells[3,RowCount - 1] := eAuthor.Text;
      Cells[4,RowCount - 1] := eOriginalName.Text;
      Cells[5,RowCount - 1] := eOriginalLanguage.Text;
      Cells[6,RowCount - 1] := ePublisherName.Text;
      Cells[7,RowCount - 1] := eTranslator.Text;
      Cells[8,RowCount - 1] := eIssueYear.Text;
      Cells[9,RowCount - 1] := inttostr(ePageCount.Value);
      Cells[10,RowCount - 1] := inttostr(eBookCount.Value);
      Cells[11,RowCount - 1] := inttostr(eBookPrice.Value);
    end;
    if eOFRR.Checked then
      buf := 'Да'
    else
      buf := 'Нет';
    fTable.SG.Cells[12,fTable.SG.Row] := buf;
    fTable.SG.Cells[13,fTable.SG.Row] := eComment.Lines.Text;

    fAuto.SQLQ.Close;
  end;

  Saved := True;
  fEditBook.Close;
end;

end.

