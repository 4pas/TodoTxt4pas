unit Mv.LibBase;

{
    Mv-Lib functions, that are used in this project

    Copyright (c) 2025 marvotron.de

    This code is licensed under the Mozilla Public License, version 2.0 (MPL 2.0).
    You may obtain a copy of the license at:
    https://opensource.org/licenses/MPL-2.0

}


interface

uses
    System.SysUtils;

//Mv.BaseUtils
function Cat(const AStr1, AStr2, AConcatenator: string): string;


implementation


{ ConCATenation of 2 strings with AConcatenator if both are not empty (also @see Cat)
  e.g.:
    Cat('Hello', 'world', #13#10) -> 'Hello'#13#10'world' //#
    Cat('', 'world', #13#10) -> 'world' //#
------------------------------------------------------------------------------------------------------------------}
function Cat(const AStr1, AStr2, AConcatenator: string): string;
begin
    if AStr2 = '' then
      Result := AStr1
    else if AStr1 = '' then
      Result := AStr2
    else
      Result := AStr1 + AConcatenator + AStr2;
end;

end.
