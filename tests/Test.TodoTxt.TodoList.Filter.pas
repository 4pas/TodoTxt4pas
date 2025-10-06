unit Test.TodoTxt.TodoList.Filter;

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
    System.DateUtils,
    System.RegularExpressions,
    System.StrUtils,
    TodoTxt.TodoList,
    TodoTxt.TodoItem;

type
    [TestFixture]
    TTestTodoListFilter = class
    public
        [Test]
        procedure Filter_All;

        [Test]
        procedure Filter_Complete;

        [Test]
        procedure Filter_NotComplete;

        [Test]
        procedure Filter_Priority;

        [Test]
        procedure Filter_Priority_NoMatch;

        [Test]
        procedure Filter_NotPriority;

        [Test]
        procedure Filter_Created_AfterStart;

        [Test]
        procedure Filter_Created_BeforeEnd;

        [Test]
        procedure Filter_Created_Between;

        [Test]
        procedure Filter_NotCreated;

        [Test]
        procedure Filter_Completed_AfterStart;

        [Test]
        procedure Filter_Completed_BeforeEnd;

        [Test]
        procedure Filter_Completed_Between;

        [Test]
        procedure Filter_NotCompleted;

        [Test]
        procedure Filter_Body_Regex;

        [Test]
        procedure Filter_Body_Regex2;

        [Test]
        procedure Filter_Body_String;

        [Test]
        procedure Filter_Body_String2;

        [Test]
        procedure Filter_Contexts_And_Single;

        [Test]
        procedure Filter_Contexts_And_Multiple;

        [Test]
        procedure Filter_Contexts_Or_Single;

        [Test]
        procedure Filter_Contexts_Or_Multiple;

        [Test]
        procedure Filter_Contexts_Not;

        [Test]
        procedure Filter_Contexts_OrAndNot;

        [Test]
        procedure Filter_Projects_And_Single;

        [Test]
        procedure Filter_Projects_And_Multiple;

        [Test]
        procedure Filter_Projects_Or_Single;

        [Test]
        procedure Filter_Projects_Or_Multiple;

        [Test]
        procedure Filter_Projects_Not;

        [Test]
        procedure Filter_Projects_OrAndNot;

        [Test]
        procedure Filter_Extensions_ByKey;

        [Test]
        procedure Filter_Extensions_ByFunction;
    end;

implementation

const NOT_COMPLETE = 'not complete';
const COMPLETE = 'x complete';
const PRIORITY = '(A) Priority';
const EVERYTHING = 'x (B) 2020-06-22 2020-05-17 Everything @everywhere +allAtOnce due:2022-02-01';
const CREATED_MARCH = '2021-03-01 Created in March';
const CREATED_JULY = '2021-07-01 Created in July';
const COMPLETED_AUGUST = 'x 2020-08-01 2020-07-01 Completed in August';
const COMPLETED_DECEMBER = 'x 2020-12-01 2020-10-01 Completed in December';
const CONTEXT_HOME = 'Close windows @home';
const CONTEXT_COMPUTER = 'Check email @computer';
const CONTEXTS = 'Work on @computer when @home';
const PROJECT_REPORT = 'Create an outline for my +report';
const PROJECT_SHED = 'Put siding on the +shed';
const PROJECTS = 'Gather dimensions for my +report on my +shed build';
const EXTENSION_BLUE = 'Paint room color:blue';
const EXTENSION_RED = 'Paint room color:red';



// helper: build the shared list used by tests (keeps same order as original tests)
function BuildSampleList: ITodoList;
var
    TodoList: ITodoList;
begin
    TodoList := TITodoList.Create;
    TodoList.ParseFromLines(
        TArray<string>.Create(
            NOT_COMPLETE,
            COMPLETE,
            PRIORITY,
            EVERYTHING,
            CREATED_MARCH,
            CREATED_JULY,
            COMPLETED_AUGUST,
            COMPLETED_DECEMBER,
            CONTEXT_HOME,
            CONTEXT_COMPUTER,
            CONTEXTS,
            PROJECT_REPORT,
            PROJECT_SHED,
            PROJECTS,
            EXTENSION_BLUE,
            EXTENSION_RED
        )
    );
    Result := TodoList;
