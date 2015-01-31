-module(cb_sakila_staffs_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	  Staffs = boss_db:find(staff, []),
	  {ok, [{staffs, Staffs}]}.

show('GET', [StaffId]) ->
	  Staff = boss_db:find(StaffId),
	  {ok, [{staff, Staff}]}.

create('GET', []) -> ok;
create('POST', []) -> Staff = staff:new(id, Req:post_param("first_name"), Req:post_param("last_name"), Req:post_param("address_id"), Req:post_param("email"), Req:post_param("store_id"), Req:post_param("active"), Req:post_param("username"), Req:post_param("password"), erlang:localtime()),
	  case Staff:save() of
		    {ok, SavedStaff} -> {redirect, "/staffs/show/"++SavedStaff:id()};
		    {error, Errors} -> {ok, [{errors, Errors}, {staff, Staff}]}
			  end.

delete('GET', [StaffId]) ->
	  boss_db:delete(StaffId),
	  {redirect, [{action, "index"}]}.

update('GET', [StaffId]) -> Staff = boss_db:find(StaffId), {ok, [{staff, Staff}]};
update('POST', [StaffId]) ->
	  Staff = boss_db:find(StaffId),
	EditedStaff = Staff:set([{first_name, Req:post_param("first_name")},{last_name, Req:post_param("last_name")}, {address_id, Req:post_param("address_id")}, {email, Req:post_param("email")}, {store_id, Req:post_param("store_id")}, {active, Req:post_param("active")}, {username, Req:post_param("username")}, {password, Req:post_param("password")}]),
	  EditedStaff:save(),
	  {redirect, [{action, "index"}]}.

