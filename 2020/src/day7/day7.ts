import * as fs from 'fs';
import * as path from 'path';

const input = fs
  //.readFileSync(path.join(__dirname, 'sample.txt'), 'utf8')
  //.readFileSync(path.join(__dirname, 'sample2.txt'), 'utf8')
  .readFileSync(path.join(__dirname, 'input.txt'), 'utf8')
  .toString()
  .trim();
console.log('Part 1:', part1(input));
console.log('Part 2:', part2(input));

function part1(input) {
  let reverse = {};
  let bags = input
    .split('\n')
    .map(line => line.split(/contain/))
    .map(([bag, contains]) => [
      bag.trim().replace(/ bags$/, ''),
      contains
        .trim()
        .split(', ')
        .filter(x => !x.match(/no other/))
        .map(x => {
          const a = x
            .trim()
            .replace(/ bags| bag/, '')
            .replace(/\./, '')
            .split(' ');

          return [a.shift(), a.join(' ')];
        }),
    ])
    .filter(([bag, contains]) => contains.length > 0)
    .reduce((bags, [bag, contains]) => {
      bags[bag] = contains;
      contains.forEach(([count, id]) => {
        if (!(id in reverse)) {
          reverse[id] = [];
        }
        reverse[id].push([bag, count]);
        //console.log(bag, id);
      });
      return bags;
    }, {});
  //console.log('reverse', reverse);
  let colors = new Set();
  let open = reverse['shiny gold'];
  delete reverse['shiny gold'];
  while (open.length) {
    const [c /*count*/] = open.pop();
    colors.add(c);
    if (c in reverse) {
      open = open.concat(reverse[c]);
    }
    delete reverse[c];
  }

  //console.log(colors);

  return colors.size;
}

function part2(input) {
  let reverse = {};
  let bags = input
    .split('\n')
    .map(line => line.split(/contain/))
    .map(([bag, contains]) => {
      const b = bag.trim().replace(/ bags$/, '');
      let c;
      if (contains.match(/no other bags/)) {
        c = [];
      } else {
        c = contains
          .trim()
          .split(', ')
          .map(x => {
            const a = x
              .trim()
              .replace(/ bags| bag/, '')
              .replace(/\./, '')
              .split(' ');

            const r = [+a.shift(), a.join(' ')];
            //console.log(r);
            return r;
          });
      }

      return [b, c];
    })
    .reduce((bags, [bag, contains]) => {
      bags[bag] = contains;
      contains.forEach(([count, id]) => {
        if (!(id in reverse)) {
          reverse[id] = [];
        }
        reverse[id].push([bag, count]);
        //console.log(bag, id);
      });
      return bags;
    }, {});
  //console.log(bags);
  let count = 0;
  let open = [['shiny gold', 1]];
  while (open.length) {
    let [id, multiplier] = open.pop();
    let contains = bags[id];
    count += +multiplier;
    //console.log(id, multiplier, contains);
    contains.forEach(([count, id]) => {
      open.push([id, count * +multiplier]);
    });
  }

  return count - 1;
}
