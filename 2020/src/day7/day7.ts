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
  delete reverse['shiny gold'];
  while (open.length) {
    const [c] = open.pop();
    colors.add(c);
    if (c in reverse) {
      open = open.concat(reverse[c]);
    }
    delete reverse[c];
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
    .replace(/ bags?\.?/g, '')
    .replace(/no other/g, '')
    .split('\n')
    .map(x => x.split(/ contain /))
    .map(x => [
      x[0],
      x[1] != ''
        ? x[1].split(', ').map(x => x.match(/(\d) (.*)/).slice(1))
        : [],
    ]);
}
