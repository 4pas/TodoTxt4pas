program DUnitXTests;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  Mv.LibBase in '..\source\Mv.LibBase.pas',
  Mv.StringList in '..\source\Mv.StringList.pas',
  TodoTxt.TodoItem in '..\source\TodoTxt.TodoItem.pas',
  TodoTxt.TodoList in '..\source\TodoTxt.TodoList.pas',
  Test.TodoTxt.TodoItem.Body in 'Test.TodoTxt.TodoItem.Body.pas',
  Test.TodoTxt.TodoItem.Complete in 'Test.TodoTxt.TodoItem.Complete.pas',
  Test.TodoTxt.TodoItem.Completed in 'Test.TodoTxt.TodoItem.Completed.pas',
  Test.TodoTxt.TodoItem.Contexts in 'Test.TodoTxt.TodoItem.Contexts.pas',
  Test.TodoTxt.Todo.TodoItem.Created in 'Test.TodoTxt.Todo.TodoItem.Created.pas',
  Test.TodoTxt.TodoItem.Extensions in 'Test.TodoTxt.TodoItem.Extensions.pas',
  Test.TodoTxt.TodoItem.Inputs in 'Test.TodoTxt.TodoItem.Inputs.pas',
  Test.TodoTxt.TodoItem.Outputs in 'Test.TodoTxt.TodoItem.Outputs.pas',
  Test.TodoTxt.TodoItem.Priority in 'Test.TodoTxt.TodoItem.Priority.pas',
  Test.TodoTxt.TodoItem.Projects in 'Test.TodoTxt.TodoItem.Projects.pas',
  Test.TodoTxt.TodoList.Add in 'Test.TodoTxt.TodoList.Add.pas',
  Test.TodoTxt.TodoList.Filter in 'Test.TodoTxt.TodoList.Filter.pas',
  Test.TodoTxt.TodoList.Inputs in 'Test.TodoTxt.TodoList.Inputs.pas',
  Test.TodoTxt.TodoList.Outputs in 'Test.TodoTxt.TodoList.Outputs.pas';

{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
