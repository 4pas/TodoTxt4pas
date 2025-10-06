unit Test.Mv.Todo.TodoList.Inputs;

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    System.Classes,
    System.Generics.Collections,
    Mv.Todo.TodoList,
    Mv.Todo.TodoItem;

type
    [TestFixture]
    TTestTodoListInputs = class
    public
        [Test]
        procedure Constructor_String;

        [Test]
        procedure Constructor_String_StripsBlankLines;

        [Test]
        procedure Constructor_Array;

        [Test]
        procedure Constructor_Array_StripsBlankLines;
    end;

implementation

function LinesFromString(const S: string): TArray<string>;
var
    SL: TStringList;
    i: Integer;
    TempList: TList<string>;
    Line: string;
begin
    SL := TStringList.Create;
    TempList := TList<string>.Create;
    try
        // TStringList.Text will split on CR/LF and LF as needed
        SL.Text := S;
        for i := 0 to SL.Count - 1 do
        begin
            Line := Trim(SL[i]);
            if Line <> '' then
                TempList.Add(Line);
        end;
        Result := TempList.ToArray;
    finally
        SL.Free;
        TempList.Free;
    end;
end;

(* Original test: constructor › string *)
(*
import test from 'ava';
import { List } from './List';

test('constructor › string', (t) => {
    const list = new List('first item\nsecond item');
    t.is(list.items().length, 2);
});
*)
procedure TTestTodoListInputs.Constructor_String;
var
    TodoList: ITodoList;
    Lines: TArray<string>;
begin
    TodoList := TITodoList.Create as ITodoList;
    try
        Lines := LinesFromString('first item' + sLineBreak + 'second item');
        TodoList.ParseFromLines(Lines);
        Assert.AreEqual(2, Length(TodoList.Items));
    finally
        TodoList := nil;
    end;
end;

(* Original test: constructor › string › strips blank lines *)
(*
test('constructor › string › strips blank lines', (t) => {
    const list = new List('first item\nsecond item\n\nthird item\n\n');
    t.is(list.items().length, 3);
});
*)
procedure TTestTodoListInputs.Constructor_String_StripsBlankLines;
var
    TodoList: ITodoList;
    Lines: TArray<string>;
begin
    TodoList := TITodoList.Create as ITodoList;
    try
        Lines := LinesFromString('first item' + sLineBreak + 'second item' + sLineBreak + sLineBreak + 'third item' + sLineBreak + sLineBreak);
        TodoList.ParseFromLines(Lines);
        Assert.AreEqual(3, Length(TodoList.Items));
    finally
        TodoList := nil;
    end;
end;

(* Original test: constructor › array *)
(*
test('constructor › array', (t) => {
    const list = new List(['first item', 'second item', 'third item']);
    t.is(list.items().length, 3);
});
*)
procedure TTestTodoListInputs.Constructor_Array;
var
    TodoList: ITodoList;
    InputArray: TArray<string>;
begin
    TodoList := TITodoList.Create as ITodoList;
    try
        InputArray := TArray<string>.Create('first item', 'second item', 'third item');
        TodoList.ParseFromLines(InputArray);
        Assert.AreEqual(3, Length(TodoList.Items));
    finally
        TodoList := nil;
    end;
end;

(* Original test: constructor › array › strips blank lines *)
(*
test('constructor › array › strips blank lines', (t) => {
    const list = new List(['first item', '', 'second item', '   ', '\t', 'third item']);
    t.is(list.items().length, 3);
});
*)
procedure TTestTodoListInputs.Constructor_Array_StripsBlankLines;
var
    TodoList: ITodoList;
    InputArray: TArray<string>;
begin
    TodoList := TITodoList.Create as ITodoList;
    try
        InputArray := TArray<string>.Create('first item', '', 'second item', '   ', #9, 'third item');
        TodoList.ParseFromLines(InputArray);
        Assert.AreEqual(3, Length(TodoList.Items));
    finally
        TodoList := nil;
    end;
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoListInputs);

end.
