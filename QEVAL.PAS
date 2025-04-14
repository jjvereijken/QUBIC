UNIT QEval;

(* this unit implements a automatic function evaluation object *)

INTERFACE

  USES

    QTypes, QLines, QDBase, QObjRoot,
    {$IFDEF WINDOWS} WinCrt {$ELSE} Crt {$ENDIF};

  TYPE

    AutoEvalPositionObj = OBJECT(PositionObj)

      k1, k2, k3, r1, r2, r3, lt : BYTE;
      Winner                     : Color;
      Evaluation                 : INTEGER;
      LinesK, LinesR             : LineCountArray;

      PROCEDURE Init;
      PROCEDURE PutPiece(PieceColor : Color; Field : FieldNumber);
      FUNCTION GameOver : BOOLEAN;
      FUNCTION WillDraw : BOOLEAN;

    END;

IMPLEMENTATION

  PROCEDURE AutoEvalPositionObj.Init;

    VAR

      l : LineNumber;

    BEGIN
      PositionObj.Init;
      k1 := 0; k2 := 0; k3 := 0;
      r1 := 0; r2 := 0; r3 := 0;
      lt := 0;
      Winner := None;
      FOR l := 0 TO 75 DO BEGIN
        LinesK[l] := 0;
        LinesR[l] := 0;
      END;
    END;

  PROCEDURE AutoEvalPositionObj.PutPiece(PieceColor : Color;
                                         Field : FieldNumber);

    { adapt k1,...,r3 with respect to newly put piece }

    VAR

      i          : BYTE;
      l          : LineNumber;
      MaxLine    : BYTE;
      a1, a2, a3 : ^BYTE; { point to k when Color = X, to r otherwise }
      b1, b2, b3 : ^BYTE; { point to r when Color = Y, to k otherwise }
      LinesA     : ^LineCountArray; { idem dito for LinesK }
      LinesB     : ^LineCountArray; { idem dito for LinesR }
      Max_i      : BYTE;

    BEGIN
      PositionObj.PutPiece(PieceColor, Field);
      IF PieceColor = X THEN BEGIN
        a1 := @k1; a2 := @k2; a3 := @k3;
        b1 := @r1; b2 := @r2; b3 := @r3;
        LinesA := @LinesK;
        LinesB := @LinesR
      END
      ELSE BEGIN
        a1 := @r1; a2 := @r2; a3 := @r3;
        b1 := @k1; b2 := @k2; b3 := @k3;
        LinesA := @LinesR;
        LinesB := @LinesK
      END;
      WITH Field_To_Lines[Field] DO BEGIN
        IF RichField THEN Max_i := 6
                     ELSE Max_i := 3;
        FOR i := 0 TO Max_i DO BEGIN
          l := CutLine[i];
          IF (LinesK[l] = 0) OR (LinesR[l] = 0) THEN BEGIN

            Inc(LinesA^[l]); { one more A piece on this line }

            IF LinesB^[l] <> 0 THEN BEGIN { hmm... two colors on 1 line!!! }

              { repair b1^, b2^, b3^ }

              CASE LinesB^[l] OF
                1 : Dec(b1^);
                2 : Dec(b2^);
                3 : Dec(b3^);
              END;
              Inc(lt); { one more line unavailable as winline! }

            END
            ELSE BEGIN { line can become winline! }

              { update LinesA, a1, a2, a3 }

              CASE LinesA^[l] OF
                1 : Inc(a1^);
                2 : BEGIN Dec(a1^); Inc(a2^) END;
                3 : BEGIN Dec(a2^); Inc(a3^) END;
                4 : BEGIN
                      Dec(a3^);
                      IF Winner = none THEN Winner := PieceColor
                    END;
              END;

            END;
          END;
        END;
      END;
      { compute evaluation! }
      IF Winner = none THEN
        Evaluation := (127*a3^ + 31*a2^ + 7*a1^)
                      - (255*b3^ + 63*b2^ + 15*b1^)
      ELSE IF Winner = PieceColor THEN Evaluation := +MAXINT
                                  ELSE Evaluation := -MAXINT;
      { reverse evaluation for player O }
      IF PieceColor = O THEN Evaluation := -Evaluation;
    END;

  FUNCTION AutoEvalPositionObj.GameOver : BOOLEAN;

    BEGIN
      GameOver := (Winner = X) OR (Winner = O);
    END;

  FUNCTION AutoEvalPositionObj.WillDraw : BOOLEAN;

    BEGIN
      WillDraw := (lt=76); { all lines are taken, this game will draw }
    END;

END.