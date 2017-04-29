package Mailjet::Client;

use strict;
use warnings;

use JSON::MaybeXS;
use Carp qw(croak);
use LWP::UserAgent;
use HTTP::Request::Common qw(GET POST DELETE);

our $base = 'https://api.mailjet.com/v3';

sub new {
  my ($class, $params) = @_;

  croak "Missing public API key" unless $$params{api_keys}->{public};
  croak "Missing private API key" unless $$params{api_keys}->{private};

  my $attribs = {
    api_keys => $$params{api_keys},
    ua => LWP::UserAgent->new
  };

  return bless $attribs, $class
}

sub send_mail {
  my ($self, $body) = @_;
  $body = encode_json($body);

  my $req = POST "$base/send";
  $req->content($body);

  return $self->send_request($req)
}

sub send_request {
  my ($self, $req) = @_;
  
  $req->authorization_basic($$self{api_keys}->{public}, $$self{api_keys}->{private});
  $req->header('content-type' => 'application/json');

  my $res = $self->{ua}->request($req);

  return decode_json($res->decoded_content) if($res->is_success);
  croak $res->status_line
}

1;