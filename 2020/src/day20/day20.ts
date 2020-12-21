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
  .split('\n\n')
  .map(x => x.split('\n'));

//let p1 = part1(lines);
//console.log('Part 1:', p1);
test();
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  const size = Math.sqrt(lines.length);
  //console.log(size);

  let [tiles, lookup] = lines.reduce(
    ([tiles, lookup], x) => {
      let id = +x[0].replace(/Tile (\d+):/, '$1');
      let grid = x.slice(1).map(x => x.split(''));

      let top = '';
      let bottom = '';
      let right = '';
      let left = '';
      for (let x = 0; x < grid.length; x++) {
        for (let y = 0; y < grid[0].length; y++) {
          let t = grid[x][y];
          if (y == 0) {
            left += t;
          }
          if (y == grid.length - 1) {
            right += t;
          }
          if (x == 0) {
            top += t;
          }
          if (x == grid[0].length - 1) {
            bottom += t;
          }
        }
      }

      //console.log(id, top, bottom, left, right);

      tiles[id] = {
        grid,
        top,
        bottom,
        left,
        right,
      };

      let ht = getHash(tiles[id], 'top');
      let hb = getHash(tiles[id], 'bottom');
      let hr = getHash(tiles[id], 'right');
      let hl = getHash(tiles[id], 'left');
      if (ht != top) {
        console.log(`error ${ht} != ${top}`);
      } else if (hb != bottom) {
        console.log(`error ${hb} != ${bottom}`);
      } else if (hl != left) {
        console.log(`error ${hl} != ${left}`);
      } else if (hr != right) {
        console.log(`error ${hr} != ${right}`);
      }

      lookup = [left, right, top, bottom].reduce((lookup, k) => {
        if (!(k in lookup)) {
          lookup[k] = [];
        }
        let r = k.split('').reverse().join('');
        if (!(r in lookup)) {
          lookup[r] = [];
        }

        lookup[k].push(id);
        lookup[r].push(id);

        return lookup;
      }, lookup);

      //console.log(lookup);

      return [tiles, lookup];
    },
    [{}, {}]
  );
  //console.log(tiles, lookup);

  lookup = Object.entries(lookup)
    .filter(([, v]) => (v as number[]).length > 1)
    .map(([k, v]) => {
      (v as number[]).sort((a, b) => a - b);
      return [k, v];
    });
  //console.log(lookup);

  let shared = lookup
    .map(x => x[1])
    .flat()
    .reduce((counts, id) => {
      if (!(id in counts)) {
        counts[id] = 0;
      }
      counts[id]++;
      return counts;
    }, {});
  //console.log(shared);
  let corners = Object.entries(shared).filter(x => x[1] == 4);

  return corners.map(x => +x[0]).reduce((a, b) => a * b, 1);
}

