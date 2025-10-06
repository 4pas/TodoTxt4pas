unit Test.TodoTxt.TodoItem.Priority;

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

type
    [TestFixture]
    TTestTodoItemPriority = class
    public
        [Test]
        procedure SetPriority_Adding;

        [Test]
        procedure SetPriority_Updating;

        [Test]
        procedure SetPriority_Removing;

        [Test]
        procedure SetPriority_ThrowsOnInvalidInput;

        [Test]
        procedure ClearPriority_ClearsPriority;
    end;

implementation

(*
Original test: setPriority › Adding

test('setPriority › Adding', (t) => {
    const item = new Item('I have to do this.');
    item.setPriority('T');
    t.is(item.priority(), 'T');
    t.is(item.toString(), '(T) I have to do this.');
});
*)
procedure TTestTodoItemPriority.SetPriority_Adding;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create('I have to do this.');
    Item.SetPriority('T');

    Assert.AreEqual('T', Item.Priority);
    Assert.AreEqual('(T) I have to do this.', Item.ToString);
end;

(*
Original test: setPriority › Updating

test('setPriority › Updating', (t) => {
    const item = new Item('(Z) I have to do this.');
    item.setPriority('T');
    t.is(item.priority(), 'T');
    t.is(item.toString(), '(T) I have to do this.');
});
*)
procedure TTestTodoItemPriority.SetPriority_Updating;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create('(Z) I have to do this.');
    Item.SetPriority('T');

    Assert.AreEqual('T', Item.Priority);
    Assert.AreEqual('(T) I have to do this.', Item.ToString);
end;

(*
Original test: setPriority › Removing

test('setPriority › Removing', (t) => {
    const item = new Item('(L) I have to do this.');
    item.setPriority();
    t.is(item.priority(), null);
    t.is(item.toString(), 'I have to do this.');
});
*)
procedure TTestTodoItemPriority.SetPriority_Removing;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create('(L) I have to do this.');
    // calling without parameter clears priority in JS; in Delphi pass empty string
    Item.SetPriority('');

    Assert.AreEqual('', Item.Priority);
    Assert.AreEqual('I have to do this.', Item.ToString);
end;

(*
Original test: setPriority › Throws an exception when provided invalid input

test('setPriority › Throws an exception when provided invalid input', (t) => {
    const item = new Item('(L) I have to do this.');
    t.throws(() => item.setPriority('6'));
});
*)
procedure TTestTodoItemPriority.SetPriority_ThrowsOnInvalidInput;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create('(L) I have to do this.');
    Assert.WillRaise(
        procedure
        begin
            Item.SetPriority('6');
        end,
        ETodoListError
    );
end;

(*
Original test: clearPriority › Clears the priority from a task

test('clearPriority › Clears the priority from a task', (t) => {
    const item = new Item('(L) I have to do this.');
    item.clearPriority();
    t.is(item.priority(), null);
});
*)
procedure TTestTodoItemPriority.ClearPriority_ClearsPriority;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create('(L) I have to do this.');
    Item.ClearPriority;

    Assert.AreEqual('', Item.Priority);
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemPriority);

end.
