unit Test.Mv.Todo.TodoItem.Completed;

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    System.DateUtils,
    Mv.Todo.TodoItem;

type
    [TestFixture]
    TTestTodoItemCompleted = class
    public
        [Test]
        procedure SetCompleted_AddingWithDate;

        [Test]
        procedure SetCompleted_NoCreatingDate;

        [Test]
        procedure SetCompleted_AddingWithString;

        [Test]
        procedure SetCompleted_UpdatingWithDate;

        [Test]
        procedure SetCompleted_UpdatingWithString;

        [Test]
        procedure SetCompleted_Removing;

        [Test]
        procedure SetCompleted_InvalidInputRaises;

        [Test]
        procedure ClearCompleted_RemovesCompletedDate;
    end;

implementation

const
    NO_DATE: TDateTime = 0;

(*
Original test: setCompleted › Adding with Date

test('setCompleted › Adding with Date', (t) => {
    const item = new Item('2022-06-29 I have to do this.');
    const due = new Date(2022, 6, 1);
    item.setCompleted(due);
    t.deepEqual(item.completed(), due);
    t.true(item.complete());
    t.is(item.createdToString(), '2022-06-29');
    t.is(item.toString(), 'x 2022-07-01 2022-06-29 I have to do this.');
});
*)
procedure TTestTodoItemCompleted.SetCompleted_AddingWithDate;
var
    Item: ITodoItem;
    Due: TDateTime;
begin
    // Ported from original test above
    Item := TITodoItem.Create('2022-06-29 I have to do this.') as ITodoItem;
    Due := EncodeDate(2022, 7, 1); // JS new Date(2022,6,1) -> 2022-07-01

    Item.SetCompleted(Due);

    Assert.AreEqual(Due, Item.Completed);
    Assert.IsTrue(Item.Complete);
    Assert.AreEqual('2022-06-29', Item.CreatedToString);
    Assert.AreEqual('x 2022-07-01 2022-06-29 I have to do this.', Item.ToString);
end;

(*
Original test: setCompleted › Set a task completed without a creating date

test('setCompleted › Set a task completed without a creating date ', (t) => {
    const item = new Item('I have to do this.');
    const due = new Date(2022, 6, 1);
    item.setCompleted(due);
    t.deepEqual(item.completed(), due);
    t.true(item.complete());
    t.is(item.created(), null);
    t.is(item.toString(), 'x 2022-07-01 I have to do this.');
});
*)
procedure TTestTodoItemCompleted.SetCompleted_NoCreatingDate;
var
    Item: ITodoItem;
    Due: TDateTime;
begin
    // Ported from original test above
    Item := TITodoItem.Create('I have to do this.') as ITodoItem;
    Due := EncodeDate(2022, 7, 1);

    Item.SetCompleted(Due);

    Assert.AreEqual(Due, Item.Completed);
    Assert.IsTrue(Item.Complete);
    Assert.AreEqual(NO_DATE, Item.Created);
    Assert.AreEqual('x 2022-07-01 I have to do this.', Item.ToString);
end;

(*
Original test: setCompleted › Adding with string

test('setCompleted › Adding with string', (t) => {
    const item = new Item('2022-06-29 I have to do this.');
    const due = new Date(2022, 6, 1);
    item.setCompleted('2022-07-01');
    t.deepEqual(item.completed(), due);
    t.true(item.complete());
    t.is(item.toString(), 'x 2022-07-01 2022-06-29 I have to do this.');
});
*)
procedure TTestTodoItemCompleted.SetCompleted_AddingWithString;
var
    Item: ITodoItem;
    Due: TDateTime;
begin
    // Ported from original test above
    Item := TITodoItem.Create('2022-06-29 I have to do this.') as ITodoItem;
    Item.SetCompleted('2022-07-01');
    Due := EncodeDate(2022, 7, 1);

    Assert.AreEqual(Due, Item.Completed);
    Assert.IsTrue(Item.Complete);
    Assert.AreEqual('2022-06-29', Item.CreatedToString);
    Assert.AreEqual('x 2022-07-01 2022-06-29 I have to do this.', Item.ToString);
end;