function part2(lines) {
  const size = Math.sqrt(lines.length);
  //console.log(size);

  let [tiles, lookup] = lines.reduce(
    ([tiles, lookup], x) => {
      let id = +x[0].replace(/Tile (\d+):/, '$1');
      let grid = x.slice(1).map(x => x.split(''));

      let top = '';
      let bottom = '';
      let right = '';
      let left = '';
      for (let x = 0; x < grid.length; x++) {
        for (let y = 0; y < grid[0].length; y++) {
          let t = grid[x][y];
          if (y == 0) {
            left += t;
          }
          if (y == grid.length - 1) {
            right += t;
          }
          if (x == 0) {
            top += t;
          }
          if (x == grid[0].length - 1) {
            bottom += t;
          }
        }
      }

      //console.log(id, top, bottom, left, right);

      tiles[id] = {
        grid,
        rotation: 0,
        flipV: false,
        flipH: false,
      };
      lookup = [left, right, top, bottom].reduce((lookup, k) => {
        if (!(k in lookup)) {
          lookup[k] = [];
        }
        let r = k.split('').reverse().join('');
        if (!(r in lookup)) {
          lookup[r] = [];
        }

        lookup[k].push(id);
        lookup[r].push(id);

        return lookup;
      }, lookup);

      //console.log(lookup);

      return [tiles, lookup];
    },
    [{}, {}]
  );
  //console.log(tiles, lookup);

  let shared = Object.entries(lookup)
    .filter(([, v]) => (v as number[]).length > 1)
    .map(([k, v]) => {
      (v as number[]).sort((a, b) => a - b);
      return [k, v];
    })
    .map(x => x[1])
    .flat()
    .reduce((counts: object, id: number) => {
      if (!(id in counts)) {
        counts[id] = 0;
      }
      counts[id]++;
      return counts;
    }, {});
  //console.log(Object.entries(shared));
  //console.log(shared, lookup);
  let corners = Object.entries(shared)
    .filter(x => x[1] == 4)
    .map(x => x[0]);
  //console.log(corners, lookup);

  let grid = new Array(size).fill(false).map(() => new Array(size).fill(false));
  // find top left corner, it can be left/bottom or right/top
  let topCorner = corners.find(id => {
    let t = tiles[id];
    let ds = ['left', 'right', 'top', 'bottom']
      .map(d => [d, lookup[getHash(t, d)].filter(n => n != id)])
      .filter(x => x[1].length > 0)
      .map(x => x[0]);

    return (
      (ds.includes('right') && ds.includes('bottom')) ||
      (ds.includes('left') && ds.includes('top'))
    );
  });
  //console.log('top corner', topCorner);
  if (!topCorner) {
    throw new Error('could not find top corner');
  }

  grid[0][0] = +topCorner;
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      let id = grid[y][x];
      let t = tiles[id];
      let shared = ['left', 'right', 'top', 'bottom']
        .map(d => [d, lookup[getHash(t, d)].filter(n => n != id)])
        .filter(x => x[1].length > 0)
        .map(x => [x[0], x[1][0]])
        .reduce((acc, [d, id]) => {
          acc[d] = id;
          return acc;
        }, {});
      console.log(x, y, id, shared);

      if (x == 0 && y == 0) {
        // rotate?
        // first iteration let's orient to top left corner
        if (!('right' in shared)) {
          t = rotateRight(t, 2);
        }
      } else if (x > 0) {
        // we are going right, check left
        let prevId = grid[y][x - 1];
        let prevT = tiles[prevId];
        // TODO apply rotation to prevT to get current "right"
        // TODO find matching side and rotate as necessary
        if (shared['left'] == prevId) {
        } else if (shared['bottom'] == prevId) {
          t = rotateRight(t, 1);
          shared = rotateShared(shared, 1);
        } else if (shared['right'] == prevId) {
          t = rotateRight(t, 2);
          shared = rotateShared(shared, 2);
        } else if (shared['top'] == prevId) {
          t = rotateRight(t, 3);
          shared = rotateShared(shared, 3);
        }
        let left = getHash(prevT, 'right');
        let right = getHash(t, 'left');
        if (left != right) {
          t.flipV = true;
          let newShared = {};
          if ('bottom' in shared) {
            newShared['top'] = shared['bottom'];
          }
          if ('top' in shared) {
            newShared['bottom'] = shared['top'];
          }
          if ('left' in shared) {
            newShared['left'] = shared['left'];
          }
          if ('right' in shared) {
            newShared['right'] = shared['right'];
          }
          shared = newShared;
          console.log(shared);
          if (getHash(t, 'left') != left) {
            throw new Error('flipping did not work');
          }
        }
      } else {
        // we are going down, check up
        let prevId = grid[y - 1][x];
        let prevT = tiles[prevId];
        if (shared['top'] == prevId) {
        } else if (shared['left'] == prevId) {
          t = rotateRight(t, 1);
          shared = rotateShared(shared, 1);
        } else if (shared['bottom'] == prevId) {
          t = rotateRight(t, 2);
          shared = rotateShared(shared, 2);
        } else if (shared['right'] == prevId) {
          t = rotateRight(t, 3);
          shared = rotateShared(shared, 3);
        }
        let top = getHash(prevT, 'bottom');
        let bottom = getHash(t, 'top');
        if (bottom != top) {
          t.flipH = true;
          let newShared = {};
          if ('bottom' in shared) {
            newShared['bottom'] = shared['bottom'];
          }
          if ('top' in shared) {
            newShared['top'] = shared['top'];
          }
          if ('left' in shared) {
            newShared['right'] = shared['left'];
          }
          if ('right' in shared) {
            newShared['left'] = shared['right'];
          }
          shared = newShared;
          if (getHash(t, 'top') != top) {
            throw new Error('flipping did not work');
          }
        }
      }
      if ('right' in shared) {
        if (x + 1 > size - 1) {
          console.error('waaaaaaaaaaaaat', id);
        }
        grid[y][x + 1] = shared['right'];
      }
      if ('bottom' in shared) {
        if (y + 1 > size - 1) {
          /*
          console.log(t);
          console.log(lookup2);
          */
          console.error('waaaaaaaaaaaaat', id);
        }
        grid[y + 1][x] = shared['bottom'];
      }
      console.log(
        grid
          .map(l => l.map(x => (x == false ? 'xxxx' : x)).join(','))
          .join('\n')
      );
      console.log('---');
    }
  }
  //console.log(grid);

  let n = tiles[grid[0][0]].grid.length;
  console.log(n, (n - 2) * size);
  let superGrid = new Array((n - 2) * size)
    .fill(false)
    .map(() => new Array((n - 2) * size).fill(false));
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      let id = grid[y][x];
      let t = tiles[id];
      /*
      console.log(grid[y][x]);
      console.log(draw(getGrid(t)));
      */
      let offsetX = x * (n - 2);
      let offsetY = y * (n - 2);
      let g = getGrid(t);
      for (let y2 = 0; y2 < n - 2; y2++) {
        for (let x2 = 0; x2 < n - 2; x2++) {
          //console.log(offsetX + x2, offsetY + y2);
          superGrid[offsetY + y2][offsetX + x2] = g[y2 + 1][x2 + 1];
        }
      }
    }
  }
  let seaMonster = `..................#.
#....##....##....###
.#..#..#..#..#..#...`
    .split('\n')
    .map(l => l.split(''));
  //console.log(seaMonster);
  let sm = [];
  for (let y = 0; y < seaMonster.length; y++) {
    for (let x = 0; x < seaMonster[0].length; x++) {
      if (seaMonster[y][x] == '#') {
        sm.push([x, y]);
      }
    }
  }
  //console.log(sm);

  /*
  let tile = {
    grid: superGrid,
    rotation: 90,
    flipV: false,
    flipH: false,
  };
  let g2 = getGrid(tile);
  */
  //console.log(g2);
  const props = [0, 90, 180, 270].reduce((acc, rot) => {
    acc = [
      [false, false],
      [true, false],
      [false, true],
    ].reduce((acc, [flipV, flipH]) => {
      acc.push([rot, flipV, flipH]);
      return acc;
    }, acc);

    return acc;
  }, []);
  console.log(props);

  let g2;
  props.find(([rotation, flipV, flipH]) => {
    const t = {
      grid: superGrid,
      rotation,
      flipV,
      flipH,
    };
    g2 = getGrid(t);
    let found = false;
    for (let y = 0; y < g2.length - seaMonster.length + 1; y++) {
      for (let x = 0; x < g2[0].length - seaMonster[0].length; x++) {
        if (sm.every(([mx, my]) => g2[y + my][x + mx] == '#')) {
          found = true;
          console.log('found sea monster at', x, y);
          sm.forEach(([mx, my]) => {
            g2[y + my][x + mx] = 'O';
          });
        }
      }
    }

    return found;
  });
  /*
  tile = {
    grid: g2,
    rotation: 0,
    flipV: false,
    flipH: false,
  };
  console.log(draw(getGrid(tile)));
  */
  return g2.flat().filter(x => x == '#').length;
}

