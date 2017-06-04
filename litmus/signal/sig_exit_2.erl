%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_exit_2).

-operation_1(sig_deliver).
-operation_2({erlang, exit, 2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(P) ->
  exit(P, foo).

p2(P1) ->
  exit(P1, abnormal).

test() ->
  process_flag(trap_exit, true),
  P = self(),
  Fun1 = fun() -> p1(P) end,
  {P1, M} = spawn_monitor(Fun1),
  Fun2 = fun() -> p2(P1) end,
  _    = spawn(Fun2),
  receive
    {'DOWN', M, process, P1, _} -> ok
  end,
  receive
    {'EXIT', _, _} -> true
  after
    0 -> false
  end.
