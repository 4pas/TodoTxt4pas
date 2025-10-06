unit Test.Mv.Todo.TodoItem.Priority;

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    Mv.Todo.TodoItem;

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
    Item := TITodoItem.Create('I have to do this.') as ITodoItem;
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
    Item := TITodoItem.Create('(Z) I have to do this.') as ITodoItem;
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
    Item := TITodoItem.Create('(L) I have to do this.') as ITodoItem;
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
    Item := TITodoItem.Create('(L) I have to do this.') as ITodoItem;
    Assert.WillRaise(
        procedure
        begin
            Item.SetPriority('6');
        end,
        Exception
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
    Item := TITodoItem.Create('(L) I have to do this.') as ITodoItem;
    Item.ClearPriority;

    Assert.AreEqual('', Item.Priority);
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemPriority);

end.