function rotateRight(t, n) {
  t.rotation = (t.rotation + 90 * n) % 360;

  return t;
}

function getHash(t, direction) {
  let size = t.grid.length;
  const dirs: { [key: string]: [number, number, number, number] } = {
    top: [0, 0, size, 1],
    bottom: [0, size - 1, size, 1],
    left: [0, 0, 1, size],
    right: [size - 1, 0, 1, size],
  };

  const g = getGrid(t);
  let d;
  switch (direction) {
    case 'top':
      d = rect(g, dirs.top);
      break;
    case 'bottom':
      d = rect(g, dirs.bottom);
      break;
    case 'left':
      d = rect(g, dirs.left);
      break;
    case 'right':
      d = rect(g, dirs.right);
      break;
    default:
      throw new Error(`invalid direction ${direction}`);
  }

  return d.join('');
}

/*
function getHash(t, direction) {
  let size = t.grid.length;
  const dirs: { [key: string]: [number, number, number, number] } = {
    top: [0, 0, size, 1],
    bottom: [0, size - 1, size, 1],
    left: [0, 0, 1, size],
    right: [size - 1, 0, 1, size],
  };
  if (t.flipV && t.flipH) {
    throw new Error(
      'Currently does not support flipping horizontally and vertically, it is a 180 rotation'
    );
  }
  if (t.flipV && ['top', 'bottom'].includes(direction)) {
    direction = direction === 'top' ? 'bottom' : 'top';
  }
  if (t.flipH && ['left', 'right'].includes(direction)) {
    direction = direction === 'left' ? 'right' : 'left';
  }
  let d;
  switch (direction) {
    case 'top':
      switch (t.rotation) {
        case 0:
          d = rect(t.grid, dirs.top);
          break;
        case 90:
          d = rect(t.grid, dirs.left).reverse();
          break;
        case 180:
          d = rect(t.grid, dirs.bottom).reverse();
          break;
        case 270:
          d = rect(t.grid, dirs.right);
          break;
        default:
          throw new Error(`Unsupported rotation ${t.rotation}`);
      }
      break;
    case 'bottom':
      switch (t.rotation) {
        case 0:
          d = rect(t.grid, dirs.bottom);
          break;
        case 90:
          d = rect(t.grid, dirs.right).reverse();
          break;
        case 180:
          d = rect(t.grid, dirs.top).reverse();
          break;
        case 270:
          d = rect(t.grid, dirs.left);
          break;
        default:
          throw new Error(`Unsupported rotation ${t.rotation}`);
      }
      break;
    case 'left':
      switch (t.rotation) {
        case 0:
          d = rect(t.grid, dirs.left);
          break;
        case 90:
          d = rect(t.grid, dirs.bottom);
          if (t.flipV) {
            d = d.reverse();
          }
          break;
        case 180:
          d = rect(t.grid, dirs.right).reverse();
          break;
        case 270:
          d = rect(t.grid, dirs.top).reverse();
          break;
        default:
          throw new Error(`Unsupported rotation ${t.rotation}`);
      }
      break;
    case 'right':
      switch (t.rotation) {
        case 0:
          d = rect(t.grid, dirs.right);
          break;
        case 90:
          d = rect(t.grid, dirs.top);
          if (t.flipV) {
            d = d.reverse();
          }
          break;
        case 180:
          d = rect(t.grid, dirs.left).reverse();
          break;
        case 270:
          d = rect(t.grid, dirs.bottom).reverse();
          break;
        default:
          throw new Error(`Unsupported rotation ${t.rotation}`);
      }
      break;
    default:
      throw new Error(`invalid direction ${direction}`);
  }

  if (t.flipV && ['left', 'right'].includes(direction)) {
    return d.reverse().join('');
  }

  if (t.flipH && ['top', 'bottom'].includes(direction)) {
    return d.reverse().join('');
  }

  return d.join('');
}
*/

