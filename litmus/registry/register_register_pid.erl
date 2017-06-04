%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(register_register_pid).

-operation_1({erlang,register,2}).
-operation_2({erlang,register,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(P) ->
  register(name1, P).

p2(P) ->
  register(name2, P).

test() ->
  P = self(),
  Fun1 = fun() -> p1(P) end,
  P1   = spawn(Fun),
  Fun2 = fun() -> p2(P) end,
  {P2, M} = spawn_monitor(Fun2),
  receive
    {'DOWN', M, process, P, Tag} ->
      Tag =/= normal
  end.
