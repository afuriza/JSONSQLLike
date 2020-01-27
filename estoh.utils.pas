unit estoh.utils;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils;

function angka2huruf( angka : integer ) : string;
operator in(const Val: string; CompareSL: TStringList): boolean;
function estDecrypt( teks: String; pengacak: Byte) : String;
function estEncrypt( teks: String; pengacak: Byte) : String;
function Hashing(input:string):string;


implementation

operator in(const Val: string; CompareSL: TStringList): boolean;
var
  i: integer;
begin
  Result := False;
  for i := 0 to CompareSl.Count -1 do
  begin
    if Val = CompareSl[i] then
      Result := True;
  end;
end;

function Hashing(input : string):string;
var
  password, password1, password2 : string;
  a:integer;
begin
  password := '';
  password1 := '';
  password2 := '';
  {StringHashSHA1(SHA1Digest, input);
  password := BufferToHex(SHA1Digest, SizeOf(SHA1Digest));}
  password := input;
  password1 := copy(password,1,4) + copy(password,12,4) + copy(password,23,4) + copy(password,34,4);

  for a:=1 to length(password1) do
  begin
      case a mod 3 of
          0 : password2 := password2 + chr( (ord(password1[a]))-ord('(') );
          1 : password2 := password2 + chr( (ord(password1[a]))-ord(')') );
          2 : password2 := password2 + chr( (ord(password1[a]))-ord('*') );
      end;
  end;

  if length(trim(input)) = 0 then
      Hashing := ''
  else
      Hashing := password2;
end;


// ----------- function ----------------
function estEncript( teks: String; pengacak: Byte) : String;
var
  T, TeksJadi : String;
  x, c : word;
  hr : real;
begin
  T := teks;
//  T := StringReplace( T, 's', 'SS', [rfReplaceAll, rfIgnoreCase]);
  T := StringReplace( T, 's', 'SS', [rfReplaceAll]);
//  T := StringReplace( T, 'y', 'YY', [rfReplaceAll, rfIgnoreCase]);
  T := StringReplace( T, 'y', 'YY', [rfReplaceAll]);

  // acak 1
  TeksJadi := '';
  c := length(T);
  for x:=1 to length(T) do
  begin
     hr := Ord( T[x] );
     TeksJadi := TeksJadi + FormatFloat('000',hr+c*pengacak);
     c := c - 1;
  end;

  T := TeksJadi;
  // acak 2
  TeksJadi := '';
  x := 1;
  while x < length(T) do
  begin
     TeksJadi := TeksJadi + chr( strtoint( copy(T, x, 3) ) );
     x := x + 3;
  end;

  result := TeksJadi;
end;

// ----------- function ----------------
function estEncrypt( teks: String; pengacak: Byte) : String;
var
  T, TeksJadi : String;
  x, c : word;
  hr : real;
begin
  T := teks;
//  T := StringReplace( T, 's', 'SS', [rfReplaceAll, rfIgnoreCase]);
  T := StringReplace( T, 's', 'SS', [rfReplaceAll]);
//  T := StringReplace( T, 'y', 'YY', [rfReplaceAll, rfIgnoreCase]);
  T := StringReplace( T, 'y', 'YY', [rfReplaceAll]);

  // acak 1
  TeksJadi := '';
  c := length(T);
  for x:=1 to length(T) do
  begin
     hr := Ord( T[x] );
     TeksJadi := TeksJadi + FormatFloat('000',hr+c*pengacak);
     c := c - 1;
  end;

  T := TeksJadi;
  // acak 2
  TeksJadi := '';
  x := 1;
  while x < length(T) do
  begin
     TeksJadi := TeksJadi + chr( strtoint( copy(T, x, 3) ) );
     x := x + 3;
  end;

  result := TeksJadi;
end;


// ----------- function ----------------
function estDecrypt( teks: String; pengacak: Byte) : String;
var
  T, TeksJadi : String;
  x, c : word;
  hr : real;
begin
  T := teks;
  // acak 1
  TeksJadi := '';
  for x:=1 to length(T) do
  begin
     hr := Ord( T[x] );
     TeksJadi := TeksJadi + FormatFloat('000',hr);
  end;

  T := TeksJadi;
  // acak 2
  TeksJadi := '';
  x := 1;
  c := trunc( length(T)/3 );
  while x < length(T) do
  begin
     TeksJadi := TeksJadi + chr( strtoint( copy(T, x, 3) )-c*pengacak );
     x := x + 3;
     c := c - 1;
  end;

//  TeksJadi := StringReplace( TeksJadi, 'SS', 's', [rfReplaceAll, rfIgnoreCase]);
  TeksJadi := StringReplace( TeksJadi, 'SS', 's', [rfReplaceAll]);
//  TeksJadi := StringReplace( TeksJadi, 'YY', 'y', [rfReplaceAll, rfIgnoreCase]);
  TeksJadi := StringReplace( TeksJadi, 'YY', 'y', [rfReplaceAll]);

  result := TeksJadi;
end;

function angka2huruf( angka : integer ) : string;
var
  A1, A2, jh : integer;
  hrf, hsl : string;
begin
       // 123456789012345678901234567890123456
//  hrf := '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ';
       // 12345678901234567890123456
  hrf := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  jh := length(hrf);

  if angka<=99 then  // dalam angka
     hsl := formatfloat('00', angka)
  else // dalam huruf
  begin
     angka := angka - 99;
     if angka<=jh then
     begin
        hsl := '0'+hrf[ angka ];
     end
     else
     begin
        A1 := angka div jh;
        A2 := angka - A1*jh;
        hsl := hrf[A1]+hrf[A2];
     end;
  end;

  result := hsl;
end;

end.

