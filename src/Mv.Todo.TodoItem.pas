unit Mv.Todo.TodoItem;

interface

uses
    System.SysUtils,
    System.Classes,
    System.Generics.Collections,
    System.RegularExpressions,
    System.DateUtils,
    System.Math;

{
  Original file: src/Item.ts (jsTodoTxt)
  This unit is a faithful port of Item.ts:
  - Block comments from the original were preserved and converted from /** ... */ to (* ... *).
  - Function order follows the original exactly to ease diff/sync comparison.
  - Interface name: ITodoItem; implementing object: TITodoItem (TInterfacedObject).
  - Internal tracked tag/extension start indices are zero-based (matching JS indexOf / Match.Index).
  - Dates use TDateTime; 'null' dates in JS are represented by 0.0 in Delphi (and empty-string outputs).
  Port decisions:
  - rTodo, rTags and rDate implemented with TRegEx and the same patterns as original JS.
  - ParseBody uses regex groups to obtain each tag and their start positions (zero-based) similar to JS.
  - CutOutSpans removes also the preceding space when available (same semantic as the original).
  - SetExtension/AddExtension/RemoveExtension implement logic from the JS original; RemoveExtension
    creates spans and removes them sorted descending to avoid index shifts.
  - This unit intentionally keeps data structures and method order for a straightforward sync with the JS source.
}

type
    TSpan = record
        StartPos: Integer; // zero-based start index
        EndPos: Integer;   // zero-based exclusive end index
    end;

    TTagRec = record
        Text: string; // the tag string (or key/value concatenation)
        Span: TSpan; 
    end;

    TExtensionRec = record
        Text: string;
        ParsedKey: string;
        ParsedValue: string;
        Span: TSpan;
    end;

    // External types
    TContext = TTagRec;
    TProject = TTagRec;
    TPriority = string; // use empty string to represent null

    TAnnotatedItem = record
        Text: string;
        Contexts: TArray<TContext>;
        Projects: TArray<TProject>;
        Extensions: TArray<TExtensionRec>;
    end;

    // Internal
    TTrackedTag = record
        Tag: string;
        StartPos: Integer; // zero-based
    end;

    TTrackedExtension = record
        Key: string;
        Value: string;
        StartPos: Integer; // zero-based
    end;

    (**
     * Represents a single line in a todo.txt file.
     *)
    ITodoItem = interface
        ['{E9B9C9A4-9E54-4D7B-8C5B-1F9A8C2F0B21}']
        procedure Parse(const ALine: string);
        function ToString: string;
        function ToAnnotatedString: TAnnotatedItem;

        function Complete: Boolean;
        procedure SetComplete(const AComplete: Boolean);

        function Priority: string;
        procedure SetPriority(const APriority: string);
        procedure ClearPriority;

        function Created: TDateTime;
        function CreatedToString: string;
        procedure SetCreated(const ADate: TDateTime); overload;
        procedure SetCreated(const ADateString: string); overload;
        procedure SetCreatedNull; // clear

        procedure ClearCreated;

        function Completed: TDateTime;
        function CompletedToString: string;
        procedure SetCompletedNull; // clear
        procedure SetCompleted(const ADate: TDateTime); overload;
        procedure SetCompleted(const ADateString: string); overload;

        procedure ClearCompleted;

        function Body: string;
        procedure SetBody(const ABody: string);

        function Contexts: TArray<string>;
        procedure AddContext(const ATag: string);
        procedure RemoveContext(const ATag: string);

        function Projects: TArray<string>;
        procedure AddProject(const ATag: string);
        procedure RemoveProject(const ATag: string);

        function Extensions: TArray<TTrackedExtension>;
        procedure SetExtension(const AKey: string; const AValue: string);
        procedure AddExtension(const AKey: string; const AValue: string);
        procedure RemoveExtension(const AKey: string; const AValue: string = '');
    end;

    (**
     * Represents a single line in a todo.txt file.
     *)
    TITodoItem = class(TInterfacedObject, ITodoItem)
    private
        // regex patterns ported from JS:
        const R_TODO =
            '^((x) )?(\(([A-Z])\) )?(((\d{4}-\d{2}-\d{2}) (\d{4}-\d{2}-\d{2})|(\d{4}-\d{2}-\d{2})) )?(.*)$';
// A regex to match all tags (context, priority or extensions)
        const R_TAGS = '(^|\s)([^\s:]+:[^\s:]+|[+@]\S+)';
