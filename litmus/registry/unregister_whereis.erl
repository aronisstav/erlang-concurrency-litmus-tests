%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(unregister_whereis).

-operation_1({erlang,unregister,1}).
-operation_2({erlang,whereis,1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  receive ok -> ok end,
  unregister(name),
  receive ok -> ok end.

p2() ->
  undefined = whereis(name).

test() ->
  Fun1 = fun() -> p1() end,
  P1 = spawn(Fun1),
  register(name, P1),
  P1 ! ok,
  Fun2 = fun() -> p2() end,
  {P2, M} = spawn_monitor(Fun2),
  Result =
    receive
      {'DOWN', M, process, P2, Tag} -> Tag =/= normal
    end,
  P1 ! ok,
  Result.
