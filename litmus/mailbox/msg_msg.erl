%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(msg_msg).

-operation_1(msg_deliver).
-operation_2(msg_deliver).

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
