%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_unlink_other).

-operation_1(sig_deliver).
-operation_2({erlang, unlink, 1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(P) ->
  receive
    {ok, P2} ->
      P ! ok,
      unlink(P2)
  end.

p2(P1) ->
  link(P1),
  P1 ! {ok, self()}.

test() ->
  P = self(),
  Fun1 = fun() -> p1(P) end,
  P1   = spawn(Fun1),
  Fun2 = fun() -> p2(P1) end,
  _    = spawn_monitor(Fun2),
  receive ok ->
      exit(P1, abnormal)
  end,
  receive
    {'DOWN', M, process, P2, Tag} -> Tag =/= normal
  end.
