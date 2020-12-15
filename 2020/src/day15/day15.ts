import * as fs from 'fs';
import * as path from 'path';

let file: string;
file = 'sample2.txt';
file = 'sample.txt';
file = 'input.txt';

const lines: number[] = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split(',')
  .map(x => +x);

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(startingNumbers: number[]): number {
  return spokenNumberAt(startingNumbers, 2020);
}

function part2(startingNumbers: number[]): number {
  return spokenNumberAt(startingNumbers, 30000000);
}

function range(n: number, i: number = 0): number[] {
  return [...Array(n).keys()].reduce((a, k) => {
    a.push(k + i);
    return a;
  }, []);
}

function spokenNumberAt(startingNumbers: number[], n: number) {
  const seen: Record<number, number[]> = {};

  return range(n, 1).reduce((lastSpoken: number, turn: number) => {
    let spoken;
    if (turn - 1 in startingNumbers) {
      spoken = startingNumbers[turn - 1];
    } else {
      if (seen[lastSpoken].length === 1) {
        spoken = 0;
      } else {
        const lastSeen = seen[lastSpoken][0];
        const prevSeen = seen[lastSpoken][1];
        spoken = lastSeen - prevSeen;

        seen[lastSpoken].pop();
      }
    }
    if (!(spoken in seen)) {
      seen[spoken] = [];
    }
    seen[spoken].unshift(turn);
    //console.log(`turn=${turn} prev=${lastSpoken} spoken=${spoken}`);

    return spoken;
  }, 0);
}
