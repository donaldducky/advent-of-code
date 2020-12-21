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
  let [rules, msgs] = lines;
  rules = rules.reduce((acc, x) => {
    let [id, rule] = x.split(': ');
    if (rule.includes('|')) {
      rule = rule.split(' | ').map(r => r.split(' '));
    } else if (rule.includes('"')) {
      rule = rule.replace(/"/g, '');
    } else {
      rule = rule.split(' ');
    }
    acc[id] = rule;

    return acc;
  }, {});
  //console.log(rules, msgs);

  // resolve 0
  let re = resolve(0, rules);
  re = `^${re}$`;
  //console.log(re);

  return msgs.filter(m => m.match(re)).length;
}

function part2(lines) {
  let [rules, msgs] = lines;
  rules = rules.reduce((acc, x) => {
    let [id, rule] = x.split(': ');
    /*
    switch (id) {
      case '8':
        // 42 | 42 (42 | 42 (42 | 42 8)
        //rule = '42 | 42 8';
        rule = '42+';
        break;
      case '11':
        //rule = '42 31 | 42 11 31';
        rule = '42 11* 31';
        break;
    }
    */

    if (rule.includes('|')) {
      rule = rule.split(' | ').map(r => r.split(' '));
    } else if (rule.includes('"')) {
      rule = rule.replace(/"/g, '');
    } else {
      rule = rule.split(' ');
    }
    acc[id] = rule;

    return acc;
  }, {});
  //console.log(rules, msgs);

  // resolve 0
  let re = resolve(0, rules, true);
  re = `^${re}$`;
  //console.log(re);

  return msgs.filter(m => m.match(re)).length;
}

function resolve(id, rules, isPart2 = false) {
  let r = rules[id];

  if (isPart2) {
    if (id == 8) {
      let re = resolve(42, rules);
      //console.log(8, '42', re);
      return `${re}+`;
    } else if (id == 11) {
      let re42 = resolve(42, rules);
      let re31 = resolve(31, rules);
      //console.log(11, re42, re31);
      return (
        re42 +
        new Array(20).fill(0).reduce(s => '(' + re42 + s + re31 + ')?', '') +
        re31
      );
    }
  }

  if (typeof r === 'string') {
    return r;
  } else if (Array.isArray(r)) {
    if (Array.isArray(r[0])) {
      return (
        '(' +
        r
          .map(xs => xs.map(x => resolve(x, rules, isPart2)).join(''))
          .join('|') +
        ')'
      );
    } else {
      return r.map(x => resolve(x, rules, isPart2)).join('');
    }
  }

  throw new Error('no thank you');
}
