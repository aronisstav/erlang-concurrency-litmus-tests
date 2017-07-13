%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(register_timer_send).

-operation_1({erlang,register,2}).
-operation_2(timer_send).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  %% Establish the timer
  erlang:send_after(42, name, foo, []),
  %% The timer can expire either before or after the register
  register(name, self()),
  %% If it expires before, then the message is definitely lost:
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
