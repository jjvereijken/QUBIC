UNIT QDBase;

(* this unit constructs the database that links a field to a set of lines *)

INTERFACE

USES

  QTypes, QLines;

VAR

  Field_To_Lines : Field_To_Lines_Array;

IMPLEMENTATION

VAR

  i : ARRAY [LineNumber] OF 0..21;
  l : LineNumber;
  k : 0..3;
  f : FieldNumber;

BEGIN

  { first, let al i[l] point to the first free entry }

  FOR l := 0 TO 75 DO i[l] := 0;

  { now process all point of all lines }

  FOR l := 0 TO 75 DO
    FOR k := 0 TO 3 DO BEGIN
      f := Lines[l][k];
      Field_To_Lines[f].CutLine[i[f]] := l; { line l cuts field f }
      Inc(i[f]); { point to next free entry }
    END;

  { now determine rich points }

  FOR f := 0 TO 63 DO
    Field_To_Lines[f].RichField := (i[f] = 7);
    { field has 7 cutlines (a.o.t. 4) }

END.
