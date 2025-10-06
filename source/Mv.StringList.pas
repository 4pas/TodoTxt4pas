unit Mv.StringList;

{
    IStringList - Interfaced access to TStringList

    Copyright (c) 2025 marvotron.de

    This code is licensed under the Mozilla Public License, version 2.0 (MPL 2.0).
    You may obtain a copy of the license at:
    https://opensource.org/licenses/MPL-2.0

    Inspired by
    http://www.dummzeuch.de/delphi/object_pascal_interfaces2/deutsch.html
}

interface

uses
    System.Classes,
    System.SysUtils;

type

    { Interface for StringList
    --------------------------------------------------------------------------------------------------------------}
    IStringList = interface
    ['{2764EDD4-1743-4D58-9554-60D75583E327}']
        function Add(const S: string): Integer;
        function AddObject(const S: string; AObject: TObject): Integer;
        procedure Append(const S: string);
        procedure AddStrings(Strings: TStrings);
        procedure Assign(Source: TPersistent);
        procedure BeginUpdate;
        procedure Clear;
        procedure Delete(Index: Integer);
        procedure EndUpdate;
        function Equals(Strings: TStrings): Boolean;
        procedure Exchange(Index1, Index2: Integer);
        function GetText: PChar;
        function IndexOf(const S: string): Integer;
        function IndexOfName(const Name: string): Integer;
        function IndexOfObject(AObject: TObject): Integer;
        procedure Insert(Index: Integer; const S: string);
        procedure InsertObject(Index: Integer; const S: string;
          AObject: TObject);
        procedure LoadFromFile(const FileName: string);
        procedure LoadFromStream(Stream: TStream);
        procedure Move(CurIndex, NewIndex: Integer);
        procedure SaveToFile(const FileName: string); overload;
        procedure SaveToFile(const FileName: string; Encoding: TEncoding); overload;
        procedure SaveToStream(Stream: TStream);
        procedure SetText(Text: PChar);
        //only Implementation of properties
        function Get(Index: Integer): string;
        function GetCapacity: Integer;
        function GetCount: Integer;
        function GetObject(Index: Integer): TObject;
        function GetTextStr: string;
        procedure Put(Index: Integer; const S: string);
        procedure PutObject(Index: Integer; AObject: TObject);
        procedure SetCapacity(NewCapacity: Integer);
        procedure SetTextStr(const Value: string);
        procedure SetUpdateState(Updating: Boolean);
        function GetCommaText: string;
        procedure SetCommaText(const Value: string);
        function GetDelimitedText: string;
        procedure SetDelimitedText(const Value: string);
        function GetDelimiter: Char;
        procedure SetDelimiter(const Value: Char);
        function GetName(Index: Integer): string;
        function GetValue(const Name: string): string;
        procedure SetValue(const Name, Value: string);
        function GetValueFromIndex(Index: Integer): string;
        procedure SetValueFromIndex(Index: Integer; const Value: string);
        function GetDuplicates: TDuplicates;
        procedure SetDuplicates(const Value: TDuplicates);
        function GetSorted: Boolean;
        procedure SetSorted(const Value: Boolean);
        function GetCaseSensitive: Boolean;
        procedure SetCaseSensitive(const Value: Boolean);
        function GetOwnsObjects: Boolean;
        procedure SetOwnsObjects(const Value: Boolean);
        function GetQuoteChar: Char;
        procedure SetQuoteChar(const Value: Char);

        //properties
        property Capacity: Integer read GetCapacity write SetCapacity;
        property CommaText: string read GetCommaText write SetCommaText;
        property Count: Integer read GetCount;
        property Names[Index: Integer]: string read GetName;
        property Objects[Index: Integer]: TObject read GetObject write PutObject;
        property Values[const Name: string]: string read GetValue write SetValue;
        property ValueFromIndex[Index: Integer]: string read GetValueFromIndex write SetValueFromIndex;
        property Strings[Index: Integer]: string read Get write Put; default;
        property Text: string read GetTextStr write SetTextStr;
        property Duplicates: TDuplicates read GetDuplicates write SetDuplicates;
        property Sorted: Boolean read GetSorted write SetSorted;
        property CaseSensitive: Boolean read GetCaseSensitive write SetCaseSensitive;
        property DelimitedText: string read GetDelimitedText write SetDelimitedText;
        property Delimiter: Char read GetDelimiter write SetDelimiter;
        property OwnsObjects: Boolean read GetOwnsObjects write SetOwnsObjects;
        property QuoteChar: Char read GetQuoteChar write SetQuoteChar;

        function GetEnumerator: TStringsEnumerator;

        //TODO: Delphi >XE2 supports OwnsObjects, this should be supported here as well

        //Native access
        function AsTStrings: TStrings;

        function AddNameValue(AName: string; AValue: string): Integer;
        function NamesAsIStringList: IStringList;
        function ValuesAsIStringList: IStringList;
        procedure AppendEach(sToAppend: string);
        procedure AddIStringList(Strings: IStringList); //Fehler bei AddStrings?
        function ToStringArray: TArray<string>;
    end;

    { Helper class - some functions necessary for IStringList are only available via their properties
    --------------------------------------------------------------------------------------------------------------}
    TExtStringList = class(TStringList)
    public
        function GetCommaText: string;
        procedure SetCommaText(const Value: string);
        function GetDelimitedText: string;
        procedure SetDelimitedText(const Value: string);
        function GetDelimiter: Char;
        procedure SetDelimiter(const Value: Char);
        function GetName(Index: Integer): string;
        function GetValue(const Name: string): string;
        procedure SetValue(const Name, Value: string);
        function GetValueFromIndex(Index: Integer): string;
        procedure SetValueFromIndex(Index: Integer; const Value: string);
        function GetDuplicates: TDuplicates;
        procedure SetDuplicates(const Value: TDuplicates);
        function GetSorted: Boolean;
        procedure SetSorted(const Value: Boolean);
        function GetCaseSensitive: Boolean;
        procedure SetCaseSensitive(const Value: Boolean);
        function GetOwnsObjects: Boolean;
        procedure SetOwnsObjects(const Value: Boolean);
        function GetQuoteChar: Char;
        procedure SetQuoteChar(const Value: Char);
    end;

    { Implementation of IStringList
    --------------------------------------------------------------------------------------------------------------}
    TIStringList = class(TInterfacedObject, IStringList)
    private
        FStringList: TExtStringList;
    protected
        property Strings: TExtStringList read FStringList implements IStringList;
        function AsTStrings: TStrings;
        function AddNameValue(AName: string; AValue: string): Integer;
        function NamesAsIStringList: IStringList;
        function ValuesAsIStringList: IStringList;
        procedure AppendEach(AToAppend: string);
        procedure AddIStringList(AStrings: IStringList);
    public
       constructor Create();
       constructor CreateIgnoreDuplicates();
        destructor Destroy; override;
    end;


