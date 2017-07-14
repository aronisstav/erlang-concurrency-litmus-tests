-export([test/0]).

-export([possible_1/0, possible_2/0, exhaustive/0]).

-include_lib("stdlib/include/assert.hrl").

possible_1() ->
  ?assertNotEqual(?RESULT_1, test()).

possible_2() ->
  ?assertNotEqual(?RESULT_2, test()).

exhaustive() ->
  ?assert(lists:member(test(), [?RESULT_1, ?RESULT_2])).
