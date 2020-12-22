import * as fs from 'fs';
import * as path from 'path';

let file = 'input.txt';
//file = 'sample.txt';
//file = 'sample2.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('\n')
  .map(n => +n);

lines.push(Math.max(...lines) + 3);
lines.push(0);
lines.sort((a, b) => a - b);

let p1 = part1(lines);
console.log('Part 1:', p1);
let cache = [];
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  let js = lines.reduce(
    (acc, n) => {
      let d = +n - acc.sum;
      if (!(d in acc)) {
        acc[d] = 0;
      }
      acc.sum += d;
      acc[+d]++;

      return acc;
    },
    { sum: 0 }
  );
  return js[1] * js[3];
}

function part2(lines) {
  return recurse(lines, 0);
}

function recurse(lines, i) {
  let sum = 0;
  if (i in cache) {
    return cache[i];
  }
  if (i === lines.length - 1) {
    return 1;
  }

  for (let j = i + 1; j < lines.length; j++) {
    if (lines[j] - lines[i] <= 3) {
      cache[j] = recurse(lines, j);
      sum += cache[j];
    } else {
      break;
    }
  }

  return sum;
}
