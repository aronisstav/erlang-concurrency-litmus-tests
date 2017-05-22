%%% @doc Template for litmus tests
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(template).

%%% Tests must define at least RESULT_1 macro and should define
%%% additional RESULT_X macros, for every possible result of the
%%% test/0 function. Up to three different results are supported by
%%% litmus.hrl

-define(RESULT_1, true).
%% -define(RESULT_2, false).
%% -define(RESULT_3, undefined).

%%% After defining RESULT_X macros, the litmus.hrl header should be
%%% included to add the scaffolding for running the tests. See that
%%% header file for further explanations.

-include("../../headers/litmus.hrl").

%%% Any execution of the test/0 function should evaluate normally
%%% (i.e., no uncaught exceptions) and return one of the values
%%% defined as RESULT_X.

test() ->
  true.
