use Digest::MD5 qw(md5_hex);

my $in = <STDIN>;
chomp $in;
print "$in\n";

#my $in = "abc";
my $i = 0;
my $n = 8;

my %digits = ();

while ($n > 0) {
  $i++;
  $h = md5_hex("$in$i");
  #if ($h =~ /^([0-7])(.)/) {
  if ($h =~ /^00000([0-7])(.)/) {
    if (!exists($digits{$1})) {
      $digits{$1} = $2;
      print "match at i=$i [$h] $1 $2\n";
      $n--;
    } else {
      print "already exists at key $1\n";
    }
  }
}

foreach $i (0..7) {
  print "$digits{$i}";
}
print "\n";
