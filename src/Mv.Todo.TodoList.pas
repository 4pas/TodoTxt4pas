unit Mv.Todo.TodoList;

interface

uses
    System.SysUtils,
    System.Classes,
    System.Generics.Collections,
    System.RegularExpressions,
    System.DateUtils,
    Mv.StringList,
    Mv.Todo.TodoItem;

(*
  Original file: src/List.ts (jsTodoTxt) - MIT License
  Port notes & changes:
  - TOptionalDateRange renamed to TDateRange.
    * Start -> StartDate, End -> EndDate
    * CreateSelectAll sets StartDate and EndDate to 0.0 (select all).
    * HasStartDate / HasEndDate are computed: True when date is present (StartDate <> 0).
  - TTodoListFilter exposes properties. Setting a property that represents a filter value
    will set the corresponding HasXxx flag to True (e.g. setting Complete sets HasComplete := True).
  - Variable names use PascalCase.
  - Other logic follows the original List.ts ordering and semantics.
*)

type
    // TDateRange: maps original DateRange | null semantics
    TDateRange = record
        StartDate: TDateTime; // 0.0 = not set / null
        EndDate: TDateTime;   // 0.0 = not set / null
        class function CreateSelectAll: TDateRange; static; // both zero -> select all
        function HasStartDate: Boolean;
        function HasEndDate: Boolean;
        class function CreateRange(const AStartDate, AEndDate: TDateTime): TDateRange; static;
        class function CreateIsNull: TDateRange; static; // helper to express explicit null (both zero)
    end;

    // Extension filter function type
    TExtensionFilterFunction = reference to function(const AExtensions: TArray<TTrackedExtension>): Boolean;

    // ListFilter analog
    TTodoListFilter = record
    private
        // complete
        FHasComplete: Boolean;
        FComplete: Boolean;

        // priority
        FHasPriority: Boolean;
        FPriority: string;

        // created / completed ranges
        FHasCreated: Boolean;
        FCreatedRange: TDateRange;

        FHasCompleted: Boolean;
        FCompletedRange: TDateRange;

        // body
        FHasBody: Boolean;
        FBodyIsRegex: Boolean;
        FBodyRegex: TRegEx;
        FBodyText: string;

        // contexts/projects arrays are public fields (empty array = not set)
        // extensions
        FHasExtensionFunc: Boolean;
        FExtensionFunc: TExtensionFilterFunction;
        FExtensionKeys: TArray<string>;

        procedure SetComplete(const AValue: Boolean);
        procedure SetPriority(const AValue: string);
        procedure SetCreatedRange(const AValue: TDateRange);
        procedure SetCompletedRange(const AValue: TDateRange);
        procedure SetCreatedStartDate(const AValue: TDateTime);
        procedure SetCreatedEndDate(const AValue: TDateTime);
        procedure SetCompletedStartDate(const AValue: TDateTime);
        procedure SetCompletedEndDate(const AValue: TDateTime);
        procedure SetBodyText(const AValue: string);
        procedure SetBodyRegex(const ARegex: TRegEx);
        procedure SetExtensionFunc(const AValue: TExtensionFilterFunction);
        procedure SetExtensionKeys(const AValue: TArray<string>);
    public
        ContextsAnd: TArray<string>;
        ContextsOr: TArray<string>;
        ContextsNot: TArray<string>;

        ProjectsAnd: TArray<string>;
        ProjectsOr: TArray<string>;
        ProjectsNot: TArray<string>;

        class function CreateEmpty: TTodoListFilter; static;
        procedure Reset;

        // properties (HasXxx can be inspected)
        property HasComplete: Boolean read FHasComplete;
        property Complete: Boolean read FComplete write SetComplete;

        property HasPriority: Boolean read FHasPriority;
        property Priority: string read FPriority write SetPriority;

        property HasCreated: Boolean read FHasCreated;
        property CreatedRange: TDateRange read FCreatedRange write SetCreatedRange;
        property CreatedStartDate: TDateTime read FCreatedRange.StartDate write SetCreatedStartDate;
        property CreatedEndDate: TDateTime read FCreatedRange.EndDate write SetCreatedEndDate;

        property HasCompleted: Boolean read FHasCompleted;
        property CompletedRange: TDateRange read FCompletedRange write SetCompletedRange;
        property CompletedStartDate: TDateTime read FCompletedRange.StartDate write SetCompletedStartDate;
        property CompletedEndDate: TDateTime read FCompletedRange.EndDate write SetCompletedEndDate;

        property HasBody: Boolean read FHasBody;
        property BodyIsRegex: Boolean read FBodyIsRegex;
        property BodyRegex: TRegEx read FBodyRegex write SetBodyRegex;
        property BodyText: string read FBodyText write SetBodyText;

        property HasExtensionFunc: Boolean read FHasExtensionFunc;
        property ExtensionFunc: TExtensionFilterFunction read FExtensionFunc write SetExtensionFunc;
        property ExtensionKeys: TArray<string> read FExtensionKeys write SetExtensionKeys;
    end;

    // ListItem result record
    TTodoListItem = record
        Index: Integer;
        Item: ITodoItem;
    end;

    ITodoList = interface
        ['{D2F3A8E1-9B2D-4A3F-A0B6-7D1A5FF9C8B8}']
        procedure ParseFromString(const AInput: string);
        procedure ParseFromLines(const ALines: TArray<string>);

        function ToString: string;

        function Items: TArray<TTodoListItem>;
        function Projects: IStringList;
        function Contexts: IStringList;
        function GetExtensions: IStringList;
        function GetExtensionValues(const AExtension: string): IStringList; // returns unique values for the key

        function Filter(const AFilter: TTodoListFilter): TArray<TTodoListItem>;

        function Add(const AItem: ITodoItem): TTodoListItem; overload;
        function Add(const ALine: string): TTodoListItem; overload;
    end;

    TITodoList = class(TInterfacedObject, ITodoList)
    private
        FItems: TList<ITodoItem>;
    public
        constructor Create; overload;
        destructor Destroy; override;

        procedure ParseFromString(const AInput: string);
        procedure ParseFromLines(const ALines: TArray<string>);

        function ToString: string; override;

        function Items: TArray<TTodoListItem>;
        function Projects: IStringList;
        function Contexts: IStringList;
        function GetExtensions: IStringList;
        function GetExtensionValues(const AExtension: string): IStringList;

        function Filter(const AFilter: TTodoListFilter): TArray<TTodoListItem>;

        function Add(const AItem: ITodoItem): TTodoListItem; overload;
        function Add(const ALine: string): TTodoListItem; overload;
    end;

