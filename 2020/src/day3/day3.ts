import * as fs from 'fs';
import * as path from 'path';

const lines = fs
  .readFileSync(path.join(__dirname, 'input.txt'), 'utf8')
  .toString()
  .trim()
  .split('\n')
  .map(l => l.split(''));

console.log('Part 1:', part1(lines));
console.log('Part 2:', part2(lines));

function part1(lines): number {
  return treesHit(lines, 3, 1);
}

function part2(lines) {
  return [
    [1, 1],
    [3, 1],
    [5, 1],
    [7, 1],
    [1, 2],
  ]
    .map(([mx, my]) => {
      return treesHit(lines, mx, my);
    })
    .reduce((acc, n) => acc * n, 1);
}

function treesHit(lines, mx, my) {
  const numCols = lines[0].length;

  let numTrees = 0;
  let x = mx;
  for (let y = my; y < lines.length; y += my, x += mx) {
    if (lines[y][x % numCols] === '#') {
      numTrees++;
    }
  }

  return numTrees;
}
