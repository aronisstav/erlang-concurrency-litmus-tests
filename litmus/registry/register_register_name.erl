%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(register_register_name).

-operation_1({erlang,register,2}).
-operation_2({erlang,register,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1() ->
  register(name, self()).

p2() ->
  register(name, self()).

test() ->
  Fun1 = fun() -> p1() end,
  P1   = spawn(Fun),
  Fun2 = fun() -> p2() end,
  {P2, M} = spawn_monitor(Fun2),
  receive
    {'DOWN', M, process, P, Tag} ->
      Tag =/= normal
  end.
