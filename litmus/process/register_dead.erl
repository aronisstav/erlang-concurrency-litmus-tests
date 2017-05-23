%%% @doc A register operation races with the exit of the registered
%%% PID.
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(register_dead).

-operation_1(exit).
-operation_2({erlang,register,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

test() ->
  Fun1 = fun() -> receive ok -> ok end end,
  Fun2 = fun(Q) -> fun() -> register(name, Q) end end,
  Q      = spawn(Fun1),
  {P, M} = spawn_monitor(Fun2(Q)),
  Q ! ok,
  receive
    {'DOWN', M, process, P, Tag} -> Tag =/= normal
  end.
