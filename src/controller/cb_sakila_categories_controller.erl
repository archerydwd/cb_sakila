-module(cb_sakila_categories_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	    Categories = boss_db:find(category, []),
	    {ok, [{categories, Categories}]}.

show('GET', [CategoryId]) ->
	    Category = boss_db:find(CategoryId),
	    {ok, [{category, Category}]}.

create('GET', []) -> ok;
create('POST', []) -> Category = category:new(id, Req:post_param("name"), erlang:localtime()),
	    case Category:save() of
		        {ok, SavedCategory} -> {redirect, "/categories/show/"++SavedCategory:id()};
		        {error, Errors} -> {ok, [{errors, Errors}, {category, Category}]}
			        end.

delete('GET', [CategoryId]) ->
	    boss_db:delete(CategoryId),
	    {redirect, [{action, "index"}]}.

update('GET', [CategoryId]) -> Category = boss_db:find(CategoryId), {ok, [{category, Category}]};
update('POST', [CategoryId]) ->
	    Category = boss_db:find(CategoryId),
	    EditedCategory = Category:set([{name, Req:post_param("name")}]),
	    EditedCategory:save(),
	    {redirect, [{action, "index"}]}.
