%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(timer_send_unregister).

-operation_1(timer_send).
-operation_2({erlang,unregister,1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  %% Register name
  register(name, self()),
  %% Establish the timer
  erlang:send_after(42, name, foo, []),
  %% The timer can expire either before or after the unregister
  unregister(name),
  %% If it expires after, then the message is definitely lost:
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
