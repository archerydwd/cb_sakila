# Chicago Boss cb_sakila Application

I built this app with the Chicago Boss framework to be used as part of a series of applications that I will be 
performing tests on. This is a Chicago Boss version of the Ruby on Rails ror_sakila application: https://github.com/archerydwd/ror_sakila.

I am going to be performing tests on this app using some load testing tools such as Tsung, J-Meter and Basho bench. 

Once I have tested this application and the Ruby on Rails verison of it, I will publish the results, which can then be used as a benchmark for others to use when trying to choose a framework.

You can build this app using a framework of your choosing and then follow the testing mechanisms that I will describe and then compare the results against my benchmark to get an indication of performance levels of your chosen framework.

###Installing Erlang and Chicago Boss

At the time of writing Erlang was at version: 17.4 and Chicago Boss at version: 0.8.12

**Install Erlang on osx using Homebrew:**
```
brew install erlang
```
**Installing Erlang on Linux:**
```
sudo apt-get update
sudo apt-get erlang
```
**Install Chicago Boss:**

>Download the latest release from the Chicago Boss site: http://www.chicagoboss.org

*Compile it*
```
cd ChicagoBoss
make
```

**Working with the existing database**

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

**Create the database**

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

**Create the cb_sakila app**

```
make app PROJECT=cb_sakila
cd ../blog
```

**Starting the development server**

To start the dev server:

```
./init-dev.sh
```

To stop the development server:

```
ctrl + c
```

**Pointing the app to the database**

Edit the boss.config under the Database header:

```
{db_host, "localhost"},
% {db_port, 1978},
{db_adapter, mysql},
{db_username, "root"},
{db_password, "secret"},
{db_database, "cb_sakila"},
```

**Create the Models**

Ok we are going to create all of the models that we will need in this section. 
* First thing to note is that the name of the file should not be plural, eg: the model for actors should be actor.erl.
* Inside any model file. The first line has to be -module(name, [Id, Attributes, FilmId]).

*Let me explain,* name should be the same as the file name. Id always should be first in the attribute list, this makes boss create the id itself. Also note in the database the id field has to be named 'id' and not actor_id or anything else like this. Then after Id, you can put the other attributes, but a field named actor_name should be named ActorName in the attributes list. Forign keys should be named here too, in camel case format alse.

* The second line should be -compile(export_all). export_all means export all the functions that are in this module. To make them available outside of the module.
* -belongs_to(othermodel) means that there is an association between this model and the one in the brackets. In the model in the brackets, you must put a -has() with this model in its brackets.
* -has(othermodel) means that there is an association between this model and the one in the brackets. This goes into the model that would be in the brackets of the -belongs_to part in the other model.

Anyway lets get to it.

*Create the model for actors:*

>touch src/model/actor.erl

Now edit: src/model/actor.erl

```
-module(actor, [Id, FirstName, LastName, LastUpdate]).
-compile(export_all).
```

*Create the model for addresses:*

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

*Create the model for categories:*

>touch src/model/category.erl

Now edit: src/model/category.erl

```
-module(category, [Id, Name, LastUpdate]).
-compile(export_all).
```

*Create the model for cities:*

>touch src/model/city.erl

Now edit: src/model/city.erl

```
-module(city, [Id, City, CountryId, LastUpdate]).
-compile(export_all).
-belongs_to(country).
-has({addresses, many}).
```

*Create the model for countries:*

>touch src/model/country.erl

Now edit: src/model/country.erl

```
-module(country, [Id, Country, LastUpdate]).
-compile(export_all).
-has({cities, many}).
```

*Create the model for customers:*

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

*Create the model for films:*

>touch src/model/film.erl

Now edit: src/model/film.erl

```
-module(film, [Id, Title, Description, ReleaseYear, LanguageId, RentalDuration, RentalRate, Length, ReplacementCost, Rating, SpecialFeatures, LastUpdate]).
-compile(export_all).
-belongs_to(language).
-has({inventories, many}).
```

*Create the model for filmtexts:*

>touch src/model/filmtext.erl

Now edit: src/model/filmtext.erl

```
-module(filmtext, [Id, Title, Description]).
-compile(export_all).
```

*Create the model for inventories:*

>touch src/model/inventory.erl

Now edit: src/model/inventory.erl

```
-module(inventory, [Id, FilmId, StoreId, LastUpdate]).
-compile(export_all).
-belongs_to(film).
-belongs_to(store).
-has({rentals, many}).
```

*Create the model for languages:*

>touch src/model/language.erl

Now edit: src/model/language.erl

```
-module(language, [Id, Name, LastUpdate]).
-compile(export_all).
-has({films, many}).
```

*Create the model for payments:*

>touch src/model/payment.erl

Now edit: src/model/payment.erl

```
-module(payment, [Id, CustomerId, StaffId, RentalId, Amount, PaymentDate, LastUpdate]).
-compile(export_all).
-belongs_to(customer).
-belongs_to(staff).
-belongs_to(rental).
```

*Create the model for rentals:*

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

*Create the model for staffs:*

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

*Create the model for stores:*

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

**Create the controllers**





**Create the views**




**Create the home controller and index view**




**Set the root route**



**The End**















