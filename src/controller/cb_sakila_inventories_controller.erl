-module(cb_sakila_inventories_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	  Inventories = boss_db:find(inventory, []),
	  {ok, [{inventories, Inventories}]}.

show('GET', [InventoryId]) ->
	  Inventory = boss_db:find(InventoryId),
	  {ok, [{inventory, Inventory}]}.

create('GET', []) -> ok;
create('POST', []) -> Inventory = inventory:new(id, Req:post_param("film_id"), Req:post_param("store_id"), erlang:localtime()),
	  case Inventory:save() of
		    {ok, SavedInventory} -> {redirect, "/inventories/show/"++SavedInventory:id()};
		    {error, Errors} -> {ok, [{errors, Errors}, {inventory, Inventory}]}
			  end.

delete('GET', [InventoryId]) ->
	  boss_db:delete(InventoryId),
	  {redirect, [{action, "index"}]}.

update('GET', [InventoryId]) -> Inventory = boss_db:find(InventoryId), {ok, [{inventory, Inventory}]};
update('POST', [InventoryId]) ->
	  Inventory = boss_db:find(InventoryId),
	  EditedInventory = Inventory:set([{film_id, Req:post_param("film_id")},{store_id, Req:post_param("store_id")}]),
	  EditedInventory:save(),
	  {redirect, [{action, "index"}]}.

