unit Test.TodoTxt.TodoItem.Extensions;

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
    TTestTodoItemExtensions = class
    public
        [Test]
        procedure Extensions_ReadsExtensions;

        [Test]
        procedure SetExtension_OverwritesExistingValues;

        [Test]
        procedure SetExtension_RemovesAdditionalValues;

        [Test]
        procedure SetExtension_NotFoundAddsNewExtension;

        [Test]
        procedure AddExtension_AllowsMultipleOfSameKey;

        [Test]
        procedure RemoveExtension_RemovesByKey;

        [Test]
        procedure RemoveExtension_RemovesByKeyAndValue;
    end;

implementation

(*
Original test: extensions › Reads extensions

test('extensions › Reads extensions', (t) => {
    const item = new Item('due:today Hello there extensions:todo and color:red');
    t.deepEqual(item.extensions(), [
        { key: 'due', value: 'today' },
        { key: 'extensions', value: 'todo' },
        { key: 'color', value: 'red' },
    ]);
});
*)
procedure TTestTodoItemExtensions.Extensions_ReadsExtensions;
var
    Item: ITodoItem;
    Exts: TExtensionArray;
begin
    Item := TITodoItem.Create('due:today Hello there extensions:todo and color:red');
    Exts := Item.GetExtensions;

    Assert.AreEqual(3, Length(Exts));
    Assert.AreEqual('due', Exts[0].Key);
    Assert.AreEqual('today', Exts[0].Value);
    Assert.AreEqual('extensions', Exts[1].Key);
    Assert.AreEqual('todo', Exts[1].Value);
    Assert.AreEqual('color', Exts[2].Key);
    Assert.AreEqual('red', Exts[2].Value);
end;

(*
Original test: setExtension › Overwrites existing values

test('setExtension › Overwrites existing values', (t) => {
    const item = new Item('Party like its due:2022-10-22');
    item.setExtension('due', '1999-12-31');
    t.deepEqual(item.extensions(), [{ key: 'due', value: '1999-12-31' }]);
    t.is(item.body(), 'Party like its due:1999-12-31');
});
*)
procedure TTestTodoItemExtensions.SetExtension_OverwritesExistingValues;
var
    Item: ITodoItem;
    Exts: TExtensionArray;
begin
    Item := TITodoItem.Create('Party like its due:2022-10-22');
    Item.SetExtension('due', '1999-12-31');
    Exts := Item.GetExtensions;

    Assert.AreEqual(1, Length(Exts));
    Assert.AreEqual('due', Exts[0].Key);
    Assert.AreEqual('1999-12-31', Exts[0].Value);
    Assert.IsTrue(Pos('due:1999-12-31', Item.Body) > 0);
end;

(*
Original test: setExtension › Removes additional values

test('setExtension › Removes additional values', (t) => {
    const item = new Item('My wall is painted the color:blue color:yellow @home for +housePainting');
    item.setExtension('color', 'red');
    t.deepEqual(item.extensions(), [{ key: 'color', value: 'red' }]);
    t.is(item.body(), 'My wall is painted the color:red @home for +housePainting');
});
*)
procedure TTestTodoItemExtensions.SetExtension_RemovesAdditionalValues;
var
    Item: ITodoItem;
    Exts: TExtensionArray;
begin
    Item := TITodoItem.Create('My wall is painted the color:blue color:yellow @home for +housePainting');
    Item.SetExtension('color', 'red');
    Exts := Item.GetExtensions;

    Assert.AreEqual(1, Length(Exts));
    Assert.AreEqual('color', Exts[0].Key);
    Assert.AreEqual('red', Exts[0].Value);
    Assert.AreEqual('My wall is painted the color:red @home for +housePainting', Item.Body);
end;

(*
Original test: setExtension › Not found

test('setExtension › Not found', (t) => {
    const item = new Item('My wall is painted the color:blue @home for +housePainting');
    item.setExtension('finish', 'matte');
    t.deepEqual(item.extensions(), [
        { key: 'color', value: 'blue' },
        { key: 'finish', value: 'matte' },
    ]);
    t.is(item.body(), 'My wall is painted the color:blue @home for +housePainting finish:matte');
});
*)
procedure TTestTodoItemExtensions.SetExtension_NotFoundAddsNewExtension;
var
    Item: ITodoItem;
    Exts: TExtensionArray;
