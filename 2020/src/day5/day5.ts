import * as fs from 'fs';
import * as path from 'path';

const input = fs
  .readFileSync(path.join(__dirname, 'input.txt'), 'utf8')
  .toString()
  .trim();

console.log('Part 1:', part1(input));
console.log('Part 2:', part2(input));

function part1(input) {
  return Math.max(...parse(input));
}

function part2(input) {
  const seatIds = parse(input);
  seatIds.sort((a, b) => a - b);

  return seatIds.find((id, i) => id + 1 != seatIds[i + 1]) + 1;
}

function parse(input) {
  const tr = {
    F: 0,
    B: 1,
    L: 0,
    R: 1,
  };
  return input
    .split('\n')
    .map(s => s.replace(/./g, m => tr[m]))
    .map(s => parseInt(s, 2));
}
