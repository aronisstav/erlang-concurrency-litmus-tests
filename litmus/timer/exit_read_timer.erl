%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(exit_read_timer).

-operation_1(exit).
-operation_2({erlang, read_timer, 2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  ok.

test() ->
  Fun1 = fun() -> p1() end,
  P1   = spawn(Fun1),
  T = erlang:send_after(42, P1, foo, []),
  false =/= erlang:read_timer(T).
