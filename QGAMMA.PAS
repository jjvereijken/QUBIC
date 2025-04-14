UNIT QGamma;

(* this unit implements an gamma'ing object (аб + forcinfg + PC) *)

INTERFACE

  USES

    QTypes, QEval;

  TYPE

    GammaingPositionObj = OBJECT(AutoEvalPositionObj)

      PROCEDURE Init;
      PROCEDURE PutPiece(PieceColor : Color; Field : FieldNumber);
      PROCEDURE CalculateMove(VAR Move   : FieldNumber;
                              VAR Value  : INTEGER;
                                  Depth  : SearchDepth;
                                  Player : Color;
                                  alfa,
                                  beta   : INTEGER);

      PROCEDURE ResetNodesCounter;
      FUNCTION NodesSearched : LONGINT;

    END;

IMPLEMENTATION

  VAR

    NodesSearchedCounter : LONGINT;

    { !!! GLOBAL counter !!!, gets incremented with each move }

    PrinCont  : ARRAY [FieldNumber] OF FieldNumber;
    ThisLevel : FieldNumber;

  PROCEDURE GammaingPositionObj.Init;

    VAR

      i : FieldNumber;

    BEGIN
      AutoEvalPositionObj.Init;
      ThisLevel := 0;
      FOR i := 0 TO 63 DO PrinCont[i] := 0;
    END;

  PROCEDURE GammaingPositionObj.PutPiece(PieceColor : Color; Field : FieldNumber);

    BEGIN
      AutoEvalPositionObj.PutPiece(PieceColor, Field);
      Inc(ThisLevel);
    END;

  PROCEDURE GammaingPositionObj.CalculateMove(VAR Move   : FieldNumber;
                                                  VAR Value  : INTEGER;
                                                      Depth  : SearchDepth;
                                                      Player : Color;
                                                      alfa,
                                                      beta   : INTEGER);

    { Perform a Depth-ply AlfaBeta search. Return the best move in Move, }
    { the corresponding evaluation value in Value. Player is to move.    }
    { View alfa as the worst value max is willing to accept,             }
    { view beta as the worst value min is willing to accept.             }
    { Is a move is forced, or a position is already won, don't analyse   }
    { unneccesary positions.                                             }

    VAR

      tmpPos      : GammaingPositionObj;
      tmpMove     : FieldNumber;
      dummyMove   : FieldNumber;
      tmpValue    : INTEGER;
      NStmpMove   : FieldNumber; { holds non-PC-sequenced tmpMove }
      PC          : FieldNumber; { principal continuation for this level }
      OtherPlayer : Color;
      CutOffFound : BOOLEAN;
      IHave3Row   : BOOLEAN;
      HeHas3Row   : BOOLEAN;
      His3Row     : ^BYTE;
      His3Value   : BYTE;
      Forcing     : BOOLEAN; { TRUE if we are looking for a forced move }

    BEGIN
      CASE Player OF
        X : OtherPlayer := O;
        O : OtherPlayer := X;
      END;
      IF Player = X THEN BEGIN
        { maximize level }
        Value := -MAXINT;
        IHave3Row := (k3 > 0); { player can force a win! }
        HeHas3Row := (r3 > 0); { player has to block his opponent }
        His3Row   := @tmpPos.r3;
        His3Value := r3;
      END
      ELSE BEGIN
        { minimize level }
        Value := +MAXINT;
        IHave3Row := (r3 > 0); { player can force a win! }
        HeHas3Row := (k3 > 0); { player has to block his opponent }
        His3Row   := @tmpPos.k3;
        His3Value := k3;
      END;
      IF IHave3Row THEN HeHas3Row := FALSE; { why bother? }
      Forcing := IHave3Row OR HeHas3Row;
      dummyMove := 0; { to avoid out of range error }
      tmpValue := 0;
      CutOffFound := FALSE;
      PC := PrinCont[ThisLevel];
      FOR NStmpMove := 0 TO 63 DO BEGIN
        IF (NStmpMove = 0) OR (NStmpMove = PC) THEN tmpMove := PC - NStmpMove
                                               ELSE tmpMove := NStmpMove;
        IF (NOT CutOffFound) AND FieldEmpty(tmpMove) THEN BEGIN
          { for all valid moves }
          tmpPos := Self;
          tmpPos.PutPiece(Player, tmpMove);
          IF (NOT Forcing) OR
             ((IHave3Row) AND (tmpPos.Winner = Player)) OR
             ((HeHas3Row) AND (His3Row^ < His3Value)) THEN BEGIN
            IF Forcing THEN { this is the forced move! }
              CutOffFound := TRUE; { no need to continue after this }
            IF (Depth = 1) OR
               (tmpPos.Winner <> none) OR
               tmpPos.WillDraw THEN BEGIN
              { tail of recursion, also when winner is known or game will draw }
              tmpValue := tmpPos.Evaluation;
              Inc(NodesSearchedCounter); { one more node searched }
            END
            ELSE
              { use recursion, on this level we're not interested }
              { in the best move, only in the resulting value }
              tmpPos.CalculateMove(dummyMove, tmpValue, Depth-1, OtherPlayer, alfa, beta);
            Dec(ThisLevel); { undo effect of tmpPos.PutPiece }
            IF Player = X THEN BEGIN { beware of dangling ELSE!!! }
              { maximize level }
              IF tmpValue >= Value THEN BEGIN
                { set new maximum }
                Move  := tmpMove;
                Value := tmpValue;
                PrinCont[ThisLevel] := Move;
                IF Value > beta THEN
                  { min can get at most beta, so this subtree makes no sense }
                  CutOffFound := TRUE;
                IF Value > alfa THEN
                  { max has found a better worst case }
                  alfa := Value;
              END;
            END
            ELSE
              { minimize level }
              IF tmpValue <= Value THEN BEGIN
                { set new minimum }
                Move  := tmpMove;
                Value := tmpValue;
                PrinCont[ThisLevel] := Move;
                IF Value < alfa THEN
                  { max can get at least alfa, so this subtree makes no sense }
                  CutOffFound := TRUE;
                IF Value < beta THEN
                  { min has found a better worst case }
                  beta := Value;
              END;
          END
          ELSE
            Dec(ThisLevel); { undo effect of tmpPos.PutPiece };
        END;
      END;
    END;

  PROCEDURE GammaingPositionObj.ResetNodesCounter;

    BEGIN
      NodesSearchedCounter := 0;
    END;

  FUNCTION GammaingPositionObj.NodesSearched : LONGINT;

    BEGIN
      NodesSearched := NodesSearchedCounter;
    END;
END.