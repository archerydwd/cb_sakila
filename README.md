# Chicago Boss cb_sakila Application

Please note this is not a tutorial, I have wrote it in that style so you can follow along. If you get into trouble (like I did) try the mailing list or just google it. You will find that you will actually learn more from researching it and getting into tight spots. ;) 

I built this app with the Chicago Boss framework to be used as part of a series of applications that I will be 
performing tests on. This is a Chicago Boss version of the Ruby on Rails ror_sakila application: https://github.com/archerydwd/ror_sakila & the Flask version is here: https://github.com/archerydwd/flask_sakila

I am going to be performing tests on this app using some load testing tools such as Gatling & Tsung. 

Once I have tested this application and the other verisons of it, I will publish the results, which can then be used as a benchmark for others when trying to choose a framework.

You can build this app using a framework of your choosing and then follow the testing mechanisms that I will describe and then compare the results against my benchmark to get an indication of performance levels of your chosen framework.

###Installing Erlang and Chicago Boss

At the time of writing Erlang was at version: 17.4 and Chicago Boss at version: 0.8.12

**Install Erlang on osx using Homebrew:**
```
brew install erlang
```
**Installing Erlang on Linux:**
```
wget http://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
sudo dpkg -i erlang-solutions_1.0_all.deb
sudo apt-get update
sudo apt-get install erlang
```
**Install Chicago Boss:**

>Download the latest release from the Chicago Boss site: http://www.chicagoboss.org

*Compile it*
```
cd ChicagoBoss
make
```

If you get an when doing the make command, about uuid then do the following:

>vim deps/boss_db/rebar.config

Find the line that contains git://gitorious.org/avtobiff/erlang-uuid.git and change it to https://gitorious.org/avtobiff/erlang-uuid.git

Now re-run the make command.

==

###Working with the existing database

==

Firstly I am creating this application with the sakila_dump.sql file, which you can get from here: https://github.com/archerydwd/cb_sakila/blob/master/sakila_dump.sql. Its included in the source for this repository.


**Install mysql**


We are going to be using mysql for this database. If you don't have it, please install it:

Using HomeBrew:

```
brew update
brew doctor
brew upgrade
brew install mysql
```

==

###Create the database

==

To create the database, we need to login and enter a few commands. Please note, if this is your first time using mysql, the first time you login and enter a password, this acts as setting a password. If you don't want to set a password (bad idea) just hit enter when it requests the password.

```
mysql -u root -p
create database cb_sakila
use database cb_sakila

source PATH/TO/sakila_dump.sql
```

Then to check that this has indeed worked, you can enter the following command and you should see a list of the tables in the database:

```
show tables;
```

###Building the application

Because we do not have scaffolding or generators in Chicago Boss, we have to manually enter all the details from the database ourselves in order to create the app. So here goes..

==

###Create the cb_sakila app

==

```
make app PROJECT=cb_sakila
cd ../blog
```

==

###Starting the development server

==

To start the dev server:

```
./init-dev.sh
```

To stop the development server:

```
ctrl + c
```

==

###Pointing the app to the database

==

Edit the boss.config under the Database header:

```
{db_host, "localhost"},
% {db_port, 1978},
{db_adapter, mysql},
{db_username, "root"},
{db_password, "secret"},
{db_database, "cb_sakila"},
```

==

###Create the Models

==

Ok we are going to create all of the models that we will need in this section. 
* First thing to note is that the name of the file should not be plural, eg: the model for actors should be actor.erl.
* Inside any model file. The first line has to be -module(name, [Id, Attributes, FilmId]).

*Let me explain,* name should be the same as the file name. Id always should be first in the attribute list, this makes boss create the id itself. Also note in the database the id field has to be named 'id' and not actor_id or anything else like this. Then after Id, you can put the other attributes, but a field named actor_name should be named ActorName in the attributes list. Forign keys should be named here too, in camel case format alse.

* The second line should be -compile(export_all). export_all means export all the functions that are in this module. To make them available outside of the module.
* -belongs_to(othermodel) means that there is an association between this model and the one in the brackets. In the model in the brackets, you must put a -has() with this model in its brackets.
* -has(othermodel) means that there is an association between this model and the one in the brackets. This goes into the model that would be in the brackets of the -belongs_to part in the other model.

Anyway lets get to it.

**Create the model for actors:**

>touch src/model/actor.erl

Now edit: src/model/actor.erl

```
-module(actor, [Id, FirstName, LastName, LastUpdate]).
-compile(export_all).
```

**Create the model for addresses:**

>touch src/model/address.erl

Now edit: src/model/address.erl

```
-module(address, [Id, Address, District, CityId, PostalCode, Phone, LastUpdate]).
-compile(export_all).
-belongs_to(city).
-has({customers, many}).
-has({staffs, many}).
-has({stores, many}).
```

**Create the model for categories:**

>touch src/model/category.erl

Now edit: src/model/category.erl

```
-module(category, [Id, Name, LastUpdate]).
-compile(export_all).
```

**Create the model for cities:**

>touch src/model/city.erl

Now edit: src/model/city.erl

```
-module(city, [Id, City, CountryId, LastUpdate]).
-compile(export_all).
-belongs_to(country).
-has({addresses, many}).
```

**Create the model for countries:**

>touch src/model/country.erl

Now edit: src/model/country.erl

```
-module(country, [Id, Country, LastUpdate]).
-compile(export_all).
-has({cities, many}).
```

**Create the model for customers:**

>touch src/model/customer.erl

Now edit: src/model/customer.erl

```
-module(customer, [Id, StoreId, FirstName, LastName, Email, AddressId, Active, CreateDate, LastUpdate]).
-compile(export_all).
-belongs_to(store).
-belongs_to(address).
-has({payments, many}).
-has({rentals, many}).
```

**Create the model for films:**

>touch src/model/film.erl

Now edit: src/model/film.erl

```
-module(film, [Id, Title, Description, ReleaseYear, LanguageId, RentalDuration, RentalRate, Length, ReplacementCost, Rating, SpecialFeatures, LastUpdate]).
-compile(export_all).
-belongs_to(language).
-has({inventories, many}).
```

**Create the model for filmtexts:**

>touch src/model/filmtext.erl

Now edit: src/model/filmtext.erl

```
-module(filmtext, [Id, Title, Description]).
-compile(export_all).
```

**Create the model for inventories:**

>touch src/model/inventory.erl

Now edit: src/model/inventory.erl

```
-module(inventory, [Id, FilmId, StoreId, LastUpdate]).
-compile(export_all).
-belongs_to(film).
-belongs_to(store).
-has({rentals, many}).
```

**Create the model for languages:**

>touch src/model/language.erl

Now edit: src/model/language.erl

```
-module(language, [Id, Name, LastUpdate]).
-compile(export_all).
-has({films, many}).
```

**Create the model for payments:**

>touch src/model/payment.erl

Now edit: src/model/payment.erl

```
-module(payment, [Id, CustomerId, StaffId, RentalId, Amount, PaymentDate, LastUpdate]).
-compile(export_all).
-belongs_to(customer).
-belongs_to(staff).
-belongs_to(rental).
```

**Create the model for rentals:**

>touch src/model/rental.erl

Now edit: src/model/rental.erl

```
-module(rental, [Id, RentalDate, InventoryId, CustomerId, ReturnDate, StaffId, LastUpdate]).
-compile(export_all).
-belongs_to(inventory).
-belongs_to(customer).
-belongs_to(staff).
-has({payments, many}).
```

**Create the model for staffs:**

>touch src/model/staff.erl

Now edit: src/model/staff.erl

```
-module(staff, [Id, FirstName, LastName, AddressId, Email, StoreId, Active, Username, Password, LastUpdate]).
-compile(export_all).
-belongs_to(address).
-belongs_to(store).
-has({payments, many}).
-has({rentals, many}).
```

**Create the model for stores:**

>touch src/model/store.erl

Now edit: src/model/store.erl

```
-module(store, [Id, AddressId, LastUpdate]).
-compile(export_all).
-belongs_to(address).
-has({customers, many}).
-has({inventories, many}).
-has({staffs, many}).
```

==

###Create the controllers

