-module(cb_sakila_home_controller, [Req]).
-compile(export_all).

index('GET', []) -> {ok, []}.
