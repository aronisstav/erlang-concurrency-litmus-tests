%%% @doc A registered process exiting vs a send to its name
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(exit_send).

-operation_1(exit).
-operation_2({erlang,send,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(Main) ->
  register(name, self()),
  Main ! ok.

p2() ->
  name ! foo.

test() ->
  Main = self(),
  Fun1 = fun() -> p1(Main) end,
  P1 = spawn(Fun1),
  Fun2 = fun() -> p2() end,
  receive ok -> ok end,
  {P2, M} = spawn_monitor(Fun2),
  receive
    {'DOWN', M, process, P2, Tag} -> Tag =/= normal
  end.
