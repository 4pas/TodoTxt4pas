unit Test.TodoTxt.TodoItem.Body;

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
    Mv.StringList,
    TodoTxt.TodoItem;

type
    [TestFixture]
    TTestTodoItemBody = class
    public
        [Test]
        procedure SetBody_UpdatesContextsProjectsExtensions;
    end;

implementation
(*
Original TypeScript file: Item.body.test.ts
import test from 'ava';
import { Item } from './Item';
test('setBody › Updates contexts, projects and extensions', (t) => {
    const item = new Item('This is @before and +willDelete these tags:all');
    const newBody = 'A new @world with +newTags and extension:values';
    item.setBody(newBody);
    t.deepEqual(item.contexts(), ['world']);
    t.deepEqual(item.projects(), ['newTags']);
    t.deepEqual(item.extensions(), [{ key: 'extension', value: 'values' }]);
    t.is(item.body(), newBody);
});
*)
procedure TTestTodoItemBody.SetBody_UpdatesContextsProjectsExtensions;
var
    Item: ITodoItem;
    NewBody: string;
    Ctxs: IStringList;
    Projs: IStringList;
    Exts: TExtensionArray;
begin
    // Ported from original test above
    Item := TITodoItem.Create('This is @before and +willDelete these tags:all');
    NewBody := 'A new @world with +newTags and extension:values';
    Item.SetBody(NewBody);
    Ctxs := Item.GetContexts;
    Assert.AreEqual(1, Ctxs.Count);
    Assert.AreEqual('world', Ctxs[0]);
    Projs := Item.GetProjects;
    Assert.AreEqual(1, Projs.Count);
    Assert.AreEqual('newTags', Projs[0]);
    Exts := Item.GetExtensions;
    Assert.AreEqual(1, Length(Exts));
    Assert.AreEqual('extension', Exts[0].Key);
    Assert.AreEqual('values', Exts[0].Value);
    Assert.AreEqual(NewBody, Item.Body);
end;
initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemBody);
end.

