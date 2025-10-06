unit Test.Mv.Todo.TodoItem.Created;

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    System.DateUtils,
    Mv.Todo.TodoItem;

type
    [TestFixture]
    TTestTodoItemCreated = class
    public
        [Test]
        procedure SetCreatedAddingWithDate;

        [Test]
        procedure SetCreatedAddingWithString;

        [Test]
        procedure SetCreatedUpdatingWithDate;

        [Test]
        procedure SetCreatedUpdatingWithString;

        [Test]
        procedure SetCreatedRemovingWorks;

        [Test]
        procedure SetCreatedRemovingAlsoRemovesCompletedDate;

        [Test]
        procedure SetCreatedThrowsOnInvalidInput;
    end;

implementation

const
    NO_DATE: TDateTime = 0;

(*
Original test: setCreated › Adding with Date

test('setCreated › Adding with Date', (t) => {
    const item = new Item('I have to do this.');
    const due = new Date(2022, 7, 1);
    item.setCreated(due);
    t.deepEqual(item.created(), due);
});
*)
procedure TTestTodoItemCreated.SetCreatedAddingWithDate;
var
    Item: ITodoItem;
    D: TDateTime;
begin
    // Ported from original test above
    Item := TITodoItem.Create('I have to do this.') as ITodoItem;
    D := EncodeDate(2022, 8, 1); // JS new Date(2022,7,1) -> 2022-08-01
    Item.SetCreated(D);
    Assert.AreEqual(D, Item.Created);
end;

(*
Original test: setCreated › Adding with string

test('setCreated › Adding with string', (t) => {
    const item = new Item('I have to do this.');
    const due = new Date(2022, 6, 1);
    item.setCreated('2022-07-01');
    t.deepEqual(item.created(), due);
});
*)
procedure TTestTodoItemCreated.SetCreatedAddingWithString;
var
    Item: ITodoItem;
    D: TDateTime;
begin
    Item := TITodoItem.Create('I have to do this.') as ITodoItem;
    Item.SetCreated('2022-07-01');
    D := EncodeDate(2022, 7, 1); // JS new Date(2022,6,1)
    Assert.AreEqual(D, Item.Created);
end;

(*
Original test: setCreated › Updating with Date

test('setCreated › Updating with Date', (t) => {
    const item = new Item('1999-04-12 I have to do this.');
    const due = new Date(2022, 7, 1);
    item.setCreated(due);
    t.deepEqual(item.created(), due);
});
*)
procedure TTestTodoItemCreated.SetCreatedUpdatingWithDate;
var
    Item: ITodoItem;
    D: TDateTime;
begin
    Item := TITodoItem.Create('1999-04-12 I have to do this.') as ITodoItem;
    D := EncodeDate(2022, 8, 1);
    Item.SetCreated(D);
    Assert.AreEqual(D, Item.Created);
end;

(*
Original test: setCreated › Updating with string

test('setCreated › Updating with string', (t) => {
    const item = new Item('1999-04-12 I have to do this.');
    item.setCreated('2022-07-01');
    t.deepEqual(item.created(), new Date(2022, 6, 1));
});
*)
procedure TTestTodoItemCreated.SetCreatedUpdatingWithString;
var
    Item: ITodoItem;
    D: TDateTime;
begin
    Item := TITodoItem.Create('1999-04-12 I have to do this.') as ITodoItem;
    Item.SetCreated('2022-07-01');
    D := EncodeDate(2022, 7, 1);
    Assert.AreEqual(D, Item.Created);
end;

(*
Original test: setCreated › Removing works

test('setCreated › Removing works', (t) => {
    const item = new Item('x 2022-05-23 1999-04-12 I have to do this.');
    item.setCreated();
    t.is(item.created(), null);
});
*)
procedure TTestTodoItemCreated.SetCreatedRemovingWorks;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create('x 2022-05-23 1999-04-12 I have to do this.') as ITodoItem;
    Item.SetCreatedNull;
    Assert.AreEqual(NO_DATE, Item.Created);
end;

(*
Original test: setCreated › Removing also removes completed date

test('setCreated › Removing also removes completed date', (t) => {
    const item = new Item('x 2022-05-23 1999-04-12 I have to do this.');
    item.setCreated();
    t.is(item.created(), null);
    t.is(item.completed(), null);
});
*)
procedure TTestTodoItemCreated.SetCreatedRemovingAlsoRemovesCompletedDate;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create('x 2022-05-23 1999-04-12 I have to do this.') as ITodoItem;
    Item.SetCreatedNull;
    Assert.AreEqual(NO_DATE, Item.Created);
    Assert.AreEqual(NO_DATE, Item.Completed);
end;

(*
Original test: setCreated › Throws an exception for invalid input

test('setCreated › Throws an exception for invalid input', (t) => {
    const item = new Item('I have to do this.');
    t.throws(() => item.setCreated('20220102'));
});
*)
procedure TTestTodoItemCreated.SetCreatedThrowsOnInvalidInput;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create('I have to do this.') as ITodoItem;
    Assert.WillRaise(
        procedure
        begin
            Item.SetCreated('20220102');
        end,
        Exception
    );
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemCreated);

end.

