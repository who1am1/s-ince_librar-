program science_library;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, autorisation, books, edit, main, profile, save, changepassword, sort,
  editbook, editreader, borrowbook, enterid, returnbook, confirmreturn
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfAuto, fAuto);
  Application.CreateForm(TfTable, fTable);
  Application.CreateForm(TfEdit, fEdit);
  Application.CreateForm(TfMain, fMain);
  Application.CreateForm(TfProfile, fProfile);
  Application.CreateForm(TfSave, fSave);
  Application.CreateForm(TfChangePass, fChangePass);
  Application.CreateForm(TfSort, fSort);
  Application.CreateForm(TfEditBook, fEditBook);
  Application.CreateForm(TfEditReader, fEditReader);
  Application.CreateForm(TfBorrowBook, fBorrowBook);
  Application.CreateForm(TfEnterID, fEnterID);
  Application.CreateForm(TfReturnBook, fReturnBook);
  Application.CreateForm(TfConfirmReturn, fConfirmReturn);
  Application.Run;
end.

