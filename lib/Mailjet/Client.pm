package Mailjet::Client;

use v5.28;

use strict;
use warnings;

use JSON::MaybeXS;
use Carp qw(croak);
use LWP::UserAgent;
use HTTP::Request::Common qw(GET POST DELETE);

our $VERSION = '0.01';

our $base = 'https://api.mailjet.com/v3';
our $ua = LWP::UserAgent->new;

sub new {
  my $class = shift;
  my %args = scalar @_ == 1 ? @_->%* : @_;

  croak "Missing public API key" unless $args{api_key};
  croak "Missing private API key" unless $args{secret_key};

  my %attribs = %args{qw(api_key secret_key)};

  return bless \%attribs, $class
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
  
  $req->authorization_basic($$self{api_key}, $$self{secret_key});
  $req->header('content-type' => 'application/json');

  my $res = $ua->request($req);

  return decode_json($res->decoded_content)
    if($res->is_success);
    
  croak $res->status_line, $res->decoded_content;
}

1

__END__

=encoding utf-8

=head1 NAME

Mailjet::Client - Blah blah blah

=head1 SYNOPSIS

  use Mailjet::Client;

=head1 DESCRIPTION

Mailjet::Client is

=head1 AUTHOR

Ian P Bradley E<lt>ian.bradley@studiocrabapple.comE<gt>

=head1 COPYRIGHT

Copyright 2019- Ian P Bradley

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