function FilterDateRange(const ADate: TDateTime; const ARange: TDateRange): Boolean;

implementation

{ TDateRange }

class function TDateRange.CreateSelectAll: TDateRange;
begin
    Result.StartDate := 0;
    Result.EndDate := 0;
end;

class function TDateRange.CreateRange(const AStartDate, AEndDate: TDateTime): TDateRange;
begin
    Result.StartDate := AStartDate;
    Result.EndDate := AEndDate;
end;

class function TDateRange.CreateIsNull: TDateRange;
begin
    // explicit null expressed with StartDate = 0 and EndDate = 0
    Result.StartDate := 0;
    Result.EndDate := 0;
end;

function TDateRange.HasStartDate: Boolean;
begin
    Result := (StartDate <> 0);
end;

function TDateRange.HasEndDate: Boolean;
begin
    Result := (EndDate <> 0);
end;

{ TTodoListFilter }

class function TTodoListFilter.CreateEmpty: TTodoListFilter;
begin
    Result.Reset;
end;

procedure TTodoListFilter.Reset;
begin
    FHasComplete := False;
    FComplete := False;

    FHasPriority := False;
    FPriority := '';

    FHasCreated := False;
    FCreatedRange := TDateRange.CreateSelectAll;

    FHasCompleted := False;
    FCompletedRange := TDateRange.CreateSelectAll;

    FHasBody := False;
    FBodyIsRegex := False;
    FBodyText := '';
    FBodyRegex := TRegEx.Create('');    //record

    FHasExtensionFunc := False;
    FExtensionFunc := nil;
    FExtensionKeys := nil;

    ContextsAnd := nil;
    ContextsOr := nil;
    ContextsNot := nil;

    ProjectsAnd := nil;
    ProjectsOr := nil;
    ProjectsNot := nil;
