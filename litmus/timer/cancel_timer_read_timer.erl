%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(cancel_timer_read_timer).

-operation_1({erlang, cancel_timer, 2}).
-operation_2({erlang, read_timer, 2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(T) ->
  erlang:cancel_timer(T).

p2(T) ->
  true = (false =/= erlang:read_timer(T)).

test() ->
  T = erlang:send_after(42, self(), foo, []),
  Fun1 = fun() -> p1(T) end,
  P1   = spawn(Fun1),
  Fun2 = fun() -> p2(T) end,
  {P2, M} = spawn_monitor(Fun2),
  receive
    {'DOWN', M, process, P2, Tag} ->
      Tag =/= normal
  end.
