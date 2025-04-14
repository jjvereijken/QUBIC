UNIT QTypes;

(* this unit defines most data types used, and some more stuff *)

INTERFACE

  USES

    {$IFDEF WINDOWS} WinDos {$ELSE} Dos {$ENDIF};

  TYPE

    Color = (X, O, None);

    CoordinateValue = 0..3;

    Coordinate = RECORD
      x, y, z : CoordinateValue;
    END;

    FieldNumber = 0..63;

    SearchDepth = 1..64;

    Line = ARRAY [0..3] OF FieldNumber;

    LineNumber = 0..75;

    LineArray = ARRAY [LineNumber] OF Line;

    LineCountArray = ARRAY [LineNumber] OF BYTE;

    CutLineArray = ARRAY [0..6] OF LineNumber;

    Field_To_Lines_Entry = RECORD
      CutLine   : CutLineArray;
      RichField : BOOLEAN; { TRUE : 7 cutlines through field, FALSE : 4 }
      { note that this record has a size of 22 bytes, so data stays aligned }
    END;

    Field_To_Lines_Array = ARRAY [FieldNumber] OF Field_To_Lines_Entry;

    Board = ARRAY [0..63] OF Color;

    pBoard = ^Board;

    PlayerType = (Human, Computer);

    MenuStatus = RECORD
      X_Player, O_Player : PlayerType;
      Moves              : ARRAY [0..63] OF FieldNumber;
      LastMove           : -1..63;
      MTX, MTO, TTX, TTO : LONGINT { ticks on the timer };
    END;

    String12 = STRING[12]; { used to hold filenames }

    StrategyType = (MiniMax, AlfaBeta, AlfaBetaK, AlfaBetaP, AlfaBetaW, AlfaBetaF, Gamma);

  CONST

    LogFileName : STRING = 'QUBIC.LOG';

    EmptyBoard : Board = (none, none, none, none, none, none, none, none,
                          none, none, none, none, none, none, none, none,
                          none, none, none, none, none, none, none, none,
                          none, none, none, none, none, none, none, none,
                          none, none, none, none, none, none, none, none,
                          none, none, none, none, none, none, none, none,
                          none, none, none, none, none, none, none, none,
                          none, none, none, none, none, none, none, none);

    RightArrow = #77;
    LeftArrow  = #75;
    UpArrow    = #72;
    DownArrow  = #80;
    F1Key      = #59;
    EnterKey   = #13;
    ESCKey     = #27;

    FUNCTION ColToChar(Piece : Color) : CHAR;
    PROCEDURE Upper(VAR s : STRING);
    FUNCTION Now : STRING;

IMPLEMENTATION

  FUNCTION ColToChar(Piece : Color) : CHAR;

    { translate a color into a character }

    BEGIN
      CASE Piece OF
        X    : ColToChar := 'X';
        O    : ColToChar := 'O';
        none : ColToChar := 'ú';
      END;
    END;

  PROCEDURE Upper(VAR s : STRING);

    { make a string uppercase }

    VAR

      i : BYTE;

  BEGIN
    FOR i := 1 TO Length(s) DO s[i] := UpCase(s[i]);
  END;

  FUNCTION Now : STRING;

    { get the current date & time }

    VAR

       Year, Month, Date, Hour, DayOfWeek, Minute, Second, Sec100 : WORD;
       r,t : STRING;

    BEGIN
      GetDate(Year, Month, Date, DayOfWeek);
      GetTime(Hour, Minute, Second, Sec100);
      Str(Date, t);
      r := t;
      Str(Month, t);
      r := r + '-' + t;
      Str(Year, t);
      r := r + '-' + t;
      Str(Hour, t);
      r := r + ', ' + t;
      Str(Minute:2, t);
      IF t[1] = ' ' THEN t[1] := '0'; { leading zero ! }
      r := r + ':' + t;
      Str(Second:2, t);
      IF t[1] = ' ' THEN t[1] := '0'; { leading zero ! }
      r := r + ':' + t;
      Now := r;
    END;

END.