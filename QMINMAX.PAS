UNIT QMinMax;

{ this unit implements a mini-max'ing object }

INTERFACE

  USES

    QTypes, QEval;

  TYPE

    MiniMaxingPositionObj = OBJECT(AutoEvalPositionObj)

      PROCEDURE CalculateMove(VAR Move   : FieldNumber;
                              VAR Value  : INTEGER;
                                  Depth  : SearchDepth;
                                  Player : Color);

      PROCEDURE ResetNodesCounter;
      FUNCTION NodesSearched : LONGINT;

    END;

  FUNCTION MiniMaxSpeedUp(l : BYTE; p : SearchDepth; n : LONGINT) : REAL;

IMPLEMENTATION

  FUNCTION MiniMaxSpeedUp(l : BYTE; p : SearchDepth; n : LONGINT) : REAL;

    { this function returns the factor by with n is less to  }
    { the number of nodes searched for a full minimax search }
    { when l contains the number of the lastmove             }

    VAR

      m : REAL; { the number of nodes that minixmax would search }
      i : BYTE;

    BEGIN
      m := 1;
      FOR i := (64-l) DOWNTO (64-l-p+1) DO m := m*i;
      MiniMaxSpeedUp := m/n;
    END;

  VAR

    NodesSearchedCounter : LONGINT;

    { !!! GLOBAL counter !!!, gets incremented with each move }

  PROCEDURE MiniMaxingPositionObj.CalculateMove(VAR Move   : FieldNumber;
                                                VAR Value  : INTEGER;
                                                    Depth  : SearchDepth;
                                                    Player : Color);

    { Perform a Depth-ply MiniMax search. Return the best move in Move, }
    { the corresponding evaluation value in Value. Player is to move.   }

    VAR

      tmpPos      : MiniMaxingPositionObj;
      tmpMove     : FieldNumber;
      dummyMove   : FieldNumber;
      tmpValue    : INTEGER;
      OtherPlayer : Color;

    BEGIN
      CASE Player OF
        X : OtherPlayer := O;
        O : OtherPlayer := X;
      END;
      IF Player = X THEN { maximize level } Value := -MAXINT
                    ELSE { minimize level } Value := +MAXINT;
      dummyMove := 0; { to avoid out of range error }
      tmpValue := 0;
      FOR tmpMove := 0 TO 63 DO
        IF FieldEmpty(tmpMove) THEN BEGIN
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
            tmpPos.CalculateMove(dummyMove, tmpValue, Depth-1, OtherPlayer);
          IF Player = X THEN BEGIN { beware of dangling ELSE!!! }
            { maximize level }
            IF tmpValue >= Value THEN BEGIN
              { set new maximum }
              Move  := tmpMove;
              Value := tmpValue;
            END;
          END
          ELSE
            { minimize level }
            IF tmpValue <= Value THEN BEGIN
              { set new minimum }
              Move  := tmpMove;
              Value := tmpValue;
            END
        END;
    END;

  PROCEDURE MiniMaxingPositionObj.ResetNodesCounter;

    BEGIN
      NodesSearchedCounter := 0;
    END;

  FUNCTION MiniMaxingPositionObj.NodesSearched : LONGINT;

    BEGIN
      NodesSearched := NodesSearchedCounter;
    END;
END.