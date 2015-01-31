-module(cb_sakila_addresses_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	    Addresses = boss_db:find(address, []),
	    {ok, [{addresses, Addresses}]}.

show('GET', [AddressId]) ->
	    Address = boss_db:find(AddressId),
	    {ok, [{address, Address}]}.

create('GET', []) -> ok;
create('POST', []) -> Address = address:new(id, Req:post_param("address"), Req:post_param("district"), Req:post_param("city_id"), Req:post_param("postal_code"), Req:post_param("phone"), erlang:localtime()),
	    case Address:save() of
		        {ok, SavedAddress} -> {redirect, "/addresses/show/"++SavedAddress:id()};
		        {error, Errors} -> {ok, [{errors, Errors}, {address, Address}]}
			        end.

delete('GET', [AddressId]) ->
	    boss_db:delete(AddressId),
	    {redirect, [{action, "index"}]}.

update('GET', [AddressId]) -> Address = boss_db:find(AddressId), {ok, [{address, Address}]};
update('POST', [AddressId]) ->
	    Address = boss_db:find(AddressId),
	EditedAddress = Address:set([{address, Req:post_param("address")},{district, Req:post_param("district")},{city_id, Req:post_param("city_id")}, {postal_code, Req:post_param("postal_code")}, {phone, Req:post_param("phone")}]),
	    EditedAddress:save(),
	    {redirect, [{action, "index"}]}.
