%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(new_new).

-operation_1({ets,new,2}).
-operation_2({ets,new,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  catch ets:new(table, [named_table]),
  receive ok -> ok end.

p2() ->
  ets:new(table, [named_table]).

test() ->
  Fun1 = fun() -> p1() end,
  P1 = spawn(Fun1),
  Fun2 = fun() -> p2() end,
  {P2, M} = spawn_monitor(Fun2),
  Result =
    receive
      {'DOWN', M, process, P2, Tag} -> Tag =/= normal
    end,
  P1 ! ok,
  Result.
