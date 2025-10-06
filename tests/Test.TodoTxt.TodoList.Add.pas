unit Test.TodoTxt.TodoList.Add;

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
    System.Types,
    TodoTxt.TodoList,
    TodoTxt.TodoItem;

type
    [TestFixture]
    TTestTodoListAdd = class
    public
        [Test]
        procedure Add_String;

        [Test]
        procedure Add_Item;
    end;

implementation

(* Original test: add › string *)
(*
import test from 'ava';
import { List } from './List';
import { Item } from './Item';

test('add › string', (t) => {
    const list = new List(['first item', 'second item', 'third item']);
    const listItem = list.add('fourth item');
    t.is(listItem.index, 3);
    t.is(listItem.item.toString(), 'fourth item');
});
*)
procedure TTestTodoListAdd.Add_String;
var
    TodoList: ITodoList;
    Added: TTodoListItem;
begin
    TodoList := TITodoList.Create;
    try
        TodoList.ParseFromLines(TArray<string>.Create('first item', 'second item', 'third item'));

        Added := TodoList.Add('fourth item');

        Assert.AreEqual(3, Added.Index);
        Assert.AreEqual('fourth item', Added.Item.ToString);
        Assert.AreEqual('first item' + sLineBreak + 'second item' + sLineBreak + 'third item' + sLineBreak + 'fourth item', TodoList.ToString);
    finally
        // release interface (will free object when refcount reaches 0)
        TodoList := nil;
    end;
end;

(* Original test: add › Item *)
(*
test('add › Item', (t) => {
    const list = new List(['first item', 'second item', 'third item']);
    const listItem = list.add(new Item('fourth item'));
    t.is(listItem.index, 3);
    t.is(listItem.item.toString(), 'fourth item');
});
*)
procedure TTestTodoListAdd.Add_Item;
var
    TodoList: ITodoList;
    Added: TTodoListItem;
    ItemObj: ITodoItem;
begin
    TodoList := TITodoList.Create;
    try
        TodoList.ParseFromLines(TArray<string>.Create('first item', 'second item', 'third item'));

        ItemObj := TITodoItem.Create('fourth item');
        Added := TodoList.Add(ItemObj);

        Assert.AreEqual(3, Added.Index);
        Assert.AreEqual('fourth item', Added.Item.ToString);
        Assert.AreEqual(4, Length(TodoList.Items));
    finally
        TodoList := nil;
    end;
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoListAdd);

end.

