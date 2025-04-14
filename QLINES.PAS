UNIT QLines;

(* this unit builds an array filled with all lines *)

INTERFACE

  USES QTypes;

  VAR Lines : LineArray;

IMPLEMENTATION

VAR
      i : 0..76;
      j : 0..15;
      f : FieldNumber;

PROCEDURE AddLine(f0, f1, f2, f3 : FieldNumber);

  BEGIN
    Lines[i][0] := f0;
    Lines[i][1] := f1;
    Lines[i][2] := f2;
    Lines[i][3] := f3;
    Inc(i);
  END;

BEGIN

  i := 0; { point to first entry in Lines }

  { do the ortholines }

  { first do all lines in the x-direction }

  FOR j := 0 TO 15 DO BEGIN
    f := 4*j;
    AddLine(f, f+1, f+2, f+3);
  END;

  { now do all lines in the y-direction }

  FOR j := 0 TO 15 DO BEGIN
    f := 16*(j DIV 4) + j MOD 4;
    AddLine(f, f+4, f+8, f+12);
  END;

  { now do all lines in the z-direction }

  FOR j := 0 TO 15 DO BEGIN
    f := j;
    AddLine(f, f+16, f+32, f+48);
  END;

  { do the 2 dimensional diagolines }

  AddLine( 0,  5, 10, 15);
  AddLine(16, 21, 26, 31);
  AddLine(32, 37, 42, 47);
  AddLine(48, 53, 58, 63);

  AddLine( 3,  6,  9, 12);
  AddLine(19, 22, 25, 28);
  AddLine(35, 38, 41, 44);
  AddLine(51, 54, 57, 60);

  AddLine( 0, 17, 34, 51);
  AddLine( 4, 21, 38, 55);
  AddLine( 8, 25, 42, 59);
  AddLine(12, 29, 46, 63);

  AddLine( 3, 18, 33, 48);
  AddLine( 7, 22, 37, 52);
  AddLine(11, 26, 41, 56);
  AddLine(15, 30, 45, 60);

  AddLine( 0, 20, 40, 60);
  AddLine( 1, 21, 41, 61);
  AddLine( 2, 22, 42, 62);
  AddLine( 3, 23, 43, 63);

  AddLine(12, 24, 36, 48);
  AddLine(13, 25, 37, 49);
  AddLine(14, 26, 38, 50);
  AddLine(15, 27, 39, 51);

  { finally, do the 3 dimensional diagolines }

  AddLine( 0, 21, 42, 63);
  AddLine( 3, 22, 41, 60);
  AddLine(12, 25, 38, 51);
  AddLine(15, 26, 37, 48);

END.

