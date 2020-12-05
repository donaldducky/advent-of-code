import * as fs from 'fs';
import * as path from 'path';

const lines = fs
  .readFileSync(path.join(__dirname, 'input.txt'), 'utf8')
  .toString()
  .trim()
  .split('\n');

console.log('Part 1:', part1(lines));
console.log('Part 2:', part2(lines));

function part1(lines): number {
  return Math.max(...lines.map(genId));
}

function part2(lines) {
  const seatIds = lines.map(genId);
  seatIds.sort((a, b) => a - b);

  for (let i = 0; i < seatIds.length; i++) {
    if (seatIds[i] + 1 != seatIds[i + 1]) {
      return seatIds[i] + 1;
    }
  }

  throw new Error('failed');
}

function genId(line) {
  const parts = line.split('');

  let [row] = binarySearch(parts.slice(0, 7), 127, 'F');
  let [, col] = binarySearch(parts.slice(7, 10), 7, 'L');

  return row * 8 + col;
}

function binarySearch(input, upper, loChar) {
  let min = 0;
  let max = upper;
  input.forEach(c => {
    if (c === loChar) {
      max = Math.floor(max - (max - min) / 2);
    } else {
      min = Math.ceil(min + (max - min) / 2);
    }
  });

  return [min, max];
}
