import * as fs from 'fs';
import * as path from 'path';

const input = fs
  .readFileSync(path.join(__dirname, 'input.txt'), 'utf8')
  .toString()
  .trim();
console.log('Part 1:', part1(input));
console.log('Part 2:', part2(input));

function part1(input) {
  return (
    input
      .split('\n\n')
      //.map(g => new Set(g.split(/\n/).join('').split('')).size)
      .map(g => new Set(g.split(/\n/).flatMap(a => a.split(''))).size)
      .reduce((a, b) => a + b)
  );
}

function part2(input) {
  return input
    .split('\n\n')
    .map(
      g =>
        g
          .split(/\n/)
          .map(a => a.split(''))
          .reduce((a, b) => a.filter(x => b.includes(x))).length
    )
    .reduce((a, b) => a + b);
}
