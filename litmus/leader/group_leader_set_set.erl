%%% @doc Setting leader for another process
%%% @author Stavros Aronis <aronisstav@gmail.com>

-module(group_leader_set_set).

-operation_1({erlang,group_leader,2}).
-operation_2({erlang,group_leader,2}).

-define(RESULT_1, first).
-define(RESULT_2, second).

-include("../../headers/litmus.hrl").

test() ->
  P = self(),
  %% A target process will have it's leader set by two different
  %% processes.
  Fun1 = fun() ->
             %% Wait for coordinator signal. This is to prevent races
             %% with `group_leader/0` below.
             receive
               ok ->
                 %% Report leader to coordinator.
                 P ! group_leader()
             end
         end,
  Q = spawn(Fun1),
  %% The two leader changers are in a "messaging chain" with the
  %% coordinator: each notifies the next when done and the coordinator
  %% continues once the message has gone full circle.
  Fun2 =
    fun(N) ->
        fun() ->
            %% Change the leader to myself
            group_leader(self(), Q),
            %% Report to "next in chain"
            receive ok -> N ! ok end
        end
    end,
  %% First changer is chained to coordinator
  R = spawn(Fun2(P)),
  %% Second hanger is chained to the first one
  S = spawn(Fun2(R)),
  %% Coordinator notifies the second...
  S ! ok,
  %% ... and expects a reply from the first one.
  receive ok -> ok end,
  %% Then it notifies the target
  Q ! ok,
  %% And checks whether the leader is one of the processes.
  receive
    R -> first;
    S -> second;
    _ -> other
  end.
