%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_unlink_other).

-operation_1(sig_deliver).
-operation_2({erlang, unlink, 1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(P) ->
  unlink(P).

p2(P1) ->
  exit(P1, abnormal).

test() ->
  P = self(),
  process_flag(trap_exit, true),
  Fun1 = fun() -> p1(P) end,
  {P1, M} = spawn_opt(Fun1, [link, monitor]),
  Fun2 = fun() -> p2(P1) end,
  _ = spawn(Fun2),
  receive
    {'DOWN', M, process, P1, _} -> ok
  end,
  receive
    _Exit -> true
  after
    0 -> false
  end.
