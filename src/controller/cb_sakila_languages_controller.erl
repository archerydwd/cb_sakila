-module(cb_sakila_languages_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	  	Languages = boss_db:find(language, []),
	    {ok, [{languages, Languages}]}.

show('GET', [LanguageId]) ->
	    Language = boss_db:find(LanguageId),
	    {ok, [{language, Language}]}.

create('GET', []) -> ok;
create('POST', []) -> Language = language:new(id, Req:post_param("name"), erlang:localtime()),
	    case Language:save() of
		        {ok, SavedLanguage} -> {redirect, "/languages/show/"++SavedLanguage:id()};
		        {error, Errors} -> {ok, [{errors, Errors}, {language, Language}]}
			        end.

delete('GET', [LanguageId]) ->
	    boss_db:delete(LanguageId),
	    {redirect, [{action, "index"}]}.

update('GET', [LanguageId]) -> Language = boss_db:find(LanguageId), {ok, [{language, Language}]};
update('POST', [LanguageId]) ->
	    Language = boss_db:find(LanguageId),
	    EditedLanguage = Language:set([{language, Req:post_param("name")}]),
	    EditedLanguage:save(),
	    {redirect, [{action, "index"}]}.
