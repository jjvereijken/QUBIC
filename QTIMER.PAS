UNIT QTimer;

(* This unit defines a simple timer object. Please note that it   *)
(* hooks INT $1C, and abuses INT $FD. The alternative is writing  *)
(* self modifying code. That's real filthy, this is merely dirty. *)

INTERFACE

  USES

    {$IFDEF WINDOWS} WinDos {$ELSE} Dos {$ENDIF};

  TYPE

    Timer = OBJECT
      TicksPassed  : LONGINT;
      TicksAtStart : LONGINT;
      PROCEDURE Reset;
      PROCEDURE Start;
      PROCEDURE Stop;
      FUNCTION SecsPassed : REAL;
    END;

IMPLEMENTATION

VAR

  SystemTicks  : LONGINT; { holds the number of systemticks }
                          { since starting up Qubic         }

  SavedInt1C   : POINTER; { holds the original INT $1C vector }
  SavedIntFD   : POINTER; { holds the original INT $FD vector }
  ExitSave     : POINTER;

PROCEDURE UpdateSystemTicks; ASSEMBLER;

  { this procedure will be called by INT $1C, to count the systemticks }

  ASM
    STI                            { allow other interrupts          }
    PUSH AX                        { save AX and DS                  }
    PUSH DS
    MOV AX, SEG @Data              { set up data segment             }
    MOV DS, AX
    MOV AX, WORD PTR SystemTicks   { add 1 to SystemTicks            }
    ADD AX, 1
    MOV WORD PTR SystemTicks, AX
    JNC @NoCarry
    MOV AX, WORD PTR SystemTicks+2 { add the carry                   }
    INC AX
    MOV WORD PTR SystemTicks+2, AX
    @NoCarry:
    {$IFNDEF WINDOWS}
    MOV AX, SegB000                { tickle the 6845 chip, so it     }
    MOV DS, AX                     { won't trigger the hardware      }
    MOV AX, DS:[$0000]             { screen blanker                  }
    {$ENDIF}
    POP DS                         { restore AX and DS               }
    POP AX
    INT $FD                        { do the old INT $1C              }
    IRET                           { return from interrupt           }
  END;

PROCEDURE CleanUp; FAR;

  { this procedure is called when exiting the program,   }
  { it restores the original INT $1C and INT $FD vectors }

  BEGIN
    ExitProc := ExitSave;       { restore old exit vector    }
    SetIntVec($1C, SavedInt1C); { restore old INT $1C vector }
    SetIntVec($FD, SavedIntFD); { restore old INT $FD vector }
  END;

PROCEDURE Timer.Reset;

  { reset the timer }

  BEGIN
    TicksPassed := 0;
  END;

PROCEDURE Timer.Start;

  { start the timer }

  BEGIN
    TicksAtStart := SystemTicks;
  END;


PROCEDURE Timer.Stop;

  { stop the timer }

  BEGIN
   Inc(TicksPassed, SystemTicks - TicksAtStart);
  END;

FUNCTION Timer.SecsPassed : REAL;

  { give the number of secs on the timer }

  VAR

    Result : REAL;

  BEGIN
    Result := (TicksPassed-0.5) / 18.2065;
    IF Result <= 0 THEN Result := 0.001;
    SecsPassed := Result;
  END;

BEGIN

  SystemTicks := 0; { we are starting Qubic up, no ticks yet }

  { intialize interrupthandler and cleanup code }

  GetIntVec($1C, SavedInt1C); { get old INT $1C vector }
  GetIntVec($FD, SavedIntFD); { get old INT $FD vector }

  ExitSave := ExitProc; { save the exit vector }
  ExitProc := @CleanUp; { install our cleanup code }

  SetIntVec($FD, SavedInt1C);         { abuse INT $FD to do old INT $1C }
  SetIntVec($1C, @UpdateSystemTicks); { install our INT $1C handler }

END.
