use v6;

BEGIN { @*INC.push('t', 'lib') };
use Redis;
use Test;

my $r = Redis.new("127.0.0.1:63790", decode_response => True);
$r.auth('20bdfc8e73365b2fde82d7b17c3e429a9a94c5c9');

plan 1;

is_deeply $r.exec_command("CONFIG GET", "timeout"), ["timeout", "1"];

