import * as fs from 'fs';
import * as path from 'path';

const DIRS = [
  [0, 1],
  [0, -1],
  [1, 0],
  [-1, 0],
  [1, 1],
  [1, -1],
  [-1, 1],
  [-1, -1],
];

let file;
file = 'sample.txt';
file = 'input.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('\n')
  .map(l => l.split(''));

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  return countSeats(lines, 4, adj);
}

function part2(lines) {
  return countSeats(lines, 5, adj2);
}

function countSeats(lines, nOccupied, adjFn) {
  let hash = lines.map(n => n.join('')).join('');
  let prevHash;
  while (prevHash !== hash) {
    //console.log(lines.map(l => l.join('')).join('\n') + '\n');
    // technically can get away without the stringify/parse since it's an array of numbers
    // but if we were using objects, we would need to parse/stringify to do a deep copy
    //lines = JSON.parse(JSON.stringify(lines)).map((line, i) => {
    lines = lines.map((line, i) => {
      return line.map((s, j) => {
        let n = adjFn(lines, i, j);
        if (s == 'L' && n == 0) {
          return '#';
        } else if (s == '#' && n >= nOccupied) {
          return 'L';
        }

        return s;
      });
    });
    prevHash = hash;
    hash = lines.map(n => n.join('')).join('');
  }

  return hash
    .split('')
    .filter(c => c == '#')
    .join('').length;
}

function adj(grid, x, y) {
  return DIRS.map(([dx, dy]) => [dx + x, dy + y]).filter(
    ([x, y]) => x in grid && y in grid[x] && grid[x][y] == '#'
  ).length;
}

function adj2(grid, x, y) {
  return DIRS.reduce((sum, [dx, dy]) => {
    let x2 = x + dx;
    let y2 = y + dy;
    while (x2 in grid && y2 in grid[x2]) {
      if (grid[x2][y2] === 'L') return sum;
      if (grid[x2][y2] === '#') return sum + 1;
      x2 += dx;
      y2 += dy;
    }

    return sum;
  }, 0);
}
