unit save;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Buttons;

type

  { TfSave }

  TfSave = class(TForm)
    bYes: TBitBtn;
    bNo: TBitBtn;
    Label1: TLabel;
    procedure bYesClick(Sender: TObject);
    procedure bNoClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  fSave: TfSave;

implementation
uses
  Profile, ChangePassword, Edit, EditBook, EditReader, ConfirmReturn;

{$R *.lfm}

{ TfSave }

procedure TfSave.bNoClick(Sender: TObject);
begin
  fProfile.ModalResult := mrNo;
  fChangePass.ModalResult := mrNo;
  fEdit.ModalResult := mrNo;
  fEditBook.ModalResult := mrNo;
  fEditReader.ModalResult := mrNo;
  fConfirmReturn.ModalResult := mrNo;
end;

procedure TfSave.FormShow(Sender: TObject);
begin
  bYes.SetFocus;
end;

procedure TfSave.bYesClick(Sender: TObject);
begin
  fProfile.ModalResult := mrYes;
  fChangePass.ModalResult := mrYes;
  fEdit.ModalResult := mrYes;
  fEditBook.ModalResult := mrYes;
  fEditReader.ModalResult := mrYes;
  fConfirmReturn.ModalResult := mrYes;
end;

end.

