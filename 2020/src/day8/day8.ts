import * as fs from 'fs';
import * as path from 'path';

let file = 'input.txt';
//file = 'sample.txt';
//file = 'sample2.txt';

const input = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim();

const lines = input
  .split('\n')
  .map(l => l.split(' '))
  .map(x => [x[0], parseInt(x[1], 10)]);

let acc = 0;
let i = 0;
let seen = new Set();

while (!seen.has(i)) {
  seen.add(i);
  const [op, v] = lines[i];
  switch (op) {
    case 'acc':
      acc += +v;
      i++;
      break;
    case 'nop':
      i++;
      break;
    case 'jmp':
      i += +v;
      break;
  }
  if (i === lines.length) {
    break;
  }
}

let p1 = acc;

console.log('Part 1:', p1);

let lastFlip;

while (!(i == lines.length)) {
  i = 0;
  acc = 0;
  seen = new Set();

  for (let j = lastFlip ?? 0; j < lines.length; j++) {
    if (j === lastFlip) continue;
    if (lines[j][0] === 'nop') {
      lines[j][0] = 'jmp';
      lastFlip = j;
      break;
    } else if (lines[j][0] === 'jmp') {
      lines[j][0] = 'nop';
      lastFlip = j;
      break;
    }
  }

  while (!seen.has(i)) {
    seen.add(i);
    const [op, v] = lines[i];
    switch (op) {
      case 'acc':
        acc += +v;
        i++;
        break;
      case 'nop':
        i++;
        break;
      case 'jmp':
        i += +v;
        break;
    }
    if (i === lines.length) {
      break;
    }
  }

  lines[lastFlip][0] = lines[lastFlip][0] == 'jmp' ? 'nop' : 'jmp';
}

let p2 = acc;

console.log('Part 2:', p2);
