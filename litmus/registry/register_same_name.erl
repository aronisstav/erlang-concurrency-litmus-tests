%%% @doc Two processes registering with the same name.
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(register_same_name).

-operation_1({erlang,register,2}).
-operation_2({erlang,register,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

test() ->
  Fun = fun() -> register(same_name, self()) end,
  {P, M} = spawn_monitor(Fun),
  _      = spawn(Fun),
  receive
    {'DOWN', M, process, P, Tag} -> Tag =/= normal
  end.
