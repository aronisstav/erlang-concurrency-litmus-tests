%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(sig_receive).

-operation_1(sig_deliver).
-operation_2('receive').

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

test() ->
  P = self(),
  process_flag(trap_exit, true),
  spawn(fun() -> exit(P,foo) end),
  receive
    _ -> true
  after
    42 -> false
  end.