==

Things to note about controllers:
* The name of the controller takes the form: APPLICATIONNAME_MODELNAME_CONTROLLER.ERL
* The name should be a plural version of the model, for MODELNAME above for the actor controller the name should be: cb_sakila_actors_controller.erl.
* The first line is: -module(name, [Req]). Req is a SimpleBridge request object, which is used to access useful information such as values that were passed in through a POST call from a form.
* The -compile(export_all) line still has the same purpose.
* Each action corrosponds to a template in the views folder, this is achieved through using the same name for the method as the html file.

**Create the controller for actors:**

>touch src/controller/cb_sakila_actors_controller.erl

Now edit: src/controller/cb_sakila_actors_controller.erl

```
-module(cb_sakila_actors_controller, [Req]).
-compile(export_all).

index('GET', []) ->
    Actors = boss_db:find(actor, []),
    {ok, [{actors, Actors}]}.

show('GET', [ActorId]) ->
    Actor = boss_db:find(ActorId),
    {ok, [{actor, Actor}]}.

create('GET', []) -> ok;
create('POST', []) -> Actor = actor:new(id, Req:post_param("first_name"), Req:post_param("last_name"), erlang:localtime()),
    case Actor:save() of
        {ok, SavedActor} -> {redirect, "/actors/show/"++SavedActor:id()};
        {error, Errors} -> {ok, [{errors, Errors}, {actor, Actor}]}
        end.

delete('GET', [ActorId]) ->
    boss_db:delete(ActorId),
    {redirect, [{action, "index"}]}.

update('GET', [ActorId]) -> Actor = boss_db:find(ActorId), {ok, [{actor, Actor}]};
update('POST', [ActorId]) ->
    Actor = boss_db:find(ActorId),
    EditedActor = Actor:set([{first_name, Req:post_param("first_name")},{last_name, Req:post_param("last_name")}]),
    EditedActor:save(),
    {redirect, [{action, "index"}]}.
```

**Create the controller for addresses:**

>touch src/controller/cb_sakila_addresses_controller.erl

Now edit: src/controller/cb_sakila_addresses_controller.erl

```
-module(cb_sakila_addresses_controller, [Req]).
-compile(export_all).

index('GET', []) ->
      Addresses = boss_db:find(address, []),
      {ok, [{addresses, Addresses}]}.

show('GET', [AddressId]) ->
      Address = boss_db:find(AddressId),
      {ok, [{address, Address}]}.

create('GET', []) -> ok;
create('POST', []) -> Address = address:new(id, Req:post_param("address"), Req:post_param("district"), Req:post_param("city_id"), Req:post_param("postal_code"), Req:post_param("phone"), erlang:           localtime()),
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
  EditedAddress = Address:set([{address, Req:post_param("address")},{district, Req:post_param("district")},{city_id, Req:post_param("city_id")}, {postal_code, Req:post_param("postal_code")}, {phone, Req: post_param("phone")}]),
      EditedAddress:save(),
      {redirect, [{action, "index"}]}.
```

**Create the controller for categories:**

>touch src/controller/cb_sakila_categories_controller.erl

Now edit: src/controller/cb_sakila_categories_controller.erl

```
-module(cb_sakila_categories_controller, [Req]).
-compile(export_all).

index('GET', []) ->
      Categories = boss_db:find(category, []),
      {ok, [{categories, Categories}]}.

show('GET', [CategoryId]) ->
      Category = boss_db:find(CategoryId),
      {ok, [{category, Category}]}.

create('GET', []) -> ok;
create('POST', []) -> Category = category:new(id, Req:post_param("name"), erlang:localtime()),
      case Category:save() of
            {ok, SavedCategory} -> {redirect, "/categories/show/"++SavedCategory:id()};
            {error, Errors} -> {ok, [{errors, Errors}, {category, Category}]}
              end.

delete('GET', [CategoryId]) ->
      boss_db:delete(CategoryId),
      {redirect, [{action, "index"}]}.

update('GET', [CategoryId]) -> Category = boss_db:find(CategoryId), {ok, [{category, Category}]};
update('POST', [CategoryId]) ->
      Category = boss_db:find(CategoryId),
      EditedCategory = Category:set([{name, Req:post_param("name")}]),
      EditedCategory:save(),
      {redirect, [{action, "index"}]}.
```

**Create the controller for cities:**

>touch src/controller/cb_sakila_cities_controller.erl

Now edit: src/controller/cb_sakila_cities_controller.erl

```
-module(cb_sakila_cities_controller, [Req]).
-compile(export_all).

index('GET', []) ->
      Cities = boss_db:find(city, []),
      {ok, [{cities, Cities}]}.

show('GET', [CityId]) ->
      City = boss_db:find(CityId),
      {ok, [{city, City}]}.

create('GET', []) -> ok;
create('POST', []) -> City = city:new(id, Req:post_param("city"), Req:post_param("country_id"), erlang:localtime()),
      case City:save() of
            {ok, SavedCity} -> {redirect, "/cities/show/"++SavedCity:id()};
            {error, Errors} -> {ok, [{errors, Errors}, {city, City}]}
              end.

delete('GET', [CityId]) ->
      boss_db:delete(CityId),
      {redirect, [{action, "index"}]}.

update('GET', [CityId]) -> City = boss_db:find(CityId), {ok, [{city, City}]};
update('POST', [CityId]) ->
      City = boss_db:find(CityId),
      EditedCity = City:set([{city, Req:post_param("city")},{country_id, Req:post_param("country_id")}]),
      EditedCity:save(),
      {redirect, [{action, "index"}]}.
```

**Create the controller for countries:**

>touch src/controller/cb_sakila_countries_controller.erl

Now edit: src/controller/cb_sakila_countries_controller.erl

```
-module(cb_sakila_countries_controller, [Req]).
-compile(export_all).

index('GET', []) ->
      Countries = boss_db:find(country, []),
      {ok, [{countries, Countries}]}.

show('GET', [CountryId]) ->
      Country = boss_db:find(CountryId),
      {ok, [{country, Country}]}.

create('GET', []) -> ok;
create('POST', []) -> Country = country:new(id, Req:post_param("country"), erlang:localtime()),
      case Country:save() of
            {ok, SavedCountry} -> {redirect, "/countries/show/"++SavedCountry:id()};
            {error, Errors} -> {ok, [{errors, Errors}, {country, Country}]}
              end.

delete('GET', [CountryId]) ->
      boss_db:delete(CountryId),
      {redirect, [{action, "index"}]}.

update('GET', [CountryId]) -> Country = boss_db:find(CountryId), {ok, [{country, Country}]};
update('POST', [CountryId]) ->
      Country = boss_db:find(CountryId),
      EditedCountry = Country:set([{country, Req:post_param("country")}]),
      EditedCountry:save(),
      {redirect, [{action, "index"}]}.
```

**Create the controller for customers:**

>touch src/controller/cb_sakila_customers_controller.erl

Now edit: src/controller/cb_sakila_customers_controller.erl

```
-module(cb_sakila_customers_controller, [Req]).
-compile(export_all).

index('GET', []) ->
      Customers = boss_db:find(customer, []),
      {ok, [{customers, Customers}]}.

show('GET', [CustomerId]) ->
      Customer = boss_db:find(CustomerId),
      {ok, [{customer, Customer}]}.

create('GET', []) -> ok;
create('POST', []) -> Customer = customer:new(id, Req:post_param("store_id"), Req:post_param("first_name"), Req:post_param("last_name"), Req:post_param("email"), Req:post_param("address_id"), Req:        post_param("active"), erlang:localtime(), erlang:localtime()),
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
```

**Create the controller for films:**

>touch src/controller/cb_sakila_films_controller.erl

Now edit: src/controller/cb_sakila_films_controller.erl

