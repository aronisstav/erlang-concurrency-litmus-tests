%%% @doc Header file for litmus tests
%%% @author Stavros Aronis <aronisstav@gmail.com>

%%% litmus.hrl exports a number of `possible_x/0` functions that are
%%% generated for each of the possible results of a litmus test. It
%%% also exports the `exhaustive/0` function, useful for checking
%%% whether any other results are possible.

-include_lib("stdlib/include/assert.hrl").

%%% Base exports
-export([exhaustive/0, possible_1/0]).

%%% Additional exports and definition of the list of ALL results.
-ifdef(RESULT_2).
-export([possible_2/0]).
-ifdef(RESULT_3).
-export([possible_3/0]).
-define(ALL, [?RESULT_1, ?RESULT_2, ?RESULT_3]).
-else.
-define(ALL, [?RESULT_1, ?RESULT_2]).
-endif.
-else.
-define(ALL, [?RESULT_1]).
-endif.

%%% Tests are run by a process executed the `test/0` defined inside
%%% each litmus test. This process is monitored by the "top" process
%%% and is expected to exit normally and return a value that is then
%%% sent to the top process.
run_until_exit() ->
  S = self(),
  R = make_ref(),
  {P, M} = spawn_monitor(fun() -> S ! {R, test()} end),
  receive
    {'DOWN', M, process, P, Reason} ->
      case Reason =:= normal of
        true -> receive {R, V} -> {normal, V} end;
        false -> {abnormal, Reason}
      end
  end.

%%% Definitions of possible_x/0 functions:

%%% Any `possible_x/0` tests are supposed to FAIL, since they contain
%%% an assertion that a particular result is not possible under normal
%%% termination: this will only fail if the result is possible.

possible_1() ->
  ?assertNotEqual({normal, ?RESULT_1}, run_until_exit()).

-ifdef(RESULT_2).
possible_2() ->
  ?assertNotEqual({normal, ?RESULT_2}, run_until_exit()).
-endif.

-ifdef(RESULT_3).
possible_3() ->
  ?assertNotEqual({normal, ?RESULT_3}, run_until_exit()).
-endif.

%%% Definition of exhaustive/0 function:

%%% The `exhaustive/0` test is supposed to SUCCEED, proving that every
%%% possible result is in the list of ALL results. It also shows that
%%% the test process can never exit abnormally.

exhaustive() ->
  Result = run_until_exit(),
  ?assert(lists:member(Result, [{normal, V} || V <- ?ALL])).
