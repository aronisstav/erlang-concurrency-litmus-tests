%%% @doc Sending to a name races with the name's registration
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(register_and_send).

-operation_1({erlang,register,2}).
-operation_2({erlang,send,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

test() ->
  Fun1 = fun() -> name ! message end,
  Fun2 =
    fun() ->
        register(name, self()),
        receive ok -> ok end
    end,
  {P, M} = spawn_monitor(Fun1),
  Q      = spawn(Fun2),
  Tag =
    receive
      {'DOWN', M, process, P, T} -> T
    end,
  Q ! ok,
  Tag =/= normal.
