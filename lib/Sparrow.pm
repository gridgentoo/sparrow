package Sparrow;

our $VERSION = '0.0.1';

1;

__END__

=encoding utf8


=head1 SYNOPSIS

Sparrow - L<swat|https://github.com/melezhik/swat> based monitoring tool.


=head1 FEATURES

=over

=item *

easy setup


=item *

console client to setup and run swat test suites


=item *

runs swat tests suites against web applications


=item *

ability to run tests remotely over rest API (TODO)


=item *

community and private plugins support


=back


=head1 DEPENDENCIES

git, bash


=head1 INSTALL

    # yes, you need a git
    sudo yum install git
    
    # minimal perl depencies, Carton only
    cpanm Sparrow


=head1 CONFIGURATION

    # this is root directory for sparrow stuff
    
    mkdir ~/sparrow


=head2 setup sparrow plugin list

In case you want to play with community plugins:

    curl https://raw.githubusercontent.com/melezhik/sparrow-hub/master/sparrow.list > ~/sparrow/sparrow.list

In case you want add some private plugins:

    echo 'my-cool-plugin git-remote-repo-url' >> ~/sparrow/sparrow.list

More about sparrow plugins is written below in L<sparrow plugins section|#sparrow-plugins>


=head1 USAGE


=head2 create a project

I<sparrow project $project_name create>

Create a sparrow project.

Sparrow project is a container for swat test suites and applications.

Sparrow project allow to run swat tests against different applications.

    sparrow project foo create

To get project info say this:

I<sparrow project $project_name info>

For example:

    sparrow project foo info


=head2 download and install swat plugins

I<sparrow plg install $plugin_name>

Sparrow plugin is a shareable swat test suite.

One could install sparrow plugin and then run related swat tests, see L<check_site|#run-swat-tests> action.

    sparrow plg install swat-nginx
    sparrow plg install swat-tomcat

To see available plugin list say this:

I<sparrow plg list --local>

To see installed plugin list say this:

I<sparrow plg list --local>

For example:

    sparrow plg swat-nginx info


=head2 link plugins to project

I<sparrow project $project_name add_plg $plugin_name>

Swat project could link to one or more plugins.

Linked plugins could be run against sites in swat project.

    sparrow project foo add_plg nginx
    sparrow project foo add_plg tomcat


=head2 link sites to project

I<sparrow project $project_name add_site $site_name $base_url>

Sparrow site is a abstraction of web application to run swat tests against.

Site's $base_url parameter is root http URL to send http requests to.

$Base_url should be curl compliant. Examples:

    sparrow project foo add_site nginx_proxy http://127.0.0.1
    sparrow project foo add_site tomcat_app 127.0.0.1:8080
    sparrow project foo add_site tomcat_app my.host/foo/bar


=head2 run swat tests

I<sparrow project $project_name check_site $site_name $plugin_name>

Once sparrow project is configured and has some  sites and plugins one could start running swat test suites:

    # run swat-nginx test suite for application nginx_proxy
    sparrow project foo check_site nginx_proxy swat-nginx
    
    # run swat-tomcat test suite for application tomcat_app
    sparrow project foo check_site tomcat_app swat-tomcat


=head2 customize swat settings for site

NOT IMPLIMENTED YET.

I<sparrow project $project_name swat_setup $site_name $path_to_swat_ini_file>

Swat_setup action allow to customize swat settings, using swat.ini file format.

This command setups L<swat ini file|https://github.com/melezhik/swat#swat-ini-files> for given site.

    cat /path/to/swat.ini
    
        port=88
        prove_options='-sq'    
    
    sparrow project foo swat_setup nginx_proxy /path/to/swat.ini

More information in swat ini files syntax could be found here - L<https://github.com/melezhik/swat#swat-ini-files|https://github.com/melezhik/swat#swat-ini-files>


=head2 run swat tests remotely

NOT IMPLIMENTED YET.

I<GET /$project_name/check_site/$site_name/$plugin_name>

