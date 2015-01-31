-module(cb_sakila_filmtexts_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	  	FilmTexts = boss_db:find(filmtext, []),
	    {ok, [{filmtexts, FilmTexts}]}.

show('GET', [FilmTextId]) ->
	    FilmText = boss_db:find(FilmTextId),
	    {ok, [{filmtext, FilmText}]}.

create('GET', []) -> ok;
create('POST', []) -> FilmText = filmtext:new(id, Req:post_param("title"), Req:post_param("description")),
	    case FilmText:save() of
		        {ok, SavedFilmText} -> {redirect, "/filmtexts/show/"++SavedFilmText:id()};
		        {error, Errors} -> {ok, [{errors, Errors}, {filmtext, FilmText}]}
			        end.

delete('GET', [FilmTextId]) ->
	    boss_db:delete(FilmTextId),
	    {redirect, [{action, "index"}]}.

update('GET', [FilmTextId]) -> FilmText = boss_db:find(FilmTextId), {ok, [{filmtext, FilmText}]};
update('POST', [FilmTextId]) ->
	  	FilmText = boss_db:find(FilmTextId),
			EditedFilmText = FilmText:set([{title, Req:post_param("title")}, {description, Req:post_param("description")}]),
	    EditedFilmText:save(),
	    {redirect, [{action, "index"}]}.
