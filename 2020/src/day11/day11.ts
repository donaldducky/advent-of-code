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
  .map(l => l.split(''));

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  let hash = lines.map(n => n.join('')).join('');
  let prevHash;
  while (prevHash !== hash) {
    let newLines = [];
    for (let i = 0; i < lines.length; i++) {
      newLines[i] = [];
      for (let j = 0; j < lines[i].length; j++) {
        let s = lines[i][j];
        let n = adj(lines, i, j);
        switch (s) {
          case 'L':
            if (n == 0) {
              newLines[i][j] = '#';
            } else {
              newLines[i][j] = 'L';
            }
            break;
          case '#':
            if (n >= 4) {
              newLines[i][j] = 'L';
            } else {
              newLines[i][j] = '#';
            }
            break;
          default:
            newLines[i][j] = '.';
        }
      }
    }
    prevHash = hash;
    hash = newLines.map(n => n.join('')).join('');
    lines = newLines;
  }

  return hash
    .split('')
    .filter(c => c == '#')
    .join('').length;
}

function part2(lines) {
  let hash = lines.map(n => n.join('')).join('');
  let prevHash;
  while (prevHash !== hash) {
    //console.log(lines.map(l => l.join('')).join('\n') + '\n');
    let newLines = [];
    for (let i = 0; i < lines.length; i++) {
      newLines[i] = [];
      for (let j = 0; j < lines[i].length; j++) {
        let s = lines[i][j];
        let n = adj2(lines, i, j);
        switch (s) {
          case 'L':
            if (n == 0) {
              newLines[i][j] = '#';
            } else {
              newLines[i][j] = 'L';
            }
            break;
          case '#':
            if (n >= 5) {
              newLines[i][j] = 'L';
            } else {
              newLines[i][j] = '#';
            }
            break;
          default:
            newLines[i][j] = '.';
        }
      }
    }
    prevHash = hash;
    hash = newLines.map(n => n.join('')).join('');
    lines = newLines;
  }

  return hash
    .split('')
    .filter(c => c == '#')
    .join('').length;
}

function adj(grid, x, y) {
  return [
    [x + 1, y + 1],
    [x + 1, y],
    [x + 1, y - 1],
    [x, y - 1],
    [x, y + 1],
    [x - 1, y + 1],
    [x - 1, y],
    [x - 1, y - 1],
  ].filter(([x, y]) => x in grid && y in grid[x] && grid[x][y] == '#').length;
}

function adj2(grid, x, y) {
  return [
    [1, 1],
    [1, 0],
    [1, -1],
    [0, 1],
    [0, -1],
    [-1, 1],
    [-1, 0],
    [-1, -1],
  ].reduce((sum, [dx, dy]) => {
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