end;

// Small helper: returns True if any element equals the given value
function FindAnyText(const Arr: TArray<string>; const Value: string): Boolean;
var
    I: Integer;
begin
    for I := 0 to Length(Arr) - 1 do
        if Arr[I] = Value then
            Exit(True);
    Result := False;
end;

(* Original:
function compare(
    t: ExecutionContext,
    filter: ListFilter,
    included: string[] | null,
    excluded: string[] | null = null
*)
// Helper compare: apply filter, assert that returned lines equal ExpectedInclude (in order) and
// that none of ExpectedExclude appear in results. If ExpectedInclude is nil, we only assert
// that none of ExpectedExclude are present.
// Helper compare: apply filter, assert that returned lines equal ExpectedInclude (in order) and
// that none of ExpectedExclude appear in results. If ExpectedInclude is nil, we only assert
// that none of ExpectedExclude are present.
procedure CompareFilter(const FilterRec: TTodoListFilter; const ExpectedInclude: TArray<string>; const ExpectedExclude: TArray<string> = nil);
var
    TodoList: ITodoList;
    Filtered: TArray<TTodoListItem>;
    I: Integer;
    ActualLines: TArray<string>;
begin
    TodoList := BuildSampleList;
    Filtered := TodoList.Filter(FilterRec);

    SetLength(ActualLines, Length(Filtered));
    for I := 0 to Length(Filtered) - 1 do
        ActualLines[I] := Filtered[I].Item.ToString;

    if ExpectedInclude <> nil then
    begin
        // Expect exact match in order
        Assert.AreEqual(Length(ExpectedInclude), Length(ActualLines), 'Filtered count mismatch');
        for I := 0 to Length(ExpectedInclude) - 1 do
            Assert.AreEqual(ExpectedInclude[I], ActualLines[I]);
    end
    else if ExpectedExclude <> nil then
    begin
        // if no includes specified, ensure excluded items are not present
        for I := 0 to Length(ExpectedExclude) - 1 do
            Assert.IsFalse(FindAnyText(ActualLines, ExpectedExclude[I]));
    end;
end;


(* Original:
test(
    'filter › all',
    compare,
    {
        complete: true,
        priority: 'B',
        created: { start: new Date(2020, 4, 1), end: new Date(2020, 5, 1) },
        completed: { start: new Date(2020, 5, 1), end: new Date(2020, 6, 1) },
        body: /^Everything/,
    },
    [EVERYTHING]
);
*)
procedure TTestTodoListFilter.Filter_All;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.Complete := True;
    FilterRec.Priority := 'B';
    FilterRec.CreatedStartDate := EncodeDate(2020, 5, 1);
    FilterRec.CreatedEndDate := EncodeDate(2020, 6, 1);
    FilterRec.CompletedStartDate := EncodeDate(2020, 6, 1);
    FilterRec.CompletedEndDate := EncodeDate(2020, 7, 1);
    FilterRec.BodyRegex := TRegEx.Create('^Everything');

    CompareFilter(FilterRec, [EVERYTHING]);
end;

(* Original:
test('filter › complete', compare, { complete: true }, [
*)
procedure TTestTodoListFilter.Filter_Complete;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.Complete := True;

    CompareFilter(FilterRec, [
        COMPLETE,
        EVERYTHING,
        COMPLETED_AUGUST,
        COMPLETED_DECEMBER
    ]);
end;

(* Original:
test('filter › ! complete', compare, { complete: false }, null, [
*)
procedure TTestTodoListFilter.Filter_NotComplete;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.Complete := False;

    // We expect that filtered results do NOT include completed items
    CompareFilter(FilterRec, nil, [
        COMPLETE,
        EVERYTHING,
        COMPLETED_AUGUST,
        COMPLETED_DECEMBER
    ]);
end;

(* Original:
test('filter › priority', compare, { priority: 'A' }, [PRIORITY]);
*)
procedure TTestTodoListFilter.Filter_Priority;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.Priority := 'A';

    CompareFilter(FilterRec, [PRIORITY]);
end;

(* Original:
test('filter › priority (no match)', compare, { priority: 'Z' }, []);
*)
procedure TTestTodoListFilter.Filter_Priority_NoMatch;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.Priority := 'Z';

    CompareFilter(FilterRec, []);
end;

(* Original:
test('filter › ! priority', compare, { priority: null }, null, [PRIORITY, EVERYTHING]);
*)
procedure TTestTodoListFilter.Filter_NotPriority;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    // priority = null -> we represent with empty string
    FilterRec.Priority := '';

    CompareFilter(FilterRec, nil, [PRIORITY, EVERYTHING]);
end;

(* Original:
test('filter › created › after start', compare, { created: { start: new Date(2021, 0, 1) } }, [
*)
procedure TTestTodoListFilter.Filter_Created_AfterStart;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.CreatedStartDate := EncodeDate(2021, 1, 1);

    CompareFilter(FilterRec, [
        CREATED_MARCH,
        CREATED_JULY
    ]);
end;

(* Original:
test('filter › created › before end', compare, { created: { end: new Date(2021, 5, 1) } }, [
*)
procedure TTestTodoListFilter.Filter_Created_BeforeEnd;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.CreatedEndDate := EncodeDate(2021, 6, 1);

    CompareFilter(FilterRec, [
        EVERYTHING,
        CREATED_MARCH,
        COMPLETED_AUGUST,
        COMPLETED_DECEMBER
    ]);
end;

(* Original:
test(
    'filter › created › between',
    compare,
    { created: { start: new Date(2021, 0, 1), end: new Date(2021, 5, 1) } },
    [CREATED_MARCH]
);
*)
procedure TTestTodoListFilter.Filter_Created_Between;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.CreatedStartDate := EncodeDate(2021, 1, 1);
    FilterRec.CreatedEndDate := EncodeDate(2021, 6, 1);

    CompareFilter(FilterRec, [CREATED_MARCH]);
end;

(* Original:
test('filter › ! created', compare, { created: null }, null, [
*)
procedure TTestTodoListFilter.Filter_NotCreated;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    // created = null -> set both start and end to 0 to indicate null
    FilterRec.CreatedStartDate := 0;
    FilterRec.CreatedEndDate := 0;

    CompareFilter(FilterRec, nil, [
      EVERYTHING,
      CREATED_MARCH,
      CREATED_JULY,
      COMPLETED_AUGUST,
      COMPLETED_DECEMBER
    ]);
end;

(* Original:
test('filter › completed › after start', compare, { completed: { start: new Date(2020, 6, 1) } }, [
*)
procedure TTestTodoListFilter.Filter_Completed_AfterStart;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.CompletedStartDate := EncodeDate(2020, 7, 1);

    CompareFilter(FilterRec, [
        COMPLETED_AUGUST,
        COMPLETED_DECEMBER
    ]);
end;

(* Original:
test('filter › completed › before end', compare, { completed: { end: new Date(2020, 11, 30) } }, [
*)
procedure TTestTodoListFilter.Filter_Completed_BeforeEnd;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.CompletedEndDate := EncodeDate(2020, 12, 30);

    CompareFilter(FilterRec, [
        EVERYTHING,
        COMPLETED_AUGUST,
        COMPLETED_DECEMBER
    ]);
end;

(* Original:
test('filter › completed › between', compare, { completed: { start: new Date(2020, 10, 1), end: new Date(2020, 12, 31) } }, [
    COMPLETED_DECEMBER,
]);
*)
procedure TTestTodoListFilter.Filter_Completed_Between;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.CompletedStartDate := EncodeDate(2020, 11, 1);
    FilterRec.CompletedEndDate := EncodeDate(2020, 12, 31);

    CompareFilter(FilterRec, [COMPLETED_DECEMBER]);
end;

(* Original:
test('filter › ! completed', compare, { completed: null }, null, [
*)
procedure TTestTodoListFilter.Filter_NotCompleted;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    // completed = null -> set both to 0
    FilterRec.CompletedStartDate := 0;
    FilterRec.CompletedEndDate := 0;

    CompareFilter(FilterRec, nil, [
        EVERYTHING,
        COMPLETED_AUGUST,
        COMPLETED_DECEMBER
    ]);
end;


(* Original:
test('filter › body › regex', compare, { body: /^Created in/ }, [CREATED_MARCH, CREATED_JULY]);
*)
procedure TTestTodoListFilter.Filter_Body_Regex;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.BodyRegex := TRegEx.Create('^Created in');

    CompareFilter(FilterRec, [CREATED_MARCH, CREATED_JULY]);
end;

procedure TTestTodoListFilter.Filter_Body_Regex2;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.BodyRegex := TRegEx.Create('^Everything');

    CompareFilter(FilterRec, [EVERYTHING]);
end;


(* Original:
test('filter › body › string', compare, { body: 'complete' }, [COMPLETE]);
*)
procedure TTestTodoListFilter.Filter_Body_String;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.BodyText := 'complete';

    CompareFilter(FilterRec, [COMPLETE]);
end;

procedure TTestTodoListFilter.Filter_Body_String2;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.BodyText := 'Created in March';

    CompareFilter(FilterRec, [CREATED_MARCH]);
end;

(* Original:
test('filter › contexts › and › single', compare, { contextsAnd: ['home'] }, [
    CONTEXT_HOME,
    CONTEXTS,
]);
*)
procedure TTestTodoListFilter.Filter_Contexts_And_Single;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ContextsAnd := ['home'];

    CompareFilter(FilterRec, [CONTEXT_HOME, CONTEXTS]);
end;

(* Original:
test('filter › contexts › and › multiple', compare, { contextsAnd: ['home', 'computer'] }, [
    CONTEXTS,
]);
*)
procedure TTestTodoListFilter.Filter_Contexts_And_Multiple;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ContextsAnd := ['home', 'computer'];

    CompareFilter(FilterRec, [CONTEXTS]);
end;

(* Original:
test('filter › contexts › or › single', compare, { contextsOr: ['home'] }, [
    CONTEXT_HOME,
    CONTEXTS,
]);
*)
procedure TTestTodoListFilter.Filter_Contexts_Or_Single;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ContextsOr := ['home'];

    CompareFilter(FilterRec, [CONTEXT_HOME, CONTEXTS]);
end;

(* Original:
test('filter › contexts › or › multiple', compare, { contextsOr: ['home', 'computer'] }, [
*)
procedure TTestTodoListFilter.Filter_Contexts_Or_Multiple;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ContextsOr := ['home', 'computer'];

    CompareFilter(FilterRec, [
        CONTEXT_HOME,
        CONTEXT_COMPUTER,
        CONTEXTS
    ]);
end;

(* Original:
test('filter › contexts › not', compare, { contextsNot: ['everywhere'] }, null, [EVERYTHING]);
*)
procedure TTestTodoListFilter.Filter_Contexts_Not;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ContextsNot := ['everywhere'];

    CompareFilter(FilterRec, nil, [EVERYTHING]);
end;

(* Original:
test(
    'filter › contexts › or + not',
    compare,
    { contextsOr: ['home', 'computer'], contextsNot: ['home'] },
    [CONTEXT_COMPUTER]
);*)
procedure TTestTodoListFilter.Filter_Contexts_OrAndNot;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ContextsOr := ['home', 'computer'];
    FilterRec.ContextsNot := ['home'];

    CompareFilter(FilterRec, [CONTEXT_COMPUTER]);
end;

(* Original:
test('filter › projects › and › single', compare, { projectsAnd: ['shed'] }, [
    PROJECT_SHED,
    PROJECTS,
]);
*)
procedure TTestTodoListFilter.Filter_Projects_And_Single;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ProjectsAnd := ['shed'];

    CompareFilter(FilterRec, [PROJECT_SHED, PROJECTS]);
end;

(* Original:
test('filter › projects › and › multiple', compare, { projectsAnd: ['shed', 'report'] }, [
    PROJECTS,
]);
*)
procedure TTestTodoListFilter.Filter_Projects_And_Multiple;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ProjectsAnd := ['shed', 'report'];

    CompareFilter(FilterRec, [PROJECTS]);
end;

(* Original:
test('filter › projects › or › single', compare, { projectsOr: ['shed'] }, [
    PROJECT_SHED,
    PROJECTS,
]);
*)
procedure TTestTodoListFilter.Filter_Projects_Or_Single;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ProjectsOr := ['shed'];

    CompareFilter(FilterRec, [PROJECT_SHED, PROJECTS]);
end;

(* Original:
test('filter › projects › or › multiple', compare, { projectsOr: ['shed', 'report'] }, [
*)
procedure TTestTodoListFilter.Filter_Projects_Or_Multiple;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ProjectsOr := ['shed', 'report'];

    CompareFilter(FilterRec, [
      PROJECT_REPORT,
      PROJECT_SHED,
      PROJECTS
    ]);
end;

(* Original:
test('filter › projects › not', compare, { projectsNot: ['allAtOnce'] }, null, [EVERYTHING]);
*)
procedure TTestTodoListFilter.Filter_Projects_Not;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ProjectsNot := ['allAtOnce'];

    CompareFilter(FilterRec, nil, [EVERYTHING]);
end;

(* Original:
test(
    'filter › projects › or + not',
    compare,
    { projectsOr: ['shed', 'report'], projectsNot: ['shed'] },
    [PROJECT_REPORT]
);
*)
procedure TTestTodoListFilter.Filter_Projects_OrAndNot;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ProjectsOr := ['shed', 'report'];
    FilterRec.ProjectsNot := ['shed'];

    CompareFilter(FilterRec, [PROJECT_REPORT]);
end;

(* Original:
test(
    'filter › extensions › by key',
    compare,
    {
        extensions: ['color'],
    },
    [EXTENSION_BLUE, EXTENSION_RED]
);
*)
procedure TTestTodoListFilter.Filter_Extensions_ByKey;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ExtensionKeys := ['color'];

    CompareFilter(FilterRec, [EXTENSION_BLUE, EXTENSION_RED]);
end;

(* Original:
test(
    'filter › extensions › by function',
    compare,
    {
        extensions: (extensions: { key: string; value: string }[]): boolean => {
            return extensions.filter(({ key, value }) => key === 'color' && value === 'blue').length > 0;
        },
    },
    [EXTENSION_BLUE]
);
*)
procedure TTestTodoListFilter.Filter_Extensions_ByFunction;
var
    FilterRec: TTodoListFilter;
begin
    FilterRec := TTodoListFilter.CreateEmpty;
    FilterRec.ExtensionFunc :=
        function(const Extensions: TArray<TTrackedExtension>): Boolean
        var
            Ext: TTrackedExtension;
        begin
            for Ext in Extensions do
                if (Ext.Key = 'color') and (Ext.Value = 'blue') then
                    Exit(True);
            Result := False;
        end;

    CompareFilter(FilterRec, [EXTENSION_BLUE]);
end;

initialization
    TDUnitX.RegisterTestFixture(TTestTodoListFilter);

end.

