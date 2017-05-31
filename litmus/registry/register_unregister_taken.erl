%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(register_unregister_taken).

-operation_1({erlang,register,2}).
-operation_2({erlang,unregister,1}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

p1(P) ->
  receive ok -> ok end,
  P ! {self(), (catch register(name, self()))},
  receive ok -> ok end.

p2() ->
  unregister(name).

test() ->
  P = self(),
  Fun1 = fun() -> p1(P) end,
  P1 = spawn(Fun1),
  register(name, P1),
  P1 ! ok,
  Fun2 = fun() -> p2() end,
  {P2, M} = spawn_monitor(Fun2),
  Result =
    receive
      {'DOWN', M, process, P2, normal} -> ok
    end,
  P1 ! ok,
  receive
    {P1, R} -> R =:= true
  end.
