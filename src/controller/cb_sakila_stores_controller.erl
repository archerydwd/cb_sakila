-module(cb_sakila_stores_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	  	Stores = boss_db:find(store, []),
	    {ok, [{stores, Stores}]}.

show('GET', [StoreId]) ->
	    Store = boss_db:find(StoreId),
	    {ok, [{store, Store}]}.

create('GET', []) -> ok;
create('POST', []) -> Store = store:new(id, Req:post_param("address_id"), erlang:localtime()),
	    case Store:save() of
		        {ok, SavedStore} -> {redirect, "/stores/show/"++SavedStore:id()};
		        {error, Errors} -> {ok, [{errors, Errors}, {store, Store}]}
			        end.

delete('GET', [StoreId]) ->
	    boss_db:delete(StoreId),
	    {redirect, [{action, "index"}]}.

update('GET', [StoreId]) -> Store = boss_db:find(StoreId), {ok, [{store, Store}]};
update('POST', [StoreId]) ->
	    Store = boss_db:find(StoreId),
	    EditedStore = Store:set([{address_id, Req:post_param("address_id")}]),
	    EditedStore:save(),
	    {redirect, [{action, "index"}]}.
