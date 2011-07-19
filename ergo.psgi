use strict; use warnings; use 5.010.0;
use Plack::Builder;
use Plack::Request;
use Plack::Response;
use Plack::App::File;
use JSON;
use Net::Twitter::Lite;
use Template;
my $twit = Net::Twitter::Lite->new;
my $json = JSON->new->pretty;
my $tt   = Template->new;

my $app = sub {
   my $req = Plack::Request->new(shift);
   if ( $req->path_info =~ qr{/(\d+)(\.json)?} ) {
      my $tweet = eval { $twit->show_status($1) };
      $tweet->{twitter_bits} = ref $tweet ne 'HASH'
         ? $json->encode( $tweet->error )
         : $json->encode( $tweet );
      my $out;
      $tt->process('tweet.tt.html', $tweet, \$out);
      my $res = $req->new_response(200);
      $res->content_type('text/html'); 
      $res->body($out);
      $res->finalize;
   } else {
      $req->new_response(500)->finalize
   }
};

my $twitter = sub {
   my $req = Plack::Request->new(shift);
   if ( $req->path_info =~ qr{/status/(\d+)\.json} ) {
      my $tweet = eval { $twit->show_status($1) };
      my $res = $req->new_response(200);
      $res->content_type('application/json'); 
      $res->body($json->encode( $tweet ));
      $res->finalize;
   } else {
      $req->new_response(404)->finalize
   }
};

builder {
   enable 'Cache', match_url => '[?&]ergo-cache',
      cache_dir => '/tmp/ergo-twitter-cache';
   mount '/'   => Plack::App::File->new(file => 'root.html');
   mount '/js' => Plack::App::File->new(file => 'ergo.js');
   mount '/status' => $app;
   mount '/twitter' => $twitter;
};
