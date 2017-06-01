%%% @doc Setting leader for another process, vs it spawning a child
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(group_leader_spawn).

-operation_1({erlang,group_leader,2}).
-operation_2({erlang,spawn,1}).

-define(RESULT_1, original).
-define(RESULT_2, new).

-include("../../headers/litmus.hrl").

test() ->
  P = self(),
  %% Set leader to myself, to simplify the test's logic:
  group_leader(P, P),
  %% A target process will have it's leader changed by another process.
  Fun1 = fun() ->
             Fun3 =
               fun() ->
                   %% Wait for a signal and report back to coordinator
                   receive
                     ok -> P ! group_leader()
                   end
               end,
             Q1 = spawn(Fun3),
             receive ok -> Q1 ! ok end
         end,
  Q = spawn(Fun1),
  %% A process that changes the leader of Q and reports back to
  %% coordinator when done.
  Fun2 =
    fun() ->
        %% Change the leader to myself.
        group_leader(self(), Q),
        %% Report to coordinator.
        P ! ok
    end,
  R = spawn(Fun2),
  %% Wait until changer is done
  receive ok -> ok end,
  %% Notify the target to send a result too
  Q ! ok,
  %% And checks whether the leader is one of the processes.
  receive
    P -> original;
    R -> new;
    _ -> other
  end.
