%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(msg_demonitor).

-operation_1(msg_deliver).
-operation_2({erlang,demonitor,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  receive ok -> ok end.

p2(P1) ->
  M = monitor(process, P1),
  P1 ! ok,
  demonitor(M, []),
  self() ! foo,
  receive
    Q -> Q = foo
  end.

test() ->
  Fun1 = fun() -> p1() end,
  P1 = spawn(Fun1),
  Fun2 = fun() -> p2(P1) end,
  {P2, M} = spawn_monitor(Fun2),
  receive
    {'DOWN', M, process, P2, Tag} -> Tag =/= normal
  end.