begin
    Item := TITodoItem.Create('My wall is painted the color:blue @home for +housePainting');
    Item.SetExtension('finish', 'matte');
    Exts := Item.GetExtensions;

    Assert.AreEqual(2, Length(Exts));
    Assert.AreEqual('color', Exts[0].Key);
    Assert.AreEqual('blue', Exts[0].Value);
    Assert.AreEqual('finish', Exts[1].Key);
    Assert.AreEqual('matte', Exts[1].Value);
    Assert.IsTrue(Pos('finish:matte', Item.Body) > 0);
end;

(*
Original test: addExtension › Allows for multiple of the same key

test('addExtension › Allows for multiple of the same key', (t) => {
    const item = new Item('My wall is painted the color:blue');
    item.addExtension('color', 'red');
    t.deepEqual(item.extensions(), [
        { key: 'color', value: 'blue' },
        { key: 'color', value: 'red' },
    ]);
    t.is(item.body(), 'My wall is painted the color:blue color:red');
});
*)
procedure TTestTodoItemExtensions.AddExtension_AllowsMultipleOfSameKey;
var
    Item: ITodoItem;
    Exts: TExtensionArray;
begin
    Item := TITodoItem.Create('My wall is painted the color:blue');
    Item.AddExtension('color', 'red');
    Exts := Item.GetExtensions;

    Assert.AreEqual(2, Length(Exts));
    Assert.AreEqual('color', Exts[0].Key);
    Assert.AreEqual('blue', Exts[0].Value);
    Assert.AreEqual('color', Exts[1].Key);
    Assert.AreEqual('red', Exts[1].Value);
    Assert.AreEqual('My wall is painted the color:blue color:red', Item.Body);
end;

(*
Original test: removeExtension › Removes the extension by key

test('removeExtension › Removes the extension by key', (t) => {
    const item = new Item('My room:kitchen wall is painted color:blue and color:red');
    item.removeExtension('color');
    t.deepEqual(item.extensions(), [{ key: 'room', value: 'kitchen' }]);
    t.is(item.body(), 'My room:kitchen wall is painted and');
});
*)
procedure TTestTodoItemExtensions.RemoveExtension_RemovesByKey;
var
    Item: ITodoItem;
    Exts: TExtensionArray;
    BodyStr: string;
begin
    Item := TITodoItem.Create('My room:kitchen wall is painted color:blue and color:red');
    Item.RemoveExtension('color');
    Exts := Item.GetExtensions;

    Assert.AreEqual(1, Length(Exts));
    Assert.AreEqual('room', Exts[0].Key);
    Assert.AreEqual('kitchen', Exts[0].Value);
    BodyStr := Item.Body;
    Assert.AreEqual('My room:kitchen wall is painted and', BodyStr);
end;

(*
Original test: removeExtension › Removes the extension by key and value

test('removeExtension › Removes the extension by key and value', (t) => {
    const item = new Item('My room:kitchen wall is painted color:blue and color:red');
    item.removeExtension('color', 'blue');
    t.deepEqual(item.extensions(), [
        { key: 'room', value: 'kitchen' },
        { key: 'color', value: 'red' },
    ]);
    t.is(item.body(), 'My room:kitchen wall is painted and color:red');
});
*)
procedure TTestTodoItemExtensions.RemoveExtension_RemovesByKeyAndValue;
var
    Item: ITodoItem;
    Exts: TExtensionArray;
    BodyStr: string;
begin
    Item := TITodoItem.Create('My room:kitchen wall is painted color:blue and color:red');
    Item.RemoveExtension('color', 'blue');
    Exts := Item.GetExtensions;
    Assert.AreEqual(2, Length(Exts));
    Assert.AreEqual('room', Exts[0].Key);
    Assert.AreEqual('kitchen', Exts[0].Value);
    Assert.AreEqual('color', Exts[1].Key);
    Assert.AreEqual('red', Exts[1].Value);
    BodyStr := Item.Body;
    Assert.AreEqual('My room:kitchen wall is painted and color:red', BodyStr);
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemExtensions);

end.

