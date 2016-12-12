# A bits of theory

In this post I am going to show how you can use Sparrow to test 
mojolicious applications.


Sparrow approach to test things differ from convenient unit tests approach, practically this means:

* a tested code is treated as black box rather than unit test way where you relies deeply on inner application
structure

* a sparrow test suites are not a part of CPAN distribution ( the one you keep under t/* ) and gets
run NOT during distribution install (`make test` stage)

* sparrow test suite code is decoupled from tested application code and is better to be treated
as third party tests for your application

* sparrow tests suites have it's own life cycle and get released _in parallel_ with tested application
 

Ok, let's go to the practical example.

# Simple test

A Mojolicious comes with some handy tools to invoke a http requests against web application.

Consider simple mojolicious code:


    #!/usr/bin/env perl
    
    use Mojolicious::Lite;
    
    get '/' => {text => 'hello world'};
    
    app->start;
    

Now we can quickly test a `GET /` route with help of mojolicious `get` command:



    ./app.pl get /
    [Sun Dec 11 17:23:38 2016] [debug] GET "/"
    [Sun Dec 11 17:23:38 2016] [debug] 200 OK (0.000456s, 2192.982/s)
    hello world    

That's ok. This is going to be a base for out first sparrow test:


    $ nano story.bash

    $project_root_dir/app.pl get /


    $ nano story.check

    hello world


    $ strun
    
    / started
    
    [Sun Dec 11 17:45:28 2016] [debug] GET "/"
    [Sun Dec 11 17:45:28 2016] [debug] 200 OK (0.000469s, 2132.196/s)
    hello world
    ok      scenario succeeded
    ok      output match 'hello world'
    STATUS  SUCCEED
    
What we have done here.

* created a story to run `GET /` against mojolicious application - file named story.bash
* created a story check file to validate data returned from http request.
* finally run a test suite ( story ) with the help of so called story runner - strun

More about stories and check files could be found at [Outthentic](https://metacpan.org/pod/Outthentic) - a module for execution sparrow scripts.


Consider a negative here, when test fails. For this let's change a check file to express we need 
another string returned from calling `GET /` route:

 
    $ nano story.check

    hello sparrow


    $ strun

    / started
    
    [Sun Dec 11 18:18:07 2016] [debug] GET "/"
    [Sun Dec 11 18:18:07 2016] [debug] 200 OK (0.001237s, 808.407/s)
    hello world
    ok      scenario succeeded
    not ok  output match 'hello sparrow'
    STATUS  FAILED (256)
    


# Splitting test suite on many simple tests


As your application grows it comprises many routes, let's how we organize our test suite layout
to test them all.


    $ cat app.pl

    #!/usr/bin/env perl
    
    use Mojolicious::Lite;
    
    get '/' => sub {
      my $c = shift;
      $c->render( text => 'welcome page')
    
    };
    
    get '/hello' => sub  {
    
      my $c = shift;
      $c->render( text => 'hello '.($c->param('name')))
    
    };
    
    get '/bye' => sub {
    
      my $c = shift;
      $c->render( text => 'bye '.($c->param('name')))
    
    };
    
    app->start;
    

Here is the story modules:


    $ mkdir -p modules/welcome-page modules/hello modules/buy
    $ echo 'welcome page' > modules/welcome-page/story.check
    $ echo 'hello sparrow' > modules/hello/story.check
    $ echo 'bye sparrow' > modules/bye/story.check
    $ echo '$project_root_dir/app.pl get /' > modules/welcome-page/story.bash
    $ echo '$project_root_dir/app.pl get /hello?name=sparrow' > modules/hello/story.bash
    $ echo '$project_root_dir/app.pl get /bye?name=sparrow' > modules/bye/story.bash


And main story-container to call them all:

    $ echo 'Smoke tests for app.pl' > meta.txt
    $ nano hook.bash

    run_story welcome-page
    run_story hello
    run_story bye


    $ strun

    / started
    
    Smoke tests for app.pl
    
    /modules/welcome-page/ started
    
    [Sun Dec 11 19:34:08 2016] [debug] GET "/"
    [Sun Dec 11 19:34:08 2016] [debug] Routing to a callback
    [Sun Dec 11 19:34:08 2016] [debug] 200 OK (0.00091s, 1098.901/s)
    welcome page
    ok      scenario succeeded
    ok      output match 'welcome page'
    
    /modules/hello/ started
    
    [Sun Dec 11 19:34:09 2016] [debug] GET "/hello"
    [Sun Dec 11 19:34:09 2016] [debug] Routing to a callback
    [Sun Dec 11 19:34:09 2016] [debug] 200 OK (0.000871s, 1148.106/s)
    hello sparrow
    ok      scenario succeeded
    ok      output match 'hello sparrow'
    
    /modules/bye/ started
    
    [Sun Dec 11 19:34:09 2016] [debug] GET "/bye"
    [Sun Dec 11 19:34:09 2016] [debug] Routing to a callback
    [Sun Dec 11 19:34:09 2016] [debug] 200 OK (0.001051s, 951.475/s)
    bye sparrow
    ok      scenario succeeded
    ok      output match 'bye sparrow'
    STATUS  SUCCEED
    


What we have done here.


* created 3 story modules each for a route (GET /, GET /hello , GET /buy )
* create a story-container to call a story modules
* run `strun` to execute test suite

More about story modules and story containers be found at [Outthentic](https://metacpan.org/pod/Outthentic) - a module for execution sparrow scripts.



# Parameterizing test suite

We hardcoded a string `sparrow` get passed as parameter to routes GET /hello and GET /buy.
Let's parametrize out test suite:


    $ nano modules/hello/story.bash

    name=$(story_var name)
    $project_root_dir/app.pl get '/hello?name='$name


    $ nano hook.bash

    run_story welcome-page
    run_story hello name Mojolicious
    run_story bye

And then run our test suite:


    # some output truncated ...

    /modules/hello/ started
    
    [Mon Dec 12 12:42:04 2016] [debug] GET "/hello"
    [Mon Dec 12 12:42:04 2016] [debug] Routing to a callback
    [Mon Dec 12 12:42:04 2016] [debug] 200 OK (0.000845s, 1183.432/s)
    hello Mojolicious
    ok      scenario succeeded
    not ok  output match 'hello sparrow'
    
    /modules/bye/ started
    


Obviously our test failed as we need to change a check list:


    $ nano modules/hello/story.check

    generator: [ "hello ".(story_var('name')) ]

Generators are way to create story check list in runtime. More on this read at [Outthentic](https://metacpan.org/pod/Outthentic) doc pages.


Ok, now let's make our name parameter configurable via configuration file


# Configuring test suites


Sparrow test suites maintain three well known configuration formats: 

* Config::General ( probably most convenient way to describe various configurations  )
* JSON
* YAML


Let's go with Config::General. As our example quite trivial the configuration won't be too complicated:


    $ nano suite suite.ini

    name Sparrow


    $ nano hook.bash

    name=$(config name)
    run_story welcome-page
    run_story hello name $name
    run_story bye name $name
    


We can even use nested configuration parameters:


    $ nano suite suite.ini

    <name>
      bird Sparrow
      animal Fox
    </name>


    $ nano hook.bash

    bird_name=$(config name.bird)
    animal_name=$(config name.animal)

    run_story welcome-page
    run_story hello name $bird_name
    run_story bye name $animal_name


And finally we can override parameters via command line:


    $ strun --param name.animal='Bear'


As I said we could use another configuration formats, like for example JSON:


    $ nano suite.json

    {

      "name" : {
        "bird"    : "sparrow",
        "animal"  : "bear"
      }
    }


    $ strun --json suite.json


# Processing output data

Sometimes we need to process output data to make it testable via Sparrow. It's very common when 
dealing with application emitting JSON:


    $ cat app.pl

    #!/usr/bin/env perl
    
    use Mojolicious::Lite;
    
    get '/' => sub {
      my $c = shift;
      $c->render( text => 'welcome page')
    
    };