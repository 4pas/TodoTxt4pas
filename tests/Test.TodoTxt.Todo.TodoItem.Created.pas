unit Test.TodoTxt.Todo.TodoItem.Created;

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
    System.DateUtils,
    TodoTxt.TodoItem;

type
    [TestFixture]
    TTestTodoItemCreated = class
    public
        [Test]
        procedure SetCreatedAddingWithDate;

        [Test]
        procedure SetCreatedAddingWithString;

        [Test]
        procedure SetCreatedUpdatingWithDate;

        [Test]
        procedure SetCreatedUpdatingWithString;

        [Test]
        procedure SetCreatedRemovingWorks;

        [Test]
        procedure SetCreatedRemovingAlsoRemovesCompletedDate;

        [Test]
        procedure SetCreatedThrowsOnInvalidInput;
    end;

implementation

(*
Original test: setCreated › Adding with Date

test('setCreated › Adding with Date', (t) => {
    const item = new Item('I have to do this.');
    const due = new Date(2022, 7, 1);
    item.setCreated(due);
    t.deepEqual(item.created(), due);
});
*)
procedure TTestTodoItemCreated.SetCreatedAddingWithDate;
var
    Item: ITodoItem;
    D: TDateTime;
begin
    // Ported from original test above
    Item := TITodoItem.Create('I have to do this.');
    D := EncodeDate(2022, 8, 1); // JS new Date(2022,7,1) -> 2022-08-01
    Item.SetCreated(D);
    Assert.AreEqual(D, Item.Created);
end;

(*
Original test: setCreated › Adding with string

test('setCreated › Adding with string', (t) => {
    const item = new Item('I have to do this.');
    const due = new Date(2022, 6, 1);
    item.setCreated('2022-07-01');
    t.deepEqual(item.created(), due);
});
*)
procedure TTestTodoItemCreated.SetCreatedAddingWithString;
var
    Item: ITodoItem;
    D: TDateTime;
begin
    Item := TITodoItem.Create('I have to do this.');
    Item.SetCreated('2022-07-01');
    D := EncodeDate(2022, 7, 1); // JS new Date(2022,6,1)
    Assert.AreEqual(D, Item.Created);
end;

(*
Original test: setCreated › Updating with Date

test('setCreated › Updating with Date', (t) => {
    const item = new Item('1999-04-12 I have to do this.');
    const due = new Date(2022, 7, 1);
    item.setCreated(due);
    t.deepEqual(item.created(), due);
});
*)
procedure TTestTodoItemCreated.SetCreatedUpdatingWithDate;
var
    Item: ITodoItem;
    D: TDateTime;
begin
    Item := TITodoItem.Create('1999-04-12 I have to do this.');
    D := EncodeDate(2022, 8, 1);
    Item.SetCreated(D);
    Assert.AreEqual(D, Item.Created);
end;

(*
Original test: setCreated › Updating with string

test('setCreated › Updating with string', (t) => {
    const item = new Item('1999-04-12 I have to do this.');
    item.setCreated('2022-07-01');
    t.deepEqual(item.created(), new Date(2022, 6, 1));
});
*)
procedure TTestTodoItemCreated.SetCreatedUpdatingWithString;
var
    Item: ITodoItem;
    D: TDateTime;
begin
    Item := TITodoItem.Create('1999-04-12 I have to do this.');
    Item.SetCreated('2022-07-01');
    D := EncodeDate(2022, 7, 1);
    Assert.AreEqual(D, Item.Created);
end;

(*
Original test: setCreated › Removing works

test('setCreated › Removing works', (t) => {
    const item = new Item('x 2022-05-23 1999-04-12 I have to do this.');
    item.setCreated();
    t.is(item.created(), null);
});
*)
procedure TTestTodoItemCreated.SetCreatedRemovingWorks;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create('x 2022-05-23 1999-04-12 I have to do this.');
    Item.SetCreatedNull;
    Assert.AreEqual(NO_DATE, Item.Created);
end;

(*
Original test: setCreated › Removing also removes completed date

test('setCreated › Removing also removes completed date', (t) => {
    const item = new Item('x 2022-05-23 1999-04-12 I have to do this.');
    item.setCreated();
    t.is(item.created(), null);
    t.is(item.completed(), null);
});
*)
procedure TTestTodoItemCreated.SetCreatedRemovingAlsoRemovesCompletedDate;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create('x 2022-05-23 1999-04-12 I have to do this.');
    Item.SetCreatedNull;
    Assert.AreEqual(NO_DATE, Item.Created);
    Assert.AreEqual(NO_DATE, Item.Completed);
end;

(*
Original test: setCreated › Throws an exception for invalid input

test('setCreated › Throws an exception for invalid input', (t) => {
    const item = new Item('I have to do this.');
    t.throws(() => item.setCreated('20220102'));
});
*)
procedure TTestTodoItemCreated.SetCreatedThrowsOnInvalidInput;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create('I have to do this.');
    Assert.WillRaise(
        procedure
        begin
            Item.SetCreated('20220102');
        end,
        ETodoListError
    );
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemCreated);

end.

