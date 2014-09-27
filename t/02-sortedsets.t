use v6;

BEGIN { @*INC.push('t', 'lib') };
use Redis;
use Test;

my $r = Redis.new("127.0.0.1:63790", decode_response => True);
$r.auth('20bdfc8e73365b2fde82d7b17c3e429a9a94c5c9');
$r.flushall;

plan 23;

is_deeply $r.zadd("myzset", ONE => 1, TWO => 2, THREE=> 3), 3;
is_deeply $r.zadd("myzset", "ZERO", 0, "ONE" => 1, TWO => 2, THREE=> 3), 1;
dies_ok { $r.zadd("myzset", "ZERO", ONE => 1, TWO => 2, THREE=> 3) }

is_deeply $r.zcard("myzset"), 4;

is_deeply $r.zcount("myzset", 2, 3), 2;

is_deeply $r.zincrby("myzset", 1.1, "THREE"), 4.1;

# zinterstore & zrange & zrangebyscore & zrevrange & zrevrangebyscore
$r.zadd("zset1", "one" => 1, "two" => 2);
$r.zadd("zset2", "one" => 1, "two" => 2, "three" => 3);
is_deeply $r.zinterstore("out", "zset1", "zset2", weights => (2,3)), 2;
is_deeply $r.zinterstore("out", "zset1", "zset2", WEIGHTS => (2,3)), 2;
is_deeply $r.zrange("out", 0, -1), ["one", "two"];
is_deeply $r.zrange("out", 0, -1, :WITHSCORES), ["one", "5", "two", "10"];
is_deeply $r.zrevrange("out", 0, -1, :WITHSCORES), ["two", "10", "one", "5"];
is_deeply $r.zrangebyscore("out", 6, 10), ["two"];
is_deeply $r.zrangebyscore("out", 6, 10, :WITHSCORES), ["two", "10"];
is_deeply $r.zrangebyscore("out", 0, 10, :WITHSCORES, OFFSET=>0, COUNT=>1), ["one", "5"];
is_deeply $r.zrevrangebyscore("out", 10, 0, :WITHSCORES, OFFSET=>0, COUNT=>1), ["two", "10"];

# zrank & zrem & zremrangbyrank & zrevrank
$r.flushall;
$r.zadd("myzset", one=>1, two=>2, three=>3, four=>4);
is_deeply $r.zrank("myzset", "one"), 0;
is_deeply $r.zrevrank("myzset", "one"), 3;
is_deeply $r.zrank("myzset", "other"), Any;
is_deeply $r.zrem("myzset", "other", "one"), 1;
is_deeply $r.zremrangbyrank("myzset", 0, 1), 2;
is_deeply $r.zremrangebyscore("myzset", 2, 3), 0;

# zscore & zunionstore
$r.flushall;
$r.zadd("myzset", one=>1, two=>2, three=>3, four=>4);
$r.zadd("myzset2", five=>5, six=>6);
is_deeply $r.zscore("myzset", "three"), 3;
is_deeply $r.zunionstore("newset", "myzset", "myzset2"), 6;

