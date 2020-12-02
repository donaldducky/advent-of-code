import * as fs from 'fs';
import * as path from 'path';

const nums = fs
  .readFileSync(path.join(__dirname, 'input.txt'), 'utf8')
  .toString()
  .trim()
  .split('\n')
  .map(i => parseInt(i, 10));

console.log('Part 1:', part1(nums));
console.log('Part 2:', part2(nums));

function part1(nums) {
  const numMap = nums.reduce((acc, n) => acc.add(n), new Set());

  const entry = nums.find(n => {
    return numMap.has(2020 - n);
  });

  return entry * (2020 - entry);
}

function part2(nums) {
  let list = [];

  nums.sort((n1, n2) => n1 - n2);

  for (let i = 0; i < nums.length && list.length === 0; i++) {
    for (let j = 0; j < nums.length && list.length === 0; j++) {
      if (nums[i] + nums[j] < 2020) {
        for (let k = 0; k < nums.length && list.length === 0; k++) {
          if (nums[i] + nums[j] + nums[k] === 2020) {
            list = [nums[i], nums[j], nums[k]];
          }
        }
      }
    }
  }

  return list.reduce((n, m) => n * m);
}
