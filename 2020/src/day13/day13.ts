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
  .split('\n');

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  const time: number = lines[0];
  const busIds: number[] = lines[1]
    .split(',')
    .filter(x => x !== 'x')
    .map(n => +n);
  const busTimes = busIds.map(n => {
    let t = 0;
    while (t < time) {
      t += n;
    }

    return t;
  });
  let min = Math.min(...busTimes);
  let i = busTimes.findIndex(n => n === min);
  return busIds[i] * (min - time);
}

function part2(lines) {
  const busIds = lines[1]
    .split(',')
    .map((n, i) => [n, i])
    .filter(([n]) => n !== 'x')
    .map(([n, i]) => [+n, i]);

  let ts = busIds[0][0];
  while (!busIds.every(([n, m]) => (ts + m) % n === 0)) {
    ts += busIds
      .filter(([n, m]) => (ts + m) % n === 0)
      .reduce((a, [n]) => a * n, 1);
    //console.log(ts);
  }

  return ts;
}
