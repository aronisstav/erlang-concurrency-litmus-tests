%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(timer_send_cancel_timer).

-operation_1(timer_send).
-operation_2({erlang, cancel_timer, 2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  %% Establish the timer
  T = erlang:send_after(42, self(), foo, []),
  %% The timer can expire either before or after the cancel
  erlang:cancel_timer(T),
  %% If it expires before, then the message already exists.
  receive
    foo -> exit(abnormal)
  after
    0 -> ok
  end.

test() ->
  Fun1 = fun() -> p1() end,
  {P1, M} = spawn_monitor(Fun1),
  receive
    {'DOWN', M, process, P1, Tag} -> Tag =/= normal
  end.
