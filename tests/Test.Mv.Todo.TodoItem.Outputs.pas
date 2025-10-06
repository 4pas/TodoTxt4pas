unit Test.Mv.Todo.TodoItem.Outputs;

interface

uses
    DUnitX.TestFramework,
    System.SysUtils,
    System.DateUtils,
    Mv.Todo.TodoItem;

type
    [TestFixture]
    TTestTodoItemOutputs = class
    public
        [Test]
        procedure ToString_KeepsPositioningOfTags;

        [Test]
        procedure ToString_AppendsNewTagsToEnd;

        [Test]
        procedure ToAnnotatedString_ReturnsCorrectString;

        [Test]
        procedure ToAnnotatedString_ReturnsCorrectRanges;
    end;

implementation

(*
Original test: toString › Keeps positioning of tags

const sampleCompleted =
    'x (Z) 2022-10-17 2022-09-03 We should keep +todoItems in their @place when rendering out due:2022-10-22';

test('toString › Keeps positioning of tags', (t) => {
    const item = new Item(sampleCompleted);
    t.is(item.toString(), sampleCompleted);
});
*)
procedure TTestTodoItemOutputs.ToString_KeepsPositioningOfTags;
var
    SampleCompleted: string;
    Item: ITodoItem;
begin
    SampleCompleted := 'x (Z) 2022-10-17 2022-09-03 We should keep +todoItems in their @place when rendering out due:2022-10-22';
    Item := TITodoItem.Create(SampleCompleted) as ITodoItem;

    Assert.AreEqual(SampleCompleted, Item.ToString);
end;

(*
Original test: toString › Appends new tags to the end

test('toString › Appends new tags to the end', (t) => {
    const item = new Item(sampleCompleted);
    item.addProject('rewrite');
    item.addContext('computer');
    item.addExtension('h', '1');
    t.is(item.toString(), `${sampleCompleted} +rewrite @computer h:1`);
});
*)
procedure TTestTodoItemOutputs.ToString_AppendsNewTagsToEnd;
var
    SampleCompleted: string;
    Item: ITodoItem;
begin
    SampleCompleted := 'x (Z) 2022-10-17 2022-09-03 We should keep +todoItems in their @place when rendering out due:2022-10-22';
    Item := TITodoItem.Create(SampleCompleted) as ITodoItem;
    Item.AddProject('rewrite');
    Item.AddContext('computer');
    Item.AddExtension('h', '1');

    Assert.AreEqual(SampleCompleted + ' +rewrite @computer h:1', Item.ToString);
end;

(*
Original test: toAnnotatedString › Returns the correct string

test('toAnnotatedString › Returns the correct string', (t) => {
    const itemStr = '(B) 2022-01-04 My @wall is +painted the color:blue';
    const item = new Item(itemStr);
    const annotated = item.toAnnotatedString();
    t.is(annotated.string, itemStr);
});
*)
procedure TTestTodoItemOutputs.ToAnnotatedString_ReturnsCorrectString;
var
    ItemStr: string;
    Item: ITodoItem;
    Annot: TAnnotatedItem;
begin
    ItemStr := '(B) 2022-01-04 My @wall is +painted the color:blue';
    Item := TITodoItem.Create(ItemStr) as ITodoItem;
    Annot := Item.ToAnnotatedString;

    Assert.AreEqual(ItemStr, Annot.Text);
end;

(*
Original test: toAnnotatedString › Returns the correct ranges

test('toAnnotatedString › Returns the correct ranges', (t) => {
    const itemStr = '(B) 2022-01-04 My @wall is +painted the color:blue';
    const item = new Item(itemStr);
    const annotated = item.toAnnotatedString();

    t.deepEqual(
        annotated.contexts.map((ctx) => ctx.string),
        ['@wall']
    );
    t.deepEqual(
        annotated.projects.map((prj) => prj.string),
        ['+painted']
    );
    t.deepEqual(
        annotated.extensions.map((ext) => ext.string),
        ['color:blue']
    );
    annotated.contexts.forEach((ctx) => {
        t.is(annotated.string.slice(ctx.span.start, ctx.span.end), ctx.string);
    });
    annotated.projects.forEach((prj) => {
        t.is(annotated.string.slice(prj.span.start, prj.span.end), prj.string);
    });
    annotated.extensions.forEach((ext) => {
        t.is(annotated.string.slice(ext.span.start, ext.span.end), ext.string);
    });
});
*)
procedure TTestTodoItemOutputs.ToAnnotatedString_ReturnsCorrectRanges;
var
    ItemStr: string;
    Item: ITodoItem;
    Annot: TAnnotatedItem;
    i: Integer;
    SubStr: string;
begin
    ItemStr := '(B) 2022-01-04 My @wall is +painted the color:blue';
    Item := TITodoItem.Create(ItemStr) as ITodoItem;
    Annot := Item.ToAnnotatedString;

    // contexts
    Assert.AreEqual(1, Length(Annot.Contexts));
    Assert.AreEqual('@wall', Annot.Contexts[0].Text);

    // projects
    Assert.AreEqual(1, Length(Annot.Projects));
    Assert.AreEqual('+painted', Annot.Projects[0].Text);

    // extensions
    Assert.AreEqual(1, Length(Annot.Extensions));
    Assert.AreEqual('color:blue', Annot.Extensions[0].Text);

    for i := 0 to Length(Annot.Contexts) - 1 do
    begin
        SubStr := Copy(Annot.Text, Annot.Contexts[i].Span.StartPos + 1, Annot.Contexts[i].Span.EndPos - Annot.Contexts[i].Span.StartPos);
        Assert.AreEqual(Annot.Contexts[i].Text, SubStr);
    end;

    for i := 0 to Length(Annot.Projects) - 1 do
    begin
        SubStr := Copy(Annot.Text, Annot.Projects[i].Span.StartPos + 1, Annot.Projects[i].Span.EndPos - Annot.Projects[i].Span.StartPos);
        Assert.AreEqual(Annot.Projects[i].Text, SubStr);
    end;

    for i := 0 to Length(Annot.Extensions) - 1 do
    begin
        SubStr := Copy(Annot.Text, Annot.Extensions[i].Span.StartPos + 1, Annot.Extensions[i].Span.EndPos - Annot.Extensions[i].Span.StartPos);
        Assert.AreEqual(Annot.Extensions[i].Text, SubStr);
    end;
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoItemOutputs);

end.
