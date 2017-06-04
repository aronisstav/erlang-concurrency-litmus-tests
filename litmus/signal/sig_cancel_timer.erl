%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_cancel_timer).

-operation_1(sig_deliver).
-operation_2({erlang, cancel_timer, 1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(Timer) ->
  erlang:cancel_timer(Timer, []).

p2(P1) ->
  exit(P1, abnormal).

test() ->
  Timer = erlang:send_after(42, self(), foo), []),
  Fun1 = fun() -> p1(Timer) end,
  {P1,_}  = spawn_monitor(Fun1),
  Fun2 = fun() -> p2(P1) end,
  _    = spawn(Fun2),
  receive
    {'DOWN', M, process, P1, _} -> ok
  end,
  receive
    foo -> true
  after
    100 -> false
  end.
