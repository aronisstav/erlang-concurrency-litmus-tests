%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_sig).

-operation_1(sig_deliver).
-operation_2(sig_deliver).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  receive after infinity -> ok end.

p2(P1) ->
  exit(P1, bar).

test() ->
  Fun1 = fun() -> p1() end,
  {P1, M} = spawn_monitor(Fun1),
  Fun2 = fun() -> p2(P1) end,
  spawn(Fun2),
  exit(P1, foo),
  receive
    {'DOWN', M, process, P1, Tag} -> Tag =/= foo
  end.