Sparrow rest API allow to run swat test suites remotely over http.

    # runs sparrow rest API daemon
    sparrowd
    
    # runs swat tests via http call
    curl http://127.0.0.1:5090/foo/check_site/nginx_proxy/nginx


=head1 SPARROW PLUGINS

Sparrow plugins are shareable swat test suites installed from remote git repositories.

No sparrow plugins installed by default. There is two alternative for you:


=head1 COMMUNITY SPARROW PLUGINS

Community sparrow plugins are public plugins listed at L<https://github.com/melezhik/sparrow-hub|https://github.com/melezhik/sparrow-hub>

Sparrow community members are encouraged to create a useful plugins and have them listed here.


=head1 PRIVATE SPARROW PLUGINS

Private sparrow plugins are plugins you create for yourself and don't want to share with others.
As with community plugins private plugins have to be listed.


=head1 SPARROW PLUGINS LIST

Sparrow plugins list (SPL) is a text file, named I<sparrow.list> with lines of following format:

I<$plugin_name $git_repo_url>

Where:

=over

=item *

gitI<repo>url is git repository URL


=item *

plugin_name is name of swat plugin.


=back

For example:

    swat-yars https://github.com/melezhik/swat-yars.git
    metacpan https://github.com/CPAN-API/metacpan-monitoring.git

To start using sparrow plugins just create SPL file and place it at ~/sparrow/sparrow.list:

    touch ~/sparrow/sparrow.list
    echo swat-yars https://github.com/melezhik/swat-yars.git >> ~/sparrow/sparrow.list


=head1 AUTHORIZATION ISSUE

As technically speaking sparrow plugins are just listing in text files, there is no explicit difference between
public and private plugins. From other hand sparrow relies on git to download install plugins, so this sort
of authentication/authorization issues is addressed to remote git repository owner to setup a proper access policies.


=head1 CREATING SPARROW PLUGINS

To accomplish this task one should be able to

=over

=item *

init local git repository and map it to remote one



=item *

create swat test suite



=item *

add sparrow related configuration



=item *

commit changes and then push into remote



=back


=head2 Init git repository

Sparrow expects your swat test suite will be under git and will be accessed as remote git repository:

    git init .
    echo 'my first sparrow plugin' > README.md
    git add README.md
    git commit -m 'my first sparrow plugin' -a
    git remote add origin $your-remote-git-repository
    git push origin master


=head2 Create swat test suite

To get know what swat is and how to create swat tests for various web applications please follow swat project documentation -
L<https://github.com/melezhik/swat|https://github.com/melezhik/swat>.

A simplest swat test suite to check if GET / returns 200 OK would be like this:

    echo 200 OK > get.txt


=head2 Add sparrow related info

As sparrow relies on L<carton|https://metacpan.org/pod/Carton> to handle perl dependencies and execute script
the only minimal requirement is having valid cpanfile on the root directory of your swat test suite project.

For example:

    # cat cpanfile
       
    # yes, we need a swat to run our tests
    require 'swat';
    
    # and some other modules
    require 'HTML::Entities'


=head2 Step by step list

To create sparrow plugin:

    * create local git repository
    * create swat tests
    * run swat test to ensure that they works fine ( this one is optional but really useful )
    * create cpanfile to declare perl dependencies
    * commit your changes
    * add remote git repository
    * push your changes


=head2 Hello world example

To repeat all told before in a code way:

    git init .
    echo "local" > .gitignore
    echo "require 'swat';" > cpanfile
    echo 200 OK > get.txt
    git add .
    git commit -m 'my first swat plugin' -a
    git remote add origin $your-remote-git-repository
    git push origin master

That's it. To use your freshly baked plugin just say this:

    echo my-plugin $your-remote-git-repository >> sparrow.list
    sparrow plg install my-plugin


=head1 AUTHOR

L<Aleksei Melezhik|mailto:melezhik@gmail.com>


=head1 Home page

https://github.com/melezhik/sparrow


=head1 COPYRIGHT

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.


=head1 THANKS

=over

=item *

to God as - I<For the LORD giveth wisdom: out of his mouth cometh knowledge and understanding. (Proverbs 2:6)>


=back