%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_send).

-operation_1(sig_deliver).
-operation_2({erlang, send, 2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(P) ->
  P ! foo.

p2(P1) ->
  exit(P1, abnormal).

test() ->
  P = self(),
  Fun1 = fun() -> p1(P) end,
  {P1,_} = spawn_monitor(Fun1),
  Fun2 = fun() -> p2(P1) end,
  _    = spawn(Fun2),
  receive
    {'DOWN', M, process, P1, _} -> ok
  end,
  receive
    foo -> true
  after
    0 -> false
  end.
