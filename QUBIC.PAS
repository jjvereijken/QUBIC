PROGRAM Qubic;

  {$M $8000, $00000, $A0000} { grab some more stack space }
  {$C FIXED PRELOAD PERMANENT}
  {$D QUBIC V1.0 - (c)1991 Jan Joris Vereijken}

  USES QMenu, {$IFDEF WINDOWS} WinCrt {$ELSE} Crt {$ENDIF};

(**************************************************************************)
(* Author   : Jan Joris Vereijken, RUL 8849803, 071-171752/276803         *)
(* Dates    : 07 April 1991 till 29 April 1991,                           *)
(*            adapted for DPMI on 14-05-1993,                             *)
(*            adapted for Windows on 18-05-1993 (very messy)              *)
(* Compiler : Borland Pascal 7.0                                          *)
(**************************************************************************)

BEGIN

     IF ParamCount = 0 THEN BEGIN

       QMenu.GoQubic; { do your thing! }
       ClrScr;

     END
     ELSE

       WriteLn(Chr(7),Chr(10),'Qubic V1.0, (c)1991 Jan Joris Vereijken, forchk@rullf2.LeidenUniv.NL');

END.