UNIT QAlfBetK;

(* this unit implements an alfa-beta'ing object, with killer heuristic extension *)

INTERFACE

  USES

    QTypes, QEval;

  TYPE

    AlfaBetaingKillerPositionObj = OBJECT(AutoEvalPositionObj)

      PROCEDURE Init;
      PROCEDURE CalculateMove(VAR Move   : FieldNumber;
                              VAR Value  : INTEGER;
                                  Depth  : SearchDepth;
                                  Player : Color;
                                  alfa,
                                  beta   : INTEGER);

      PROCEDURE ResetNodesCounter;
      FUNCTION NodesSearched : LONGINT;

    END;

  PROCEDURE SetUpKillerSequence(Player : Color);

IMPLEMENTATION


  VAR

    NodesSearchedCounter : LONGINT;

    { !!! GLOBAL counter !!!, gets incremented with each move }

    Killers        : ARRAY [Color, FieldNumber] OF BOOLEAN;
    KillerSequence : ARRAY [Color, FieldNumber] OF FieldNumber;

  PROCEDURE ClearKillers(Player : Color); FORWARD;

  PROCEDURE AlfaBetaingKillerPositionObj.Init;

    BEGIN
      AutoEvalPositionObj.Init;
      ClearKillers(X);
      ClearKillers(O);
    END;

  PROCEDURE AlfaBetaingKillerPositionObj.CalculateMove(VAR Move   : FieldNumber;
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

      tmpPos      : AlfaBetaingKillerPositionObj;
      NStmpMove   : FieldNumber; { holds non-killer-sequenced tmpMove }
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
      FOR NStmpMove := 0 TO 63 DO BEGIN
        tmpMove := KillerSequence[Player, NStmpMove]; { do killers first! }
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
              IF Value > alfa THEN BEGIN
                { max has found a better worst case }
                alfa := Value;
                Killers[Player, tmpMove] := TRUE; { killer found! }
              END;
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
              IF Value < beta THEN BEGIN
                { min has found a better worst case }
                beta := Value;
                Killers[Player, tmpMove] := TRUE; { killer found! }
              END;
            END;
        END;
      END;
    END;

  PROCEDURE AlfaBetaingKillerPositionObj.ResetNodesCounter;

    BEGIN
      NodesSearchedCounter := 0;
    END;

  FUNCTION AlfaBetaingKillerPositionObj.NodesSearched : LONGINT;

    BEGIN
      NodesSearched := NodesSearchedCounter;
    END;

  PROCEDURE ClearKillers(Player : Color);

    VAR

      f : FieldNumber;

    BEGIN
      FOR f := 0 TO 63 DO Killers[Player, f] := FALSE;
    END;

  PROCEDURE SetUpKillerSequence(Player : Color);

    { This procedure uses the array Killers to set up a ordering of moves }
    { where the killers come first.                                       }

    VAR

      f    : FieldNumber;
      i, j : -1..64;

    BEGIN
      i :=  0; { index to first element of KillerSequence }
      j := 63; { index to last element of KillerSequence }
      FOR f := 63 DOWNTO 0 DO { DOWNTO due to benchmarkreasons, DON'T remove }
        IF Killers[Player, f] THEN BEGIN
          { add killer to begin of sequence }
          KillerSequence[Player, i] := f;
          Inc(i);
        END
        ELSE BEGIN
          { add pacifist to end of sequence }
          KillerSequence[Player, j] := f;
          Dec(j);
        END;
        ClearKillers(Player); { clear array, so we can start all over again }
    END;

END.