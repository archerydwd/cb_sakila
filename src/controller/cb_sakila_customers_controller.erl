-module(cb_sakila_customers_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	    Customers = boss_db:find(customer, []),
	    {ok, [{customers, Customers}]}.

show('GET', [CustomerId]) ->
	    Customer = boss_db:find(CustomerId),
	    {ok, [{customer, Customer}]}.

create('GET', []) -> ok;
create('POST', []) -> Customer = customer:new(id, Req:post_param("store_id"), Req:post_param("first_name"), Req:post_param("last_name"), Req:post_param("email"), Req:post_param("address_id"), Req:post_param("active"), erlang:localtime(), erlang:localtime()),
	    case Customer:save() of
		        {ok, SavedCustomer} -> {redirect, "/customers/show/"++SavedCustomer:id()};
		        {error, Errors} -> {ok, [{errors, Errors}, {customer, Customer}]}
			        end.

delete('GET', [CustomerId]) ->
	    boss_db:delete(CustomerId),
	    {redirect, [{action, "index"}]}.

update('GET', [CustomerId]) -> Customer = boss_db:find(CustomerId), {ok, [{customer, Customer}]};
update('POST', [CustomerId]) ->
	    Customer = boss_db:find(CustomerId),
	EditedCustomer = Customer:set([{store_id, Req:post_param("store_id")},{first_name, Req:post_param("first_name")},{last_name, Req:post_param("last_name")}, {email, Req:post_param("email")}, {address_id, Req:post_param("address_id")}, {active, Req:post_param("active")}]),
	    EditedCustomer:save(),
	    {redirect, [{action, "index"}]}.
