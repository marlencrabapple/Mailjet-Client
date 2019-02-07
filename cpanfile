requires 'perl', '5.28.1';

requires 'JSON::MaybeXS';
requires 'LWP::UserAgent';
requires 'LWP::Protocol::https';
requires 'HTTP::Request::Common';

on test => sub {
    requires 'Test::More', '0.96';
};