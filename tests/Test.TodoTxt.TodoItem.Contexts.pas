unit Test.TodoTxt.TodoItem.Contexts;

{
  Copyright (c) 2025 marvotron.de

  This Source Code is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at https://mozilla.org/MPL/2.0/.

  This file incorporates work covered by the following copyright and
  permission notice:

    Original Copyright (c) 2011 John Hobbs

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE
}

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    TodoTxt.TodoItem;

const
    SampleCompleted: string =
        'x (Z) 2022-10-17 We should keep +todoItems in their @place when rendering out due:2022-10-22';

type
    [TestFixture]
    TTestTodoItemContexts = class
    public
        [Test]
        procedure Contexts_Deduplicated;

        [Test]
        procedure Contexts_DoesNotParseEmailAsContext;

        [Test]
        procedure Contexts_ParsesContextAtStartOfLine;

        [Test]
        procedure AddContext_AddsNewContexts;

        [Test]
        procedure AddContext_DoesNotAddExisting;

        [Test]
        procedure AddContext_UpdatesBody;

        [Test]
        procedure RemoveContext_RemovesContexts;

        [Test]
        procedure RemoveContext_RemovesContextsWhenNonePresent;

        [Test]
        procedure RemoveContext_UpdatesBody;

        [Test]
        procedure Contexts_DoesNotParseEmailAddresses;
    end;

implementation

uses
    Mv.StringList;

function ContainsString(const Arr: TArray<string>; const Value: string): Boolean;
var
    I: Integer;
begin
    Result := False;
    for I := 0 to Length(Arr) - 1 do
        if Arr[I] = Value then
        begin
            Result := True;
            Exit;
        end;
end;

(*
Original test: contexts › Deduplicated

test('contexts › Deduplicated', (t) => {
    const item = new Item('Hello @home and @work with +projects and @work extensions:todo');
    t.deepEqual(item.contexts(), ['home', 'work']);
});
*)
procedure TTestTodoItemContexts.Contexts_Deduplicated;
var
    Item: ITodoItem;
    Ctxs: IStringList;
begin
    Item := TITodoItem.Create('Hello @home and @work with +projects and @work extensions:todo');
    Ctxs := Item.GetContexts;
    Assert.AreEqual(2, Ctxs.Count);
    Assert.AreEqual('home', Ctxs[0]);
    Assert.AreEqual('work', Ctxs[1]);
end;

(*
Original test: contexts › Does not parse email as context

test('contexts › Does not parse email as context', (t) => {
    const item = new Item('My email is me@example.com it is not a context');
    t.deepEqual(item.contexts(), []);
});
*)
procedure TTestTodoItemContexts.Contexts_DoesNotParseEmailAsContext;
var
    Item: ITodoItem;
    Ctxs: IStringList;
begin
    Item := TITodoItem.Create('My email is me@example.com it is not a context');
    Ctxs := Item.GetContexts;
    Assert.AreEqual(0, Ctxs.Count);
end;

(*
Original test: contexts › Parses context at start of line

test('contexts › Parses context at start of line', (t) => {
    const item = new Item('@home wash the dishes');
    t.deepEqual(item.contexts(), ['home']);
});
*)
procedure TTestTodoItemContexts.Contexts_ParsesContextAtStartOfLine;
var
    Item: ITodoItem;
    Ctxs: IStringList;
begin
    Item := TITodoItem.Create('@home wash the dishes');
    Ctxs := Item.GetContexts;
    Assert.AreEqual(1, Ctxs.Count);
    Assert.AreEqual('home', Ctxs[0]);
end;

(*
Original test: addContext › Adds new contexts

test('addContext › Adds new contexts', (t) => {
    const item = new Item(sampleCompleted);
    item.addContext('computer');
    t.deepEqual(item.contexts(), ['place', 'computer']);
});
*)
procedure TTestTodoItemContexts.AddContext_AddsNewContexts;
var
    Item: ITodoItem;
    Ctxs: IStringList;
begin
    Item := TITodoItem.Create(SampleCompleted);
    Item.AddContext('computer');
    Ctxs := Item.GetContexts;
    Assert.AreEqual(2, Ctxs.Count);
    Assert.AreEqual('place', Ctxs[0]);
    Assert.AreEqual('computer', Ctxs[1]);
