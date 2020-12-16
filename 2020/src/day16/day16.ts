import * as fs from 'fs';
import * as path from 'path';

let file;
file = 'sample.txt';
file = 'sample2.txt';
file = 'input.txt';

const lines = fs
  .readFileSync(path.join(__dirname, file), 'utf8')
  .toString()
  .trim()
  .split('\n\n')
  .map(x => x.split('\n'));

let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  let [fields, , nearby] = lines;

  fields = fields
    .map(x => x.split(': '))
    .map(x => x[1].split(' or ').map(x => x.split('-').map(x => +x)))
    .flat();

  const valid = fields.reduce((s, [lo, hi]) => {
    for (let i = lo; i <= hi; i++) {
      s.add(i);
    }
    return s;
  }, new Set());

  nearby.shift();

  return nearby
    .map(x => x.split(',').map(x => +x))
    .map(ns => ns.filter(n => !valid.has(n)))
    .flat()
    .reduce((a, b) => a + b, 0);
}

function part2(lines) {
  let [fields, mine, nearby] = lines;

  let ranges = fields
    .map(x => x.split(': '))
    .map(x => x[1].split(' or ').map(x => x.split('-').map(x => +x)))
    .flat();

  fields = fields
    .map(x => x.split(': '))
    .map(x => [
      x[0],
      x[1]
        .split(' or ')
        .map(x => x.split('-').map(x => +x))
        .reduce((s, [lo, hi]) => {
          for (let i = lo; i <= hi; i++) {
            s.add(i);
          }
          return s;
        }, new Set()),
    ]);

  const valid = ranges.reduce((s, [lo, hi]) => {
    for (let i = lo; i <= hi; i++) {
      s.add(i);
    }
    return s;
  }, new Set());

  let nf = nearby[0].split(',').length;
  let transposed = [];
  for (let i = 0; i < nf; i++) {
    transposed.push([]);
  }
  transposed = nearby
    .map(x => x.split(',').map(x => +x))
    .filter(ns => ns.every(n => valid.has(n)))
    .reduce((a, ns) => {
      for (let i = 0; i < ns.length; i++) {
        a[i].push(ns[i]);
      }
      return a;
    }, transposed);

  let validCols = transposed.map((ns, i) => [
    i,
    fields.filter(([, s]) => ns.every(n => s.has(n))).map(x => x[0]),
  ]);

  let order = [];
  while (validCols.length) {
    let found = [];
    validCols
      .filter(([, names]) => names.length === 1)
      .forEach(([i, names]) => {
        order[i] = names[0];
        found.push(names[0]);
      });

    validCols = validCols
      .filter(([, cols]) => cols.length > 1)
      .map(([i, cols]) => [i, cols.filter(name => !found.includes(name))]);
  }

  return mine[1]
    .split(',')
    .map(n => +n)
    .filter((n, i) => order[i].match(/departure/))
    .reduce((a, b) => a * b, 1);
}
