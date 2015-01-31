-module(cb_sakila_rentals_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	    Rentals = boss_db:find(rental, []),
	    {ok, [{rentals, Rentals}]}.

show('GET', [RentalId]) ->
	    Rental = boss_db:find(RentalId),
	    {ok, [{rental, Rental}]}.

create('GET', []) -> ok;
create('POST', []) -> Rental = rental:new(id, erlang:localtime(), Req:post_param("inventory_id"), Req:post_param("customer_id"), erlang:localtime(), Req:post_param("staff_id"), erlang:localtime()),
	    case Rental:save() of
		        {ok, SavedRental} -> {redirect, "/rentals/show/"++SavedRental:id()};
		        {error, Errors} -> {ok, [{errors, Errors}, {rental, Rental}]}
			        end.

delete('GET', [RentalId]) ->
	    boss_db:delete(RentalId),
	    {redirect, [{action, "index"}]}.

update('GET', [RentalId]) -> Rental = boss_db:find(RentalId), {ok, [{rental, Rental}]};
update('POST', [RentalId]) ->
	    Rental = boss_db:find(RentalId),
	EditedRental = Rental:set([{inventory_id, Req:post_param("inventory_id")},{customer_id, Req:post_param("customer_id")}, {staff_id, Req:post_param("staff_id")}]),
	    EditedRental:save(),
	    {redirect, [{action, "index"}]}.
