%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_spawn).

-operation_1(sig_deliver).
-operation_2({erlang, spawn, 1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  spawn(fun() -> receive after infinity -> ok end end).

p2(P1) ->
  exit(P1, abnormal).

test() ->
  A = processes(),
  Fun1 = fun() -> p1() end,
  {P1, M1} = spawn_monitor(Fun1),
  Fun2 = fun() -> p2(P1) end,
  {P2, M2} = spawn_monitor(Fun2),
  receive
    {'DOWN', M1, process, P1, _} -> ok
  end,
  receive
    {'DOWN', M2, process, P2, _} -> ok
  end,
  (processes() -- A) =:= [].
