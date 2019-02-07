package Mailjet::Client;

use v5.28;

use strict;
use warnings;

use URI;
use JSON::MaybeXS;
use Carp qw(croak);
use LWP::UserAgent;
use Syntax::Keyword::Try;
use HTTP::Request::Common qw(GET POST);

our $VERSION = '0.01';

our $base = 'https://api.mailjet.com/v3';
our $ua = LWP::UserAgent->new;

sub new {
  my ($class, %args) = @_;

  croak 'Missing public API key.' unless $args{api_key};
  croak 'Missing secret API key.' unless $args{secret_key};

  my %attribs = %args{qw(api_key secret_key version)};
  $attribs{sandbox_mode} = 1 if $args{sandbox_mode};

  return bless \%attribs, $class
}

sub send_mail {
  my ($self, %args) = @_;

  my $version = $args{version} ? $args{version} : $$self{version};
  $args{json_body} = 1;

  return $version && $version == 3? $self->send_mail_3(%args) : $self->send_mail_31(%args)
}

sub send_mail_31 {
  my ($self, %args) = @_;

  $args{data}->{SandboxMode} = 1
    if $$self{sandbox_mode} || $args{data}->{SandboxMode};

  return $self->post("$base.1/send", %args)
}

sub send_mail_3 {
  return shift->post("$base/send", @_)
}

sub get_message {
  my ($self, $id, %args) = @_;

  if($args{no_id} && !$id) {
    $id = ''
  }
  elsif(!$id) {
    croak 'Missing message ID.'
  }

  my $type = $args{type} ? $args{type} : '';

  return $self->get("$base/REST/message$type/$id", %args)
}

sub get_messages {
  my ($self, %args) = @_;
  return $self->get_message(undef, %args, no_id => 1)
}

sub get_message_history {
  return shift->get_message(@_, type => 'history')
}

sub get_message_info {
  return shift->get_message(@_, type => 'information')
}

sub get_messages_info {
  return shift->get_message_info(undef, @_, no_id => 1) 
}

sub get {
  my ($self, $uri_str, %args) = @_;

  my $uri = URI->new($uri_str);
  $uri->query_form($args{data}) if scalar keys $args{data}->%*;

  return $self->send_request(GET $uri->as_string)
}

sub post {
  my ($self, $uri_str, %args) = @_;
  my $req;

  if($args{json_body}) {
    $req = POST $uri_str;
    $req->content(encode_json($args{data}))
  }
  else {
    $req = POST $uri_str, $args{data}
  }

  return $self->send_request($req)
}

sub send_request {
  my ($self, $req, %args) = @_;
  
  $req->authorization_basic($self->@{qw(api_key secret_key)});
  $req->header('content-type' => 'application/json');

  my $res = $ua->request($req);

  return decode_json($res->decoded_content)
    if $res->is_success;

  my $error_content;

  try {
    $error_content = decode_json($res->decoded_content)
  }
  catch {
    croak $res->status_line, $res->decoded_content
  }

  return {
    code => $res->code,
    message => $res->message,
    content => $error_content
  }
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
