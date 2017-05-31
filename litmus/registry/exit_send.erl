%%% @doc A registered process exiting vs a send to its name
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(exit_send).

-operation_1(exit).
-operation_2({erlang,send,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  receive ok -> ok end.

p2() ->
  name ! foo.

test() ->
  Fun1 = fun() -> p1() end,
  P1 = spawn(Fun1),
  register(name, P1),
  P1 ! ok,
  Fun2 = fun() -> p2() end,
  {P2, M} = spawn_monitor(Fun2),
  receive
    {'DOWN', M, process, P2, Tag} -> Tag =/= normal
  end.
