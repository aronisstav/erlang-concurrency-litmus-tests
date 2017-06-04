%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(link_unlink_unlinked).

-operation_1({erlang, link, 1}).
-operation_2({erlang, unlink, 1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  %%STUB
  ok.

p2(P1) ->
  %%STUB
  ok.

test() ->
  Fun1 = fun() -> p1() end,
  P1   = spawn(Fun1),
  Fun2 = fun() -> p2(P1) end,
  {P2, M} = spawn_monitor(Fun2),
  receive
    {'DOWN', M, process, P2, Tag} ->
      Tag =/= normal
  end.
