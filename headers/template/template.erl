%%% @doc Template for litmus tests.
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(template).

%%% Tests musts define two attributes 'operation_1', 'operation_2',
%%% describing the operations/events that are involved in the race.
%%% The attributes are either tuples containing the Module, Function
%%% and Arity of a built-in operation, or one of the following atoms:
%%%
%%% * 'exit': denotes a process exiting
%%% * 'deliver': denotes the delivery of a message/signal
%%% * 'receive': denotes a receive statement
%%%
%%% In any case the builtin or the event denoted by the atom should be
%%% relevant to the race

-operation_1({erlang,spawn,1}).
-operation_2(exit).

%%% Tests must define at least RESULT_1 macro and should define
%%% additional RESULT_X macros, for every possible result of the
%%% test/0 function.  Up to three different results are supported by
%%% litmus.hrl

-define(RESULT_1, true).
%% -define(RESULT_2, false).
%% -define(RESULT_3, undefined).

%%% After defining RESULT_X macros, the litmus.hrl header should be
%%% included to add the scaffolding for running the tests.  See that
%%% header file for further explanations.

-include("../../headers/litmus.hrl").

%%% Any execution of the test/0 function should evaluate normally
%%% (i.e., no uncaught exceptions) and return one of the values
%%% defined as RESULT_X.

test() ->
  true.
