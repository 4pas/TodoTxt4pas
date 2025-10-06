unit Test.Mv.Todo.TodoItem.Inputs;

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    System.DateUtils,
    Mv.Todo.TodoItem;

type
    [TestFixture]
    TTestTodoItemInputs = class
    public
        [Test]
        procedure Constructor_Basic;

        [Test]
        procedure Constructor_Complete;

        [Test]
        procedure Parse_ResetsEverything;
    end;

implementation

const
    NO_DATE: TDateTime = 0;

(*
Original TypeScript file: Item.inputs.test.ts

import test, { ExecutionContext } from 'ava';
import { Item } from './Item';

interface Extension {
    key: string;
    value: string;
}

function compare(
    t: ExecutionContext,
    item: Item,
    complete: boolean,
    priority: string | null,
    created: Date | null,
    completed: Date | null,
    body: string,
    contexts: string[],
    projects: string[],
    extensions: Extension[]
) {
    t.is(item.complete(), complete);
    t.is(item.priority(), priority);
    t.deepEqual(item.created(), created);
    t.deepEqual(item.completed(), completed);
    t.is(item.body(), body);
    t.deepEqual(item.projects(), projects);
    t.deepEqual(item.contexts(), contexts);
    t.deepEqual(item.extensions(), extensions);
}

function constructAndCompare(
    t: ExecutionContext,
    input: string,
    complete: boolean,
    priority: string | null,
    created: Date | null,
    completed: Date | null,
    body: string,
    contexts: string[],
    projects: string[],
    extensions: Extension[]
) {
    const item = new Item(input);
    compare(t, item, complete, priority, created, completed, body, contexts, projects, extensions);
}

test(
    'Constructor › Basic',
    constructAndCompare,
    'Just the body.',
    false,
    null,
    null,
    null,
    'Just the body.',
    [],
    [],
    []
);

test(
    'Constructor › Complete',
    constructAndCompare,
    'x (A) 2016-01-03 2016-01-02 measure space for +chapelShelving @chapel due:2016-01-04',
    true,
    'A',
    new Date(2016, 0, 2),
    new Date(2016, 0, 3),
    'measure space for +chapelShelving @chapel due:2016-01-04',
    ['chapel'],
    ['chapelShelving'],
    [{ key: 'due', value: '2016-01-04' }]
);

test('parse › Resets everything', (t) => {
    const item = new Item(
        'x (A) 2016-01-03 2016-01-02 measure space for +chapelShelving @chapel due:2016-01-04'
    );
    item.parse('Hello');
    compare(t, item, false, null, null, null, 'Hello', [], [], []);
});
*)

(* Original test: Constructor › Basic *)
procedure TTestTodoItemInputs.Constructor_Basic;
var
    ItemObj: ITodoItem;
begin
    ItemObj := TITodoItem.Create('Just the body.') as ITodoItem;

    Assert.IsFalse(ItemObj.Complete);
    Assert.AreEqual('', ItemObj.Priority);
    Assert.AreEqual(NO_DATE, ItemObj.Created);
    Assert.AreEqual(NO_DATE, ItemObj.Completed);
    Assert.AreEqual('Just the body.', ItemObj.Body);
    Assert.AreEqual(0, Length(ItemObj.Projects));
    Assert.AreEqual(0, Length(ItemObj.Contexts));
    Assert.AreEqual(0, Length(ItemObj.Extensions));
end;

(* Original test: Constructor › Complete *)
procedure TTestTodoItemInputs.Constructor_Complete;
var
    ItemObj: ITodoItem;
    CreatedDate: TDateTime;
    CompletedDate: TDateTime;
begin
    ItemObj := TITodoItem.Create('x (A) 2016-01-03 2016-01-02 measure space for +chapelShelving @chapel due:2016-01-04') as ITodoItem;

    Assert.IsTrue(ItemObj.Complete);
    Assert.AreEqual('A', ItemObj.Priority);

    // JS new Date(2016,0,2) => 2016-01-02
    CreatedDate := EncodeDate(2016, 1, 2);
    // JS new Date(2016,0,3) => 2016-01-03
    CompletedDate := EncodeDate(2016, 1, 3);

    Assert.AreEqual(CreatedDate, ItemObj.Created);
    Assert.AreEqual(CompletedDate, ItemObj.Completed);
    Assert.AreEqual('measure space for +chapelShelving @chapel due:2016-01-04', ItemObj.Body);

    Assert.AreEqual(1, Length(ItemObj.Contexts));
    Assert.AreEqual('chapel', ItemObj.Contexts[0]);

    Assert.AreEqual(1, Length(ItemObj.Projects));
    Assert.AreEqual('chapelShelving', ItemObj.Projects[0]);

    Assert.AreEqual(1, Length(ItemObj.Extensions));
    Assert.AreEqual('due', ItemObj.Extensions[0].Key);
    Assert.AreEqual('2016-01-04', ItemObj.Extensions[0].Value);
end;

(* Original test: parse › Resets everything *)
procedure TTestTodoItemInputs.Parse_ResetsEverything;
var
    ItemObj: ITodoItem;
    Ctxs: TArray<string>;
    Projs: TArray<string>;
    Exts: TArray<TTrackedExtension>;
begin
    ItemObj := TITodoItem.Create('x (A) 2016-01-03 2016-01-02 measure space for +chapelShelving @chapel due:2016-01-04') as ITodoItem;
    ItemObj.Parse('Hello');

    Assert.IsFalse(ItemObj.Complete);
    Assert.AreEqual('', ItemObj.Priority);
    Assert.AreEqual(NO_DATE, ItemObj.Created);
    Assert.AreEqual(NO_DATE, ItemObj.Completed);
    Assert.AreEqual('Hello', ItemObj.Body);

    Ctxs := ItemObj.Contexts;
    Projs := ItemObj.Projects;
    Exts := ItemObj.Extensions;

    Assert.AreEqual(0, Length(Ctxs));
    Assert.AreEqual(0, Length(Projs));
    Assert.AreEqual(0, Length(Exts));
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemInputs);

end.
