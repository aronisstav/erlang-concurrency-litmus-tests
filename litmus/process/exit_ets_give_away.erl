%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(exit_ets_give_away).

-operation_1(exit).
-operation_2({ets,give_away,3}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  ok.

p2(P1) ->
  T = ets:new(table, []),
  ets:give_away(T, P1, foo).

test() ->
  Fun1 = fun() -> p1() end,
  P1 = spawn(Fun1),
  Fun2 = fun() -> p2(P1) end,
  {P2, M} = spawn_monitor(Fun2),
  receive
    {'DOWN', M, process, P2, Tag} -> Tag =/= normal
  end.
