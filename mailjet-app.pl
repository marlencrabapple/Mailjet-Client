#!/usr/bin/perl

use strict;
use warnings;

use lib 'lib';

use Mailjet::Client;
use Data::Dumper;

my $from_name = $ARGV[0];
my $from_email = $ARGV[1];
my $recipients = [ { email => $ARGV[2] } ];

my $client = Mailjet::Client->new({
  api_keys => {
    public => 'public_key_here',
    private => 'private_key_here'
  }
});

my $res = $client->send_mail({
  FromEmail => $from_email,
  FromName => $from_name,
  Recipients => $recipients,
  Subject => 'Mailjet API Test',
  'Text-Part' => 'Testing Mailjet::Client, a Mailjet API client. Ignore this please.',
  Headers => {
    'Reply-To' => 'webmaster@crosnerlegal.com'
  }
});

print Dumper($res)