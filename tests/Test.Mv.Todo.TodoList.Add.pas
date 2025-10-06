unit Test.Mv.Todo.TodoList.Add;

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    System.Types,
    Mv.Todo.TodoList,
    Mv.Todo.TodoItem;

type
    [TestFixture]
    TTestTodoListAdd = class
    public
        [Test]
        procedure Add_String;

        [Test]
        procedure Add_Item;
    end;

implementation

(* Original test: add › string *)
(*
import test from 'ava';
import { List } from './List';
import { Item } from './Item';

test('add › string', (t) => {
    const list = new List(['first item', 'second item', 'third item']);
    const listItem = list.add('fourth item');
    t.is(listItem.index, 3);
    t.is(listItem.item.toString(), 'fourth item');
});
*)
procedure TTestTodoListAdd.Add_String;
var
    TodoList: ITodoList;
    Added: TTodoListItem;
begin
    TodoList := TITodoList.Create as ITodoList;
    try
        TodoList.ParseFromLines(TArray<string>.Create('first item', 'second item', 'third item'));

        Added := TodoList.Add('fourth item');

        Assert.AreEqual(3, Added.Index);
        Assert.AreEqual('fourth item', Added.Item.ToString);
        Assert.AreEqual('first item' + sLineBreak + 'second item' + sLineBreak + 'third item' + sLineBreak + 'fourth item', TodoList.ToString);
    finally
        // release interface (will free object when refcount reaches 0)
        TodoList := nil;
    end;
end;

(* Original test: add › Item *)
(*
test('add › Item', (t) => {
    const list = new List(['first item', 'second item', 'third item']);
    const listItem = list.add(new Item('fourth item'));
    t.is(listItem.index, 3);
    t.is(listItem.item.toString(), 'fourth item');
});
*)
procedure TTestTodoListAdd.Add_Item;
var
    TodoList: ITodoList;
    Added: TTodoListItem;
    ItemObj: ITodoItem;
begin
    TodoList := TITodoList.Create as ITodoList;
    try
        TodoList.ParseFromLines(TArray<string>.Create('first item', 'second item', 'third item'));

        ItemObj := TITodoItem.Create('fourth item') as ITodoItem;
        Added := TodoList.Add(ItemObj);

        Assert.AreEqual(3, Added.Index);
        Assert.AreEqual('fourth item', Added.Item.ToString);
        Assert.AreEqual(4, Length(TodoList.Items));
    finally
        TodoList := nil;
    end;
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoListAdd);

end.

