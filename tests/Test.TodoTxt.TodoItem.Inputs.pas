unit Test.TodoTxt.TodoItem.Inputs;

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

uses
    Mv.StringList;

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
    ItemObj := TITodoItem.Create('Just the body.');

    Assert.IsFalse(ItemObj.Complete);
    Assert.AreEqual('', ItemObj.Priority);
    Assert.AreEqual(NO_DATE, ItemObj.Created);
    Assert.AreEqual(NO_DATE, ItemObj.Completed);
    Assert.AreEqual('Just the body.', ItemObj.Body);
    Assert.AreEqual(0, ItemObj.GetProjects.Count);
    Assert.AreEqual(0, ItemObj.GetContexts.Count);
    Assert.AreEqual(0, Length(ItemObj.GetExtensions));
end;

(* Original test: Constructor › Complete *)
procedure TTestTodoItemInputs.Constructor_Complete;
var
    ItemObj: ITodoItem;
    CreatedDate: TDateTime;
    CompletedDate: TDateTime;
begin
    ItemObj := TITodoItem.Create('x (A) 2016-01-03 2016-01-02 measure space for +chapelShelving @chapel due:2016-01-04');

    Assert.IsTrue(ItemObj.Complete);
    Assert.AreEqual('A', ItemObj.Priority);

    // JS new Date(2016,0,2) => 2016-01-02
    CreatedDate := EncodeDate(2016, 1, 2);
    // JS new Date(2016,0,3) => 2016-01-03
    CompletedDate := EncodeDate(2016, 1, 3);

    Assert.AreEqual(CreatedDate, ItemObj.Created);
    Assert.AreEqual(CompletedDate, ItemObj.Completed);
    Assert.AreEqual('measure space for +chapelShelving @chapel due:2016-01-04', ItemObj.Body);

    Assert.AreEqual(1, ItemObj.GetContexts.Count);
    Assert.AreEqual('chapel', ItemObj.GetContexts[0]);

    Assert.AreEqual(1, ItemObj.GetProjects.Count);
    Assert.AreEqual('chapelShelving', ItemObj.GetProjects[0]);

    Assert.AreEqual(1, Length(ItemObj.GetExtensions));
    Assert.AreEqual('due', ItemObj.GetExtensions[0].Key);
    Assert.AreEqual('2016-01-04', ItemObj.GetExtensions[0].Value);
end;

(* Original test: parse › Resets everything *)
procedure TTestTodoItemInputs.Parse_ResetsEverything;
var
    ItemObj: ITodoItem;
    Ctxs: IStringList;
    Projs: IStringList;
    Exts: TExtensionArray;
begin
    ItemObj := TITodoItem.Create('x (A) 2016-01-03 2016-01-02 measure space for +chapelShelving @chapel due:2016-01-04');
    ItemObj.Parse('Hello');

    Assert.IsFalse(ItemObj.Complete);
    Assert.AreEqual('', ItemObj.Priority);
    Assert.AreEqual(NO_DATE, ItemObj.Created);
    Assert.AreEqual(NO_DATE, ItemObj.Completed);
    Assert.AreEqual('Hello', ItemObj.Body);

    Ctxs := ItemObj.GetContexts;
    Projs := ItemObj.GetProjects;
    Exts := ItemObj.GetExtensions;

    Assert.AreEqual(0, Ctxs.Count);
    Assert.AreEqual(0, Projs.Count);
    Assert.AreEqual(0, Length(Exts));
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemInputs);

end.
