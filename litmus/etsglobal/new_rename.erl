%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(new_rename).

-operation_1({ets,new,2}).
-operation_2({ets,rename,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  ets:new(table, [named_table]).

test() ->
  ets:new(foo, [named_table]),
  Fun1 = fun() -> p1() end,
  {P1, M} = spawn_monitor(Fun1),
  catch ets:rename(foo, table),
  receive
    {'DOWN', M, process, P1, Tag} -> Tag =/= normal
  end.
