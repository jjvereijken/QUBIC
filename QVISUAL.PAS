UNIT QVisual;

(* this unit takes care of showing the board and stuff *)

INTERFACE

  USES

    {$IFDEF WINDOWS} WinCrt {$ELSE} Crt {$ENDIF}, QTypes, Qlines, QObjRoot;

  TYPE

    VisualBoardObj = OBJECT(PositionObj)
      BeNice : BOOLEAN; { indicates that a pending 4-on-a-row is being shown }
      PROCEDURE Init;
      PROCEDURE ShowBoard;
      PROCEDURE WritePiece(c : CHAR; f : FieldNumber);
      PROCEDURE ShowPieces;
      PROCEDURE GetMove(VAR Move : FieldNumber; VAR Succes : BOOLEAN);
    END;

    PROCEDURE ShowCursor;
    PROCEDURE HideCursor;
    PROCEDURE Beep;
    PROCEDURE Buzz;

IMPLEMENTATION

  VAR

    Field_To_X,     Field_To_Y,
    Field_To_X_SV1, Field_To_Y_SV1,
    Field_To_X_SV2, Field_To_Y_SV2  : ARRAY [FieldNumber] OF BYTE;

    RightField, LeftField,
    UpField, DownField              : ARRAY [FieldNumber] OF FieldNumber;

    f                               : FieldNumber;
    ExitSave                        : POINTER;

  PROCEDURE Beep;

    BEGIN
      {$IFNDEF WINDOWS}
        Sound(1000);
        Delay(100);
        NoSound;
      {$ENDIF}
    END;

  PROCEDURE Buzz;

    BEGIN
      {$IFNDEF WINDOWS}
        Sound(250);
        Delay(250);
        NoSound;
      {$ENDIF}
    END;

  PROCEDURE ShowCursor; ASSEMBLER;

     ASM
       MOV AH, $03       { function $03, get cursor info     }
       INT $10           { interrupt $10, video              }
       AND CH, 10011111b { clear bits 5 and 6 of CH          }
       MOV AH, $01       { function $01, set cursor info     }
       INT $10           { interrupt $10, video              }
     END;

  PROCEDURE HideCursor; ASSEMBLER;

     ASM
       MOV AH, $03       { function $03, get cursor info     }
       INT $10           { interrupt $10, video              }
       AND CH, 10011111b { clear bits 5 and 6 of CH          }
       OR  CH, 00100000b { put 01 into them (=invisible)     }
       MOV AH, $01       { function $01, set cursor info     }
       INT $10           { interrupt $10, video              }
     END;

  PROCEDURE CleanUp; FAR;

  { This procedure is called in case of an (ab)normal return to DOS,         }
  { and un-hides the cursor. It has to be FAR, because anyone might call it. }

    BEGIN
      ExitProc := ExitSave; { restore old exit vector }
      ShowCursor;           { since we're returning to DOS a visible }
                            { cursor might be a good idea :-)        }
      {$IFNDEF WINDOWS}
        TextBackground(Black);
        TextColor(White);
      {$ENDIF}
    END;


  PROCEDURE VisualBoardObj.Init;

    BEGIN
      PositionObj.Init;
      BeNice := FALSE; { we are not yet going to be nice! }
    END;


  PROCEDURE VisualBoardObj.ShowBoard;

      BEGIN
      GotoXY(1,1);
      Write('здддбдддбдддбддд©    здддбдддбдддбддд©    здддбдддбдддбддд©    здддбдддбдддбддд©');
      Write('Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё');
      Write('цдддедддедддеддд╢    цдддедддедддеддд╢    цдддедддедддеддд╢    цдддедддедддеддд╢');
      Write('Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё');
      Write('цдддедддедддеддд╢    цдддедддедддеддд╢    цдддедддедддеддд╢    цдддедддедддеддд╢');
      Write('Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё');
      Write('цдддедддедддеддд╢    цдддедддедддеддд╢    цдддедддедддеддд╢    цдддедддедддеддд╢');
      Write('Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё    Ё   Ё   Ё   Ё   Ё');
      Write('юдддадддадддаддды    юдддадддадддаддды    юдддадддадддаддды    юдддадддадддаддды');
      WriteLn;
      WriteLn('          side view #1                               side view #2');
      WriteLn;
      Write('З З З З   З З З З   З З З З   З З З З      З З З З   З З З З   З З З З   З З З З');
      Write('З З З З   З З З З   З З З З   З З З З      З З З З   З З З З   З З З З   З З З З');
      Write('З З З З   З З З З   З З З З   З З З З      З З З З   З З З З   З З З З   З З З З');
      Write('З З З З   З З З З   З З З З   З З З З      З З З З   З З З З   З З З З   З З З З');
    END;

  PROCEDURE VisualBoardObj.WritePiece(c : CHAR; f : FieldNumber);

    BEGIN

      { do main view }

      GotoXY(Field_To_X[f], Field_To_Y[f]);
      Write(c);

      { do side views }

      IF c = ' ' THEN c := 'З'; { side views have 'З' as empty field }
      GotoXY(Field_To_X_SV1[f], Field_To_Y_SV1[f]);
      Write(c);
      GotoXY(Field_To_X_SV2[f], Field_To_Y_SV2[f]);
      Write(c);
    END;

  PROCEDURE VisualBoardObj.ShowPieces;

    VAR

      f      : FieldNumber;
      l      : LineNumber;
      i      : 0..3;
      Q      : ARRAY [0..3] OF Color;

    BEGIN

      { first, show all normal pieces }

      FOR f := 0 TO 63 DO
        CASE GetPiece(f) OF
          X    : WritePiece('X', f);
          O    : WritePiece('O', f);
          None : WritePiece(' ', f);
        END;

      IF BeNice THEN

      { then be nice to that CPU-less creature of flesh and blood }
      { put a "Ы" on all fields where a 4-on-a-row is pending :-) }

        FOR l := 0 TO 75 DO BEGIN
          FOR i := 0 TO 3 DO
            Q[i] := GetPiece(Lines[l][i]);
          FOR i := 0 TO 3 DO
            IF (Q[i] = none) AND
               (Q[(i+1) MOD 4] <> None) AND
               (Q[(i+1) MOD 4] = Q[(i+2) MOD 4]) AND
               (Q[(i+2) MOD 4] = Q[(i+3) MOD 4]) THEN

                 { we've got one...}

                 WritePiece('Ы', Lines[l][i]);

      END;

    END;

  PROCEDURE VisualBoardObj.GetMove(VAR Move : FieldNumber; VAR Succes : BOOLEAN);

    VAR

      Field, NewField : FieldNumber;
      Key             : CHAR;

    BEGIN

      Field := LastMove; { LastMove is the field where we start }
      REPEAT
        {$IFNDEF WINDOWS}
           TextColor(Black); TextBackGround(White); { go inverse }
        {$ENDIF}
        CASE GetPiece(Field) OF
          X    : WritePiece('X', Field);
          O    : WritePiece('O', Field);
          None : WritePiece(' ', Field);
        END;
        REPEAT
          REPEAT Key := ReadKey
            UNTIL (Key = #0) OR (Key = EnterKey) OR (Key = ESCKey);
          IF Key = #0 THEN Key := ReadKey; { read extended key code }
          IF Key = F1Key THEN BEGIN
             { ah, poor user, he needs some help, well, we'll be nice... }
             {$IFNDEF WINDOWS}
               TextColor(White); TextBackGround(Black);
             {$ENDIF}
             BeNice := TRUE;
             ShowPieces;
             {$IFNDEF WINDOWS} Delay(1000); {$ENDIF}
             BeNice := FALSE;
             ShowPieces;
          END;
        UNTIL Key IN [EnterKey, RightArrow, LeftArrow, UpArrow,
                      DownArrow, F1Key, ESCKey];
        CASE Key OF
          RightArrow : NewField := RightField[Field];
          LeftArrow  : NewField := LeftField[Field];
          UpArrow    : NewField := UpField[Field];
          DownArrow  : NewField := DownField[Field];
          EnterKey   : BEGIN
                         NewField := Field;
                         IF GetPiece(Field) = None THEN Beep ELSE Buzz;
                       END;
          F1Key,
          ESCKey     : NewField := Field;
        END;
        {$IFNDEF WINDOWS}
          TextColor(White); TextBackGround(Black); { go normal }
        {$ENDIF}
        CASE GetPiece(Field) OF
          X    : WritePiece('X', Field);
          O    : WritePiece('O', Field);
          none : WritePiece(' ', Field);
        END;
        Field := NewField;
      UNTIL (Key = ESCKey ) OR ((Key = EnterKey) AND (GetPiece(Field) = None));
      IF Key = ESCKey THEN Succes := FALSE ELSE Succes := TRUE;
      Move := Field; { return the result! }
    END;

BEGIN

  HideCursor; { hey, we don't want no cursor blinking nowhere! }
  ExitSave := ExitProc; { save the exit vector }
  ExitProc := @Cleanup; { install an exit vector to un-hide the cursor }
                        { when we fall back into DOS }

  { set our colors }

  {$IFNDEF WINDOWS}
    TextColor(White); TextBackground(Black);
  {$ENDIF}

  { calculate tables that say where on the screen a field is }

  FOR f := 0 TO 63 DO BEGIN

    Field_To_X[f]     :=  3 + 4*(f MOD 4) + 21*(f DIV 16);
    Field_To_Y[f]     :=  2 + 2*((f DIV 4) MOD 4);

    Field_To_X_SV1[f] :=  1 + 10*(3 - (f MOD 16) DIV 4) + 2*(f MOD 4);
    Field_To_Y_SV1[f] := 13 + f DIV 16;

    Field_To_X_SV2[f] := 44 + 10*(3 - f MOD 4) + 2*(3 - (f MOD 16) DIV 4);
    Field_To_Y_SV2[f] := 13 + f DIV 16;

  END;

  { calculate tables that say which field is next to which on the screen}

  FOR f := 0 TO 63 DO BEGIN
    IF f MOD 4 <> 3 THEN
      RightField[f] := f + 1
    ELSE
      RightField[f] := (f + 13) MOD 64;
    LeftField[RightField[f]] := f; { ha! an inverse! that's easy :-) }
    IF (f DIV 4) MOD 4 <> 3 THEN
      DownField[f] := f + 4
    ELSE
      DownField[f] := (f + 52) MOD 64;
    UpField[DownField[f]] := f;
  END;

END.