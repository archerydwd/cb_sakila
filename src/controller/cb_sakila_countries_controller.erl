-module(cb_sakila_countries_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	  	Countries = boss_db:find(country, []),
	    {ok, [{countries, Countries}]}.

show('GET', [CountryId]) ->
	    Country = boss_db:find(CountryId),
	    {ok, [{country, Country}]}.

create('GET', []) -> ok;
create('POST', []) -> Country = country:new(id, Req:post_param("country"), erlang:localtime()),
	    case Country:save() of
		        {ok, SavedCountry} -> {redirect, "/countries/show/"++SavedCountry:id()};
		        {error, Errors} -> {ok, [{errors, Errors}, {country, Country}]}
			        end.

delete('GET', [CountryId]) ->
	    boss_db:delete(CountryId),
	    {redirect, [{action, "index"}]}.

update('GET', [CountryId]) -> Country = boss_db:find(CountryId), {ok, [{country, Country}]};
update('POST', [CountryId]) ->
	    Country = boss_db:find(CountryId),
	    EditedCountry = Country:set([{country, Req:post_param("country")}]),
	    EditedCountry:save(),
	    {redirect, [{action, "index"}]}.
