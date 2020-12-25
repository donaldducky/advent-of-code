import * as fs from 'fs';
import * as path from 'path';

let file;
file = 'sample.txt';
file = 'input.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('\n').map(x=>+x);

let p1 = part1(lines);
console.log('Part 1:', p1);

function part1(lines) {
  let [cpub, dpub] = lines;

  let doorLoop = 0;
  let v = 1;
  let sn = 7;
  while (v != dpub) {
    v *= sn;
    v %= 20201227;
    doorLoop++;
  }

  sn = cpub;
  v = 1;
  for (let i = 0; i < doorLoop; i++) {
    v *= sn;
    v %= 20201227;
  }

  return v;
}