// A regex to match dates valid in the todo.txt spec
        const R_DATE = '^\d{4}-\d{2}-\d{2}$';

    private
        FComplete: Boolean;
        FPriority: string; // empty string == null
        FCreated: TDateTime; // 0 == null
        FCompleted: TDateTime; // 0 == null
        FBody: string;
        FContexts: TList<TTrackedTag>;
        FProjects: TList<TTrackedTag>;
        FExtensions: TList<TTrackedExtension>;

        function DateFromString(const AInput: string): TDateTime;
        function DateToString(const ADate: TDateTime): string;
        function ParseBody(const ABody: string;
            out ResultContexts: TArray<TTrackedTag>;
            out ResultProjects: TArray<TTrackedTag>;
            out ResultExtensions: TArray<TTrackedExtension>): Boolean;
        function CutOutSpans(const ABody: string; const ASpans: TArray<TSpan>): string;
        function RemoveTag(const ABody: string; const ATags: TArray<TTrackedTag>; const ATag: string; out ResultNewBody: string): Boolean;
    public
        constructor Create(const ALine: string = '');
        destructor Destroy; override;

        procedure Parse(const ALine: string);
        function ToString: string; override;
        function ToAnnotatedString: TAnnotatedItem;

        function Complete: Boolean;
        procedure SetComplete(const AComplete: Boolean);

        function Priority: string;
        procedure SetPriority(const APriority: string);
        procedure ClearPriority;

        function Created: TDateTime;
        function CreatedToString: string;
        procedure SetCreated(const ADate: TDateTime); overload;
        procedure SetCreated(const ADateString: string); overload;
        procedure SetCreatedNull;

        procedure ClearCreated;

        function Completed: TDateTime;
        function CompletedToString: string;
        procedure SetCompletedNull;
        procedure SetCompleted(const ADate: TDateTime); overload;
        procedure SetCompleted(const ADateString: string); overload;

        procedure ClearCompleted;

        function Body: string;
        procedure SetBody(const ABody: string);

        function Contexts: TArray<string>;
        procedure AddContext(const ATag: string);
        procedure RemoveContext(const ATag: string);

        function Projects: TArray<string>;
        procedure AddProject(const ATag: string);
        procedure RemoveProject(const ATag: string);

        function Extensions: TArray<TTrackedExtension>;
        procedure SetExtension(const AKey: string; const AValue: string);
        procedure AddExtension(const AKey: string; const AValue: string);
        procedure RemoveExtension(const AKey: string; const AValue: string = '');
    end;

implementation

uses
    System.Generics.Defaults,
    Mv.LibBase;

const
    NO_DATE: TDateTime = 0.0;

{ TITodoItem }

constructor TITodoItem.Create(const ALine: string);
begin
    inherited Create;
    FContexts := TList<TTrackedTag>.Create;
    FProjects := TList<TTrackedTag>.Create;
    FExtensions := TList<TTrackedExtension>.Create;
    FComplete := False;
    FPriority := '';
    FCreated := 0;
    FCompleted := 0;
    FBody := '';
    if ALine <> '' then
      Parse(ALine);
end;

destructor TITodoItem.Destroy;
begin
    FContexts.Free;
    FProjects.Free;
    FExtensions.Free;
    inherited Destroy;
end;

