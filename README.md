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

Firstly I am creating this application with the sakila_dump.sql file, which you can get from here: . Its included in the source for this repository.


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


















