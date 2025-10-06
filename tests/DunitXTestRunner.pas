program DUnitXTestRunner;

{$APPTYPE CONSOLE}

uses
    System.SysUtils,
    DUnitX.TestFramework,
    // Add your generated test units here so their initialization sections run
    // and register the fixtures. Example (uncomment and adjust file paths):
    //, Test.Mv.Todo.Item_created_test
    //, Test.Mv.Todo.Item_extensions_test
    //, Test.Mv.Todo.Item_body_test
    //, Test.Mv.Todo.Item_contexts_test
    //, Test.Mv.Todo.Item_inputs_test
    //, Test.Mv.Todo.Item_outputs_test
    //, Test.Mv.Todo.List_inputs_test
    //, Test.Mv.Todo.List_outputs_test
    //, Test.Mv.Todo.List_filtering_test
    Test.Mv.Todo.TodoItem.Completed;

begin
    try
        // Run all registered tests. Make sure the test units are included in the project
        // (their initialization sections register the fixtures with DUnitX).
        Writeln('Starting DUnitX test run...');
        TDUnitX.RunRegisteredTests;
    except
        on E: Exception do
        begin
            Writeln('Unhandled exception during tests: ' + E.ClassName + ': ' + E.Message);
            Halt(1);
        end;
    end;
end.
