#!/usr/bin/env escript
%% -*- erlang-indent-level: 2 -*-
%%! +S1 -noshell

main(Args) ->
  try
    {LabelDir, Files} =
      try
        [LD] = Args,
        {ok, F} = file:list_dir(LD),
        {LD, F}
      catch
        _:_ ->
          Error = "Error: Give a litmus subdirectory as argument.~n",
          io:format(standard_error, Error, []),
          exit(1)
      end,
    State = inspect_files([filename:join([LabelDir, F]) || F <- Files]),
    print_table(LabelDir, State)
  catch
    throw:{bad_test, Test, Reason} ->
      io:format(standard_error, "Error: ~s failed: ~p.~n", [Test, Reason])
  end.

%%%-----------------------------------------------------------------------------

-record(
   state,
   {
     operations = sets:new(),
     tests = dict:new()
   }).

inspect_files(Files) ->
  inspect_files(Files, #state{}).

inspect_files([File|Rest], State) ->
  NewState =
    case
      filename:extension(File) =/= ".erl"
    of
    true -> State;
      false ->
        case
          compile:file(File, [{outdir, filename:dirname(File)}, debug_info])
        of
          error -> throw({bad_test, File, compile_error});
          {ok, Module} ->
            BeamName = filename:rootname(File, ".erl") ++ ".beam",
            code:load_abs(filename:rootname(BeamName, ".beam")),
            Attrs = Module:module_info(attributes),
            [Op1] = proplists:get_value(operation_1, Attrs, []),
            [Op2] = proplists:get_value(operation_2, Attrs, []),
            try name(Op1) catch _:_ -> throw({bad_test, File, {unknown, Op1}}) end,
            try name(Op2) catch _:_ -> throw({bad_test, File, {unknown, Op1}}) end,
            Test = filename:basename(File, ".erl"),
            #state{
               operations = Ops0,
               tests = Tests0
              } = State,
            Ops1 = sets:add_element(Op1, Ops0),
            Tests1 = dict:append(Op1, {Op2, Test}, Tests0),
            case Op1 =:= Op2 of
              true ->
                State#state{operations = Ops1, tests = Tests1};
              false ->
                Ops2 = sets:add_element(Op2, Ops1),
                Tests2 = dict:append(Op2, {Op1, Test}, Tests1),
                State#state{operations = Ops2, tests = Tests2}
            end
        end
    end,
  inspect_files(Rest, NewState);
inspect_files([], State) ->
  State.

%%%-----------------------------------------------------------------------------

print_table(LabelDir, State) ->
  print_header(LabelDir),
  print_contents(State).

print_header(LabelDir) ->
  Name = filename:basename(LabelDir),
  io:format(
    "\\begin{table*}[h]~n"
    "\\caption{Dependencies between built-ins and events labeled as ``\\~s''.}~n"
    "\\label{tab:ops-label-~s}~n"
    "\\centering~n",
    [Name, Name]
   ).

print_contents(State) ->
  #state{
     operations = Ops,
     tests = Tests
    } = State,
  SortedOps = lists:sort(sets:to_list(Ops)),
  print_structure(SortedOps),
  print_first(SortedOps),
  print_contents(SortedOps, [], foo, SortedOps, Tests).

print_structure(SortedOps) ->
  Spec = ["c|" || _ <- SortedOps],
  Length = length(SortedOps) + 1,
  io:format(
    "\\begin{tabular}{l|~s}~n"
    "\\cline{2-~p}~n",
    [Spec, Length]
   ).

print_first(SortedOps) ->
  Names = [name(Op) || Op <- SortedOps],
  Line = string:join(Names, " & "),
  io:format(
    "& ~s",
    [Line]
   ).

%print_contents([], _, _, _) ->
print_contents(Lines, [], _Line, SortedOps, Tests) ->
  io:format("\\\\ \\hline~n"),
  case Lines of
    [] ->
      io:format(
        "\\end{tabular}~n"
        "\\end{table*}~n",
        []
       );
    [Line|Rest] ->
      Name = name(Line),
      io:format("\\multicolumn{1}{|l|}{~s} ", [Name]),
      print_contents(Rest, SortedOps, Line, SortedOps, Tests)
  end;
print_contents(Lines, [Column|Rest], Line, SortedOps, Tests) ->
  LTests = dict:fetch(Line, Tests),
  CTests = [es(T) || {C, T} <- LTests, C =:= Column],
  Join = string:join(CTests, ", "),
  io:format("& ~s ", [Join]),
  print_contents(Lines, Rest, Line, SortedOps, Tests).

name({M,F,A}) ->
  io_lib:format("\\bif{~s:~s/~p}", [es(M),es(F),A]).