end;

procedure TTodoListFilter.SetComplete(const AValue: Boolean);
begin
    FComplete := AValue;
    FHasComplete := True;
end;

procedure TTodoListFilter.SetPriority(const AValue: string);
begin
    FPriority := AValue;
    FHasPriority := True;
end;

procedure TTodoListFilter.SetCreatedRange(const AValue: TDateRange);
begin
    FCreatedRange := AValue;
    //even if 0 (NO_DATE) is set, HasCreated must be true - we might explicitly search for NO_DATE!
    FHasCreated := True;
end;

procedure TTodoListFilter.SetCompletedRange(const AValue: TDateRange);
begin
    FCompletedRange := AValue;
    //see FHasCreated
    FHasCompleted := True;
end;

procedure TTodoListFilter.SetCreatedStartDate(const AValue: TDateTime);
begin
    FCreatedRange.StartDate := AValue;
    FHasCreated := True;
end;

procedure TTodoListFilter.SetCreatedEndDate(const AValue: TDateTime);
begin
    FCreatedRange.EndDate := AValue;
    FHasCreated := True;
end;

procedure TTodoListFilter.SetCompletedStartDate(const AValue: TDateTime);
begin
    FCompletedRange.StartDate := AValue;
    FHasCompleted := True;
end;

procedure TTodoListFilter.SetCompletedEndDate(const AValue: TDateTime);
begin
    FCompletedRange.EndDate := AValue;
    FHasCompleted := True;
end;

procedure TTodoListFilter.SetBodyText(const AValue: string);
begin
    FBodyText := AValue;
    FBodyIsRegex := False;
    FHasBody := True;
end;

procedure TTodoListFilter.SetBodyRegex(const ARegex: TRegEx);
begin
    FBodyRegex := ARegex;
    FBodyIsRegex := True;
    FHasBody := True;
end;

procedure TTodoListFilter.SetExtensionFunc(const AValue: TExtensionFilterFunction);
begin
    FExtensionFunc := AValue;
    FHasExtensionFunc := True;
end;

procedure TTodoListFilter.SetExtensionKeys(const AValue: TArray<string>);
var
    i: Integer;
begin
    SetLength(FExtensionKeys, Length(AValue));
    for i := 0 to Length(AValue) - 1 do
        FExtensionKeys[i] := LowerCase(AValue[i]);
end;

{ TITodoList }

constructor TITodoList.Create;
begin
    inherited Create;
    FItems := TList<ITodoItem>.Create;
end;

destructor TITodoList.Destroy;
begin
    FItems.Free;
    inherited Destroy;
end;

