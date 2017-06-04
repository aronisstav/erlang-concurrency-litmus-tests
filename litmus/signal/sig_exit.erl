%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_exit).

-operation_1(exit).
-operation_2(sig_deliver).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  ok.

p2(P1) ->
  exit(P1, foo).

test() ->
  Fun1 = fun() -> p1() end,
  {P1, M} = spawn_monitor(Fun1),
  Fun2 = fun() -> p2(P1) end,
  spawn(Fun2),
  receive
    {'DOWN', M, process, P1, Tag} -> Tag =/= foo
  end.
