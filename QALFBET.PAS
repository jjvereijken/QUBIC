UNIT QAlfBet;

(* this unit implements an alfa-beta'ing object *)

INTERFACE

  USES

    QTypes, QEval;

  TYPE

    AlfaBetaingPositionObj = OBJECT(AutoEvalPositionObj)

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

  PROCEDURE AlfaBetaingPositionObj.CalculateMove(VAR Move   : FieldNumber;
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

      tmpPos      : AlfaBetaingPositionObj;
      tmpMove     : FieldNumber;
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
      FOR tmpMove := 0 TO 63 DO
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
          IF Player = X THEN BEGIN { beware of dangling ELSE!!! }
            { maximize level }
            IF tmpValue >= Value THEN BEGIN
              { set new maximum }
              Move  := tmpMove;
              Value := tmpValue;
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
              IF Value < alfa THEN
                { max can get at least alfa, so this subtree makes no sense }
                CutOffFound := TRUE;
              IF Value < beta THEN
                { min has found a better worst case }
                beta := Value;
            END
        END;
    END;

  PROCEDURE AlfaBetaingPositionObj.ResetNodesCounter;

    BEGIN
      NodesSearchedCounter := 0;
    END;

  FUNCTION AlfaBetaingPositionObj.NodesSearched : LONGINT;

    BEGIN
      NodesSearched := NodesSearchedCounter;
    END;
END.