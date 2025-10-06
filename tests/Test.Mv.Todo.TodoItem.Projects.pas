unit Test.Mv.Todo.TodoItem.Projects;

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    Mv.Todo.TodoItem;

type
    [TestFixture]
    TTestTodoItemProjects = class
    public
        [Test]
        procedure Projects_Deduplicates;

        [Test]
        procedure Projects_DoesNotParseContextWithoutSpace;

        [Test]
        procedure Projects_ParsesAtStartOfLine;

        [Test]
        procedure AddProject_AddsNewProjects;

        [Test]
        procedure AddProject_DoesNotAddExisting;

        [Test]
        procedure AddProject_UpdatesBody;

        [Test]
        procedure RemoveProject_RemovesProjects;

        [Test]
        procedure RemoveProject_RemovesNothingWhenAbsent;

        [Test]
        procedure RemoveProject_UpdatesBody;
    end;

implementation

(*
Original test: projects › Deduplicates

test('projects › Deduplicates', (t) => {
    const item = new Item('Hello @home with +goals and +projects and +goals extensions:todo');
    t.deepEqual(item.projects(), ['goals', 'projects']);
});
*)
procedure TTestTodoItemProjects.Projects_Deduplicates;
var
    Item: ITodoItem;
    Projs: TArray<string>;
begin
    Item := TITodoItem.Create('Hello @home with +goals and +projects and +goals extensions:todo') as ITodoItem;
    Projs := Item.Projects;
    Assert.AreEqual(2, Length(Projs));
    Assert.AreEqual('goals', Projs[0]);
    Assert.AreEqual('projects', Projs[1]);
end;

(*
Original test: projects › Does not parse context without a space

test('projects › Does not parse context without a space', (t) => {
    const item = new Item('A small computation: 1+1 = 2');
    t.deepEqual(item.projects(), []);
});
*)
procedure TTestTodoItemProjects.Projects_DoesNotParseContextWithoutSpace;
var
    Item: ITodoItem;
    Projs: TArray<string>;
begin
    Item := TITodoItem.Create('A small computation: 1+1 = 2') as ITodoItem;
    Projs := Item.Projects;
    Assert.AreEqual(0, Length(Projs));
end;

(*
Original test: projects › Parses context at start of line

test('projects › Parses context at start of line', (t) => {
    const item = new Item('+goals Do the thing');
    t.deepEqual(item.projects(), ['goals']);
});
*)
procedure TTestTodoItemProjects.Projects_ParsesAtStartOfLine;
var
    Item: ITodoItem;
    Projs: TArray<string>;
begin
    Item := TITodoItem.Create('+goals Do the thing') as ITodoItem;
    Projs := Item.Projects;
    Assert.AreEqual(1, Length(Projs));
    Assert.AreEqual('goals', Projs[0]);
end;

(*
Original test: addProject › Adds new projects

test('addProject › Adds new projects', (t) => {
    const item = new Item(sampleCompleted);
    item.addProject('rewrite');
    t.deepEqual(item.projects(), ['todoItems', 'rewrite']);
});
*)
procedure TTestTodoItemProjects.AddProject_AddsNewProjects;
var
    SampleCompleted: string;
    Item: ITodoItem;
    Projs: TArray<string>;
begin
    SampleCompleted := 'x (Z) 2022-10-17 We should keep +todoItems in their @place when rendering out due:2022-10-22';
    Item := TITodoItem.Create(SampleCompleted) as ITodoItem;
    Item.AddProject('rewrite');
    Projs := Item.Projects;
    Assert.AreEqual(2, Length(Projs));
    Assert.AreEqual('todoItems', Projs[0]);
    Assert.AreEqual('rewrite', Projs[1]);
end;

(*
Original test: addProject › Does not add projects which already exist

test('addProject › Does not add projects which already exist', (t) => {
    const item = new Item(sampleCompleted);
    item.addProject('todoItems');
    t.deepEqual(item.projects(), ['todoItems']);
});
*)
procedure TTestTodoItemProjects.AddProject_DoesNotAddExisting;
var
    SampleCompleted: string;
    Item: ITodoItem;
    Projs: TArray<string>;
begin
    SampleCompleted := 'x (Z) 2022-10-17 We should keep +todoItems in their @place when rendering out due:2022-10-22';
    Item := TITodoItem.Create(SampleCompleted) as ITodoItem;
    Item.AddProject('todoItems');
    Projs := Item.Projects;
    Assert.AreEqual(1, Length(Projs));
    Assert.AreEqual('todoItems', Projs[0]);
end;

(*
Original test: addProject › Updates the body

test('addProject › Updates the body', (t) => {
    const item = new Item('Hello');
    item.addProject('world');
    t.is(item.body(), 'Hello +world');
});
*)
procedure TTestTodoItemProjects.AddProject_UpdatesBody;
var
    Item: ITodoItem;
    BodyStr: string;
begin
    Item := TITodoItem.Create('Hello') as ITodoItem;
    Item.AddProject('world');
    BodyStr := Item.Body;
    Assert.AreEqual('Hello +world', BodyStr);
end;

(*
Original test: removeProject › Removes projects

test('removeProject › Removes projects', (t) => {
    const item = new Item('Hello @home with +goals and +projects and +goals extensions:todo');
    item.removeProject('goals');
    t.deepEqual(item.projects(), ['projects']);
});
*)
procedure TTestTodoItemProjects.RemoveProject_RemovesProjects;
var
    Item: ITodoItem;
    Projs: TArray<string>;
begin
    Item := TITodoItem.Create('Hello @home with +goals and +projects and +goals extensions:todo') as ITodoItem;
    Item.RemoveProject('goals');
    Projs := Item.Projects;
    Assert.AreEqual(1, Length(Projs));
    Assert.AreEqual('projects', Projs[0]);
end;

(*
Original test: removeProject › Removes projects (none present)

test('removeProject › Removes projects (none present)', (t) => {
    const item = new Item('Hello @home with +goals and +projects and +goals extensions:todo');
    item.removeProject('nothing');
    t.deepEqual(item.projects(), ['goals', 'projects']);
});
*)
procedure TTestTodoItemProjects.RemoveProject_RemovesNothingWhenAbsent;
var
    Item: ITodoItem;
    Projs: TArray<string>;
begin
    Item := TITodoItem.Create('Hello @home with +goals and +projects and +goals extensions:todo') as ITodoItem;
    Item.RemoveProject('nothing');
    Projs := Item.Projects;
    Assert.AreEqual(2, Length(Projs));
    Assert.AreEqual('goals', Projs[0]);
    Assert.AreEqual('projects', Projs[1]);
end;

(*
Original test: removeProject › Updates the body

test('removeProject › Updates the body', (t) => {
    const item = new Item('Hello @home with +goals and +projects and +goals extensions:todo');
    item.removeProject('goals');
    t.is(item.body(), 'Hello @home with and +projects and extensions:todo');
});
*)
procedure TTestTodoItemProjects.RemoveProject_UpdatesBody;
var
    Item: ITodoItem;
    BodyStr: string;
begin
    Item := TITodoItem.Create('Hello @home with +goals and +projects and +goals extensions:todo') as ITodoItem;
    Item.RemoveProject('goals');
    BodyStr := Item.Body;
    Assert.AreEqual('Hello @home with and +projects and extensions:todo', BodyStr);
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemProjects);

end.
