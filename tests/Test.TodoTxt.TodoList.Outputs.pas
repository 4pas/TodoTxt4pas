unit Test.TodoTxt.TodoList.Outputs;

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
    System.Generics.Collections,
    Mv.StringList,
    TodoTxt.TodoList,
    TodoTxt.TodoItem;

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

(* Original:
test('toString', (t) => {
    const list = new List(['first item', 'second item', 'third item']);
    t.is(list.toString(), 'first item\nsecond item\nthird item');
});
*)
procedure TTestTodoListOutputs.ToString_Test;
var
    TodoList: ITodoList;
begin
    TodoList := TITodoList.Create;
    try
        TodoList.ParseFromLines(['first item', 'second item', 'third item']);
        Assert.AreEqual('first item' + sLineBreak + 'second item' + sLineBreak + 'third item', TodoList.ToString);
    finally
        TodoList := nil;
    end;
end;

(* Original:
test('projects', (t) => {
    const list = new List(['first +item', 'second +item', 'third +task']);
    t.deepEqual(list.projects(), ['item', 'task']);
});
*)
procedure TTestTodoListOutputs.Projects_Test;
var
    TodoList: ITodoList;
    Projects: IStringList;
begin
    TodoList := TITodoList.Create;
    try
        TodoList.ParseFromLines(['first +item', 'second +item', 'third +task']);
        Projects := TodoList.GetProjects;

        Assert.AreEqual(2, Projects.Count);
        Assert.AreEqual('item', Projects[0]);
        Assert.AreEqual('task', Projects[1]);
    finally
        TodoList := nil;
    end;
end;

(* Original:
test('contexts', (t) => {
    const list = new List(['first @item', 'second @task', 'third @item']);
    t.deepEqual(list.contexts(), ['item', 'task']);
});
*)
procedure TTestTodoListOutputs.Contexts_Test;
var
    TodoList: ITodoList;
    Contexts: IStringList;
begin
    TodoList := TITodoList.Create;
    try
        TodoList.ParseFromLines(['first @item', 'second @task', 'third @item']);
        Contexts := TodoList.GetContexts;

        Assert.AreEqual(2, Contexts.Count);
        Assert.AreEqual('item', Contexts[0]);
        Assert.AreEqual('task', Contexts[1]);
    finally
        TodoList := nil;
    end;
end;

(* Original:
test('extensions', (t) => {
    const list = new List(['first item is due:2022-01-05', 'second item h:1', 'third h:0']);
    t.deepEqual(list.extensions(), { due: ['2022-01-05'], h: ['1', '0'] });
});
*)
procedure TTestTodoListOutputs.Extensions_Test;
var
    TodoList: ITodoList;
    Keys: IStringList;
    Values: IStringList;
begin
    TodoList := TITodoList.Create;
    try
        TodoList.ParseFromLines(
            ['first item is due:2022-01-05', 'second item h:1', 'third h:0']
        );

        Keys := TodoList.GetExtensionKeys;

        // due and h
        Assert.AreEqual(2, Keys.Count);
        Assert.AreEqual('due', Keys[0]);
        Assert.AreEqual('h', Keys[1]);

        Values := TodoList.GetExtensionValues('due');
        Assert.AreEqual(1, Values.Count);
        Assert.AreEqual('2022-01-05', Values[0]);

        Values := TodoList.GetExtensionValues('h');
        Assert.AreEqual(2, Values.Count);
        Assert.AreEqual('1', Values[0]);
        Assert.AreEqual('0', Values[1]);

    finally
        TodoList := nil;
    end;
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoListOutputs);

end.

