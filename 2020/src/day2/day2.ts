import * as fs from 'fs';
import * as path from 'path';

const lines = fs
  .readFileSync(path.join(__dirname, 'input.txt'), 'utf8')
  .toString()
  .trim()
  .split('\n')
  .map(line => {
    const re = /(?<min>\d+)-(?<max>\d+) (?<letter>[a-z]): (?<password>[a-z]+)/;

    return line.match(re).groups;
  });

console.log('Part 1:', part1(lines));
console.log('Part 2:', part2(lines));

function part1(lines): number {
  return lines.reduce((total, { min, max, letter, password }) => {
    const count = password.split(letter).length - 1;

    if (count >= min && count <= max) {
      total++;
    }

    return total;
  }, 0);
}

function part2(lines) {
  return lines.reduce((total, { min, max, letter, password }) => {
    const count = [min, max].reduce((c, i) => {
      if (password.charAt(i - 1) === letter) {
        c++;
      }

      return c;
    }, 0);

    if (count === 1) {
      total++;
    }

    return total;
  }, 0);
}
