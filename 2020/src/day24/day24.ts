import * as fs from 'fs';
import * as path from 'path';

let file;
file = 'sample2.txt';
file = 'sample.txt';
file = 'input.txt';

const SE = '⬊';
const SW = '⬋';
const NE = '⬈';
const NW = '⬉';
const W = 'w';
const E = 'e';

const NEIGHBOURS_OFFSET = {
  [E]: [1, 0],
  [W]: [-1, 0],
  [SE]: [1, 1],
  [SW]: [0, 1],
  [NE]: [1, -1],
  [NW]: [0, -1],
};
const NEIGHBOURS = {
  [E]: [1, 0],
  [W]: [-1, 0],
  [SE]: [0, 1],
  [SW]: [-1, 1],
  [NE]: [0, -1],
  [NW]: [-1, -1],
};

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .replace(/se/g, SE)
  .replace(/sw/g, SW)
  .replace(/ne/g, NE)
  .replace(/nw/g, NW)
  .split('\n')
  .map(x => x.split(''));

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  return renovate(lines).size;
}

function part2(lines) {
  let tiles = renovate(lines);

  for (let i = 0; i < 100; i++) {
    tiles = step(tiles);
  }

  return tiles.size;
}

function renovate(lines) {
  return lines.reduce((t, line) => {
    let id = line.reduce(([x, y], d) => move(x, y, d), [0, 0]);
    let k = id.join(',');

    if (t.has(k)) {
      t.delete(k);
    } else {
      t.add(k);
    }

    return t;
  }, new Set());
}

function step(tiles) {
  const coords = [...tiles.keys()].map(x => x.split(',').map(x => +x));
  return coords.reduce((s, [x, y]) => {
    let n = neighbours(x, y);
    n.push([x, y]);
    n.forEach(([x, y]) => {
      let c = neighbours(x, y).filter(p => tiles.has(p.join(','))).length;
      let k = [x, y].join(',');
      if (tiles.has(k)) {
        if (c === 1 || c === 2) {
          s.add(k);
        }
      } else {
        if (c === 2) {
          s.add(k);
        }
      }
    });

    return s;
  }, new Set());
}

function move(x, y, d) {
  let dv = isOffset(x, y) ? NEIGHBOURS_OFFSET[d] : NEIGHBOURS[d];

  return [x + dv[0], y + dv[1]];
}

function isOffset(x, y) {
  return Math.abs(y) % 2;
}

function neighbours(x, y) {
  return Object.values(
    isOffset(x, y) ? NEIGHBOURS_OFFSET : NEIGHBOURS
  ).map(([dx, dy]) => [x + dx, y + dy]);
}
