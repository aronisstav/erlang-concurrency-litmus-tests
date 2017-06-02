%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_trap_exit).

-operation_1(sig_deliver).
-operation_2({erlang,process_flag,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  process_flag(trap_exit, true),
  receive _ -> ok end.

test() ->
  Fun1 = fun() -> p1() end,
  {P1, M} = spawn_monitor(Fun1),
  exit(P1, abnormal),
  receive
    {'DOWN', M, process, P1, Tag} -> Tag =/= normal
  end.
