unit Test.Mv.Todo.TodoItem.Body;

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    Mv.Todo.TodoItem;

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
    Ctxs: TArray<string>;
    Projs: TArray<string>;
    Exts: TArray<TTrackedExtension>;
begin
    // Ported from original test above
    Item := TITodoItem.Create('This is @before and +willDelete these tags:all') as ITodoItem;
    NewBody := 'A new @world with +newTags and extension:values';

    Item.SetBody(NewBody);

    Ctxs := Item.Contexts;
    Assert.AreEqual(1, Length(Ctxs));
    Assert.AreEqual('world', Ctxs[0]);

    Projs := Item.Projects;
    Assert.AreEqual(1, Length(Projs));
    Assert.AreEqual('newTags', Projs[0]);

    Exts := Item.Extensions;
    Assert.AreEqual(1, Length(Exts));
    Assert.AreEqual('extension', Exts[0].Key);
    Assert.AreEqual('values', Exts[0].Value);

    Assert.AreEqual(NewBody, Item.Body);
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemBody);

end.

