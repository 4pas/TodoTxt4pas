unit Test.TodoTxt.TodoItem.Complete;

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
    TTestTodoItemComplete = class
    public
        [Test]
        procedure SetComplete_WorksMarkingComplete;

        [Test]
        procedure SetComplete_WorksMarkingIncomplete;
    end;

implementation

(*
Original TypeScript file: Item.complete.test.ts

import test from 'ava';
import { Item } from './Item';

test('setComplete › Works marking complete', (t) => {
    const item = new Item('I have to do this.');
    t.false(item.complete());
    item.setComplete(true);
    t.true(item.complete());
    t.is(item.toString(), 'x I have to do this.');
});
*)
procedure TTestTodoItemComplete.SetComplete_WorksMarkingComplete;
var
    Item: ITodoItem;
begin
    // Ported from original test above
    Item := TITodoItem.Create('I have to do this.');

    Assert.IsFalse(Item.Complete);

    Item.SetComplete(True);

    Assert.IsTrue(Item.Complete);
    Assert.AreEqual('x I have to do this.', Item.ToString);
end;

(*
test('setComplete › Works marking incomplete', (t) => {
    const item = new Item('x I have to do this.');
    t.true(item.complete());
    item.setComplete(false);
    t.false(item.complete());
    t.is(item.toString(), 'I have to do this.');
});
*)
procedure TTestTodoItemComplete.SetComplete_WorksMarkingIncomplete;
var
    Item: ITodoItem;
begin
    // Ported from original test above
    Item := TITodoItem.Create('x I have to do this.');

    Assert.IsTrue(Item.Complete);

    Item.SetComplete(False);

    Assert.IsFalse(Item.Complete);
    Assert.AreEqual('I have to do this.', Item.ToString);
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemComplete);

end.
