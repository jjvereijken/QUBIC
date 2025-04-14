UNIT QObjRoot;

(* this unit defines the mother of all objects used, i.e. "PositionObj" *)

INTERFACE

  USES

    QTypes, Qlines;

  TYPE

    PositionObj = OBJECT
      Pieces : BOARD;
      LastMove : FieldNumber;
      PROCEDURE Init;
      FUNCTION FieldEmpty(Field : FieldNumber) : BOOLEAN;
      PROCEDURE PutPiece(PieceColor : Color; Field : FieldNumber);
      FUNCTION GetPiece(Field : FieldNumber) : Color;
    END;

IMPLEMENTATION

  PROCEDURE PositionObj.Init;

  { remove all pieces from the board }

    BEGIN
      Pieces := EmptyBoard;
      LastMove := 0;
    END;

  FUNCTION PositionObj.FieldEmpty(Field : FieldNumber) : BOOLEAN;

  { is there a X of a O piece on the specified field ? }

    BEGIN
      FieldEmpty := (Pieces[Field] = none);
    END;

  PROCEDURE PositionObj.PutPiece(PieceColor : Color; Field : FieldNumber);

  { put a piece of the specified color on the specified field }

    BEGIN
      Pieces[Field] := PieceColor;
      LastMove := Field;
    END;

  FUNCTION PositionObj.GetPiece(Field : FieldNumber) : Color;

  { retrieve the piece on the specified field }

     BEGIN
        GetPiece := Pieces[Field];
     END;

END.
