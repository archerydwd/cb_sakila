-module(cb_sakila_actors_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	  Actors = boss_db:find(actor, []),
	  {ok, [{actors, Actors}]}.

show('GET', [ActorId]) ->
	  Actor = boss_db:find(ActorId),
	  {ok, [{actor, Actor}]}.

create('GET', []) -> ok;
create('POST', []) -> Actor = actor:new(id, Req:post_param("first_name"), Req:post_param("last_name"), erlang:localtime()),
	  case Actor:save() of
		    {ok, SavedActor} -> {redirect, "/actors/show/"++SavedActor:id()};
		    {error, Errors} -> {ok, [{errors, Errors}, {actor, Actor}]}
			  end.

delete('GET', [ActorId]) ->
	  boss_db:delete(ActorId),
	  {redirect, [{action, "index"}]}.

update('GET', [ActorId]) -> Actor = boss_db:find(ActorId), {ok, [{actor, Actor}]};
update('POST', [ActorId]) ->
	  Actor = boss_db:find(ActorId),
	  EditedActor = Actor:set([{first_name, Req:post_param("first_name")},{last_name, Req:post_param("last_name")}]),
	  EditedActor:save(),
	  {redirect, [{action, "index"}]}.