implementation


uses
    System.Types;

{*****************************************************************************************************************}
{$region 'TExtStringList'}
{*****************************************************************************************************************}
//wrappers for private functions

function TExtStringList.GetCaseSensitive: Boolean;
begin
    Result := CaseSensitive;
end;
function TExtStringList.GetCommaText: string;
begin
    Result := CommaText;
end;
function TExtStringList.GetDelimitedText: string;
begin
    Result := DelimitedText;
end;
function TExtStringList.GetDelimiter: Char;
begin
    Result := Delimiter;
end;

function TExtStringList.GetDuplicates: TDuplicates;
begin
    Result := Duplicates;
end;

function TExtStringList.GetName(Index: Integer): string;
begin
    Result := Names[Index];
end;
function TExtStringList.GetOwnsObjects: Boolean;
begin
    Result := OwnsObjects;
end;

function TExtStringList.GetQuoteChar: Char;
begin
    Result := QuoteChar;
end;

function TExtStringList.GetSorted: Boolean;
begin
    Result := Sorted;
end;
function TExtStringList.GetValue(const Name: string): string;
begin
    Result := Values[Name];
end;

function TExtStringList.GetValueFromIndex(Index: Integer): string;
begin
   Result:= ValueFromIndex[Index];
end;

procedure TExtStringList.SetValueFromIndex(Index: Integer; const Value: string);
begin
   ValueFromIndex[Index]:= Value;
