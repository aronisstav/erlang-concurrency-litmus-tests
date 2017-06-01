%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_sig).

-operation_1(sig_deliver).
-operation_2(sig_deliver).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

test() ->
  P = self(),
  process_flag(trap_exit, true),
  spawn(fun() -> exit(P, first) end),
  spawn(fun() -> exit(P, second) end),
  receive
    {EXIT, _, M} -> M =:= first
  end.