(*
Original test: setCompleted › Updating with Date

test('setCompleted › Updating with Date', (t) => {
    const item = new Item('1999-04-12 I have to do this.');
    const due = new Date(2022, 6, 1);
    item.setCompleted(due);
    t.deepEqual(item.completed(), due);
    t.true(item.complete());
    t.is(item.toString(), 'x 2022-07-01 1999-04-12 I have to do this.');
});
*)
procedure TTestTodoItemCompleted.SetCompleted_UpdatingWithDate;
var
    Item: ITodoItem;
    Due: TDateTime;
begin
    // Ported from original test above
    Item := TITodoItem.Create('1999-04-12 I have to do this.') as ITodoItem;
    Due := EncodeDate(2022, 7, 1);

    Item.SetCompleted(Due);

    Assert.AreEqual(Due, Item.Completed);
    Assert.IsTrue(Item.Complete);
    Assert.AreEqual('x 2022-07-01 1999-04-12 I have to do this.', Item.ToString);
end;

(*
Original test: setCompleted › Updating with string

test('setCompleted › Updating with string', (t) => {
    const item = new Item('1999-04-12 I have to do this.');
    item.setCompleted('2022-07-01');
    t.deepEqual(item.completed(), new Date(2022, 6, 1));
    t.true(item.complete());
    t.is(item.toString(), 'x 2022-07-01 1999-04-12 I have to do this.');
});
*)
procedure TTestTodoItemCompleted.SetCompleted_UpdatingWithString;
var
    Item: ITodoItem;
    Due: TDateTime;
begin
    // Ported from original test above
    Item := TITodoItem.Create('1999-04-12 I have to do this.') as ITodoItem;
    Item.SetCompleted('2022-07-01');
    Due := EncodeDate(2022, 7, 1);

    Assert.AreEqual(Due, Item.Completed);
    Assert.IsTrue(Item.Complete);
    Assert.AreEqual('x 2022-07-01 1999-04-12 I have to do this.', Item.ToString);
end;

(*
Original test: setCompleted › Removing

test('setCompleted › Removing', (t) => {
    const item = new Item('x 2022-06-01 1999-04-12 I have to do this.');
    item.setCompleted();
    t.is(item.completed(), null);
    t.is(item.toString(), 'x 1999-04-12 I have to do this.');
});
*)
procedure TTestTodoItemCompleted.SetCompleted_Removing;
var
    Item: ITodoItem;
begin
    // Ported from original test above
    Item := TITodoItem.Create('x 2022-06-01 1999-04-12 I have to do this.') as ITodoItem;
    Item.SetCompletedNull; // no parameter -> clear completed

    Assert.AreEqual(NO_DATE, Item.Completed);
    Assert.AreEqual('x 1999-04-12 I have to do this.', Item.ToString);
end;

(*
Original test: setCompleted › Throws an exception for invalid input

test('setCompleted › Throws an exception for invalid input', (t) => {
    const item = new Item('x I have to do this.');
    t.throws(() => item.setCompleted('20220102'));
});
*)
procedure TTestTodoItemCompleted.SetCompleted_InvalidInputRaises;
var
    Item: ITodoItem;
begin
    // Ported from original test above
    Item := TITodoItem.Create('x I have to do this.') as ITodoItem;
    Assert.WillRaise(
        procedure
        begin
            Item.SetCompleted('20220102');
        end,
        Exception
    );
end;

(*
Original test: clearCompleted › Removes the completed date

test('clearCompleted › Removes the completed date', (t) => {
    const item = new Item('x 2022-06-01 1999-04-12 I have to do this.');
    item.clearCompleted();
    t.is(item.completed(), null);
    t.is(item.toString(), 'x 1999-04-12 I have to do this.');
});
*)
procedure TTestTodoItemCompleted.ClearCompleted_RemovesCompletedDate;
var
    Item: ITodoItem;
begin
    // Ported from original test above
    Item := TITodoItem.Create('x 2022-06-01 1999-04-12 I have to do this.') as ITodoItem;
    Item.ClearCompleted;

    Assert.AreEqual(NO_DATE, Item.Completed);
    Assert.AreEqual('x 1999-04-12 I have to do this.', Item.ToString);
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemCompleted);

end.
