import * as fs from 'fs';
import * as path from 'path';

let file = 'input.txt';
//file = 'sample.txt';
//file = 'sample2.txt';

const input = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim();
console.log('Part 1:', part1(input));
console.log('Part 2:', part2(input));

function part1(input) {
  let reverse = parse(input).reduce((reverse, [bag, contains]) => {
    contains.forEach(([count, id]) => {
      if (!(id in reverse)) {
        reverse[id] = [];
      }
      reverse[id].push([bag, count]);
    });
    return reverse;
  }, {});

  let colors = new Set();
  // initialize to empty in case no bags can carry shiny gold (ie. sample2.txt)
  let open = reverse['shiny gold'] ?? [];
  while (open.length) {
    const [c] = open.pop();
    colors.add(c);
    if (c in reverse) {
      open = open.concat(reverse[c]);
    }
  }

  return colors.size;
}

function part2(input) {
  let bags = parse(input).reduce((bags, [bag, contains]) => {
    bags[bag] = contains;
    return bags;
  }, {});
  let count = 0;
  let open = [['shiny gold', 1]];
  while (open.length) {
    let [id, multiplier] = open.pop();
    count += +multiplier;
    bags[id].forEach(([count, id]) => {
      open.push([id, count * +multiplier]);
    });
  }

  return count - 1;
}

function parse(input) {
  return input
    .split('\n')
    .map(x => x.split(/ bags contain /))
    .map(([l, r]) => [
      l,
      // r.matchAll creates an iterator, which cannot be spread unless downlevelIteration is on in tsconfig
      // allows removing Array.from(...)
      //[...Array.from(r.matchAll(/(\d+) ([^,.]+) bags?[,.]/g))].map(x => [
      [...r.matchAll(/(\d+) ([^,.]+) bags?[,.]/g)].map(x => x.slice(1)),
    ]);
}
