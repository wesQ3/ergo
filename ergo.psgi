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

my $test = {
   text => 'Gee, twitter sure is cool :D',
   created_at => 'Tue Jul 05 23:03:44 +0000 2011',
   in_reply_to_status_id => '88358794706423808',
   user => { 
      name => 'tweeter', 
      screen_name => 'herp',
      profile_background_color => '1A1B1F',
   },
};

my $app = sub {
   my $req = Plack::Request->new(shift);
   if ( $req->path_info =~ qr{/(\d+)(\.json)?} ) {
      my $tweet = eval { $twit->show_status($1) };
      #my $tweet = $test;
      if ($2 eq '.json') {
         my $res = $req->new_response(200);
         $res->content_type('application/json'); 
         $res->body($json->encode( $tweet ));
         $res->finalize;
      } else {
         $tweet->{twitter_bits} = ref $tweet ne 'HASH'
            ? $json->encode( $tweet->error )
            : $json->encode( $tweet );
         my $out;
         $tt->process('tweet.tt.html', $tweet, \$out);
         my $res = $req->new_response(200);
         $res->content_type('text/html'); 
         $res->body($out);
         $res->finalize;
      }
   } else {
      $req->new_response(500)->finalize
   }
};

builder {
   mount '/'   => Plack::App::File->new(file => 'root.html');
   mount '/js' => Plack::App::File->new(file => 'ergo.js');
   mount '/status' => $app;
};
