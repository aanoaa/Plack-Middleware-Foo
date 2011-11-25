#!/usr/bin/env perl
use strict;
use warnings;
use Plack::Builder;
use Plack::App::Proxy;

builder {
    enable "Plack::Middleware::Foo";
    mount "/" => Plack::App::Proxy->new(remote => "http://api.zangso.com:80")->to_app;
};
