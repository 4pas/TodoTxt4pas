unit Test.Mv.Todo.TodoItem.Complete;

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    Mv.Todo.TodoItem;

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
    Item := TITodoItem.Create('I have to do this.') as ITodoItem;

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
    Item := TITodoItem.Create('x I have to do this.') as ITodoItem;

    Assert.IsTrue(Item.Complete);

    Item.SetComplete(False);

    Assert.IsFalse(Item.Complete);
    Assert.AreEqual('I have to do this.', Item.ToString);
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemComplete);

end.
