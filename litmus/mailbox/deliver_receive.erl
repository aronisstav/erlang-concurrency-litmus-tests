%%% @doc Message delivery race
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(deliver_receive).

-operation_1(deliver).
-operation_2('receive').

-define(RESULT_1, first).
-define(RESULT_2, second).

-include("../../headers/litmus.hrl").

test() ->
  P = self(),
  spawn(fun() -> P ! first end),
  receive
    M -> M
  after
    42 -> second
  end.
