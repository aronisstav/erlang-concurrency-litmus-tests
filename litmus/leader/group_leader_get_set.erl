%%% @doc Setting leader for another process vs it reading it
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(group_leader_get_set).

-operation_1({erlang,group_leader,0}).
-operation_2({erlang,group_leader,2}).

-define(RESULT_1, original).
-define(RESULT_2, new).

-include("../../headers/litmus.hrl").

test() ->
  P = self(),
  %% Set leader to myself, to simplify the test's logic:
  group_leader(P, P),
  %% A target process will have it's leader changed by another process.
  Fun1 = fun() ->
             %% Read the leader
             L = group_leader(),
             %% Wait for a signal and report back to coordinator
             receive
               ok -> P ! L
             end
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
