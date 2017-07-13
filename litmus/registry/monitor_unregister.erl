%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(monitor_unregister).

-operation_1({erlang, monitor, 2}).
-operation_2({erlang, unregister, 1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(Main) ->
  register(name, self()),
  Main ! ok,
  unregister(name).

test() ->
  Main = self(),
  Fun1 = fun() -> p1(Main) end,
  P1 = spawn(Fun1),
  receive ok -> ok end,
  M = monitor(process, name),
  receive
    {'DOWN', M, process, _, Tag} -> Tag =/= normal
  end.
