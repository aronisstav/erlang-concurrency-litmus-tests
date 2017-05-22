%%% @doc Two processes registering the same process.
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(register_and_send).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

test() ->
  Fun1 = fun() -> name ! message end,
  Fun2 = fun() -> register(name, self()) end,
  {P, M} = spawn_monitor(Fun1),
  _      = spawn(Fun2),
  receive
    {'DOWN', M, process, P, Tag} -> Tag =/= normal
  end.