(*
    original:
    constructor(input: string | string[]) {
        let lines: string[];
        ...
*)
procedure TITodoList.ParseFromString(const AInput: string);
var
    Sl: TStringList;
    I: Integer;
    Lines: TArray<string>;
begin
    Sl := TStringList.Create;
    try
        Sl.Text := AInput;
        SetLength(Lines, Sl.Count);
        for I := 0 to Sl.Count - 1 do
            Lines[I] := Sl[I];
    finally
        Sl.Free;
    end;

    ParseFromLines(Lines);
end;

procedure TITodoList.ParseFromLines(const ALines: TArray<string>);
var
    I: Integer;
    Trimmed: string;
    Item: ITodoItem;
begin
    FItems.Clear;
    for I := 0 to Length(ALines) - 1 do
    begin
        Trimmed := TrimRight(ALines[I]);

        if Trimmed <> '' then
        begin
            Item := TITodoItem.Create(Trimmed);
            FItems.Add(Item);
        end;
    end;
end;

(*
    original:
    toString(): string {
        return this.#items.map((item) => item.toString()).join('\n');
    }
*)
function TITodoList.ToString: string;
var
    I: Integer;
    Parts: TList<string>;
begin
    Parts := TList<string>.Create;
    try
        for I := 0 to FItems.Count - 1 do
            Parts.Add(FItems[I].ToString);
        Result := String.Join(sLineBreak, Parts.ToArray);
    finally
        Parts.Free;
    end;
end;

(*
    original:
    items(): ListItem[] {
        return this.#items.map((item: Item, index: number): ListItem => {
        ...
*)
function TITodoList.Items: TArray<TTodoListItem>;
var
    I: Integer;
begin
    SetLength(Result, FItems.Count);
    for I := 0 to FItems.Count - 1 do
    begin
        Result[I].Index := I;
        Result[I].Item := FItems[I];
    end;
end;

(*
    original:
    projects(): string[] {
        return [
        ...
*)
function TITodoList.Projects: IStringList;
var
    Dict: TDictionary<string, Boolean>;
    I, J: Integer;
    Arr: TArray<string>;
    Proj: string;
begin
    Dict := TDictionary<string, Boolean>.Create;
    Result := TIStringList.Create;
    try
        for I := 0 to FItems.Count - 1 do
        begin
            Arr := FItems[I].Projects;
            for J := 0 to Length(Arr) - 1 do
            begin
                Proj := Arr[J];
                if not Dict.ContainsKey(Proj) then
                begin
                    Dict.Add(Proj, True);
                    Result.Add(Proj);
                end;
            end;
        end;
    finally
        Dict.Free;
    end;
end;

(*
    original:
    contexts(): string[] {
        return [
        ...
*)
function TITodoList.Contexts: IStringList;
var
    Dict: TDictionary<string, Boolean>;
    I, J: Integer;
    Arr: TArray<string>;
    Ctx: string;
begin
    Dict := TDictionary<string, Boolean>.Create;
    Result := TIStringList.Create;
    try
        for I := 0 to FItems.Count - 1 do
        begin
            Arr := FItems[I].Contexts;
            for J := 0 to Length(Arr) - 1 do
            begin
                Ctx := Arr[J];
                if not Dict.ContainsKey(Ctx) then
                begin
                    Dict.Add(Ctx, True);
                    Result.Add(Ctx);
                end;
            end;
        end;
    finally
        Dict.Free;
    end;
end;

(*
    original:
    extensions(): KeysForExtensions {
        const ret: KeysForExtensions = {};
        ...
*)
function TITodoList.GetExtensions: IStringList;
var
    DictKeys: TDictionary<string, Boolean>;
    I, J: Integer;
    Exts: TArray<TTrackedExtension>;
    Key: string;
begin
    DictKeys := TDictionary<string, Boolean>.Create;
    Result := TIStringList.Create;
    try
        for I := 0 to FItems.Count - 1 do
        begin
            Exts := FItems[I].Extensions;
            for J := 0 to Length(Exts) - 1 do
            begin
                Key := Exts[J].Key;
                if not DictKeys.ContainsKey(Key) then
                begin
                    DictKeys.Add(Key, True);
                    Result.Add(Key);
                end;
            end;
        end;
    finally
        DictKeys.Free;
    end;
end;

function TITodoList.GetExtensionValues(const AExtension: string): IStringList;
var
    DictValues: TDictionary<string, Boolean>;
    I, J: Integer;
    Exts: TArray<TTrackedExtension>;
    Value: string;
    LKey: string;
begin
    LKey := LowerCase(AExtension);

    DictValues := TDictionary<string, Boolean>.Create;
    Result := TIStringList.Create;
    try
        for I := 0 to FItems.Count - 1 do
        begin
            Exts := FItems[I].Extensions;
            for J := 0 to Length(Exts) - 1 do
            begin
                if Exts[J].Key = LKey then
                begin
                    Value := Exts[J].Value;
                    if not DictValues.ContainsKey(Value) then
                    begin
                        DictValues.Add(Value, True);
                        Result.Add(Value);
                    end;
                end;
            end;
        end;
    finally
        DictValues.Free;
    end;
end;

(*
    original
    filter(input: ListFilter): ListItem[] {
        return this.items().filter(({ item }): boolean => {
        ...
*)
function TITodoList.Filter(const AFilter: TTodoListFilter): TArray<TTodoListItem>;
var
    AllItems: TArray<TTodoListItem>;
    ResList: TList<TTodoListItem>;
    I, J: Integer;
    Item: ITodoItem;
    ContextsArr, ProjectsArr: TArray<string>;
    Exts: TArray<TTrackedExtension>;
    Ok: Boolean;

    function ArrayContains(const AArr: TArray<string>; const AValue: string): Boolean;
    var
        K: Integer;
    begin
        Result := False;
        for K := 0 to Length(AArr) - 1 do
            if AArr[K] = AValue then
                Exit(True);
    end;

begin
    AllItems := Items;
    ResList := TList<TTodoListItem>.Create;
    try
        for I := 0 to Length(AllItems) - 1 do
        begin
            Item := AllItems[I].Item;
            Ok := True;

            // complete
            if AFilter.HasComplete then
            begin
                if AFilter.Complete <> Item.Complete then
                    Ok := False;
            end;
            if not Ok then Continue;

            // priority
            if AFilter.HasPriority then
            begin
                if AFilter.Priority <> Item.Priority then
                    Ok := False;
            end;
            if not Ok then Continue;

            // created
            if AFilter.HasCreated then
            begin
                if not FilterDateRange(Item.Created, AFilter.CreatedRange) then
                    Ok := False;
            end;
            if not Ok then Continue;

            // completed
            if AFilter.HasCompleted then
            begin
                if not FilterDateRange(Item.Completed, AFilter.CompletedRange) then
                    Ok := False;
            end;
            if not Ok then Continue;

            // body
            if AFilter.HasBody then
            begin
                if AFilter.BodyIsRegex then
                begin
                    if not AFilter.BodyRegex.IsMatch(Item.Body) then
                        Ok := False;
                end
                else
                begin
                    if AFilter.BodyText <> Item.Body then
                        Ok := False;
                end;
            end;
            if not Ok then Continue;

            // contexts
            ContextsArr := Item.Contexts;
            if Length(AFilter.ContextsAnd) > 0 then
            begin
                for J := 0 to Length(AFilter.ContextsAnd) - 1 do
                    if not ArrayContains(ContextsArr, AFilter.ContextsAnd[J]) then
                    begin
                        Ok := False;
                        Break;
                    end;
            end;
            if not Ok then Continue;

            if Length(AFilter.ContextsOr) > 0 then
            begin
                Ok := False;
                for J := 0 to Length(AFilter.ContextsOr) - 1 do
                    if ArrayContains(ContextsArr, AFilter.ContextsOr[J]) then
                    begin
                        Ok := True;
                        Break;
                    end;
            end;
            if not Ok then Continue;

            if Length(AFilter.ContextsNot) > 0 then
            begin
                for J := 0 to Length(AFilter.ContextsNot) - 1 do
                    if ArrayContains(ContextsArr, AFilter.ContextsNot[J]) then
                    begin
                        Ok := False;
                        Break;
                    end;
            end;
            if not Ok then Continue;

            // projects
            ProjectsArr := Item.Projects;
            if Length(AFilter.ProjectsAnd) > 0 then
            begin
                for J := 0 to Length(AFilter.ProjectsAnd) - 1 do
                    if not ArrayContains(ProjectsArr, AFilter.ProjectsAnd[J]) then
                    begin
                        Ok := False;
                        Break;
                    end;
            end;
            if not Ok then Continue;

            if Length(AFilter.ProjectsOr) > 0 then
            begin
                Ok := False;
                for J := 0 to Length(AFilter.ProjectsOr) - 1 do
                    if ArrayContains(ProjectsArr, AFilter.ProjectsOr[J]) then
                    begin
                        Ok := True;
                        Break;
                    end;
            end;
            if not Ok then Continue;

            if Length(AFilter.ProjectsNot) > 0 then
            begin
                for J := 0 to Length(AFilter.ProjectsNot) - 1 do
                    if ArrayContains(ProjectsArr, AFilter.ProjectsNot[J]) then
                    begin
                        Ok := False;
                        Break;
                    end;
            end;
            if not Ok then Continue;

            // extensions
            if AFilter.HasExtensionFunc then
            begin
                Exts := Item.Extensions;
                if not AFilter.ExtensionFunc(Exts) then
                    Ok := False;
            end
            else if Length(AFilter.ExtensionKeys) > 0 then
            begin
                Exts := Item.Extensions;
                var FoundKey: Boolean := False;
                for J := 0 to Length(Exts) - 1 do
                begin
                    if ArrayContains(AFilter.ExtensionKeys, Exts[J].Key) then
                    begin
                        FoundKey := True;
                        Break;
                    end;
                end;
                if not FoundKey then
                    Ok := False;
            end;
            if not Ok then Continue;

            // passed all checks => add to result
            ResList.Add(AllItems[I]);
        end;

        SetLength(Result, ResList.Count);
        for I := 0 to ResList.Count - 1 do
            Result[I] := ResList[I];
    finally
        ResList.Free;
    end;
end;

(*
 * Add a new Item to the end of the List
    original:
    add(item: Item | string): ListItem {
*)
function TITodoList.Add(const AItem: ITodoItem): TTodoListItem;
begin
    FItems.Add(AItem);
    Result.Index := FItems.Count - 1;
    Result.Item := FItems[Result.Index];
end;

function TITodoList.Add(const ALine: string): TTodoListItem;
var
    Item: ITodoItem;
begin
    Item := TITodoItem.Create(ALine) as ITodoItem;
    FItems.Add(Item);
    Result.Index := FItems.Count - 1;
    Result.Item := FItems[Result.Index];
end;

(* Check if ADate is in the given date range ARange.
   To check whether no range is given set ADate to 0
original:
function filterDateRange(date: Date | null, range: DateRange | null): boolean {
    if (range === null) {
*)
function FilterDateRange(const ADate: TDateTime; const ARange: TDateRange): Boolean;
begin
//    // Note: Item port uses 0.0 to indicate 'null' (no date)
//    // ARange with both StartDate/EndDate == 0 means "select all" (no filtering)
//    if (ARange.StartDate = 0) and (ARange.EndDate = 0) then
//        Exit(True);

    // if user explicitly wants null:
    if (ARange.StartDate = 0) and (ARange.EndDate = 0) then
    begin
        if ADate <> 0 then
            Exit(False)
        else
            Exit(True);
    end;

    // If range start is present and ADate is missing -> false
    if (ARange.StartDate <> 0) and (ADate = 0) then
        Exit(False);

    // If range end is present and ADate is missing -> false
    if (ARange.EndDate <> 0) and (ADate = 0) then
        Exit(False);

    if (ARange.StartDate <> 0) and (ADate < ARange.StartDate) then
        Exit(False);
    if (ARange.EndDate <> 0) and (ADate > ARange.EndDate) then
        Exit(False);

    Result := True;
end;

end.

