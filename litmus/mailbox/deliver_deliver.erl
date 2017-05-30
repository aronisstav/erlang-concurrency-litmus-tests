%%% @doc Message delivery race
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(deliver_deliver).

-operation_1(deliver).
-operation_2(deliver).

-define(RESULT_1, first).
-define(RESULT_2, second).

-include("../../headers/litmus.hrl").

test() ->
  P = self(),
  spawn(fun() -> P ! first end),
  spawn(fun() -> P ! second end),
  receive
    M -> M
  end.
