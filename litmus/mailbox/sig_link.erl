%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_link).

-operation_1(sig_deliver).
-operation_2({erlang,link,1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(P) ->
  {Dead, M} = spawn_monitor(fun() -> ok end),
  receive
    {'DOWN', M, process, Dead, normal} -> ok
  end,
  process_flag(trap_exit, true),
  P ! ok,
  erlang:link(Dead),
  receive
    {'EXIT', _, Msg} -> ok = Msg
  end.

test() ->
  P = self(),
  Fun1 = fun() -> p1(P) end,
  {P1, M} = spawn_monitor(Fun1),
  receive ok -> ok end,
  exit(P1, ok),
  receive
    {'DOWN', M, process, P1, Tag} -> Tag =/= normal
  end.