end;

procedure TExtStringList.SetCaseSensitive(const Value: Boolean);
begin
    CaseSensitive := Value;
end;

procedure TExtStringList.SetCommaText(const Value: string);
begin
    CommaText := Value;
end;
procedure TExtStringList.SetDelimitedText(const Value: string);
begin
    DelimitedText := Value;
end;
procedure TExtStringList.SetDelimiter(const Value: Char);
begin
    Delimiter := Value;
    //StrictDelimiter := True;
end;

procedure TExtStringList.SetDuplicates(const Value: TDuplicates);
begin
    Duplicates := Value;
end;

procedure TExtStringList.SetOwnsObjects(const Value: Boolean);
begin
    OwnsObjects := Value;
end;

procedure TExtStringList.SetQuoteChar(const Value: Char);
begin
    QuoteChar := Value;
end;

procedure TExtStringList.SetSorted(const Value: Boolean);
begin
    Sorted := Value;
end;

procedure TExtStringList.SetValue(const Name, Value: string);
begin
    Values[Name] := Value;
end;

{$endregion 'TExtStringList'}


{*****************************************************************************************************************}
{TIStringList}
{*****************************************************************************************************************}

{ Standard constructor
------------------------------------------------------------------------------------------------------------------}
constructor TIStringList.Create();
begin
    inherited Create;
    FStringList := TExtStringList.Create();
end;

{ Create a string list in dupIgnore mode: "Ignore attempts to add duplicate strings to the list."
  This will create a sorted list!
------------------------------------------------------------------------------------------------------------------}
constructor TIStringList.CreateIgnoreDuplicates();
begin
    Create();
    Strings.Sorted := True;   //notwendig für Duplicates !
    Strings.Duplicates := dupIgnore;
end;

{
------------------------------------------------------------------------------------------------------------------}
destructor TIStringList.Destroy;
begin
    FreeAndNil(FStringList);
    inherited;
end;

{ like AddStrings, but for IStringList
------------------------------------------------------------------------------------------------------------------}
procedure TIStringList.AddIStringList(AStrings: IStringList);
begin
    if Assigned(AStrings) then
      Strings.AddStrings(AStrings.AsTStrings);
end;

//better use INameValueList for this kind of functionality
{ Adds a name value pair to the list
------------------------------------------------------------------------------------------------------------------}
function TIStringList.AddNameValue(AName, AValue: string): Integer;
begin
    Assert(not AName.Contains('='));
    //---
    Result := Strings.Add(Format('%s=%s', [AName, AValue]));
end;


{ Append every string of the list with AToAppend
------------------------------------------------------------------------------------------------------------------}
procedure TIStringList.AppendEach(AToAppend: string);
var
    I: Integer;
begin
    for I := 0 to Strings.Count - 1 do
      Strings[I] := Strings[I] + AToAppend;
end;

//moved to Mv.StringListUtils: StringsToVariantArray
//function TIStringList.AsArrayOfVar: TVariantArray;

//moved to Mv.SqlUtis:
//function TIStringList.AsSqlStrCommaText(): String;


{ Native Access.
  **Be very careful**. You need to make sure that there exists a reference to this IStringList as long as
  the result of this function stays referenced.
------------------------------------------------------------------------------------------------------------------}
function TIStringList.AsTStrings: TStrings;
begin
    Result := Strings;
end;

{ If the string list contains name value pairs,
  this function returns all names as IStringList
------------------------------------------------------------------------------------------------------------------}
function TIStringList.NamesAsIStringList: IStringList;
var
    I: Integer;
begin
    Result:= TIStringList.Create;
    for I := 0 to Strings.Count - 1 do
      Result.Add(Strings.Names[I]);
end;

{ If the string list contains name value pairs,
  this function returns all values as IStringList
------------------------------------------------------------------------------------------------------------------}
function TIStringList.ValuesAsIStringList: IStringList;
var
    I: Integer;
begin
    Result:= TIStringList.Create;
    for I := 0 to Strings.Count - 1 do
      Result.Add(Strings.ValueFromIndex[I]);
end;


end.
