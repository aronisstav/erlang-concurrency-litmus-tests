%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(register_unregister_taken).

-operation_1({erlang,register,2}).
-operation_2({erlang,unregister,1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(P) ->
  register(name, self()),
  P ! ok,
  unregister(name),
  receive ok -> ok end.

p2() ->
  register(name, self()).

test() ->
  P = self(),
  Fun1 = fun() -> p1(P) end,
  P1 = spawn(Fun1),
  Fun2 = fun() -> p2() end,
  receive ok -> ok end,
  {P2, M} = spawn_monitor(Fun2),
  Result =
    receive
      {'DOWN', M, process, P2, Tag} -> Tag =/= normal
    end,
  P1 ! ok,
  Result.
