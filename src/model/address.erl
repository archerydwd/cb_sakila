-module(address, [Id, Address, District, CityId, PostalCode, Phone, LastUpdate]).
-compile(export_all).
-belongs_to(city).
-has({customers, many}).
-has({staffs, many}).
-has({stores, many}).