```
-module(cb_sakila_films_controller, [Req]).
-compile(export_all).

index('GET', []) ->
      Films = boss_db:find(film, []),
      {ok, [{films, Films}]}.

show('GET', [FilmId]) ->
      Film = boss_db:find(FilmId),
      {ok, [{film, Film}]}.

create('GET', []) -> ok;
create('POST', []) -> Film = film:new(id, Req:post_param("title"), Req:post_param("description"), Req:post_param("release_year"), Req:post_param("language_id"), Req:post_param("rental_duration"), Req:    post_param("rental_rate"), Req:post_param("length"), Req:post_param("replacement_cost"), Req:post_param("rating"), Req:post_param("special_features"), erlang:localtime()),
      case Film:save() of
            {ok, SavedFilm} -> {redirect, "/films/show/"++SavedFilm:id()};
            {error, Errors} -> {ok, [{errors, Errors}, {film, Film}]}
              end.

delete('GET', [FilmId]) ->
      boss_db:delete(FilmId),
      {redirect, [{action, "index"}]}.

update('GET', [FilmId]) -> Film = boss_db:find(FilmId), {ok, [{film, Film}]};
update('POST', [FilmId]) ->
      Film = boss_db:find(FilmId),
  EditedFilm = Film:set([{title, Req:post_param("title")},{description, Req:post_param("description")},{release_year, Req:post_param("release_year")}, {language_id, Req:post_param("language_id")},        {rental_duration, Req:post_param("rental_duration")}, {rental_rate, Req:post_param("rental_rate")}, {length, Req:post_param("length")}, {replacement_cost, Req:post_param("replacement_cost")}, {rating,    Req:post_param("rating")}, {special_features, Req:post_param("special_features")}]),
      EditedFilm:save(),
      {redirect, [{action, "index"}]}.
```

**Create the controller for filmtexts:**

>touch src/controller/cb_sakila_filmtexts_controller.erl

Now edit: src/controller/cb_sakila_filmtexts_controller.erl

```
-module(cb_sakila_filmtexts_controller, [Req]).
-compile(export_all).

index('GET', []) ->
      FilmTexts = boss_db:find(filmtext, []),
      {ok, [{filmtexts, FilmTexts}]}.

show('GET', [FilmTextId]) ->
      FilmText = boss_db:find(FilmTextId),
      {ok, [{filmtext, FilmText}]}.

create('GET', []) -> ok;
create('POST', []) -> FilmText = filmtext:new(id, Req:post_param("title"), Req:post_param("description")),
      case FilmText:save() of
            {ok, SavedFilmText} -> {redirect, "/filmtexts/show/"++SavedFilmText:id()};
            {error, Errors} -> {ok, [{errors, Errors}, {filmtext, FilmText}]}
              end.

delete('GET', [FilmTextId]) ->
      boss_db:delete(FilmTextId),
      {redirect, [{action, "index"}]}.

update('GET', [FilmTextId]) -> FilmText = boss_db:find(FilmTextId), {ok, [{filmtext, FilmText}]};
update('POST', [FilmTextId]) ->
      FilmText = boss_db:find(FilmTextId),
      EditedFilmText = FilmText:set([{title, Req:post_param("title")}, {description, Req:post_param("description")}]),
      EditedFilmText:save(),
      {redirect, [{action, "index"}]}.
```

**Create the controller for inventories:**

>touch src/controller/cb_sakila_inventories_controller.erl

Now edit: src/controller/cb_sakila_inventories_controller.erl

```
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
```

**Create the controller for languages:**

>touch src/controller/cb_sakila_languages_controller.erl

Now edit: src/controller/cb_sakila_languages_controller.erl

```
-module(cb_sakila_languages_controller, [Req]).
-compile(export_all).

index('GET', []) ->
      Languages = boss_db:find(language, []),
      {ok, [{languages, Languages}]}.

show('GET', [LanguageId]) ->
      Language = boss_db:find(LanguageId),
      {ok, [{language, Language}]}.

create('GET', []) -> ok;
create('POST', []) -> Language = language:new(id, Req:post_param("name"), erlang:localtime()),
      case Language:save() of
            {ok, SavedLanguage} -> {redirect, "/languages/show/"++SavedLanguage:id()};
            {error, Errors} -> {ok, [{errors, Errors}, {language, Language}]}
              end.

delete('GET', [LanguageId]) ->
      boss_db:delete(LanguageId),
      {redirect, [{action, "index"}]}.

update('GET', [LanguageId]) -> Language = boss_db:find(LanguageId), {ok, [{language, Language}]};
update('POST', [LanguageId]) ->
      Language = boss_db:find(LanguageId),
      EditedLanguage = Language:set([{language, Req:post_param("name")}]),
      EditedLanguage:save(),
      {redirect, [{action, "index"}]}.
```

**Create the controller for payments:**

>touch src/controller/cb_sakila_payments_controller.erl

Now edit: src/controller/cb_sakila_payments_controller.erl

```
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
  EditedPayment = Payment:set([{customer_id, Req:post_param("customer_id")},{staff_id, Req:post_param("staff_id")},{rental_id, Req:post_param("rental_id")}, {amount, Req:post_param("amount")},            {payment_date, Req:post_param("payment_date")}]),
      EditedPayment:save(),
      {redirect, [{action, "index"}]}.
```

**Create the controller for rentals:**

>touch src/controller/cb_sakila_rentals_controller.erl

Now edit: src/controller/cb_sakila_rentals_controller.erl

```
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
```

**Create the controller for staffs:**

>touch src/controller/cb_sakila_staffs_controller.erl

Now edit: src/controller/cb_sakila_staffs_controller.erl

```
-module(cb_sakila_staffs_controller, [Req]).
-compile(export_all).

index('GET', []) ->
    Staffs = boss_db:find(staff, []),
    {ok, [{staffs, Staffs}]}.

show('GET', [StaffId]) ->
    Staff = boss_db:find(StaffId),
    {ok, [{staff, Staff}]}.

create('GET', []) -> ok;
create('POST', []) -> Staff = staff:new(id, Req:post_param("first_name"), Req:post_param("last_name"), Req:post_param("address_id"), Req:post_param("email"), Req:post_param("store_id"), Req:              post_param("active"), Req:post_param("username"), Req:post_param("password"), erlang:localtime()),
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
  EditedStaff = Staff:set([{first_name, Req:post_param("first_name")},{last_name, Req:post_param("last_name")}, {address_id, Req:post_param("address_id")}, {email, Req:post_param("email")}, {store_id,    Req:post_param("store_id")}, {active, Req:post_param("active")}, {username, Req:post_param("username")}, {password, Req:post_param("password")}]),
    EditedStaff:save(),
    {redirect, [{action, "index"}]}.
```

**Create the controller for stores:**

>touch src/controller/cb_sakila_stores_controller.erl

Now edit: src/controller/cb_sakila_stores_controller.erl

```
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
```

==

###Create the views

==

For the views, we use html and Django's templating language.

We need to create the directories for each model's views. The directory should use the pluralised name.

```
mkdir src/view/actors
mkdir src/view/addresses
mkdir src/view/categories
mkdir src/view/cities
mkdir src/view/countries
mkdir src/view/customers
mkdir src/view/films
mkdir src/view/filmtexts
mkdir src/view/inventories
mkdir src/view/languages
mkdir src/view/payments
mkdir src/view/rentals
mkdir src/view/staffs
mkdir src/view/stores
```

Next we need to create 4 files for each directory, a index, create, show and update .html's.

```
touch src/view/actors/index.html show.html update.html create.html
touch src/view/addresses/index.html show.html update.html create.html
touch src/view/categories/index.html show.html update.html create.html
touch src/view/cities/index.html show.html update.html create.html
touch src/view/countries/index.html show.html update.html create.html
touch src/view/customers/index.html show.html update.html create.html
touch src/view/films/index.html show.html update.html create.html
touch src/view/filmtexts/index.html show.html update.html create.html
touch src/view/inventories/index.html show.html update.html create.html
touch src/view/languages/index.html show.html update.html create.html
touch src/view/payments/index.html show.html update.html create.html
touch src/view/rentals/index.html show.html update.html create.html
touch src/view/staffs/index.html show.html update.html create.html
touch src/view/stores/index.html show.html update.html create.html
```

Now we can start editing these files:
=
###Actors
=

