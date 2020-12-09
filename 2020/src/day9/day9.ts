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

let target = part1(lines, preamble);
console.log('Part 1:', target);
console.log('Part 2:', part2(lines, preamble, target));

function part1(lines, preamble) {
  return find(lines, preamble);
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

function find(lines, preamble) {
  for (let i = 0; i < lines.length - preamble; i++) {
    //console.log(i, lines[i], lines.slice(i, i + preamble), lines[i + preamble]);
    let target = lines[i + preamble];
    let consider = lines.slice(i, i + preamble);
    //console.log(consider, target);
    const found = consider.find(n => {
      let s = new Set();
      s.add(n);
      return consider.find(m => {
        if (s.has(m)) {
          return;
        }
        s.add(m);
        //console.log(n, m, n + m);
        return n + m == target;
      });
    });
    if (!found) {
      return target;
    }
  }
}
