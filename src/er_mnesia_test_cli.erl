%%%-------------------------------------------------------------------
%%% @author sakib
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Sep 2018 2:47 PM
%%%-------------------------------------------------------------------
-module(er_mnesia_test_cli).
-author("sakib").

-include_lib("er_mnesia_test/include/er_mnesia.hrl").

%% API
-export([setup/0, insert_user/2, bulk_insert/1, find_user/1, find_all/0, delete_user/1, delete_all/0, count/0, get_random_string/0]).

% setup setups create schema, start db connection, create table
setup() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  mnesia:create_table(er_user,
    [{disc_copies, [node()]},
      {attributes,
        record_info(fields, er_user)}]),
  ok.

% insert_user inserts user into table
insert_user(Username, Password) ->
  Insert =
    fun() ->
      mnesia:write(
        #er_user{
          username = Username,
          password = Password
        })
    end,
  {atomic, Results} = mnesia:transaction(Insert),
  Results.

bulk_insert(Amount) ->
  ID = get_random_string(),
  Username = list_to_binary([<<"Username-">>, list_to_binary(ID)]),
  Password = list_to_binary([<<"Password-">>, list_to_binary(ID)]),
  Current = Amount - 1,
  if
    Current == 0 ->
      ok;
    true ->
      Insert =
        fun() ->
          mnesia:dirty_write(
            #er_user{
              username = Username,
              password = Password
            })
        end,
      {atomic, Results} = mnesia:transaction(Insert),
      bulk_insert(Current)
  end.

% find_user finds user by username
find_user(Username) ->
  Query =
    fun() ->
      mnesia:match_object({er_user, Username, '_'})
    end,
  {atomic, Results} = mnesia:transaction(Query),
  Results.

% find_all finds all users
find_all() ->
  Query =
    fun() ->
      mnesia:match_object({er_user, '_', '_'})
    end,
  {atomic, Results} = mnesia:transaction(Query),
  Results.

% delete_user deletes user by username
delete_user(Username) ->
  Query =
    fun() ->
      mnesia:delete({er_user, Username})
    end,
  {atomic, Results} = mnesia:transaction(Query),
  Results.

% delete_user deletes user by username
delete_all() ->
  mnesia:clear_table(er_user).

count() ->
  length(find_all()).

get_random_string() ->
  AllowedChars = "qwertyQWERTY1234567890",
  Length = 32,
  lists:foldl(fun(_, Acc) ->
    [lists:nth(random:uniform(length(AllowedChars)),
      AllowedChars)]
    ++ Acc
              end, [], lists:seq(1, Length)).
