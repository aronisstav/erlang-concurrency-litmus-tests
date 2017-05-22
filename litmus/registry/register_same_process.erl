%%% @doc Two processes registering the same process.
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(register_same_process).

-operation_1({erlang,register,2}).
-operation_2({erlang,register,2}).

-define(RESULT_1, true).
-define(RESULT_2, false).

-include("../../headers/litmus.hrl").

test() ->
  Parent = self(),
  Fun = fun(Name) -> fun() -> register(Name, Parent) end end,
  {P, M} = spawn_monitor(Fun(alpha)),
  _      = spawn(Fun(beta)),
  receive
    {'DOWN', M, process, P, Tag} -> Tag =/= normal
  end.
