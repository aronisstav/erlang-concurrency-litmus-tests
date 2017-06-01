%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_sig_indirect).

-operation_1(sig_deliver).
-operation_2(sig_deliver).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(P) ->
  P1 = self(),
  process_flag(trap_exit, true),
  Fun2 = fun() -> p2(P, P1) end,
  spawn(Fun2),
  receive
    {'EXIT', _, S} ->
      exit(P, S)
  end.

p2(P, P1) ->
  exit(P, first),
  exit(P1, second).

test() ->
  P = self(),
  process_flag(trap_exit, true),
  Fun1 = fun() -> p1(P) end,
  spawn(Fun1),
  receive
    {'EXIT', _, S} -> S =:= first
  end.
