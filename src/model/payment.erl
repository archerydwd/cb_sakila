-module(payment, [Id, CustomerId, StaffId, RentalId, Amount, PaymentDate, LastUpdate]).
-compile(export_all).
-belongs_to(customer).
-belongs_to(staff).
-belongs_to(rental).

