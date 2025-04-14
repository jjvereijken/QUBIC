UNIT QAlfBetP;

(* this unit implements an alfa-beta'ing object, with principal continuation *)

INTERFACE

  USES

    QTypes, QEval;

  TYPE

    AlfaBetaingPCPositionObj = OBJECT(AutoEvalPositionObj)

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

  PROCEDURE AlfaBetaingPCPositionObj.Init;

    VAR

      i : FieldNumber;

    BEGIN
      AutoEvalPositionObj.Init;
      ThisLevel := 0;
      FOR i := 0 TO 63 DO PrinCont[i] := 0;
    END;

  PROCEDURE AlfaBetaingPCPositionObj.PutPiece(PieceColor : Color; Field : FieldNumber);

    BEGIN
      AutoEvalPositionObj.PutPiece(PieceColor, Field);
      Inc(ThisLevel);
    END;

  PROCEDURE AlfaBetaingPCPositionObj.CalculateMove(VAR Move   : FieldNumber;
                                                   VAR Value  : INTEGER;
                                                       Depth  : SearchDepth;
                                                       Player : Color;
                                                       alfa,
                                                       beta   : INTEGER);

    { Perform a Depth-ply AlfaBeta search. Return the best move in Move, }
    { the corresponding evaluation value in Value. Player is to move.    }
    { View alfa as the worst value max is willing to accept,             }
    { view beta as the worst value min is willing to accept.             }

    VAR

      tmpPos      : AlfaBetaingPCPositionObj;
      tmpMove     : FieldNumber;
      NStmpMove   : FieldNumber; { holds non-PC-sequenced tmpMove }
      PC          : FieldNumber; { principal continuation for this level }
      dummyMove   : FieldNumber;
      tmpValue    : INTEGER;
      OtherPlayer : Color;
      CutOffFound : BOOLEAN;

    BEGIN
      CASE Player OF
        X : OtherPlayer := O;
        O : OtherPlayer := X;
      END;
      IF Player = X THEN { maximize level } Value := -MAXINT
                    ELSE { minimize level } Value := +MAXINT;
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
          IF Depth = 1 THEN BEGIN
            { tail of recursion }
            tmpValue := tmpPos.Evaluation;
            Inc(NodesSearchedCounter); { one more node searched }
          END
          ELSE
            { use recursion, on this level we're not interested }
            { in the best move, only in the resulting value }
            tmpPos.CalculateMove(dummyMove, tmpValue, Depth-1, OtherPlayer, alfa, beta);
          Dec(ThisLevel); { undo effects of tmpPos.PutPiece }
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
            END
        END;
      END;
    END;

  PROCEDURE AlfaBetaingPCPositionObj.ResetNodesCounter;

    BEGIN
      NodesSearchedCounter := 0;
    END;

  FUNCTION AlfaBetaingPCPositionObj.NodesSearched : LONGINT;

    BEGIN
      NodesSearched := NodesSearchedCounter;
    END;

END.