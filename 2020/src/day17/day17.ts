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
  .split('\n')
  .map(x => x.split(''));

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  let active = new Set();
  let x1 = 0;
  let x2 = lines.length;
  let y1 = 0;
  let y2 = lines[0].length;
  let z1 = 0;
  let z2 = 0;
  for (let y = y1; y < y2; y++) {
    for (let x = x1; x < x2; x++) {
      if (lines[x][y] == '#') {
        // using arrays as values doesn't work with Set...
        active.add([x, y, z1].join(','));
      }
    }
  }
  for (let i = 1; i <= 6; i++) {
    active = step(
      active,
      x1 - i - 1,
      x2 + i + 1,
      y1 - i - 1,
      y2 + i + 1,
      z1 - i - 1,
      z2 + i + 1
    );
  }

  return active.size;
}

function part2(lines) {
  let active = new Set();
  let x1 = 0;
  let x2 = lines.length;
  let y1 = 0;
  let y2 = lines[0].length;
  let z1 = 0;
  let z2 = 0;
  let w1 = 0;
  let w2 = 0;
  for (let y = y1; y < y2; y++) {
    for (let x = x1; x < x2; x++) {
      if (lines[x][y] == '#') {
        // using arrays as values doesn't work with Set...
        active.add([x, y, z1, w1].join(','));
      }
    }
  }
  for (let i = 1; i <= 6; i++) {
    active = step4(
      active,
      x1 - i - 1,
      x2 + i + 1,
      y1 - i - 1,
      y2 + i + 1,
      z1 - i - 1,
      z2 + i + 1,
      w1 - i - 1,
      w2 + i + 1
    );
  }

  return active.size;
}

function step(active, x1, x2, y1, y2, z1, z2) {
  //console.log(i, x1, x2, y1, y2, z1, z2, active);
  let active2 = new Set();
  for (let x = x1; x < x2; x++) {
    for (let y = y1; y < y2; y++) {
      for (let z = z1; z < z2; z++) {
        let n = neighbours(x, y, z).filter(c => active.has(c.join(','))).length;
        if (active.has([x, y, z].join(','))) {
          if (n === 2 || n === 3) {
            active2.add([x, y, z].join(','));
          }
        } else {
          if (n === 3) {
            active2.add([x, y, z].join(','));
          }
        }
      }
    }
  }

  return active2;
}

function step4(active, x1, x2, y1, y2, z1, z2, w1, w2) {
  let active2 = new Set();
  for (let x = x1; x < x2; x++) {
    for (let y = y1; y < y2; y++) {
      for (let z = z1; z < z2; z++) {
        for (let w = w1; w < w2; w++) {
          let n = neighbours4(x, y, z, w).filter(c => active.has(c.join(',')))
            .length;
          if (active.has([x, y, z, w].join(','))) {
            if (n === 2 || n === 3) {
              active2.add([x, y, z, w].join(','));
            }
          } else {
            if (n === 3) {
              active2.add([x, y, z, w].join(','));
            }
          }
        }
      }
    }
  }

  return active2;
}

function neighbours(x: number, y: number, z: number) {
  return [
    [0, 0, 1],
    [0, 0, -1],
    [0, 1, 0],
    [0, 1, 1],
    [0, 1, -1],
    [0, -1, 0],
    [0, -1, 1],
    [0, -1, -1],
    [1, 0, 0],
    [1, 0, 1],
    [1, 0, -1],
    [1, 1, 0],
    [1, 1, 1],
    [1, 1, -1],
    [1, -1, 0],
    [1, -1, 1],
    [1, -1, -1],
    [-1, 0, 0],
    [-1, 0, 1],
    [-1, 0, -1],
    [-1, 1, 0],
    [-1, 1, 1],
    [-1, 1, -1],
    [-1, -1, 0],
    [-1, -1, 1],
    [-1, -1, -1],
  ].map(([dx, dy, dz]) => [x + dx, y + dy, z + dz]);
}

function neighbours4(x, y, z, w) {
  return [
    [0, 0, 0, 1],
    [0, 0, 0, -1],
    [0, 0, 1, 0],
    [0, 0, 1, 1],
    [0, 0, 1, -1],
    [0, 0, -1, 0],
    [0, 0, -1, 1],
    [0, 0, -1, -1],
    [0, 1, 0, 0],
    [0, 1, 0, 1],
    [0, 1, 0, -1],
    [0, 1, 1, 0],
    [0, 1, 1, 1],
    [0, 1, 1, -1],
    [0, 1, -1, 0],
    [0, 1, -1, 1],
    [0, 1, -1, -1],
    [0, -1, 0, 0],
    [0, -1, 0, 1],
    [0, -1, 0, -1],
    [0, -1, 1, 0],
    [0, -1, 1, 1],
    [0, -1, 1, -1],
    [0, -1, -1, 0],
    [0, -1, -1, 1],
    [0, -1, -1, -1],
    [1, 0, 0, 0],
    [1, 0, 0, 1],
    [1, 0, 0, -1],
    [1, 0, 1, 0],
    [1, 0, 1, 1],
    [1, 0, 1, -1],
    [1, 0, -1, 0],
    [1, 0, -1, 1],
    [1, 0, -1, -1],
    [1, 1, 0, 0],
    [1, 1, 0, 1],
    [1, 1, 0, -1],
    [1, 1, 1, 0],
    [1, 1, 1, 1],
    [1, 1, 1, -1],
    [1, 1, -1, 0],
    [1, 1, -1, 1],
    [1, 1, -1, -1],
    [1, -1, 0, 0],
    [1, -1, 0, 1],
    [1, -1, 0, -1],
    [1, -1, 1, 0],
    [1, -1, 1, 1],
    [1, -1, 1, -1],
    [1, -1, -1, 0],
    [1, -1, -1, 1],
    [1, -1, -1, -1],
    [-1, 0, 0, 0],
    [-1, 0, 0, 1],
    [-1, 0, 0, -1],
    [-1, 0, 1, 0],
    [-1, 0, 1, 1],
    [-1, 0, 1, -1],
    [-1, 0, -1, 0],
    [-1, 0, -1, 1],
    [-1, 0, -1, -1],
    [-1, 1, 0, 0],
    [-1, 1, 0, 1],
    [-1, 1, 0, -1],
    [-1, 1, 1, 0],
    [-1, 1, 1, 1],
    [-1, 1, 1, -1],
    [-1, 1, -1, 0],
    [-1, 1, -1, 1],
    [-1, 1, -1, -1],
    [-1, -1, 0, 0],
    [-1, -1, 0, 1],
    [-1, -1, 0, -1],
    [-1, -1, 1, 0],
    [-1, -1, 1, 1],
    [-1, -1, 1, -1],
    [-1, -1, -1, 0],
    [-1, -1, -1, 1],
    [-1, -1, -1, -1],
  ].map(([dx, dy, dz, dw]) => [x + dx, y + dy, z + dz, w + dw]);
}
