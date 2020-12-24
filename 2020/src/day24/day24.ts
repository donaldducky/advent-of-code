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
  //console.log(lines);

  return lines.reduce((t, line) => {
    let id = line.reduce((p, d) => move(p, d), [0, 0]);
    let k = id.join(',');

    if (t.has(k)) {
      t.delete(k);
      //console.log(id, k, 'flip back to white');
    } else {
      t.add(k);
      //console.log(id, k, 'flip to black');
    }

    return t;
  }, new Set()).size;
}

function part2(lines) {
  let tiles = lines.reduce((t, line) => {
    let id = line.reduce((p, d) => move(p, d), [0, 0]);
    let k = id.join(',');

    if (t.has(k)) {
      t.delete(k);
    } else {
      t.add(k);
    }

    return t;
  }, new Set());

  console.log(tiles);
  const coords = [...tiles.keys()].map(x => x.split(','));
  const xs = coords.map(x => x[0]);
  const ys = coords.map(x => x[1]);
  const minX = Math.min(...xs);
  const maxX = Math.max(...xs);
  const minY = Math.min(...ys);
  const maxY = Math.max(...ys);
  console.log(coords, minX, maxX, minY, maxY);

  for (let i = 0; i < 100; i++) {
    let tiles2 = new Set();
    for (let x = minX - i - 100; x < maxX + i + 100; x++) {
      for (let y = minY - i - 100; y < minY + i + 100; y++) {
        let n = neighbours(x, y).filter(p => tiles.has(p.join(','))).length;
        let t = [x, y].join(',');
        if (tiles.has(t)) {
          if (n === 1 || n === 2) {
            tiles2.add(t);
          }
        } else {
          if (n === 2) {
            tiles2.add(t);
          }
        }
      }
    }
    tiles = tiles2;
  }

  return tiles.size;
}

function move(p, d) {
  let [x, y] = p;
  const offset = Math.abs(p[1]) % 2;
  switch (d) {
    case E:
      x++;
      break;
    case W:
      x--;
      break;
    case SE:
      if (offset) {
        x++;
        y++;
      } else {
        y++;
      }
      break;
    case SW:
      if (offset) {
        y++;
      } else {
        x--;
        y++;
      }
      break;
    case NE:
      if (offset) {
        x++;
        y--;
      } else {
        y--;
      }
      break;
    case NW:
      if (offset) {
        y--;
      } else {
        x--;
        y--;
      }
      break;
    default:
      throw new Error(`unknown ${d}`);
  }

  return [x, y];
}

function neighbours(x, y) {
  const offset = Math.abs(y) % 2;
  if (offset) {
    return [
      [x + 1, y],
      [x - 1, y],
      [x + 1, y + 1],
      [x, y + 1],
      [x + 1, y - 1],
      [x, y - 1],
    ];
  } else {
    return [
      [x + 1, y],
      [x - 1, y],
      [x, y + 1],
      [x - 1, y + 1],
      [x, y - 1],
      [x - 1, y - 1],
    ];
  }
}
