use strict; use warnings; use 5.010.0;
use Plack::Builder;
use Plack::Request;
use Plack::Response;
use Plack::App::File;
use JSON;
use Net::Twitter::Lite;
my $twit = Net::Twitter::Lite->new;
my $json = JSON->new->pretty;

my $app = sub {
   my $req = Plack::Request->new(shift);
   if ( $req->path_info =~ qr{/(\d+)} ) {
      my $res = $req->new_response(200);
      my $tweet = $twit->show_status($1);
      $res->content_type('text/plain'); 
      $res->body($json->encode( $tweet ));
      $res->finalize;
   } else {
      $req->new_response(500)->finalize
   }
};

builder {
   mount '/'   => Plack::App::File->new(file => 'root.html');
   mount '/js' => Plack::App::File->new(file => 'ergo.js');
   mount '/status' => $app;
};
