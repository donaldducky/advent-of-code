use Digest::MD5 qw(md5_hex);

my $in = <STDIN>;
chomp $in;
print "$in\n";

#my $in = "abc";
my $code = "";
my $i = 0;
my $n = 8;

while ($n > 0) {
  $i++;
  $h = md5_hex("$in$i");
  #print "$h\n";
  #if ($h =~ /^([0-9a-z])/) {
  if ($h =~ /^00000([0-9a-z])/) {
    print "match at i=$i [$h] $1\n";
    $n--;
    $code = "$code$1";
  }
}

print "$code\n";
