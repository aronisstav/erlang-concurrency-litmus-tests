%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(monitor_register).

-operation_1({erlang, monitor, 2}).
-operation_2({erlang, register, 2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  register(name, self()),
  receive ok -> ok end.

p2() ->
  monitor(process, name).

test() ->
  Fun1 = fun() -> p1() end,
  P1 = spawn(Fun1),
  Fun2 = fun() -> p2() end,
  {P2, M} = spawn_monitor(Fun1),
  Tag =
    receive
      {'DOWN', M, process, P2, T} -> T
    end,
  P1 ! ok,
  Tag =/= normal.
