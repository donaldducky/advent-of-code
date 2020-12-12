import * as fs from 'fs';
import * as path from 'path';

let file;
file = 'sample.txt';
file = 'input.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('\n')
  .map(l => [l[0], +l.slice(1)]);

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function turnLeft(dir, n) {
  const left = {
    E: 'N',
    N: 'W',
    W: 'S',
    S: 'E',
  };
  while (n > 0) {
    dir = left[dir];
    n--;
  }

  return dir;
}

function turnRight(dir, n) {
  const right = {
    E: 'S',
    N: 'E',
    W: 'N',
    S: 'W',
  };
  while (n > 0) {
    dir = right[dir];
    n--;
  }

  return dir;
}

function rotateLeft(wx, wy, n) {
  while (n > 0) {
    let x = wx;
    wx = -wy;
    wy = x;
    n--;
  }

  return [wx, wy];
}

function rotateRight(wx, wy, n) {
  while (n > 0) {
    let y = wy;
    wy = -wx;
    wx = y;
    n--;
  }

  return [wx, wy];
}

function part1(lines) {
  const directions = {
    E: [1, 0],
    W: [-1, 0],
    N: [0, 1],
    S: [0, -1],
  };

  let res = lines.reduce(
    ([x, y, dir], [c, n]) => {
      switch (c) {
        case 'N':
          y += n;
          break;
        case 'S':
          y -= n;
          break;
        case 'E':
          x += n;
          break;
        case 'W':
          x -= n;
          break;
        case 'L':
          dir = turnLeft(dir, n / 90);
          break;
        case 'R':
          dir = turnRight(dir, n / 90);
          break;
        case 'F':
          x += directions[dir][0] * n;
          y += directions[dir][1] * n;
          break;
      }

      //console.log('current', x, y, dir);
      return [x, y, dir];
    },
    [0, 0, 'E']
  );

  return Math.abs(res[0]) + Math.abs(res[1]);
}

function part2(lines) {
  let res = lines.reduce(
    ([x, y, dir, wx, wy], [c, n]) => {
      switch (c) {
        case 'N':
          wy += n;
          break;
        case 'S':
          wy -= n;
          break;
        case 'E':
          wx += n;
          break;
        case 'W':
          wx -= n;
          break;
        case 'L':
          [wx, wy] = rotateLeft(wx, wy, n / 90);
          break;
        case 'R':
          [wx, wy] = rotateRight(wx, wy, n / 90);
          break;
        case 'F':
          x += wx * n;
          y += wy * n;
          break;
      }

      //console.log(c, n, 'current', x, y, dir, wx, wy);
      return [x, y, dir, wx, wy];
    },
    [0, 0, 'E', 10, 1]
  );

  return Math.abs(res[0]) + Math.abs(res[1]);
}
