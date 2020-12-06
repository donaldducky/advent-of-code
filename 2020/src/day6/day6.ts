import * as fs from 'fs';
import * as path from 'path';

const lines = fs
  .readFileSync(path.join(__dirname, 'input.txt'), 'utf8')
  .toString()
  .trim()
  .split('\n\n');

console.log('Part 1:', part1(lines));
console.log('Part 2:', part2(lines));

function part1(lines): number {
  return lines
    .map(line => {
      return new Set(line.split(/[\n]/).flatMap(a => a.split(''))).size;
    })
    .reduce((sum, c) => sum + c, 0);
}

function part2(lines): number {
  return lines.reduce((acc, group) => {
    let answers = group.split('\n').map(a => a.split(''));
    let n = answers.length;

    let seen = {};
    answers.forEach(a => {
      a.forEach(ans => {
        if (ans in seen) {
          seen[ans]++;
        } else {
          seen[ans] = 1;
        }
      });
    });

    return (
      Object.keys(seen).reduce((acc, k) => {
        if (seen[k] === n) {
          return acc + 1;
        } else {
          return acc;
        }
      }, 0) + acc
    );
  }, 0);
}
