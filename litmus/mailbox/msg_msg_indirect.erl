%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(msg_msg_indirect).

-operation_1(msg_deliver).
-operation_2(msg_deliver).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  receive
    M -> M = first
  end.

p2(P1) ->
  receive
    M -> P1 ! M
  end.

test() ->
  Fun1 = fun() -> p1() end,
  {P1, M} = spawn_monitor(Fun1),
  Fun2 = fun() -> p2(P1) end,
  P2 = spawn(Fun2),
  P1 ! first,
  P2 ! second,
  receive
    {'DOWN', M, process, P1, Tag} -> Tag =/= normal
  end.
