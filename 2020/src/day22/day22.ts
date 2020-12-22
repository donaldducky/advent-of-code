import * as fs from 'fs';
import * as path from 'path';

let file;
file = 'sample2.txt';
file = 'sample.txt';
file = 'input.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('\n\n');

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  let [p1, p2] = lines.map(x => x.split('\n').map(x => +x));
  p1.shift();
  p2.shift();

  while (p1.length && p2.length) {
    let c1 = p1.shift();
    let c2 = p2.shift();
    if (c1 > c2) {
      p1 = p1.concat([c1, c2]);
    } else if (c2 > c1) {
      p2 = p2.concat([c2, c1]);
    }
  }

  let winner = p1.length ? p1 : p2;

  return winner.reverse().reduce((s, x, i) => {
    return s + (i + 1) * x;
  }, 0);
}

function part2(lines) {
  let [p1, p2] = lines.map(x => x.split('\n').map(x => +x));
  p1.shift();
  p2.shift();

  let [, winner] = recursiveCombat(p1, p2);

  return winner.reverse().reduce((s, x, i) => {
    return s + (i + 1) * x;
  }, 0);
}

function recursiveCombat(p1, p2) {
  let seen = new Set();
  while (p1.length && p2.length) {
    let hash = [p1, p2].map(xs => xs.join(',')).join(':');
    if (seen.has(hash)) {
      return ['p1', p1];
    }
    seen.add(hash);

    let c1 = p1.shift();
    let c2 = p2.shift();
    let win;
    if (p1.length >= c1 && p2.length >= c2) {
      [win] = recursiveCombat(p1.slice(0, c1), p2.slice(0, c2));
    } else {
      if (c1 > c2) {
        win = 'p1';
      } else if (c2 > c1) {
        win = 'p2';
      }
    }
    if (win == 'p1') {
      p1 = p1.concat([c1, c2]);
    } else {
      p2 = p2.concat([c2, c1]);
    }
  }

  if (p1.length) {
    return ['p1', p1];
  } else {
    return ['p2', p2];
  }
}
