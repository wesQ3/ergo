use strict; use warnings; use 5.010.0;
use Plack::Builder;
use Plack::Request;
use Plack::Response;
use JSON;
use Net::Twitter::Lite;
my $twit = Net::Twitter::Lite->new;
my $json = JSON->new->pretty;

my $app = sub {
   my $req = Plack::Request->new(shift);
   my $res = $req->new_response(200);
   $req->path_info =~ qr{status/(\d+)};
   my $tweet = $twit->show_status($1);
   $res->content_type('text/plain'); 
   $res->body($json->encode( $tweet ));
   $res->finalize;
};

builder {
   enable 'Plack::Middleware::Static',
      path => qr{^/static/}, root => '.';
   mount '/' => $app;
};
