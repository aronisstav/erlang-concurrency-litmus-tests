%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(msg_sig).

-operation_1(msg_deliver).
-operation_2(sig_deliver).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

test() ->
  P = self(),
  process_flag(trap_exit, true),
  spawn(fun() -> P ! first end),
  spawn(fun() -> exit(P, second) end),
  receive
    M -> M =:= first
  end.
