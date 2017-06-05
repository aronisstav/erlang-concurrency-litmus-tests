%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_unregister).

-operation_1(sig_deliver).
-operation_2({erlang, unregister, 1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  unregister(name).

p2(P1) ->
  exit(P1, abnormal).

test() ->
  P = self(),
  register(name, self()),
  Fun1 = fun() -> p1() end,
  {P1,_} = spawn_monitor(Fun1),
  Fun2 = fun() -> p2(P1) end,
  _    = spawn(Fun2),
  receive
    {'DOWN', M, process, P1, _} -> ok
  end,
  self() =:= whereis(name).
