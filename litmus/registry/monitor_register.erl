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

test() ->
  Fun1 = fun() -> p1() end,
  P1 = spawn(Fun1),
  M = monitor(process, name),
  P1 ! ok,
  receive
    {'DOWN', M, process, _, Tag} -> Tag =/= normal
  end.
