%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(send_unregister).

-operation_1({erlang,send,2}).
-operation_2({erlang,unregister,1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(Main) ->
  register(name, self()),
  Main ! ok,
  unregister(name),
  receive ok -> ok end.

p2() ->
  name ! foo.

test() ->
  Main = self(),
  Fun1 = fun() -> p1(Main) end,
  P1 = spawn(Fun1),
  Fun2 = fun() -> p2() end,
  receive ok -> ok end,
  {P2, M} = spawn_monitor(Fun2),
  Result =
    receive
      {'DOWN', M, process, P2, Tag} -> Tag =/= normal
    end,
  P1 ! ok,
  Result.