**Edit: src/view/actors/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing actors</h1>
      <table>
        <thead>
          <tr>
            <th>First Name</th>
            <th>Last Name</th>
            <th>Last Update</th>
          </tr>
        </thead>

        <tbody>
          {% for actor in actors %}
            <tr>
              <td>{{ actor.first_name }}</td>
              <td>{{ actor.last_name }}</td>
              <td>{{ actor.last_update|date:"Y-m-d" }} {{ actor.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/actors/show/{{ actor.id }}">Show</a></td>
              <td><a href="/actors/update/{{ actor.id }}">Edit</a></td>
              <td><a href="/actors/delete/{{ actor.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Actor</a>
  </body>
</html>
```

**Edit: src/view/actors/create.html**

```
<h1>Create a new Actor</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      First Name:<br>
      <input name="first_name" value="{{ actor.first_name|default_if_none:'' }}"/>
    </p>
    <p>
      Last Name:<br>
      <input name="last_name" value="{{ actor.last_name|default_if_none:'' }}"/>
    </p>
    <p>
      <input type="submit" value="Create Actor"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/actors/show.html**

```
<p>
    <strong>First Name:</strong>
    {{ actor.first_name }}
</p>
<p>
    <strong>Last Name</strong>
    {{ actor.last_name }}
</p>
<p>
    <strong>Last update:</strong>
    {{ actor.last_update|date:"Y-m-d" }} {{ actor.last_update|time:"H:i:s" }} UTC
</p>

<a href="/actors/update/{{ actor.id }}">Edit</a> |
<a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/actors/update.html**

```
<h1>Editing actor</h1>
<form method="post">
    <p>
      First name<br>
      <input name="first_name" value="{{ actor.first_name }}"/>
    </p>
    <p>
      Last name<br>
      <input name="last_name" value="{{ actor.last_name }}"/>
    </p>
    <p>
      <input type="submit" value="Update Actor"/>
    </p>
</form>

<a href="/actors/show/{{ actor.id }}">Show</a> |
<a href="{% url action="index" %}">Back</a>
```

==

###Addresses
==

**Edit: src/view/addresses/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing addresses</h1>
      <table>
        <thead>
          <tr>
            <th>Address</th>
            <th>District</th>
            <th>City id</th>
            <th>Postal code</th>
            <th>Phone</th>
            <th>Last updated</th>
          </tr>
        </thead>

        <tbody>
          {% for address in addresses %}
            <tr>
              <td>{{ address.address }}</td>
              <td>{{ address.district }}</td>
              <td>{{ address.city_id }}</td>
              <td>{{ address.postal_code }}</td>
              <td>{{ address.phone }}</td>
              <td>{{ address.last_update|date:"Y-m-d" }} {{ address.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/addresses/show/{{ address.id }}">Show</a></td>
              <td><a href="/addresses/update/{{ address.id }}">Edit</a></td>
              <td><a href="/addresses/delete/{{ address.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Address</a>
  </body>
</html>
```

**Edit: src/view/addresses/create.html**

```
<h1>Create a new Address</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      Address:<br>
      <input name="address" value="{{ address.address|default_if_none:'' }}"/>
    </p>
    <p>
      District:<br>
      <input name="district" value="{{ address.district|default_if_none:'' }}"/>
    </p>
    <p>
      City Id:<br>
      <input name="city_id" value="{{ address.city_id|default_if_none:'' }}"/>
    </p>
    <p>
      Postal Code:<br>
      <input name="postal_code" value="{{ address.postal_code|default_if_none:'' }}"/>
    </p>
    <p>
      Phone:<br>
      <input name="phone" value="{{ address.phone|default_if_none:'' }}"/>
    </p>
    <p>
      <input type="submit" value="Create Address"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/addresses/show.html**

```
<p>
    <strong>Address:</strong>
    {{ address.address }}
</p>
<p>
    <strong>District</strong>
    {{ address.district }}
</p>
<p>
    <strong>City id</strong>
    {{ address.city_id }}
</p>
<p>
    <strong>Postal code</strong>
    {{ address.postal_code }}
</p>
<p>
    <strong>Phone</strong>
    {{ address.phone }}
</p>
<p>
    <strong>Last update:</strong>
    {{ address.last_update|date:"Y-m-d" }} {{ address.last_update|time:"H:i:s" }} UTC
</p>

<a href="/addresses/update/{{ address.id }}">Edit</a> |
<a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/addresses/update.html**

```
<h1>Editing address</h1>
<form method="post">
    <p>
      Address<br>
      <input name="address" value="{{ address.address }}"/>
    </p>
    <p>
      District<br>
      <input name="district" value="{{ address.district }}"/>
    </p>
    <p>
      City id<br>
      <input name="city_id" value="{{ address.city_id }}"/>
    </p>
    <p>
      Postal code<br>
      <input name="postal_code" value="{{ address.postal_code }}"/>
    </p>
    <p>
      Phone<br>
      <input name="phone" value="{{ address.phone }}"/>
    </p>
    <p>
      <input type="submit" value="Update Address"/>
    </p>
</form>
<a href="/addresses/show/{{ address.id }}">Show</a> |
<a href="{% url action="index" %}">Back</a>
```

==

###Categories
==

**Edit: src/view/categories/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing categories</h1>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Last Update</th>
          </tr>
        </thead>

        <tbody>
          {% for category in categories %}
            <tr>
              <td>{{ category.name }}</td>
              <td>{{ category.last_update|date:"Y-m-d" }} {{ category.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/categories/show/{{ category.id }}">Show</a></td>
              <td><a href="/categories/update/{{ category.id }}">Edit</a></td>
              <td><a href="/categories/delete/{{ category.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Category</a>
  </body>
</html>
```

**Edit: src/view/categories/create.html**

```
<h1>Create a new category</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      Name:<br>
      <input name="name" value="{{ category.name|default_if_none:'' }}"/>
    </p>
    <p>
      <input type="submit" value="Create Category"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/categories/show.html**

```
  <p>
    <strong>Name:</strong>
    {{ category.name }}
  </p>
  <p>
    <strong>Last update:</strong>
    {{ category.last_update|date:"Y-m-d" }} {{ category.last_update|time:"H:i:s" }} UTC
  </p>

  <a href="/categories/update/{{ category.id }}">Edit</a> |
  <a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/categories/update.html**

```
<h1>Editing category</h1>
  <form method="post">
    <p>
      Name<br>
      <input name="name" value="{{ category.name }}"/>
    </p>
    <p>
      <input type="submit" value="Update Category"/>
    </p>
  </form>
  <a href="/categories/show/{{ category.id }}">Show</a> |
  <a href="{% url action="index" %}">Back</a>
```

==

###Cities
==

**Edit: src/view/cities/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing cities</h1>
      <table>
        <thead>
          <tr>
            <th>City</th>
            <th>Country id</th>
            <th>Last Update</th>
          </tr>
        </thead>

        <tbody>
          {% for city in cities %}
            <tr>
              <td>{{ city.city }}</td>
              <td>{{ city.country_id }}</td>
              <td>{{ city.last_update|date:"Y-m-d" }} {{ city.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/cities/show/{{ city.id }}">Show</a></td>
              <td><a href="/cities/update/{{ city.id }}">Edit</a></td>
              <td><a href="/cities/delete/{{ city.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New City</a>
  </body>
</html>
```

**Edit: src/view/cities/create.html**

```
<h1>Create a new City</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      City:<br>
      <input name="city" value="{{ city.city|default_if_none:'' }}"/>
    </p>
    <p>
      Country id:<br>
      <input name="country_id" value="{{ city.country_id|default_if_none:'' }}"/>
    </p>
    <p>
      <input type="submit" value="Create City"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/cities/show.html**

```
  <p>
    <strong>City:</strong>
    {{ city.city }}
  </p>
  <p>
    <strong>Country id</strong>
    {{ city.country_id }}
  </p>
  <p>
    <strong>Last update:</strong>
    {{ city.last_update|date:"Y-m-d" }} {{ city.last_update|time:"H:i:s" }} UTC
  </p>

  <a href="/cities/update/{{ city.id }}">Edit</a> |
  <a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/cities/update.html**

```
<h1>Editing city</h1>
  <form method="post">
    <p>
      City<br>
      <input name="city" value="{{ city.city }}"/>
    </p>
    <p>
      Country id<br>
      <input name="country_id" value="{{ city.country_id }}"/>
    </p>
    <p>
      <input type="submit" value="Update City"/>
    </p>
  </form>
  <a href="/cities/show/{{ city.id }}">Show</a> |
  <a href="{% url action="index" %}">Back</a>
```

==

###Countries
==

**Edit: src/view/countries/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing countries</h1>
      <table>
        <thead>
          <tr>
            <th>Country</th>
            <th>Last Update</th>
          </tr>
        </thead>

        <tbody>
          {% for country in countries %}
            <tr>
              <td>{{ country.country }}</td>
              <td>{{ country.last_update|date:"Y-m-d" }} {{ country.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/countries/show/{{ country.id }}">Show</a></td>
              <td><a href="/countries/update/{{ country.id }}">Edit</a></td>
              <td><a href="/countries/delete/{{ country.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Country</a>
  </body>
</html>
```

**Edit: src/view/countries/create.html**

```
<h1>Create a new Country</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      Country:<br>
      <input name="country" value="{{ country.country|default_if_none:'' }}"/>
    </p>
    <p>
      <input type="submit" value="Create Country"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/countries/show.html**

```
  <p>
    <strong>Country</strong>
    {{ country.country }}
  </p>
  <p>
    <strong>Last update:</strong>
    {{ country.last_update|date:"Y-m-d" }} {{ country.last_update|time:"H:i:s" }} UTC
  </p>

  <a href="/countries/update/{{ country.id }}">Edit</a> |
  <a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/countries/update.html**

```
<h1>Editing country</h1>
  <form method="post">
    <p>
      Country<br>
      <input name="country" value="{{ country.country }}"/>
    </p>
    <p>
      <input type="submit" value="Update Country"/>
    </p>
  </form>
  <a href="/countries/show/{{ country.id }}">Show</a> |
  <a href="{% url action="index" %}">Back</a>
```

==

###Customers
==

**Edit: src/view/customers/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing customers</h1>
      <table>
        <thead>
          <tr>
            <th>Store id</th>
            <th>First name</th>
            <th>Last name</th>
            <th>Email</th>
            <th>Address id</th>
            <th>Active</th>
            <th>Creation date</th>
            <th>Last updated</th>
          </tr>
        </thead>

        <tbody>
          {% for customer in customers %}
            <tr>
              <td>{{ customer.store_id }}</td>
              <td>{{ customer.first_name }}</td>
              <td>{{ customer.last_name }}</td>
              <td>{{ customer.email }}</td>
              <td>{{ customer.address_id }}</td>
              <td>{{ customer.active }}</td>
              <td>{{ customer.create_date|date:"Y-m-d" }} {{ customer.create_date|time:"H:i:s" }} UTC</td>
              <td>{{ customer.last_update|date:"Y-m-d" }} {{ customer.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/customers/show/{{ customer.id }}">Show</a></td>
              <td><a href="/customers/update/{{ customer.id }}">Edit</a></td>
              <td><a href="/customers/delete/{{ customer.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Customer</a>
  </body>
</html>
```

**Edit: src/view/customers/create.html**

```
<h1>Create a new Customer</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      Store id:<br>
      <input name="store_id" value="{{ customer.store_id|default_if_none:'' }}"/>
    </p>
    <p>
      First name:<br>
      <input name="first_name" value="{{ customer.first_name|default_if_none:'' }}"/>
    </p>
    <p>
      Last name:<br>
      <input name="last_name" value="{{ customer.last_name|default_if_none:'' }}"/>
    </p>
    <p>
      Email:<br>
      <input name="email" value="{{ customer.email|default_if_none:'' }}"/>
    </p>
    <p>
      Address id:<br>
      <input name="address_id" value="{{ customer.address_id|default_if_none:'' }}"/>
    </p>
    <p>
      Active:<br>
      <input type="checkbox" name="active" value="{{ customer.active }}"/>
    </p>
    <p>
      <input type="submit" value="Create Customer"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/customers/show.html**

```
  <p>
    <strong>Store id</strong>
    {{ customer.store_id }}
  </p>
  <p>
    <strong>First name</strong>
    {{ customer.first_name }}
  </p>
  <p>
    <strong>Last name</strong>
    {{ customer.last_name }}
  </p>
  <p>
    <strong>Email</strong>
    {{ customer.email }}
  </p>
  <p>
    <strong>Address id</strong>
    {{ customer.address_id }}
  </p>
  <p>
    <strong>Active</strong>
    {{ customer.active }}
  </p>
  <p>
    <strong>Creation date</strong>
    {{ customer.create_date|date:"Y-m-d" }} {{ customer.create_date|time:"H:i:s" }} UTC
  </p>
  <p>
    <strong>Last update</strong>
    {{ customer.last_update|date:"Y-m-d" }} {{ customer.last_update|time:"H:i:s" }} UTC
  </p>

  <a href="/customers/update/{{ customer.id }}">Edit</a> |
  <a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/customers/update.html**

```
<h1>Editing customer</h1>
  <form method="post">
    <p>
      Store id<br>
      <input name="store_id" value="{{ customer.store_id }}"/>
    </p>
    <p>
      First name<br>
      <input name="first_name" value="{{ customer.first_name }}"/>
    </p>
    <p>
      Last name<br>
      <input name="last_name" value="{{ customer.last_name }}"/>
    </p>
    <p>
      Email<br>
      <input name="email" value="{{ customer.email }}"/>
    </p>
    <p>
      Address id<br>
      <input name="address_id" value="{{ customer.address_id }}"/>
    </p>
    <p>
      Active<br>
      <input name="active" value="{{ customer.active }}"/>
    </p>
    <p>
      <input type="submit" value="Update Customer"/>
    </p>
  </form>
  <a href="/customers/show/{{ customer.id }}">Show</a> |
  <a href="{% url action="index" %}">Back</a>
```

==

###Films
==

**Edit: src/view/films/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing films</h1>
      <table>
        <thead>
          <tr>
            <th>Title</th>
            <th>Description</th>
            <th>Release year</th>
            <th>Language id</th>
            <th>Rental duration</th>
            <th>Rental rate</th>
            <th>Length</th>
            <th>Replacement cost</th>
            <th>Rating</th>
            <th>Special features</th>
            <th>Last updated</th>
          </tr>
        </thead>

        <tbody>
          {% for film in films %}
            <tr>
              <td>{{ film.title }}</td>
              <td>{{ film.description }}</td>
              <td>{{ film.release_year }}</td>
              <td>{{ film.language_id }}</td>
              <td>{{ film.rental_duration }}</td>
              <td>{{ film.rental_rate }}</td>
              <td>{{ film.length }}</td>
              <td>{{ film.replacement_cost }}</td>
              <td>{{ film.rating }}</td>
              <td>{{ film.special_features }}</td>
              <td>{{ film.last_update|date:"Y-m-d" }} {{ film.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/films/show/{{ film.id }}">Show</a></td>
              <td><a href="/films/update/{{ film.id }}">Edit</a></td>
              <td><a href="/films/delete/{{ film.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Film</a>
  </body>
</html>
```

**Edit: src/view/films/create.html**

```
{% if errors %}
  <ol>
    {% for error in errors %}
    <li><font color=red>{{ error }}</font>
    {% endfor %}
  </ol>
{% endif %}

<form method="post">
  <p>
    Title:<br>
    <input name="title" value="{{ film.title|default_if_none:'' }}"/>
  </p>
  <p>
    Description:<br>
    <input name="description" value="{{ film.description|default_if_none:'' }}"/>
  </p>
  <p>
    Release year:<br>
    <input name="release_year" value="{{ film.release_year|default_if_none:'' }}"/>
  </p>
  <p>
    Language id:<br>
    <input name="language_id" value="{{ film.language_id|default_if_none:'' }}"/>
  </p>
  <p>
    Rental duration:<br>
    <input name="rental_duration" value="{{ film.rental_duration|default_if_none:'' }}"/>
  </p>
  <p>
    Rental rate:<br>
    <input name="rental_rate" value="{{ film.rental_rate|default_if_none:'' }}"/>
  </p>
  <p>
    Length:<br>
    <input name="length" value="{{ film.length|default_if_none:'' }}"/>
  </p>
  <p>
    Replacement cost:<br>
    <input name="replacement_cost" value="{{ film.replacement_cost|default_if_none:'' }}"/>
  </p>
  <p>
    Rating:<br>
    <input name="rating" value="{{ film.rating|default_if_none:'' }}"/>
  </p>
  <p>                                                                                 
    Special features:<br>
    <input name="special_features" value="{{ film.special_features|default_if_none:'' }}"/>
  </p>
  <p>
    <input type="submit" value="Create Film"/>
  </p>
</form>
<a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/films/show.html**

```
  <p>
    <strong>Title</strong>
    {{ film.title }}
  </p>
  <p>
    <strong>Description</strong>
    {{ film.description }}
  </p>
  <p>
    <strong>Release year</strong>
    {{ film.release_year }}
  </p>
  <p>
    <strong>Language id</strong>
    {{ film.language_id }}
  </p>
  <p>
    <strong>Rental duration</strong>
    {{ film.rental_duration }}
  </p>
  <p>
    <strong>Rental rate</strong>
    {{ film.rental_rate }}
  </p>
  <p>
    <strong>Length</strong>
    {{ film.length }}
  </p>
  <p>
    <strong>Replacement cost</strong>
    {{ film.replacement_cost }}
  </p>
  <p>
    <strong>Rating</strong>
    {{ film.rating }}
  </p>
  <p>
    <strong>Special features</strong>
    {{ film.special_features }}
  </p>
  <p>
    <strong>Last update:</strong>
    {{ film.last_update|date:"Y-m-d" }} {{ film.last_update|time:"H:i:s" }} UTC
  </p>

  <a href="/films/update/{{ film.id }}">Edit</a> |
  <a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/films/update.html**

```
<h1>Editing film</h1>
  <form method="post">
    <p>
      Title<br>
      <input name="title" value="{{ film.title }}"/>
    </p>
    <p>
      Description<br>
      <input name="description" value="{{ film.description }}"/>
    </p>
    <p>
      Release year<br>
      <input name="release_year" value="{{ film.release_year }}"/>
    </p>
    <p>
      Language id<br>
      <input name="language_id" value="{{ film.language_id }}"/>
    </p>
    <p>
      Rental duration<br>
      <input name="rental_duration" value="{{ film.rental_duration }}"/>
    </p>
    <p>
      Rental rate<br>
      <input name="rental_rate" value="{{ film.rental_rate }}"/>
    </p>
    <p>
      Length<br>
      <input name="length" value="{{ film.length }}"/>
    </p>
    <p>
      Replacement cost<br>
      <input name="replacement_cost" value="{{ film.replacement_cost }}"/>
    </p>
    <p>
      Rating<br>
      <input name="rating" value="{{ film.rating }}"/>
    </p>
    <p>
      Special features<br>
      <input name="special_features" value="{{ film.special_features }}"/>
    </p>
    <p>
      <input type="submit" value="Update Film"/>
    </p>
  </form>
  <a href="/films/show/{{ film.id }}">Show</a> |
  <a href="{% url action="index" %}">Back</a>
```

==

###Filmtexts
==

**Edit: src/view/filmtexts/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing film texts</h1>
      <table>
        <thead>
          <tr>
            <th>Title</th>
            <th>Description</th>
          </tr>
        </thead>

        <tbody>
          {% for filmtext in filmtexts %}
            <tr>
              <td>{{ filmtext.title }}</td>
              <td>{{ filmtext.description }}</td>
              <td><a href="/filmtexts/show/{{ filmtext.id }}">Show</a></td>
              <td><a href="/filmtexts/update/{{ filmtext.id }}">Edit</a></td>
              <td><a href="/filmtexts/delete/{{ filmtext.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Film Text</a>
  </body>
</html>
```

**Edit: src/view/filmtexts/create.html**

```
<h1>Create a new Film text</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      Title:<br>
      <input name="title" value="{{ filmtext.title|default_if_none:'' }}"/>
    </p>
    <p>
      Description:<br>
      <input name="description" value="{{ filmtext.description|default_if_none:'' }}"/>
    </p>  
    <p>
      <input type="submit" value="Create Film text"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/filmtexts/show.html**

```
  <p>
    <strong>Title</strong>
    {{ filmtext.title }}
  </p>
  <p>
    <strong>Description</strong>
    {{ filmtext.description }}
  </p>

  <a href="/filmtexts/update/{{ filmtext.id }}">Edit</a> |
  <a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/filmtexts/update.html**

```
<h1>Editing film text</h1>
  <form method="post">
    <p>
      Title<br>
      <input name="title" value="{{ filmtext.title }}"/>
    </p>
    <p>
      Description<br>
      <input name="description" value="{{ filmtext.description }}"/>
    </p>  
    <p>
      <input type="submit" value="Update Film Text"/>
    </p>
  </form>
  <a href="/filmtexts/show/{{ filmtext.id }}">Show</a> |
  <a href="{% url action="index" %}">Back</a>
```

==

###Inventories
==

**Edit: src/view/inventories/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing inventories</h1>
      <table>
        <thead>
          <tr>
            <th>Film id</th>
            <th>Store id</th>
            <th>Last Update</th>
          </tr>
        </thead>

        <tbody>
          {% for inventory in inventories %}
            <tr>
              <td>{{ inventory.film_id }}</td>
              <td>{{ inventory.store_id }}</td>
              <td>{{ inventory.last_update|date:"Y-m-d" }} {{ inventory.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/inventories/show/{{ inventory.id }}">Show</a></td>
              <td><a href="/inventories/update/{{ inventory.id }}">Edit</a></td>
              <td><a href="/inventories/delete/{{ inventory.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Inventory</a>
  </body>
</html>
```

**Edit: src/view/inventories/create.html**

```
<h1>Create a new Inventory</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      Film id:<br>
      <input name="film_id" value="{{ inventory.film_id|default_if_none:'' }}"/>
    </p>
    <p>
      Store id:<br>
      <input name="store_id" value="{{ inventory.store_id|default_if_none:'' }}"/>
    </p>
    <p>
      <input type="submit" value="Create Inventory"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/inventories/show.html**

```
  <p>
    <strong>Film id</strong>
    {{ inventory.film_id }}
  </p>
  <p>
    <strong>Store id</strong>
    {{ inventory.store_id }}
  </p>
  <p>
    <strong>Last update</strong>
    {{ inventory.last_update|date:"Y-m-d" }} {{ inventory.last_update|time:"H:i:s" }} UTC
  </p>

  <a href="/inventories/update/{{ inventory.id }}">Edit</a> |
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/inventories/update.html**

```
<h1>Editing inventory</h1>
  <form method="post">
    <p>
      Film id<br>
      <input name="film_id" value="{{ inventory.film_id }}"/>
    </p>
    <p>
      Store id<br>
      <input name="store_id" value="{{ inventory.store_id }}"/>
    </p>
    <p>
      <input type="submit" value="Update Inventory"/>
    </p>
  </form>
  <a href="/inventories/show/{{ inventory.id }}">Show</a> |
  <a href="{% url action="index" %}">Back</a>
```

==

###Languages
==

**Edit: src/view/languages/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing languages</h1>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Last Update</th>
          </tr>
        </thead>

        <tbody>
          {% for language in languages %}
            <tr>
              <td>{{ language.name }}</td>
              <td>{{ language.last_update|date:"Y-m-d" }} {{ language.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/languages/show/{{ language.id }}">Show</a></td>
              <td><a href="/languages/update/{{ language.id }}">Edit</a></td>
              <td><a href="/languages/delete/{{ language.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Language</a>
  </body>
</html>
```

**Edit: src/view/languages/create.html**

```
<h1>Create a new Language</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      Name:<br>
      <input name="name" value="{{ language.name|default_if_none:'' }}"/>
    </p>
    <p>
      <input type="submit" value="Create Language"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/languages/show.html**

```
  <p>
    <strong>Name</strong>
    {{ language.name }}
  </p>
  <p>
    <strong>Last update:</strong>
    {{ language.last_update|date:"Y-m-d" }} {{ language.last_update|time:"H:i:s" }} UTC
  </p>

  <a href="/languages/update/{{ language.id }}">Edit</a> |
  <a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/languages/update.html**

```
<h1>Editing language</h1>
  <form method="post">
    <p>
      Name<br>
      <input name="name" value="{{ language.name }}"/>
    </p>
    <p>
      <input type="submit" value="Update Language"/>
    </p>
  </form>
  <a href="/languages/show/{{ language.id }}">Show</a> |
  <a href="{% url action="index" %}">Back</a>
```

==

###Payments
==

**Edit: src/view/payments/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing payments</h1>
      <table>
        <thead>
          <tr>
            <th>Customer id</th>
            <th>Staff id</th>
            <th>Rental id</th>
            <th>Amount</th>
            <th>Payment date</th>
            <th>Last updated</th>
          </tr>
        </thead>

        <tbody>
          {% for payment in payments %}
            <tr>
              <td>{{ payment.customer_id }}</td>
              <td>{{ payment.staff_id }}</td>
              <td>{{ payment.rental_id }}</td>
              <td>{{ payment.amount }}</td>
              <td>{{ payment.payment_date|date:"Y-m-d" }} {{ payment.payment_date|time:"H:i:s" }} UTC</td>
              <td>{{ payment.last_update|date:"Y-m-d" }} {{ payment.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/payments/show/{{ payment.id }}">Show</a></td>
              <td><a href="/payments/update/{{ payment.id }}">Edit</a></td>
              <td><a href="/payments/delete/{{ payment.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Payment</a>
  </body>
</html>
```

**Edit: src/view/payments/create.html**

```
<h1>Create a new Payment</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      Customer id:<br>
      <input name="customer_id" value="{{ payment.customer_id|default_if_none:'' }}"/>
    </p>
    <p>
      Staff id:<br>
      <input name="staff_id" value="{{ payment.staff_id|default_if_none:'' }}"/>
    </p>
    <p>
      Rental id:<br>
      <input name="rental_id" value="{{ payment.rental_id|default_if_none:'' }}"/>
    </p>
    <p>
      Amount:<br>
      <input name="amount" value="{{ payment.amount|default_if_none:'' }}"/>
    </p>
    <p>
      <input type="submit" value="Create Payment"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/payments/show.html**

```
  <p>
    <strong>Customer id</strong>
    {{ payment.customer_id }}
  </p>
  <p>
    <strong>Staff id</strong>
    {{ payment.staff_id }}
  </p>
  <p>
    <strong>Rental id</strong>
    {{ payment.rental_id }}
  </p>
  <p>
    <strong>Amount</strong>
    {{ payment.amount }}
  </p>
  <p>
    <strong>Payment date</strong>
    {{ payment.payment_date|date:"Y-m-d" }} {{ payment.payment_date|time:"H:i:s" }} UTC
  </p>
  <p>
    <strong>Last update:</strong>
    {{ payment.last_update|date:"Y-m-d" }} {{ payment.last_update|time:"H:i:s" }} UTC
  </p>

  <a href="/payments/update/{{ payment.id }}">Edit</a> |
  <a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/payments/update.html**

```
<h1>Editing payment</h1>
  <form method="post">
    <p>
      Customer id<br>
      <input name="customer_id" value="{{ payment.customer_id }}"/>
    </p>
    <p>
      Staff id<br>
      <input name="staff_id" value="{{ payment.staff_id }}"/>
    </p>
    <p>
      Rental id<br>
      <input name="rental_id" value="{{ payment.rental_id }}"/>
    </p>
    <p>
      Amount<br>
      <input name="amount" value="{{ payment.amount }}"/>
    </p>
    <p>
    <p>
      <input type="submit" value="Update Payment"/>
    </p>
  </form>
  <a href="/payments/show/{{ payment.id }}">Show</a> |
  <a href="{% url action="index" %}">Back</a>
```

==

###Rentals
==

**Edit: src/view/rentals/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing rentals</h1>
      <table>
        <thead>
          <tr>
            <th>Rental date</th>
            <th>Inventory id</th>
            <th>Customer id</th>
            <th>Return date</th>
            <th>Staff id</th>
            <th>Last updated</th>
          </tr>
        </thead>

        <tbody>
          {% for rental in rentals %}
            <tr>
              <td>{{ rental.rental_date|date:"Y-m-d" }} {{ rental.rental_date|time:"H:i:s" }} UTC</td>
              <td>{{ rental.inventory_id }}</td>
              <td>{{ rental.customer_id }}</td>
              <td>{{ rental.return_date|date:"Y-m-d" }} {{ rental.return_date|time:"H:i:s" }} UTC</td>
              <td>{{ rental.staff_id }}</td>
              <td>{{ rental.last_update|date:"Y-m-d" }} {{ rental.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/rentals/show/{{ rental.id }}">Show</a></td>
              <td><a href="/rentals/update/{{ rental.id }}">Edit</a></td>
              <td><a href="/rentals/delete/{{ rental.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Rental</a>
  </body>
</html>
```

**Edit: src/view/rentals/create.html**

```
<h1>Create a new Rental</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      Inventory id:<br>
      <input name="inventory_id" value="{{ rental.inventory_id|default_if_none:'' }}"/>
    </p>
    <p>
      Customer id:<br>
      <input name="customer_id" value="{{ rental.customer_id|default_if_none:'' }}"/>
    </p>
    <p>
      Staff Id:<br>
      <input name="staff_id" value="{{ rental.staff_id|default_if_none:'' }}"/>
    </p>
    <p>
      <input type="submit" value="Create Rental"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/rentals/show.html**

```
  <p>
    <strong>Rental date</strong>
    {{ rental.rental_date|date:"Y-m-d" }} {{ rental.rental_date|time:"H:i:s" }} UTC
  </p>
  <p>
    <strong>Inventory id</strong>
    {{ rental.inventory_id }}
  </p>
  <p>
    <strong>Customer id</strong>
    {{ rental.customer_id }}
  </p>
  <p>
    <strong>Return date</strong>
    {{ rental.return_date|date:"Y-m-d" }} {{ rental.return_date|time:"H:i:s" }} UTC
  </p>
  <p>
    <strong>Staff id</strong>
    {{ rental.staff_id }}
  </p>
  <p>
    <strong>Last update:</strong>
    {{ rental.last_update|date:"Y-m-d" }} {{ rental.last_update|time:"H:i:s" }} UTC
  </p>

  <a href="/rentals/update/{{ rental.id }}">Edit</a> |
  <a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/rentals/update.html**

```
<h1>Editing Rental</h1>
  <form method="post">
    <p>
      Inventory id<br>
      <input name="inventory_id" value="{{ rental.inventory_id }}"/>
    </p>
    <p>
      Customer id<br>
      <input name="customer_id" value="{{ rental.customer_id }}"/>
    </p>
    <p>
      Staff id<br>
      <input name="staff_id" value="{{ rental.staff_id }}"/>
    </p>
    <p>
      <input type="submit" value="Update Rental"/>
    </p>
  </form>
  <a href="/rentals/show/{{ rental.id }}">Show</a> |
  <a href="{% url action="index" %}">Back</a>
```

==

###Staffs
==

**Edit: src/view/staffs/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing Staff</h1>
      <table>
        <thead>
          <tr>
            <th>First Namne</th>
            <th>Last Name</th>
            <th>Address id</th>
            <th>Email</th>
            <th>Store id</th>
            <th>Active</th>
            <th>Username</th>
            <th>Password</th>
            <th>Last updated</th>
          </tr>
        </thead>

        <tbody>
          {% for staff in staffs %}
            <tr>
              <td>{{ staff.first_name }}</td>
              <td>{{ staff.last_name }}</td>
              <td>{{ staff.address_id }}</td>
              <td>{{ staff.email }}</td>
              <td>{{ staff.store_id }}</td>
              <td>{{ staff.active }}</td>
              <td>{{ staff.username }}</td>
              <td>{{ staff.password }}</td>
              <td>{{ staff.last_update|date:"Y-m-d" }} {{ staff.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/staffs/show/{{ staff.id }}">Show</a></td>
              <td><a href="/staffs/update/{{ staff.id }}">Edit</a></td>
              <td><a href="/staffs/delete/{{ staff.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Staff</a>
  </body>
</html>
```

**Edit: src/view/staffs/create.html**

```
<h1>Create a new Staff</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      First Name:<br>
      <input name="first_name" value="{{ staff.first_name|default_if_none:'' }}"/>
    </p>
    <p>
      Last Name:<br>
      <input name="last_name" value="{{ staff.last_name|default_if_none:'' }}"/>
    </p>
    <p>
      Address id:<br>
      <input name="address_id" value="{{ staff.address_id|default_if_none:'' }}"/>
    </p>
    <p>
      Email:<br>
      <input name="email" value="{{ staff.email|default_if_none:'' }}"/>
    </p>
    <p>
      Store id:<br>
      <input name="store_id" value="{{ staff.store_id|default_if_none:'' }}"/>
    </p>
    <p>
      Active:<br>
      <input type="checkbox" name="active" value="{{ staff.active|default_if_none:'' }}"/>
    </p>
    <p>
      Username:<br>
      <input name="username" value="{{ staff.username|default_if_none:'' }}"/>
    </p>
    <p>
      Password:<br>
      <input name="password" value="{{ staff.password|default_if_none:'' }}"/>
    </p>
    <p>
      <input type="submit" value="Create Staff"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/staffs/show.html**

```
<p>
  <strong>First Name:</strong>
  {{ staff.first_name }}
</p>
<p>
  <strong>Last Name:</strong>
  {{ staff.last_name }}
</p>
<p>
  <strong>Address id:</strong>
  {{ staff.address_id }}
</p>
<p>
  <strong>Email:</strong>
  {{ staff.email }}
</p>
<p>
  <strong>Store id:</strong>
  {{ staff.store_id }}
</p>
<p>
  <strong>Active:</strong>
  {{ staff.active }}
</p>
<p>
  <strong>Username:</strong>
  {{ staff.username }}
</p>
<p>
  <strong>Password:</strong>
  {{ staff.password }}
</p>
<p>
  <strong>Last update:</strong>
  {{ staff.last_update|date:"Y-m-d" }} {{ staff.last_update|time:"H:i:s" }} UTC
</p>

<a href="/staffs/update/{{ staff.id }}">Edit</a> |
<a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/staffs/update.html**

```
<h1>Editing staff</h1>
<form method="post">
  <p>
    First name<br>
    <input name="first_name" value="{{ staff.first_name }}"/>
  </p>
  <p>
    Last name<br>
    <input name="last_name" value="{{ staff.last_name }}"/>
  </p>  
  <p>
    Address id<br>
    <input name="address_id" value="{{ staff.address_id }}"/>
  </p>
  <p>
    Email<br>
    <input name="email" value="{{ staff.email }}"/>
  </p>
  <p>
    Store id<br>
    <input name="store_id" value="{{ staff.store_id }}"/>
  </p>
  <p>
    Active<br>
    <input type="checkbox" name="active" value="{{ staff.active }}"/>
  </p>
  <p>
    Username<br>
    <input name="username" value="{{ staff.username }}"/>
  </p>
  <p>
    Password<br>
    <input name="password" value="{{ staff.password }}"/>
  </p>
  <p>
    <input type="submit" value="Update Staff"/>
  </p>
</form>
<a href="/staffs/show/{{ staff.id }}">Show</a> |
<a href="{% url action="index" %}">Back</a>
```

==

###Stores
==

**Edit: src/view/stores/index.html**

```
<html>
  <head>
  </head>
  <body>
      <h1>Listing stores</h1>
      <table>
        <thead>
          <tr>
            <th>Address id</th>
            <th>Last Update</th>
          </tr>
        </thead>

        <tbody>
          {% for store in stores %}
            <tr>
              <td>{{ store.address_id }}</td>
              <td>{{ store.last_update|date:"Y-m-d" }} {{ store.last_update|time:"H:i:s" }} UTC</td>
              <td><a href="/stores/show/{{ store.id }}">Show</a></td>
              <td><a href="/stores/update/{{ store.id }}">Edit</a></td>
              <td><a href="/stores/delete/{{ store.id }}">Destroy</a></td>
            </tr>
          {% endfor %}
        </tbody>
      </table>
      <br>
      <a href="{% url action="create" %}">New Store</a>
  </body>
</html>
```

**Edit: src/view/stores/create.html**

```
<h1>Create a new Store</h1>
  {% if errors %}
    <ol>
      {% for error in errors %}
        <li><font color=red>{{ error }}</font>
      {% endfor %}
    </ol>
  {% endif %}

  <form method="post">
    <p>
      Address id:<br>
      <input name="address_id" value="{{ store.address_id|default_if_none:'' }}"/>
    </p>
    <p>
      <input type="submit" value="Create Store"/>
    </p>
  </form>
  <a href="{% url action="index" %}">Back</a>
```

**Edit: src/view/stores/show.html**

```
  <p>
    <strong>Address id</strong>
    {{ store.address_id }}
  </p>
  <p>
    <strong>Last update:</strong>
    {{ store.last_update|date:"Y-m-d" }} {{ store.last_update|time:"H:i:s" }} UTC
  </p>

  <a href="/stores/update/{{ store.id }}">Edit</a> |
  <a href="{% url action="index" %}">Back</a> 
```

**Edit: src/view/stores/update.html**

```
<h1>Editing store</h1>
  <form method="post">
    <p>
      Address id<br>
      <input name="address_id" value="{{ store.address_id }}"/>
    </p>
    <p>
      <input type="submit" value="Update Store"/>
    </p>
  </form>
  <a href="/stores/show/{{ store.id }}">Show</a> |
  <a href="{% url action="index" %}">Back</a>
```

==
###Create the home controller and index views
==

Now we need to create a page that links all the above together.

>touch src/controller/cb_sakila_home_controller.erl

Yes I realise that home is not pluralised, this is because it does not have a model and as such is not in the database, so the plural rule does not apply here.

Then edit: src/controller/cb_sakila_home_controller.erl

```
-module(cb_sakila_home_controller, [Req]).
-compile(export_all).

index('GET', []) -> {ok, []}.
```

We are only putting in one method, called index, which means when http://localhost:8001/home/index is called it will go to this controller and use the index action, which just returns ok because there is nothing to set up for the index page. It will then load up the index page from src/view/home/index.html and send it back to the browser.

So we also need to create the template. First create the new directory:

```
mkdir src/view/home
```

Now we need to create the index file:

>touch src/view/home/index.html

Then edit it:

```
<h1>Index page</h1>
<ul>
  <li><a href="/actors/index">Actors</a></li>
  <li><a href="/addresses/index">Addresses</a></li>
  <li><a href="/categories/index">Categories</a></li>
  <li><a href="/cities/index">Cities</a></li>
  <li><a href="/countries/index">Countries</a></li>
  <li><a href="/customers/index">Customers</a></li>
  <li><a href="/films/index">Films</a></li>
  <li><a href="/filmtexts/index">Film Texts</a></li>
  <li><a href="/inventories/index">Inventories</a></li>
  <li><a href="/languages/index">Languages</a></li>
  <li><a href="/payments/index">Payments</a></li>
  <li><a href="/rentals/index">Rentals</a></li>
  <li><a href="/staffs/index">Staff</a></li>
  <li><a href="/stores/index">Stores</a></li>
</ul>
```

You can now go to: http://localhost:8001/home/index and you should see the above. 

==
###Set the root route
==

We also need to set the root to point to home/index, edit: priv/cb_sakila.routes and add the following:

```
% Front page
 {"/", [{controller, "home"}, {action, "index"}]}.
```

We can now navigate to: http://localhost:8001/ and we should see the index file.

==
###Getting Production Ready
==

First we need to compile the project and then we need to start it in production mode.

**Compile the application**

To compile the app, change directory to the app and run the following command:

```
./rebar compile
```

This should produce a .beam file in the directory ebin/

**Start in production mode**

To run in production mode, use the following command:

```
./init.sh start
```

==
###The End
==

Thanks for reading, hope you learned something :)

Darren.