function rect(grid, [x0, y0, w, h]) {
  //console.log(`x=${x0}, y=${y0}, w=${w}, h=${w}`);
  let d = [];
  for (let y = y0; y < y0 + h; y++) {
    for (let x = x0; x < x0 + w; x++) {
      //console.log(x, y, grid[y][x]);
      d.push(grid[y][x]);
    }
  }

  return d;
}

function test() {
  let str = `#.#.#####.
.#..######
..#.......
######....
####.#..#.
.#...#.##.
#.#####.##
..#.###...
..#.......
..#.###...`;
  let grid = str.split('\n').map(x => x.split(''));
  let t = {
    grid,
    rotation: 0,
    flipV: false,
    flipH: false,
  };
  //console.log(str, grid);
  //console.log(t);

  t.rotation = 0;
  assertEquals('#.#.#####.', getHash(t, 'top'), 'r0 top');
  assertEquals('..#.###...', getHash(t, 'bottom'), 'r0 bottom');
  assertEquals('#..##.#...', getHash(t, 'left'), 'r0 left');
  assertEquals('.#....#...', getHash(t, 'right'), 'r0 right');
  t.rotation = 90;
  assertEquals('...#.##..#', getHash(t, 'top'), 'r90 top');
  assertEquals('...#....#.', getHash(t, 'bottom'), 'r90 bottom');
  assertEquals('..#.###...', getHash(t, 'left'), 'r90 left');
  assertEquals('#.#.#####.', getHash(t, 'right'), 'r90 right');
  t.rotation = 180;
  assertEquals('...###.#..', getHash(t, 'top'), 'r180 top');
  assertEquals('.#####.#.#', getHash(t, 'bottom'), 'r180 bottom');
  assertEquals('...#....#.', getHash(t, 'left'), 'r180 left');
  assertEquals('...#.##..#', getHash(t, 'right'), 'r180 right');
  t.rotation = 270;
  assertEquals('.#....#...', getHash(t, 'top'), 'r270 top');
  assertEquals('#..##.#...', getHash(t, 'bottom'), 'r270 bottom');
  assertEquals('.#####.#.#', getHash(t, 'left'), 'r270 left');
  assertEquals('...###.#..', getHash(t, 'right'), 'r270 right');
  t.rotation = 0;

  t.flipV = true;
  assertEquals('..#.###...', getHash(t, 'top'), 'fV top');
  assertEquals('#.#.#####.', getHash(t, 'bottom'), 'fV bottom');
  assertEquals('...#.##..#', getHash(t, 'left'), 'fV left');
  assertEquals('...#....#.', getHash(t, 'right'), 'fV right');
  t.rotation = 90;
  assertEquals('...#....#.', getHash(t, 'top'), 'fV r90 top');
  assertEquals('...#.##..#', getHash(t, 'bottom'), 'fV r90 bottom');
  assertEquals('...###.#..', getHash(t, 'left'), 'fV r90 left');
  assertEquals('.#####.#.#', getHash(t, 'right'), 'fV r90 right');
  t.rotation = 180;
  assertEquals('.#####.#.#', getHash(t, 'top'), 'fV r180 top');
  assertEquals('...###.#..', getHash(t, 'bottom'), 'fV r180 bottom');
  assertEquals('.#....#...', getHash(t, 'left'), 'fV r180 left');
  assertEquals('#..##.#...', getHash(t, 'right'), 'fV r180 right');
  t.rotation = 270;
  assertEquals('#..##.#...', getHash(t, 'top'), 'fV r270 top');
  assertEquals('.#....#...', getHash(t, 'bottom'), 'fV r270 bottom');
  assertEquals('#.#.#####.', getHash(t, 'left'), 'fV r270 left');
  assertEquals('..#.###...', getHash(t, 'right'), 'fV r270 right');
  t.rotation = 0;
  t.flipV = false;

  t.flipH = true;
  assertEquals('.#####.#.#', getHash(t, 'top'), 'fH top');
  assertEquals('...###.#..', getHash(t, 'bottom'), 'fH bottom');
  assertEquals('.#....#...', getHash(t, 'left'), 'fH left');
  assertEquals('#..##.#...', getHash(t, 'right'), 'fH right');
  t.rotation = 90;
  assertEquals('#..##.#...', getHash(t, 'top'), 'fH r90 top');
  assertEquals('.#....#...', getHash(t, 'bottom'), 'fH r90 bottom');
  assertEquals('#.#.#####.', getHash(t, 'left'), 'fH r90 left');
  assertEquals('..#.###...', getHash(t, 'right'), 'fH r90 right');
  t.rotation = 180;
  assertEquals('..#.###...', getHash(t, 'top'), 'fH r180 top');
  assertEquals('#.#.#####.', getHash(t, 'bottom'), 'fH r180 bottom');
  assertEquals('...#.##..#', getHash(t, 'left'), 'fH r180 left');
  assertEquals('...#....#.', getHash(t, 'right'), 'fH r180 right');
  t.rotation = 270;
  assertEquals('...#....#.', getHash(t, 'top'), 'fH r270 top');
  assertEquals('...#.##..#', getHash(t, 'bottom'), 'fH r270 bottom');
  assertEquals('...###.#..', getHash(t, 'left'), 'fH r270 left');
  assertEquals('.#####.#.#', getHash(t, 'right'), 'fH r270 right');
  t.rotation = 0;
  t.flipH = false;

  /*
  str = `###
##.
#..`;
  grid = str.split('\n').map(x => x.split(''));
  t = {
    grid,
    rotation: 0,
    flipV: false,
    flipH: false,
  };
  console.log(draw(getGrid(t)));
  console.log('---------------');
  t.rotation = 90;
  console.log(draw(getGrid(t)));
  console.log('---------------');
  t.rotation = 180;
  console.log(draw(getGrid(t)));
  console.log('---------------');
  t.rotation = 270;
  console.log(draw(getGrid(t)));

  console.log('------flipV----');
  t.rotation = 0;
  t.flipV = true;
  console.log(draw(getGrid(t)));
  console.log('---------------');
  t.rotation = 90;
  t.flipV = true;
  console.log(draw(getGrid(t)));
  console.log('---------------');
  t.rotation = 180;
  t.flipV = true;
  console.log(draw(getGrid(t)));
  console.log('---------------');
  t.rotation = 270;
  t.flipV = true;
  console.log(draw(getGrid(t)));
  t.flipV = false;

  console.log('------flipH----');
  t.rotation = 0;
  t.flipH = true;
  console.log(draw(getGrid(t)));
  console.log('---------------');
  t.rotation = 90;
  t.flipH = true;
  console.log(draw(getGrid(t)));
  console.log('---------------');
  t.rotation = 180;
  t.flipH = true;
  console.log(draw(getGrid(t)));
  console.log('---------------');
  t.rotation = 270;
  t.flipH = true;
  console.log(draw(getGrid(t)));
  */

  //throw new Error('done testing');
}

