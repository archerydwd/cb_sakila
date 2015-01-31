-module(cb_sakila_films_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	    Films = boss_db:find(film, []),
	    {ok, [{films, Films}]}.

show('GET', [FilmId]) ->
	    Film = boss_db:find(FilmId),
	    {ok, [{film, Film}]}.

create('GET', []) -> ok;
create('POST', []) -> Film = film:new(id, Req:post_param("title"), Req:post_param("description"), Req:post_param("release_year"), Req:post_param("language_id"), Req:post_param("rental_duration"), Req:post_param("rental_rate"), Req:post_param("length"), Req:post_param("replacement_cost"), Req:post_param("rating"), Req:post_param("special_features"), erlang:localtime()),
	    case Film:save() of
		        {ok, SavedFilm} -> {redirect, "/films/show/"++SavedFilm:id()};
		        {error, Errors} -> {ok, [{errors, Errors}, {film, Film}]}
			        end.

delete('GET', [FilmId]) ->
	    boss_db:delete(FilmId),
	    {redirect, [{action, "index"}]}.

update('GET', [FilmId]) -> Film = boss_db:find(FilmId), {ok, [{film, Film}]};
update('POST', [FilmId]) ->
	    Film = boss_db:find(FilmId),
	EditedFilm = Film:set([{title, Req:post_param("title")},{description, Req:post_param("description")},{release_year, Req:post_param("release_year")}, {language_id, Req:post_param("language_id")}, {rental_duration, Req:post_param("rental_duration")}, {rental_rate, Req:post_param("rental_rate")}, {length, Req:post_param("length")}, {replacement_cost, Req:post_param("replacement_cost")}, {rating, Req:post_param("rating")}, {special_features, Req:post_param("special_features")}]),
	    EditedFilm:save(),
	    {redirect, [{action, "index"}]}.