{
original:
function parseBody(body: string) {
    let start = 0;
    ...
 
Returns contexts, projects, extensions with start positions (zero-based),
matching the original JS parseBody logic.
------------------------------------------------------------------------------------------------------------------}
function TITodoItem.ParseBody(const ABody: string;
    out ResultContexts: TArray<TTrackedTag>;
    out ResultProjects: TArray<TTrackedTag>;
    out ResultExtensions: TArray<TTrackedExtension>): Boolean;
var
    Matches: TMatchCollection;
    Match: TMatch;
    Tag: string;
    StartPos: Integer;
    ContextList: TList<TTrackedTag>;
    ProjectList: TList<TTrackedTag>;
    ExtList: TList<TTrackedExtension>;
    TT: TTrackedTag;
begin
    ContextList := TList<TTrackedTag>.Create;
    ProjectList := TList<TTrackedTag>.Create;
    ExtList := TList<TTrackedExtension>.Create;
    try
        Matches := TRegEx.Matches(ABody, R_TAGS);
        for Match in Matches do
        begin
            // group 2 is the tag itself per JS regex
            if Match.Groups.Count >= 3 then
            begin
                Tag := Match.Groups[2].Value;
                StartPos := Match.Groups[2].Index - 1;  // StartPos is zero-based
                if (Tag <> '') then
                begin
                    if Tag[1] = '@' then
                    begin
                        TT.Tag := Copy(Tag, 2, MaxInt);
                        TT.StartPos := StartPos;
                        ContextList.Add(TT);
                    end
                    else if Tag[1] = '+' then
                    begin
                        TT.Tag := Copy(Tag, 2, MaxInt);
                        TT.StartPos := StartPos;
                        ProjectList.Add(TT);
                    end
                    else
                    begin
                        var E: TTrackedExtension;
                        var PosColon := Pos(':', Tag);
                        if PosColon > 0 then
                        begin
                            // store keys always in lowercase
                            E.Key := LowerCase(Copy(Tag, 1, PosColon - 1));
                            E.Value := Copy(Tag, PosColon + 1, MaxInt);
                        end
                        else
                        begin
                            E.Key := LowerCase(Tag);
                            E.Value := '';
                        end;
                        E.StartPos := StartPos;
                        ExtList.Add(E);
                    end;
                end;
            end;
        end;

        ResultContexts := ContextList.ToArray;
        ResultProjects := ProjectList.ToArray;
        ResultExtensions := ExtList.ToArray;
        Result := True;
    finally
        ContextList.Free;
        ProjectList.Free;
        ExtList.Free;
    end;
end;

{
original:
function dateFromString(input: string): Date {

Helper: parses a date string "YYYY-MM-DD" and returns TDateTime
Throws an Exception on invalid format (to match JS behavior).
------------------------------------------------------------------------------------------------------------------}
function TITodoItem.DateFromString(const AInput: string): TDateTime;
var
    Match: TMatch;
    Y, M, D: Integer;
begin
    if AInput = '' then
      Exit(NO_DATE);
    Match := TRegEx.Match(AInput, R_DATE);
    if not Match.Success then
        raise Exception.Create('Invalid Date Format');
    // parse components
    Y := StrToInt(Copy(AInput, 1, 4));
    M := StrToInt(Copy(AInput, 6, 2));
    D := StrToInt(Copy(AInput, 9, 2));
    try
        Result := EncodeDate(Y, M, D);
    except
        raise Exception.Create('Invalid Date Format');
    end;
end;

(**
 * Parse in a full todo.txt line, replacing and resetting all fields.
 *
 * @param line A full todo.txt task line
 *)
procedure TITodoItem.Parse(const ALine: string);
//Mirrors the JS rTodo-based parsing exactly (groups mapped to same indices).
var
    Match: TMatch;
    CreatedStr, CompletedStr: string;
begin
    // reset all fields
    FComplete := False;
    FPriority := '';
    FCreated := 0;
    FCompleted := 0;
    FBody := '';
    FContexts.Clear;
    FProjects.Clear;
    FExtensions.Clear;

    Match := TRegEx.Match(ALine, R_TODO);
    Assert(Match.Success);              // the original always matches due to trailing (.*)
    Assert(Match.Groups.Count = 11);    //This only depends on the regular expression

    if Match.Groups[2].Value = 'x' then
      FComplete := True;

    if Match.Groups[4].Value <> '' then
      FPriority := Match.Groups[4].Value;

    CreatedStr := '';
    CompletedStr := '';

    //original code: for 2 dates Match.Groups[9].Success is true (even though )
    //// group 9 is single created date when present
    //if (Match.Groups.Count >= 10) and (Match.Groups[9].Success) then
    //begin
    //    CreatedStr := Match.Groups[9].Value;
    //end
    //else if (Match.Groups.Count >= 9) and (Match.Groups[7].Success) then
    //begin
    //    // pair: completed then created
    //    CompletedStr := Match.Groups[7].Value;
    //    CreatedStr := Match.Groups[8].Value;
    //end;
    //RegEx is ((7) (8)|(9)) (7,8,9 match a date)
    if Match.Groups[8].Success then      //8 is second date
    begin
        // pair of dates: completed then created
        CompletedStr := Match.Groups[7].Value;
        CreatedStr := Match.Groups[8].Value;
    end;
    //In Delphi Match.Groups[8].Success returns true, even if there is no value, therefore
    if CreatedStr = '' then
      CreatedStr := Match.Groups[9].Value;  //9 is (single) first date

    FCreated := DateFromString(CreatedStr);
    FCompleted := DateFromString(CompletedStr);

    SetBody(Match.Groups[10].Value);
end;

(*
 * Generate a full todo.txt line out of this Item.
 *)
function TITodoItem.ToString: string;
begin
    Result := '';
    if FComplete then
      Result := 'x'
    else
      Result := '';

    if FPriority <> '' then
      Result := Cat(Result, '(' + FPriority + ')', ' ');

    Result := Cat(Result, CompletedToString, ' ');
    Result := Cat(Result, CreatedToString, ' ');

    Result := Cat(Result, FBody, ' ');
end;

(*
 * Generate the full todo.txt line of this Item, as well as spans describing the
 * location of all of it's component parts.
 *)
function TITodoItem.ToAnnotatedString: TAnnotatedItem;
var
    S: string;
    HeaderLength: Integer;

    // local remappers
    function TagRemap(const APrefix: string; const ATracked: TTrackedTag): TContext;
    begin
        Result.Text := APrefix + ATracked.Tag;
        Result.Span.StartPos := ATracked.StartPos + HeaderLength;
        Result.Span.EndPos := ATracked.StartPos + HeaderLength + Length(Result.Text);
    end;

    function ExtensionsRemap(const AExt: TTrackedExtension): TExtensionRec;
    begin
        Result.Text := AExt.Key + ':' + AExt.Value;
        Result.ParsedKey := AExt.Key;
        Result.ParsedValue := AExt.Value;
        Result.Span.StartPos := AExt.StartPos + HeaderLength;
        Result.Span.EndPos := AExt.StartPos + HeaderLength + Length(Result.Text);
    end;

var
    I: Integer;
    ContextsArr: TArray<TContext>;
    ProjectsArr: TArray<TProject>;
    ExtArr: TArray<TExtensionRec>;
begin
    S := ToString;
    HeaderLength := Length(S) - Length(FBody);

    // contexts
    SetLength(ContextsArr, FContexts.Count);
    for I := 0 to FContexts.Count - 1 do
        ContextsArr[I] := TagRemap('@', FContexts[I]);

    // projects
    SetLength(ProjectsArr, FProjects.Count);
    for I := 0 to FProjects.Count - 1 do
        ProjectsArr[I] := TagRemap('+', FProjects[I]);

    // extensions
    SetLength(ExtArr, FExtensions.Count);
    for I := 0 to FExtensions.Count - 1 do
        ExtArr[I] := ExtensionsRemap(FExtensions[I]);

    Result.Text := S;
    Result.Contexts := ContextsArr;
    Result.Projects := ProjectsArr;
    Result.Extensions := ExtArr;
end;

(*
 * Is this task complete?
 *)
function TITodoItem.Complete: Boolean;
begin
    Result := FComplete;
end;

(*
 * Set if this task is complete.
 *
 * **Side Effect**
 *
 * Setting this to false will clear the completed date.
 *
 * @param complete True if the task is complete.
 *)
procedure TITodoItem.SetComplete(const AComplete: Boolean);
begin
    FComplete := AComplete;
    if not AComplete then
        ClearCompleted;
end;

(*
 * Get the priority of this Item, or '' if not present.
 *)
function TITodoItem.Priority: string;
begin
    if FPriority = '' then
        Result := ''
    else
        Result := FPriority;
end;

(*
 * Set the priority of the task.  Passing `` clears priority.
 *
 * @param priority A priority from A-Z or null to clear priority.
 * @throws An Error when the input is invalid.
 *)
procedure TITodoItem.SetPriority(const APriority: string);
var
    CharCode: Integer;
begin
    if APriority <> '' then
    begin
        if Length(APriority) <> 1 then
            raise Exception.Create('Invalid Priority');
        CharCode := Ord(UpCase(APriority[1]));
        if (CharCode < Ord('A')) or (CharCode > Ord('Z')) then
            raise Exception.Create('Invalid Priority');
    end;
    FPriority := APriority;
end;

(*
 * Remove the priority from this task.
 *)
procedure TITodoItem.ClearPriority;
begin
    FPriority := '';
end;

(*
 * Get the creation date of this task.
 *
 * @returns The creation date, or null if not set.
 *)
function TITodoItem.Created: TDateTime;
begin
    Result := FCreated;
end;

(*
 * Get the creation date as string, or an empty string if not set.
 *
 * @returns The creation date as a string formatted for todo.txt (YYYY-MM-DD)
 *)
function TITodoItem.CreatedToString: string;
begin
    Result := DateToString(FCreated);
end;

(*
 * Set the created date for the task. Passing `null` or no argument clears the created date.
 *
 * **Side Effect**
 *
 * Clearing the created date will also unset the completed date.
 *
 * @param date
 * @throws An Error when the date is provided as a string and is invalid.
 *)
procedure TITodoItem.SetCreated(const ADate: TDateTime);
begin
    if ADate <= 0 then
        ClearCreated
    else
        FCreated := ADate;
end;

procedure TITodoItem.SetCreated(const ADateString: string);
begin
    if ADateString = '' then
        ClearCreated
    else
        FCreated := DateFromString(ADateString);
end;

procedure TITodoItem.SetCreatedNull;
begin
    ClearCreated;
end;

(*
 * Remove the created date from the task.
 *
 * **Side Effect**
 *
 * Clearing the created date will also unset the completed date.
 *)
procedure TITodoItem.ClearCreated;
begin
    FCreated := 0;
    FCompleted := 0;
    FComplete := False;
end;

(*
 * Get the completed date of this task.
 *
 * @returns The completed date, or null if not set.
 *)
function TITodoItem.Completed: TDateTime;
begin
    Result := FCompleted;
end;

(*
 * Get the completed date as string, or an empty string if not set.
 *
 * @returns The completed date as a string formatted for todo.txt (YYYY-MM-DD)
 *)
function TITodoItem.CompletedToString: string;
begin
    Result := DateToString(FCompleted);
end;

(*
 * setCompleted(date: Date | string | null = null)
 * Side effect: setting completed sets complete = true
 *)
procedure TITodoItem.SetCompletedNull;
begin
    ClearCompleted;
end;

(**
 * Set the completed date for the task. Passing `null` or no argument clears the completed date.
 *
 * **Side Effect**
 *
 * Setting completed will set complete to true.
 *
 * @param date
 * @throws An Error when the date is provided as a string and is invalid.
 *)
procedure TITodoItem.SetCompleted(const ADate: TDateTime);
begin
    if ADate <= 0 then
        ClearCompleted
    else
    begin
        FCompleted := ADate;
        FComplete := True;
    end;
end;

procedure TITodoItem.SetCompleted(const ADateString: string);
begin
    if ADateString = '' then
        ClearCompleted
    else
        SetCompleted(DateFromString(ADateString));
end;

(*
 * Remove the completed date from the task.
 *)
procedure TITodoItem.ClearCompleted;
begin
    FCompleted := 0;
end;

(*
 * Get the body of the task.
 * @returns The body portion of the task.
 *)
function TITodoItem.Body: string;
begin
    Result := FBody;
end;

(*
 * Parse and set the body and body elements.
 *
 * **Side Effect**
 *
 * This will clear and re-load contexts, projects and extensions.
 *
 * @param body A todo.txt description string.
 *)
procedure TITodoItem.SetBody(const ABody: string);
var
    ContextsArr: TArray<TTrackedTag>;
    ProjectsArr: TArray<TTrackedTag>;
    ExtArr: TArray<TTrackedExtension>;
    I: Integer;
begin
    if ABody = '' then
    begin
        FBody := '';
        FContexts.Clear;
        FProjects.Clear;
        FExtensions.Clear;
        Exit;
    end;

    if ParseBody(ABody, ContextsArr, ProjectsArr, ExtArr) then
    begin
        FBody := ABody;
        FContexts.Clear;
        FProjects.Clear;
        FExtensions.Clear;
        for I := 0 to Length(ContextsArr) - 1 do
            FContexts.Add(ContextsArr[I]);
        for I := 0 to Length(ProjectsArr) - 1 do
            FProjects.Add(ProjectsArr[I]);
        for I := 0 to Length(ExtArr) - 1 do
            FExtensions.Add(ExtArr[I]);
    end
    else
    begin
        // fallback: keep body and clear tags
        FBody := ABody;
        FContexts.Clear;
        FProjects.Clear;
        FExtensions.Clear;
    end;
end;

(*
 * Get all of the context tags on the task.
 *
 * @returns Context tags, without the `@`
 *)
function TITodoItem.Contexts: TArray<string>;
var
    SetDict: TDictionary<string, Boolean>;
    I: Integer;
    List: TList<string>;
begin
    SetDict := TDictionary<string, Boolean>.Create;
    List := TList<string>.Create;
    try
        for I := 0 to FContexts.Count - 1 do
        begin
            if not SetDict.ContainsKey(FContexts[I].Tag) then
            begin
                SetDict.Add(FContexts[I].Tag, True);
                List.Add(FContexts[I].Tag);
            end;
        end;
        Result := List.ToArray;
    finally
        SetDict.Free;
        List.Free;
    end;
end;

(*
 * Add a new context to the task. Will append to the end.
 * If the context is already present, it will not be added.
 *
 * @param tag A valid context, without the `@`
 *)
procedure TITodoItem.AddContext(const ATag: string);
var
    I: Integer;
    Found: Boolean;
    T: TTrackedTag;
begin
    Found := False;
    for I := 0 to FContexts.Count - 1 do
        if FContexts[I].Tag = ATag then
        begin
            Found := True;
            Break;
        end;
    if not Found then
    begin
        T.Tag := ATag;
        T.StartPos := Length(FBody); // zero-based position at end (Delphi Length is count)
        FContexts.Add(T);
        if FBody = '' then
            FBody := '@' + ATag
        else
            FBody := FBody + ' ' + '@' + ATag;
    end;
end;

(*
 * Remove a context from the task, if present.
 *
 * @param tag A valid context, without the `@`
 *)
procedure TITodoItem.RemoveContext(const ATag: string);
var
    NewBody: string;
    ContextArr: TArray<TTrackedTag>;
    ProjectArr: TArray<TTrackedTag>;
    ExtArr: TArray<TTrackedExtension>;
    I: Integer;
begin
    if RemoveTag(FBody, FContexts.ToArray, ATag, NewBody) then
    begin
        FBody := NewBody;
        // reparse
        if ParseBody(FBody, ContextArr, ProjectArr, ExtArr) then
        begin
            FContexts.Clear;
            FProjects.Clear;
            FExtensions.Clear;
            for I := 0 to Length(ContextArr) - 1 do FContexts.Add(ContextArr[I]);
            for I := 0 to Length(ProjectArr) - 1 do FProjects.Add(ProjectArr[I]);
            for I := 0 to Length(ExtArr) - 1 do FExtensions.Add(ExtArr[I]);
        end;
    end;
end;

(*
 * Get all of the project tags on the task.
 *
 * @returns Project tags, without the `+`
 *)
function TITodoItem.Projects: TArray<string>;
var
    SetDict: TDictionary<string, Boolean>;
    I: Integer;
    List: TList<string>;
begin
    SetDict := TDictionary<string, Boolean>.Create;
    List := TList<string>.Create;
    try
        for I := 0 to FProjects.Count - 1 do
        begin
            if not SetDict.ContainsKey(FProjects[I].Tag) then
            begin
                SetDict.Add(FProjects[I].Tag, True);
                List.Add(FProjects[I].Tag);
            end;
        end;
        Result := List.ToArray;
    finally
        SetDict.Free;
        List.Free;
    end;
end;

(*
 * Add a new project to the task. Will append to the end.
 * If the project is already present, it will not be added.
 *
 * @param tag A valid project, without the `+`
 *)
procedure TITodoItem.AddProject(const ATag: string);
var
    I: Integer;
    Found: Boolean;
    P: TTrackedTag;
begin
    Found := False;
    for I := 0 to FProjects.Count - 1 do
        if FProjects[I].Tag = ATag then
        begin
            Found := True;
            Break;
        end;
    if not Found then
    begin
        P.Tag := ATag;
        P.StartPos := Length(FBody);
        FProjects.Add(P);
        if FBody = '' then
            FBody := '+' + ATag
        else
            FBody := FBody + ' ' + '+' + ATag;
    end;
end;

(*
 * Remove a project from the task, if present.
 *
 * @param tag A valid project, without the `+`
 *)
procedure TITodoItem.RemoveProject(const ATag: string);
var
    NewBody: string;
    ContextArr: TArray<TTrackedTag>;
    ProjectArr: TArray<TTrackedTag>;
    ExtArr: TArray<TTrackedExtension>;
    I: Integer;
begin
    if RemoveTag(FBody, FProjects.ToArray, ATag, NewBody) then
    begin
        FBody := NewBody;
        // reparse
        if ParseBody(FBody, ContextArr, ProjectArr, ExtArr) then
        begin
            FContexts.Clear;
            FProjects.Clear;
            FExtensions.Clear;
            for I := 0 to Length(ContextArr) - 1 do FContexts.Add(ContextArr[I]);
            for I := 0 to Length(ProjectArr) - 1 do FProjects.Add(ProjectArr[I]);
            for I := 0 to Length(ExtArr) - 1 do FExtensions.Add(ExtArr[I]);
        end;
    end;
end;

(*
 * Get all of the project tags on the task.
 *
 * @returns Project tags, without the `+`
 *)
function TITodoItem.Extensions: TArray<TTrackedExtension>;
begin
    Result := FExtensions.ToArray;
end;

{
  original:
    setExtension(key: string, value: string) {
------------------------------------------------------------------------------------------------------------------}
procedure TITodoItem.SetExtension(const AKey: string; const AValue: string);
var
    I: Integer;
    Found: Boolean;
    BodyTemp: string;
    FirstHandled: Boolean;
    StartPos, EndPos: Integer;
    Prefix, Suffix: string;
    ContextArr: TArray<TTrackedTag>;
    ProjectArr: TArray<TTrackedTag>;
    ExtArr: TArray<TTrackedExtension>;
    J: Integer;
    LowerKey: string;
begin
    LowerKey := LowerCase(AKey);

    Found := False;
    FirstHandled := False;
    // Iterate through extensions; mimic JS logic
    for I := 0 to FExtensions.Count - 1 do
    begin
        if FExtensions[I].Key = LowerKey then
        begin
            // compute prefix and suffix based on zero-based start index
            StartPos := FExtensions[I].StartPos; // zero-based
            EndPos := StartPos + Length(FExtensions[I].Key) + Length(FExtensions[I].Value) + 1; // exclusive
            // prefix: characters before StartPos (Delphi 1-based Copy uses count StartPos)
            Prefix := Copy(FBody, 1, StartPos);
            Suffix := '';
            if EndPos < Length(FBody) then
                Suffix := Copy(FBody, EndPos + 1, MaxInt)
            else
                Suffix := '';
            if not FirstHandled then
            begin
                // replace first occurrence — use lowercase key when writing
                if Prefix = '' then
                    BodyTemp := LowerKey + ':' + AValue
                else
                begin
                    // ensure there's a separating space between prefix and new key:value
                    if Prefix[Length(Prefix)] = ' ' then
                        BodyTemp := Prefix + LowerKey + ':' + AValue + Suffix
                    else
                        BodyTemp := Prefix + ' ' + LowerKey + ':' + AValue + Suffix;
                end;
                FirstHandled := True;
            end
            else
            begin
                // remove subsequent occurrences; take off extra trailing space from prefix if present
                if Length(Prefix) > 0 then
                    Prefix := Copy(Prefix, 1, Max(0, Length(Prefix) - 1));
                BodyTemp := Prefix + Suffix;
            end;
            Found := True;
            // update FBody for subsequent iterations to compute correct indices
            FBody := BodyTemp;
            // After modifying FBody, the rest of FExtensions' StartPos are stale.
            // JS operated on original positions; to preserve behaviour we continue but
            // at the end we'll reparse the body and exit loop.
        end;
    end;

    if Found then
    begin
        // reparse
        if ParseBody(FBody, ContextArr, ProjectArr, ExtArr) then
        begin
            FContexts.Clear;
            FProjects.Clear;
            FExtensions.Clear;
            for J := 0 to Length(ContextArr) - 1 do FContexts.Add(ContextArr[J]);
            for J := 0 to Length(ProjectArr) - 1 do FProjects.Add(ProjectArr[J]);
            for J := 0 to Length(ExtArr) - 1 do FExtensions.Add(ExtArr[J]);
        end;
    end
    else
    begin
        AddExtension(LowerKey, AValue);
    end;
end;

{
  original:
    addExtension(key: string, value: string) {
------------------------------------------------------------------------------------------------------------------}
procedure TITodoItem.AddExtension(const AKey: string; const AValue: string);
var
    Ext: TTrackedExtension;
    LowerKey: string;
begin
    LowerKey := LowerCase(AKey);
    Ext.Key := LowerKey;
    Ext.Value := AValue;
    Ext.StartPos := Length(FBody);
    FExtensions.Add(Ext);
    if FBody = '' then
      FBody := LowerKey + ':' + AValue
    else
      FBody := FBody + ' ' + LowerKey + ':' + AValue;
end;

{ 
  original:
    removeExtension(key: string, value: string | null = null) {
------------------------------------------------------------------------------------------------------------------}
procedure TITodoItem.RemoveExtension(const AKey: string; const AValue: string);
var
    I: Integer;
    Spans: TList<TSpan>;
    SpanItem: TSpan;
    NewBody: string;
    Arr: TArray<TSpan>;
    Sorted: TList<TSpan>;
    J: Integer;
    ContextArr: TArray<TTrackedTag>;
    ProjectArr: TArray<TTrackedTag>;
    ExtArr: TArray<TTrackedExtension>;
begin
    Spans := TList<TSpan>.Create;
    try
        for I := 0 to FExtensions.Count - 1 do
        begin
            if (FExtensions[I].Key = LowerCase(AKey)) and ((AValue = '') or (FExtensions[I].Value = AValue)) then
            begin
                SpanItem.StartPos := FExtensions[I].StartPos;
                SpanItem.EndPos := FExtensions[I].StartPos + Length(FExtensions[I].Key) + Length(FExtensions[I].Value) + 1;
                Spans.Add(SpanItem);
            end;
        end;

        if Spans.Count = 0 then
            Exit;

        // Convert to array and sort descending
        SetLength(Arr, Spans.Count);
        for I := 0 to Spans.Count - 1 do
            Arr[I] := Spans[I];

        // Sort descending by start
        Sorted := TList<TSpan>.Create;
        try
            for I := 0 to Length(Arr) - 1 do
                Sorted.Add(Arr[I]);

            Sorted.Sort(TComparer<TSpan>.Construct(
                function(const A, B: TSpan): Integer
                begin
                    if A.StartPos < B.StartPos then
                        Result := 1
                    else if A.StartPos > B.StartPos then
                        Result := -1
                    else
                        Result := 0;
                end));

            SetLength(Arr, Sorted.Count);
            for I := 0 to Sorted.Count - 1 do
                Arr[I] := Sorted[I];
        finally
            Sorted.Free;
        end;

        // cut out spans
        NewBody := CutOutSpans(FBody, Arr);
        FBody := NewBody;

        // reparse
        if ParseBody(FBody, ContextArr, ProjectArr, ExtArr) then
        begin
            FContexts.Clear;
            FProjects.Clear;
            FExtensions.Clear;
            for J := 0 to Length(ContextArr) - 1 do FContexts.Add(ContextArr[J]);
            for J := 0 to Length(ProjectArr) - 1 do FProjects.Add(ProjectArr[J]);
            for J := 0 to Length(ExtArr) - 1 do FExtensions.Add(ExtArr[J]);
        end;
    finally
        Spans.Free;
    end;
end;

{
original:
function dateString(date: Date | null): string {
------------------------------------------------------------------------------------------------------------------}
function TITodoItem.DateToString(const ADate: TDateTime): string;
begin
    if ADate <> NO_DATE then
      Result := FormatDateTime('yyyy-mm-dd', ADate)
    else
      Result := '';
end;

{
original:
function cutOutSpans(body: string, spans: Span[]): string {

Mimic JS behaviour: remove each span and also remove the preceding character
(usually a space) when available. Spans are expected to be zero-based indices,
with 'end' being the exclusive end index.
We apply spans in the incoming order; the caller usually sorts spans descending to avoid shifting.
------------------------------------------------------------------------------------------------------------------}
function TITodoItem.CutOutSpans(const ABody: string; const ASpans: TArray<TSpan>): string;
var
    I: Integer;
    ResultStr: string;
    StartZero, EndZero: Integer;
    RemoveStart, RemoveEnd: Integer;
    SpansList: TList<TSpan>;
    Prefix, Suffix: string;
begin
    ResultStr := ABody;
    // apply spans in order provided (caller should sort desc if needed), but to be safe apply descending
    SpansList := TList<TSpan>.Create;
    try
        for I := 0 to Length(ASpans) - 1 do
            SpansList.Add(ASpans[I]);
        // sort descending by StartPos
        SpansList.Sort(TComparer<TSpan>.Construct(
            function(const A, B: TSpan): Integer
            begin
                if A.StartPos < B.StartPos then
                    Result := 1
                else if A.StartPos > B.StartPos then
                    Result := -1
                else
                    Result := 0;
            end));

        for I := 0 to SpansList.Count - 1 do
        begin
            StartZero := SpansList[I].StartPos;
            EndZero := SpansList[I].EndPos;
            // remove preceding character when possible (JS used start-1)
            RemoveStart := StartZero - 1;
            if RemoveStart < 0 then
                RemoveStart := 0;
            RemoveEnd := EndZero; // exclusive

            // Delphi Copy uses 1-based indexing.
            // prefix = Copy(ResultStr, 1, RemoveStart)
            // suffix start (Delphi 1-based) = RemoveEnd + 1
            if RemoveStart = 0 then
                Prefix := ''
            else
                Prefix := Copy(ResultStr, 1, RemoveStart);
            if RemoveEnd < Length(ResultStr) then
                Suffix := Copy(ResultStr, RemoveEnd + 1, MaxInt)
            else
                Suffix := '';
            ResultStr := Prefix + Suffix;
        end;

        Result := ResultStr;
    finally
        SpansList.Free;
    end;
end;

{
original:
function removeTag(body: string, tags: TrackedTag[], tag: string): string | null {

Returns null (false in Delphi with out param) when no spans to remove.
Otherwise returns new body via out parameter and returns true.
------------------------------------------------------------------------------------------------------------------}
function TITodoItem.RemoveTag(const ABody: string; const ATags: TArray<TTrackedTag>; const ATag: string; out ResultNewBody: string): Boolean;
var
    I: Integer;
    Spans: TList<TSpan>;
    TagLen: Integer;
    TT: TTrackedTag;
    Arr: TArray<TSpan>;
    S: TSpan;
begin
    Spans := TList<TSpan>.Create;
    try
        for I := 0 to Length(ATags) - 1 do
        begin
            TT := ATags[I];
            if TT.Tag = ATag then
            begin
                TagLen := Length(TT.Tag);
                S.StartPos := TT.StartPos;
                S.EndPos := TT.StartPos + TagLen + 1; // include leading symbol
                Spans.Add(S);
            end;
        end;

        if Spans.Count = 0 then
        begin
            Result := False;
            Exit;
        end;

        // convert to array
        SetLength(Arr, Spans.Count);
        for I := 0 to Spans.Count - 1 do
            Arr[I] := Spans[I];

        // The original cuts spans in order (they sort descending). We follow the same.
        ResultNewBody := CutOutSpans(ABody, Arr);
        Result := True;
    finally
        Spans.Free;
    end;
end;

end.
