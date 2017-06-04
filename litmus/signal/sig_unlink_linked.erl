%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_unlink_linked).

-operation_1(sig_deliver).
-operation_2({erlang, unlink, 1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  receive
    {ok, P2} ->
      unlink(P2)
  end.

p2(P1) ->
  link(P1),
  P1 ! {ok, self()},
  exit(abnormally).

test() ->
  Fun1 = fun() -> p1() end,
  {P1, M} = spawn_monitor(Fun1),
  Fun2 = fun() -> p2(P1) end,
  P2 = spawn(Fun2),
  receive
    {'DOWN', M, process, P1, Tag} -> Tag =/= normal
  end.
