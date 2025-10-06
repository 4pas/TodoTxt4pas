unit Test.Mv.Todo.TodoList.Outputs;

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    System.Generics.Collections,
    Mv.Todo.TodoList,
    Mv.Todo.TodoItem,
    Mv.StringList;

type
    [TestFixture]
    TTestTodoListOutputs = class
    public
        [Test]
        procedure ToString_Test;

        [Test]
        procedure Projects_Test;

        [Test]
        procedure Contexts_Test;

        [Test]
        procedure Extensions_Test;
    end;

implementation

function IStringListToArray(const List: IStringList): TArray<string>;
var
    Index: Integer;
begin
    if List = nil then
    begin
        Result := nil;
        Exit;
    end;
    SetLength(Result, List.Count);
    for Index := 0 to List.Count - 1 do
        Result[Index] := List.Strings[Index];
end;

(* Original test: toString *)
(*
import test from 'ava';
import { List } from './List';

test('toString', (t) => {
    const list = new List(['first item', 'second item', 'third item']);
    t.is(list.toString(), 'first item\nsecond item\nthird item');
});
*)
procedure TTestTodoListOutputs.ToString_Test;
var
    TodoList: ITodoList;
begin
    TodoList := TITodoList.Create as ITodoList;
    try
        TodoList.ParseFromLines(TArray<string>.Create('first item', 'second item', 'third item'));
        Assert.AreEqual('first item' + sLineBreak + 'second item' + sLineBreak + 'third item', TodoList.ToString);
    finally
        TodoList := nil;
    end;
end;

(* Original test: projects *)
(*
import test from 'ava';
import { List } from './List';

test('projects', (t) => {
    const list = new List(['first +item', 'second +item', 'third +task']);
    t.deepEqual(list.projects(), ['item', 'task']);
});
*)
procedure TTestTodoListOutputs.Projects_Test;
var
    TodoList: ITodoList;
    ProjectsList: IStringList;
    ProjectsArr: TArray<string>;
begin
    TodoList := TITodoList.Create as ITodoList;
    try
        TodoList.ParseFromLines(TArray<string>.Create('first +item', 'second +item', 'third +task'));
        ProjectsList := TodoList.Projects;
        ProjectsArr := IStringListToArray(ProjectsList);

        Assert.AreEqual(2, Length(ProjectsArr));
        Assert.AreEqual('item', ProjectsArr[0]);
        Assert.AreEqual('task', ProjectsArr[1]);
    finally
        TodoList := nil;
    end;
end;

(* Original test: contexts *)
(*
import test from 'ava';
import { List } from './List';

test('contexts', (t) => {
    const list = new List(['first @item', 'second @task', 'third @item']);
    t.deepEqual(list.contexts(), ['item', 'task']);
});
*)
procedure TTestTodoListOutputs.Contexts_Test;
var
    TodoList: ITodoList;
    ContextsList: IStringList;
    ContextsArr: TArray<string>;
begin
    TodoList := TITodoList.Create as ITodoList;
    try
        TodoList.ParseFromLines(TArray<string>.Create('first @item', 'second @task', 'third @item'));
        ContextsList := TodoList.Contexts;
        ContextsArr := IStringListToArray(ContextsList);

        Assert.AreEqual(2, Length(ContextsArr));
        Assert.AreEqual('item', ContextsArr[0]);
        Assert.AreEqual('task', ContextsArr[1]);
    finally
        TodoList := nil;
    end;
end;

(* Original test: extensions *)
(*
import test from 'ava';
import { List } from './List';

test('extensions', (t) => {
    const list = new List(['first item is due:2022-01-05', 'second item h:1', 'third h:0']);
    t.deepEqual(list.extensions(), { due: ['2022-01-05'], h: ['1', '0'] });
});
*)
procedure TTestTodoListOutputs.Extensions_Test;
var
    TodoList: ITodoList;
    KeysList: IStringList;
    ValuesList: IStringList;
    KeysArr: TArray<string>;
    ValuesArr: TArray<string>;
begin
    TodoList := TITodoList.Create as ITodoList;
    try
        TodoList.ParseFromLines(
            TArray<string>.Create('first item is due:2022-01-05', 'second item h:1', 'third h:0')
        );

        KeysList := TodoList.GetExtensions;
        KeysArr := IStringListToArray(KeysList);

        // due and h
        Assert.IsTrue((Length(KeysArr) = 2) and ((KeysArr[0] = 'due') or (KeysArr[1] = 'due')));
        Assert.IsTrue((Length(KeysArr) = 2) and ((KeysArr[0] = 'h') or (KeysArr[1] = 'h')));

        ValuesList := TodoList.GetExtensionValues('due');
        ValuesArr := IStringListToArray(ValuesList);
        Assert.AreEqual(1, Length(ValuesArr));
        Assert.AreEqual('2022-01-05', ValuesArr[0]);

        ValuesList := TodoList.GetExtensionValues('h');
        ValuesArr := IStringListToArray(ValuesList);
        Assert.AreEqual(2, Length(ValuesArr));
        Assert.AreEqual('1', ValuesArr[0]);
        Assert.AreEqual('0', ValuesArr[1]);

    finally
        TodoList := nil;
    end;
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoListOutputs);

end.

