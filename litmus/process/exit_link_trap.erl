%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(exit_link_trap).

-operation_1(exit).
-operation_2({erlang,link,1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  receive ok -> ok end.

p2(P, P1) ->
  process_flag(trap_exit, true),
  P ! ok,
  erlang:link(P1),
  receive
    {'EXIT', P1, Reason} -> Reason = normal
  end.

test() ->
  P = self(),
  Fun1 = fun() -> p1() end,
  P1 = spawn(Fun1),
  Fun2 = fun() -> p2(P, P1) end,
  {P2, M} = spawn_monitor(Fun2),
  receive ok -> ok end,
  P1 ! ok,
  receive
    {'DOWN', M, process, P2, Tag} -> Tag =/= normal
  end.