end;

(*
Original test: addContext › Does not add contexts which already exist

test('addContext › Does not add contexts which already exist', (t) => {
    const item = new Item(sampleCompleted);
    item.addContext(
        'place'
    );
    t.deepEqual(item.contexts(), ['place']);
});
*)
procedure TTestTodoItemContexts.AddContext_DoesNotAddExisting;
var
    Item: ITodoItem;
    Ctxs: IStringList;
begin
    Item := TITodoItem.Create(SampleCompleted);
    Item.AddContext('place');
    Ctxs := Item.GetContexts;
    Assert.AreEqual(1, Ctxs.Count);
    Assert.AreEqual('place', Ctxs[0]);
end;

(*
Original test: addContext › Updates the body

test('addContext › Updates the body', (t) => {
    const item = new Item(sampleCompleted);
    item.addContext('computer');
    t.is(item.body().indexOf('@computer') !== -1, true);
});
*)
procedure TTestTodoItemContexts.AddContext_UpdatesBody;
var
    Item: ITodoItem;
    BodyStr: string;
begin
    Item := TITodoItem.Create(SampleCompleted);
    Item.AddContext('computer');
    BodyStr := Item.Body;
    Assert.IsTrue(Pos('@computer', BodyStr) > 0);
end;

(*
Original test: removeContext › Removes contexts

test('removeContext › Removes contexts', (t) => {
    const item = new Item('Hello @home and @work with +projects and @work extensions:todo');
    item.removeContext('work');
    t.deepEqual(item.contexts(), ['home']);
});
*)
procedure TTestTodoItemContexts.RemoveContext_RemovesContexts;
var
    Item: ITodoItem;
    Ctxs: IStringList;
begin
    Item := TITodoItem.Create('Hello @home and @work with +projects and @work extensions:todo');
    Item.RemoveContext('work');
    Ctxs := Item.GetContexts;
    Assert.AreEqual(1, Ctxs.Count);
    Assert.AreEqual('home', Ctxs[0]);
end;

(*
Original test: removeContext › Removes contexts (none present)

test('removeContext › Removes contexts (none present)', (t) => {
    const item = new Item('Hello and world');
    item.removeContext('work');
    t.is(item.body(), 'Hello and world');
});
*)
procedure TTestTodoItemContexts.RemoveContext_RemovesContextsWhenNonePresent;
var
    Item: ITodoItem;
    BodyStr: string;
begin
    Item := TITodoItem.Create('Hello and world');
    Item.RemoveContext('work');
    BodyStr := Item.Body;
    Assert.AreEqual('Hello and world', BodyStr);
end;

(*
Original test: removeContext › Updates the body

test('removeContext › Updates the body', (t) => {
    const item = new Item('Hello @home and @work with +projects and @work extensions:todo');
    item.removeContext('work');
    t.is(item.body(), 'Hello @home and with +projects and extensions:todo');
});
*)
procedure TTestTodoItemContexts.RemoveContext_UpdatesBody;
var
    Item: ITodoItem;
    BodyStr: string;
begin
    Item := TITodoItem.Create('Hello @home and @work with +projects and @work extensions:todo');
    Item.RemoveContext('work');
    BodyStr := Item.Body;
    Assert.AreEqual('Hello @home and with +projects and extensions:todo', BodyStr);
end;

(*
Original test: contexts › Does not parse email addresses

test('contexts › Does not parse email addresses', (t) => {
    const item = new Item(
        'me@example.com Hello @home and name@example.com with +projects extensions:todo'
    );
    t.deepEqual(item.contexts(), ['home']);
});
*)
procedure TTestTodoItemContexts.Contexts_DoesNotParseEmailAddresses;
var
    Item: ITodoItem;
    Ctxs: IStringList;
begin
    Item := TITodoItem.Create('me@example.com Hello @home and name@example.com with +projects extensions:todo');
    Ctxs := Item.GetContexts;
    Assert.AreEqual(1, Ctxs.Count);
    Assert.AreEqual('home', Ctxs[0]);
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemContexts);

end.

