UNIT QStrats;

{ This unit severs as an intermediairy between the userinterface and       }
{ the actual game. Please note that this unit was designed with conceptual }
{ simplicity in mind. Considerable inefficiency in both code space and     }
{ executiontime resulted, but it's certainly worth the gained clarity.     }

INTERFACE

  USES

    QTypes, QMinMax, QAlfBet, QAlfBetK, QAlfBetP, QAlfBetW, QAlfBetF, QGamma;

  TYPE

    StrategyServer = OBJECT

       { the common data }

       k1, k2, k3, r1, r2, r3, lt : BYTE;
       Evaluation                 : INTEGER;
       NodesSearched              : LONGINT;

       { the control data }

       Strategy : StrategyType;

       { the various automatic searching objects (boards) }

       MinMax  : MiniMaxingPositionObj;
       AlfBet  : AlfaBetaingPositionObj;
       AlfBetK : AlfaBetaingKillerPositionObj;
       AlfBetP : AlfaBetaingPCPositionObj;
       AlfBetW : AlfaBetaingWindowPositionObj;
       AlfBetF : AlfaBetaingForcedPositionObj;
       Gamm    : GammaingPositionObj;

       { the methods on the control data }

       PROCEDURE CycleStrategy;
       FUNCTION  NameOfStrategy : STRING;

       { the methods on the boards }

       PROCEDURE Init;
       PROCEDURE PutPiece(PieceColor : Color; Field : FieldNumber);
       PROCEDURE ResetNodesCounter;
       PROCEDURE CalculateMove(VAR Move   : FieldNumber;
                               VAR Value  : INTEGER;
                                   Depth  : SearchDepth;
                                   Player : Color);
       FUNCTION  GameOver : BOOLEAN;
       FUNCTION  Winner   : Color;

    END;

IMPLEMENTATION

  PROCEDURE StrategyServer.CycleStrategy;

    { cycle to the next stategy }

    BEGIN
     IF Strategy <> Gamma THEN Strategy := Succ(Strategy)
                          ELSE Strategy := MiniMax;
    END;


  FUNCTION StrategyServer.NameOfStrategy : STRING;

     { return the name of the current strategy }

     BEGIN
       CASE Strategy OF
         MiniMax   : NameOfStrategy := 'minimax search';
         AlfaBeta  : NameOfStrategy := 'plain [а,б]-search';
         AlfaBetaK : NameOfStrategy := '[а,б]-search with killer moves';
         AlfaBetaP : NameOfStrategy := '[а,б]-search with princ. cont.';
         AlfaBetaW : NameOfStrategy := '[а,б]-search with аб-window';
         AlfaBetaF : NameOfStrategy := '[а,б]-search with forced moves';
         Gamma     : NameOfStrategy := 'full blown в-search';
       END;
     END;

  PROCEDURE StrategyServer.Init;

    { init all objects and datafields }

    BEGIN
      MinMax.Init;
      AlfBet.Init;
      AlfBetK.Init;
      AlfBetP.Init;
      AlfBetW.Init;
      AlfBetF.Init;
      Gamm.Init;
      k1 := 0; k2 := 0; k3 := 0;
      r1 := 0; r2 := 0; r3 := 0;
      lt := 0;
      Evaluation := 0;
      NodesSearched := 0;
      Strategy := Gamma;
    END;

  PROCEDURE StrategyServer.PutPiece(PieceColor : Color; Field : FieldNumber);

    { put the piece on all boards, and fetch datafields ! }

    BEGIN

      { put the piece on all boards }

      MinMax.PutPiece(PieceColor, Field);
      AlfBet.PutPiece(PieceColor, Field);
      AlfBetK.PutPiece(PieceColor, Field);
      AlfBetP.PutPiece(PieceColor, Field);
      AlfBetW.PutPiece(PieceColor, Field);
      AlfBetF.PutPiece(PieceColor, Field);
      Gamm.PutPiece(PieceColor, Field);

      { fetch datafields.... Yuk! }

      CASE Strategy OF
        MiniMax   : WITH MinMax DO BEGIN
                      Self.k1 := k1; Self.k2 := k2; Self.k3 := k3;
                      Self.r1 := r1; Self.r2 := r2; Self.r3 := r3;
                      Self.lt := lt;
                      Self.Evaluation := Evaluation;
                      Self.NodesSearched := NodesSearched;
                    END;
        AlfaBeta  : WITH AlfBet DO BEGIN
                      Self.k1 := k1; Self.k2 := k2; Self.k3 := k3;
                      Self.r1 := r1; Self.r2 := r2; Self.r3 := r3;
                      Self.lt := lt;
                      Self.Evaluation := Evaluation;
                      Self.NodesSearched := NodesSearched;
                    END;
        AlfaBetaK : WITH AlfBetK DO BEGIN
                      Self.k1 := k1; Self.k2 := k2; Self.k3 := k3;
                      Self.r1 := r1; Self.r2 := r2; Self.r3 := r3;
                      Self.lt := lt;
                      Self.Evaluation := Evaluation;
                      Self.NodesSearched := NodesSearched;
                    END;
        AlfaBetaP : WITH AlfBetP DO BEGIN
                      Self.k1 := k1; Self.k2 := k2; Self.k3 := k3;
                      Self.r1 := r1; Self.r2 := r2; Self.r3 := r3;
                      Self.lt := lt;
                      Self.Evaluation := Evaluation;
                      Self.NodesSearched := NodesSearched;
                    END;
        AlfaBetaW : WITH AlfBetW DO BEGIN
                      Self.k1 := k1; Self.k2 := k2; Self.k3 := k3;
                      Self.r1 := r1; Self.r2 := r2; Self.r3 := r3;
                      Self.lt := lt;
                      Self.Evaluation := Evaluation;
                      Self.NodesSearched := NodesSearched;
                    END;
        AlfaBetaF : WITH AlfBetF DO BEGIN
                      Self.k1 := k1; Self.k2 := k2; Self.k3 := k3;
                      Self.r1 := r1; Self.r2 := r2; Self.r3 := r3;
                      Self.lt := lt;
                      Self.Evaluation := Evaluation;
                      Self.NodesSearched := NodesSearched;
                    END;
        Gamma     : WITH Gamm DO BEGIN
                      Self.k1 := k1; Self.k2 := k2; Self.k3 := k3;
                      Self.r1 := r1; Self.r2 := r2; Self.r3 := r3;
                      Self.lt := lt;
                      Self.Evaluation := Evaluation;
                      Self.NodesSearched := NodesSearched;
                    END;
      END;
    END;

  PROCEDURE StrategyServer.ResetNodesCounter;

    { reset all nodescounters }

    BEGIN
      MinMax.ResetNodesCounter;
      AlfBet.ResetNodesCounter;
      AlfBetK.ResetNodesCounter;
      AlfBetP.ResetNodesCounter;
      AlfBetW.ResetNodesCounter;
      AlfBetF.ResetNodesCounter;
      Gamm.ResetNodesCounter;
    END;

  PROCEDURE StrategyServer.CalculateMove(VAR Move   : FieldNumber;
                                         VAR Value  : INTEGER;
                                             Depth  : SearchDepth;
                                             Player : Color);

    { call CalculateMove of the appropiate board in the appropiate way }

    CONST

      WindowSize = 1024;

    VAR

      WindowAlfa, WindowBeta : INTEGER; { used for windowing }

    BEGIN
      CASE Strategy OF
        MiniMax   : WITH MinMax DO BEGIN
                      CalculateMove(Move, Value, Depth, Player);
                      Self.NodesSearched := NodesSearched;
                    END;
        AlfaBeta  : WITH AlfBet DO BEGIN
                      CalculateMove(Move, Value, Depth, Player, -MAXINT, +MAXINT);
                      Self.NodesSearched := NodesSearched;
                    END;
        AlfaBetaK : WITH AlfBetK DO BEGIN
                      QAlfBetK.SetUpKillerSequence(X);
                      QAlfBetK.SetUpKillerSequence(O);
                      CalculateMove(Move, Value, Depth, Player, -MAXINT, +MAXINT);
                      Self.NodesSearched := NodesSearched;
                    END;
        AlfaBetaP : WITH AlfBetP DO BEGIN
                      CalculateMove(Move, Value, Depth, Player, -MAXINT, +MAXINT);
                      Self.NodesSearched := NodesSearched;
                    END;
        AlfaBetaW : WITH AlfBetW DO BEGIN
                      { first set up the window }
                      IF Abs(Evaluation) = MAXINT THEN BEGIN
                        { don't use the window }
                        WindowAlfa := -MAXINT;
                        WindowBeta := +MAXINT;
                      END
                      ELSE BEGIN
                        WindowAlfa := Evaluation - WindowSize DIV 2;
                        WindowBeta := Evaluation + WindowSize DIV 2;
                      END;
                      InitFails; { prepare for window search }
                      CalculateMove(Move, Value, Depth, Player, WindowAlfa, WindowBeta);
                      IF LowFail THEN WindowAlfa := -MAXINT;
                      IF HighFail THEN WindowBeta := +MAXINT;
                      IF LowFail OR HighFail THEN { do it again Sam! }
                        CalculateMove(Move, Value, Depth, Player, WindowAlfa, WindowBeta);
                      Self.NodesSearched := NodesSearched;
                    END;
        AlfaBetaF : WITH AlfBetF DO BEGIN
                      CalculateMove(Move, Value, Depth, Player, -MAXINT, +MAXINT);
                      Self.NodesSearched := NodesSearched;
                    END;
        Gamma     : WITH Gamm DO BEGIN
                      CalculateMove(Move, Value, Depth, Player, -MAXINT, +MAXINT);
                      Self.NodesSearched := NodesSearched;
                    END;
      END;
    END;

  FUNCTION StrategyServer.GameOver : BOOLEAN;

    BEGIN
      GameOver := (Evaluation = +MAXINT) OR (Evaluation = -MAXINT);
    END;

  FUNCTION StrategyServer.Winner : Color;

    BEGIN
      CASE Evaluation OF
        -MAXINT : Winner := O;
        +MAXINT : Winner := X;
        ELSE      Winner := none;
      END;
    END;

END.