es(Atom) when is_atom(Atom) ->
  es(atom_to_list(Atom));
es(List) ->
  lists:append([es_1(L) || L <- List]).

es_1($_) ->
  "\\_";
es_1(A) ->
  [A].

%% -record(
%%    state,
%%    {
%%      done   = 0
%%    , modules  = 0
%%    , finish = false
%%    }).

%% initialize(LabelDir) ->
%%   print_header(LabelDir),
%%   spawn_link(fun() -> loop(#state{}) end).

%% loop(#state{done = All, finish = {true, Report}, modules = All}) ->
%%   Report ! {finish, All},
%%   ok;
%% loop(#state{done = Done, modules = Modules} = State) ->
%%   receive
%%     {module, BeamName} ->
%%       Server = self(),
%%       _ = spawn_link(fun() -> find_builtins(BeamName, Server) end),
%%       NewModules = Modules + 1,
%%       loop(State#state{modules = NewModules});
%%     {test, BeamName, Builtins} ->
%%       file:delete(BeamName),
%%       F = filename:rootname(BeamName, ".beam") ++ ".erl",
%%       print_test(F, Builtins),
%%       NewDone = Done + 1,
%%       loop(State#state{done = NewDone});
%%     {finish, Report} ->
%%       loop(State#state{finish = {true, Report}})
%%   end.

%% %%%-----------------------------------------------------------------------------

%% find_builtins(Module, Server) ->
%%   Name = list_to_atom(pid_to_list(self())),
%%   xref:start(Name),
%%   xref:add_module(Name, Module, [{builtins, true}]),
%%   {ok, [{{M,_,_},_}|_] = Calls} = xref:q(Name, "XC"),
%%   Filtered =
%%     [BI ||
%%       {{_, test, 0}, {E,_,_} = BI} <- Calls,
%%       E =:= erlang orelse E =:= ets, erlang_builtins:is_unsafe(BI)],
%%   xref:stop(Name),
%%   code:load_abs(filename:rootname(Module, ".beam")),
%%   Attrs = M:module_info(attributes),
%%   Irrelevant = proplists:get_value(irrelevant, Attrs, []),
%%   Extra = proplists:get_value(relevant, Attrs, []),
%%   Relevant = lists:sort(Filtered -- Irrelevant ++ Extra),
%%   Server ! {test, Module, Relevant}.

%% %%%-----------------------------------------------------------------------------

%% inspect_files([], _Server) ->
%%   ok;
%% inspect_files([File|Rest], Server) ->
%%   case filelib:is_dir(File) of
%%     true ->
%%       {ok, Files} = file:list_dir(File),
%%       inspect_files([filename:join([File, F]) || F <- Files] ++ Rest, Server);
%%     false ->
%%       load_and_queue(File, Server),
%%       inspect_files(Rest, Server)
%%   end.

%% load_and_queue(File, Server) ->
%%   case
%%     filename:extension(File) =/= ".erl" orelse
%%     filename:basename(File, ".erl") =:= "erlang_builtins"
%%   of
%%     true -> ok;
%%     false ->
%%       case compile:file(File, [{outdir, filename:dirname(File)}, debug_info]) of
%%         error ->
%%           print_test(File, compile_error),
%%           ok;
%%         {ok, _Module} ->
%%           BeamName = filename:rootname(File, ".erl") ++ ".beam",
%%           Server ! {module, BeamName}
%%       end
%%   end.

%% %%%-----------------------------------------------------------------------------

%% finish(Server) ->
%%   Server ! {finish, self()},
%%   receive
%%     {finish, Modules} ->
%%       print_footer(Modules),
%%       halt(0)
%%   end.

%% %%%-----------------------------------------------------------------------------

%% print_header() ->
%%   io:format("~-56s~-24s~n",["File", "Primitives"]),
%%   print_line().

%% print_test(Filename, Builtins) ->
%%   TFilename = trim(Filename, 56),
%%   io:format(
%%     "~-56s~w~n",
%%     [TFilename, Builtins]
%%    ).

%% trim(Atom, Length) when is_atom(Atom) ->
%%   trim(atom_to_list(Atom), Length);
%% trim(String, Length) ->
%%   Flat = lists:flatten(String),
%%   case length(Flat) =< Length of
%%     true -> Flat;
%%     false ->
%%       Trim = lists:sublist(String, Length - 3),
%%       [Trim,"..."]
%%   end.

%% print_footer(Modules) ->
%%   print_line(),
%%   io:format("  Modules: ~p~n", [Modules]).

%% print_line() ->
%%   io:format("~80..-s~n", [""]).
