import * as fs from 'fs';
import * as path from 'path';

let file = 'input.txt';
let preamble = 25;
//file = 'sample.txt';
//preamble = 5;
//file = 'sample2.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('\n')
  .map(n => +n);

let p1 = part1(lines, preamble);
console.log('Part 1:', p1);
let p2 = part2(lines, preamble, p1);
console.log('Part 2:', p2);

function part1(lines, preamble) {
  return lines.find((n, i) => {
    if (i < preamble) return false;
    let v = lines.slice(i - preamble, i);
    return !v.find(a => v.filter(b => a !== b).find(b => a + b == lines[i]));
  });
}

function part2(lines, preamble, target) {
  let sum = 0;
  let current = [];
  for (let i = 0; i < lines.length; i++) {
    current.push(lines[i]);
    sum += lines[i];
    while (sum > target) {
      sum -= current.shift();
    }
    if (current.length < 2) continue;
    if (sum === target) {
      return Math.min(...current) + Math.max(...current);
    }
  }

  return target;
}
