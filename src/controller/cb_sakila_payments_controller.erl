-module(cb_sakila_payments_controller, [Req]).
-compile(export_all).

index('GET', []) ->
	    Payments = boss_db:find(payment, []),
	    {ok, [{payments, Payments}]}.

show('GET', [PaymentId]) ->
	    Payment = boss_db:find(PaymentId),
	    {ok, [{payment, Payment}]}.

create('GET', []) -> ok;
create('POST', []) -> Payment = payment:new(id, Req:post_param("customer_id"), Req:post_param("staff_id"), Req:post_param("rental_id"), Req:post_param("amount"), erlang:localtime(), erlang:localtime()),
	    case Payment:save() of
		        {ok, SavedPayment} -> {redirect, "/payments/show/"++SavedPayment:id()};
		        {error, Errors} -> {ok, [{errors, Errors}, {payment, Payment}]}
			        end.

delete('GET', [PaymentId]) ->
	    boss_db:delete(PaymentId),
	    {redirect, [{action, "index"}]}.

update('GET', [PaymentId]) -> Payment = boss_db:find(PaymentId), {ok, [{payment, Payment}]};
update('POST', [PaymentId]) ->
	    Payment = boss_db:find(PaymentId),
	EditedPayment = Payment:set([{customer_id, Req:post_param("customer_id")},{staff_id, Req:post_param("staff_id")},{rental_id, Req:post_param("rental_id")}, {amount, Req:post_param("amount")}, {payment_date, Req:post_param("payment_date")}]),
	    EditedPayment:save(),
	    {redirect, [{action, "index"}]}.
