-module(cb_sakila_cities_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	  	Cities = boss_db:find(city, []),
	    {ok, [{cities, Cities}]}.

show('GET', [CityId]) ->
	    City = boss_db:find(CityId),
	    {ok, [{city, City}]}.

create('GET', []) -> ok;
create('POST', []) -> City = city:new(id, Req:post_param("city"), Req:post_param("country_id"), erlang:localtime()),
	    case City:save() of
		        {ok, SavedCity} -> {redirect, "/cities/show/"++SavedCity:id()};
		        {error, Errors} -> {ok, [{errors, Errors}, {city, City}]}
			        end.

delete('GET', [CityId]) ->
	    boss_db:delete(CityId),
	    {redirect, [{action, "index"}]}.

update('GET', [CityId]) -> City = boss_db:find(CityId), {ok, [{city, City}]};
update('POST', [CityId]) ->
	    City = boss_db:find(CityId),
	    EditedCity = City:set([{city, Req:post_param("city")},{country_id, Req:post_param("country_id")}]),
	    EditedCity:save(),
	    {redirect, [{action, "index"}]}.