function assertEquals(a, b, str = '') {
  if (a !== b) {
    console.log(`[${str}]`);
    console.error(`Error: ${a} !== ${b}`);
  }
}

function getGrid(t) {
  const size = t.grid.length;

  if (t.flipH && t.flipV) {
    throw new Error('cannot flip both directions');
  }

  let grid = new Array(size).fill(false).map(() => new Array(size).fill(false));
  switch (t.rotation) {
    case 0:
      for (let y = 0; y < size; y++) {
        for (let x = 0; x < size; x++) {
          grid[y][x] = t.grid[y][x];
        }
      }
      break;
    case 90:
      for (let y = 0; y < size; y++) {
        for (let x = 0; x < size; x++) {
          grid[y][x] = t.grid[size - 1 - x][y];
        }
      }
      break;
    case 180:
      for (let y = 0; y < size; y++) {
        for (let x = 0; x < size; x++) {
          grid[y][x] = t.grid[size - 1 - y][size - 1 - x];
        }
      }
      break;
    case 270:
      for (let y = 0; y < size; y++) {
        for (let x = 0; x < size; x++) {
          grid[y][x] = t.grid[x][size - 1 - y];
        }
      }
      break;
  }

  if (t.flipV) {
    let newGrid = new Array(size)
      .fill(false)
      .map(() => new Array(size).fill(false));
    for (let y = 0; y < size; y++) {
      for (let x = 0; x < size; x++) {
        newGrid[y][x] = grid[size - 1 - y][x];
      }
    }
    grid = newGrid;
  }
  if (t.flipH) {
    let newGrid = new Array(size)
      .fill(false)
      .map(() => new Array(size).fill(false));
    for (let y = 0; y < size; y++) {
      for (let x = 0; x < size; x++) {
        newGrid[y][x] = grid[y][size - 1 - x];
      }
    }
    grid = newGrid;
  }

  return grid;
}

function draw(grid) {
  return grid.map(x => x.join('')).join('\n');
}

function rotateShared(shared, n) {
  let s = Object.fromEntries(Object.entries(shared));

  while (n > 0) {
    n--;
    let newShared = {};
    if ('right' in s) {
      newShared['bottom'] = s['right'];
    }
    if ('bottom' in s) {
      newShared['left'] = s['bottom'];
    }
    if ('left' in s) {
      newShared['top'] = s['left'];
    }
    if ('top' in s) {
      newShared['right'] = s['top'];
    }
    s = newShared;
  }

  return s;
}
