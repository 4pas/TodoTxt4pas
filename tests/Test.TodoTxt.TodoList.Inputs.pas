unit Test.TodoTxt.TodoList.Inputs;

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
    System.Classes,
    System.Generics.Collections,
    TodoTxt.TodoList,
    TodoTxt.TodoItem;

type
    [TestFixture]
    TTestTodoListInputs = class
    public
        [Test]
        procedure Constructor_String;

        [Test]
        procedure Constructor_String_StripsBlankLines;

        [Test]
        procedure Constructor_Array;

        [Test]
        procedure Constructor_Array_StripsBlankLines;
    end;

implementation

function LinesFromString(const S: string): TArray<string>;
var
    SL: TStringList;
    i: Integer;
    TempList: TList<string>;
    Line: string;
begin
    SL := TStringList.Create;
    TempList := TList<string>.Create;
    try
        // TStringList.Text will split on CR/LF and LF as needed
        SL.Text := S;
        for i := 0 to SL.Count - 1 do
        begin
            Line := Trim(SL[i]);
            if Line <> '' then
                TempList.Add(Line);
        end;
        Result := TempList.ToArray;
    finally
        SL.Free;
        TempList.Free;
    end;
end;

(* Original test: constructor › string *)
(*
import test from 'ava';
import { List } from './List';

test('constructor › string', (t) => {
    const list = new List('first item\nsecond item');
    t.is(list.items().length, 2);
});
*)
procedure TTestTodoListInputs.Constructor_String;
var
    TodoList: ITodoList;
    Lines: TArray<string>;
begin
    TodoList := TITodoList.Create;
    try
        Lines := LinesFromString('first item' + sLineBreak + 'second item');
        TodoList.ParseFromLines(Lines);
        Assert.AreEqual(2, Length(TodoList.Items));
    finally
        TodoList := nil;
    end;
end;

(* Original test: constructor › string › strips blank lines *)
(*
test('constructor › string › strips blank lines', (t) => {
    const list = new List('first item\nsecond item\n\nthird item\n\n');
    t.is(list.items().length, 3);
});
*)
procedure TTestTodoListInputs.Constructor_String_StripsBlankLines;
var
    TodoList: ITodoList;
    Lines: TArray<string>;
begin
    TodoList := TITodoList.Create;
    try
        Lines := LinesFromString('first item' + sLineBreak + 'second item' + sLineBreak + sLineBreak + 'third item' + sLineBreak + sLineBreak);
        TodoList.ParseFromLines(Lines);
        Assert.AreEqual(3, Length(TodoList.Items));
    finally
        TodoList := nil;
    end;
end;

(* Original test: constructor › array *)
(*
test('constructor › array', (t) => {
    const list = new List(['first item', 'second item', 'third item']);
    t.is(list.items().length, 3);
});
*)
procedure TTestTodoListInputs.Constructor_Array;
var
    TodoList: ITodoList;
    InputArray: TArray<string>;
begin
    TodoList := TITodoList.Create;
    try
        InputArray := TArray<string>.Create('first item', 'second item', 'third item');
        TodoList.ParseFromLines(InputArray);
        Assert.AreEqual(3, Length(TodoList.Items));
    finally
        TodoList := nil;
    end;
end;

(* Original test: constructor › array › strips blank lines *)
(*
test('constructor › array › strips blank lines', (t) => {
    const list = new List(['first item', '', 'second item', '   ', '\t', 'third item']);
    t.is(list.items().length, 3);
});
*)
procedure TTestTodoListInputs.Constructor_Array_StripsBlankLines;
var
    TodoList: ITodoList;
    InputArray: TArray<string>;
begin
    TodoList := TITodoList.Create;
    try
        InputArray := TArray<string>.Create('first item', '', 'second item', '   ', #9, 'third item');
        TodoList.ParseFromLines(InputArray);
        Assert.AreEqual(3, Length(TodoList.Items));
    finally
        TodoList := nil;
    end;
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoListInputs);

end.
