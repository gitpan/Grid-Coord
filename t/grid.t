use strict; use warnings;
use Grid::Coord;
use Test::More tests => 60;

my $g1 = Grid::Coord->new(1,1,5,5);

isa_ok($g1, 'Grid::Coord',                "isa");
is($g1->stringify, "(1,1, 5,5)",          "stringify");

my $g2 = Grid::Coord->new(3,3,7,6);

my $g3 = $g2->overlap($g1);
is($g3->stringify, "(3,3, 5,5)",          "overlap");

my $g3b = $g2->overlap(Grid::Coord->new(8,9,8,9)); # no overlap
ok( !$g3b, "No overlap (undef)");

my $g4=Grid::Coord->new(3,3,5,5);
ok($g3->equals($g4),                      "equals");
cmp_ok($g3, '==', $g4,                    "equals (overloaded)");
ok(!($g2 == $g4),                         "not equals using ! ==");

TODO: {
  local $TODO = "!= not implemented";
  eval {
    my $dummy = $g2 != $g4;
  };
  ok (! $@, "!= implemented");
}

my $g5 = Grid::Coord->new(6,6);

ok($g2->contains($g5),     "contains");
ok(! $g3->contains($g5),   "not contains");

cmp_ok ($g5->offset(1,1), '==', Grid::Coord->new(7,7),       "point offset");
cmp_ok ($g2->offset($g5), '==', Grid::Coord->new(9,9,13,12), "range offset");
cmp_ok ($g2 + $g5,        '==', Grid::Coord->new(9,9,13,12), "range offset (overloaded +)");

my $from = Grid::Coord->new(1,2,3,4);
my $to   = Grid::Coord->new(3,1,4,7);
my $exp  = Grid::Coord->new(2,-1,1,3);
cmp_ok ($from->delta($to), '==', $exp,  "delta");
cmp_ok ($from - $to,       '==', $exp,        "delta (overloaded -)");


$to   = Grid::Coord->new(3,3);
cmp_ok ($from - $to, '==', Grid::Coord->new(2,1,0,-1), "Delta to point");


my $g6=Grid::Coord->new(3,undef, 4,undef);
my $g7=Grid::Coord->new(undef,3, undef,5);
cmp_ok($g6->overlap($g7), '==', Grid::Coord->new(3,3,4,5), "overlap (row/col)");

cmp_ok($g2->head, '==', Grid::Coord->new(3,3),  "head");

my $it = $g2->rows_iterator;
is(ref $it, 'CODE',   'returned CODE ref for iterator');
my $val = $it->();
cmp_ok($val, '==', Grid::Coord->new(3,undef, 3,undef),  "First iteration");

for (4..7) {
  ok ($val = $it->(), "Iteration $_");
  ok($val == $val->row,  "Returned just a row");
  ok(! ($val == $val->col),  "Not a column");
  cmp_ok($val->min_y, '==', $_, "Correct row");
}
ok (! $it->(),        "No more iterations");
ok (! $it->(),        "(still) no more iterations");

my $it2 = $g2->cols_iterator;
for (3..6) {
  ok (my $val = $it2->(),     "Getting col");
  ok ($val == $val->col,      "Is whole column");
  ok (! ($val == $val->row),  "Is not a whole row");
}
ok (! $it->(),        "No more iterations");
ok (! $it->(),        "(still) no more iterations");

my $it3 = $g2->cell_iterator;
my @cells;
while (my $cell = $it3->()) {
  push @cells, $cell;
}
is (scalar @cells, (5*4),  "Correct number of cells returned");
cmp_ok($cells[0], '==', $g2->head, "First is head");
cmp_ok($cells[-1],'==', $g2->tail, "Last is tail");
cmp_ok($cells[10],'==', Grid::Coord->new(5,5), "Sample from middle");

@cells = (); # clear cells for colwise iteration
my $it4 = $g2->cell_iterator_colwise;
while (my $cell = $it4->()) {
  push @cells, $cell;
}
is (scalar @cells, (5*4),  "Correct number of cells returned (colwise)");
cmp_ok($cells[0], '==', $g2->head, "First is head");
cmp_ok($cells[-1],'==', $g2->tail, "Last is tail");
cmp_ok($cells[10],'==', Grid::Coord->new(3,5), "Sample from middle (different, because different direction of travel)");

