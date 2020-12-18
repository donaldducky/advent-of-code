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
  .map(x => x.replace(/ /g, '').split(''));
let p1 = part1(lines);
console.log('Part 1:', p1);
let p2 = part2(lines);
console.log('Part 2:', p2);

function part1(lines) {
  //console.log(lines);
  return lines.reduce((sum, tokens) => {
    //console.log(tokens.join(' '));
    let depth = 0;
    let nested = [[]];
    for (let i = 0; i < tokens.length; i++) {
      //console.log(tokens[i]);
      switch (tokens[i]) {
        case '+':
          nested[depth].push('+');
          break;
        case '*':
          nested[depth].push('*');
          break;
        case '(':
          depth++;
          nested[depth] = [];
          break;
        case ')': {
          let n = nested[depth].pop();
          depth--;
          if (nested[depth].length) {
            let op = nested[depth].pop();
            //console.log(n, op);
            switch (op) {
              case '+':
                nested[depth][0] = nested[depth][0] + n;
                break;
              case '*':
                nested[depth][0] = nested[depth][0] * n;
                break;
              default:
                throw new Error(`unsupported op ${op}`);
            }
          } else {
            nested[depth][0] = n;
          }
          break;
        }
        default:
          if (nested[depth].length === 0) {
            nested[depth].push(+tokens[i]);
          } else {
            let op = nested[depth].pop();
            switch (op) {
              case '+':
                nested[depth][0] = nested[depth][0] + +tokens[i];
                break;
              case '*':
                nested[depth][0] = nested[depth][0] * +tokens[i];
                break;
              default:
                throw new Error(`unsupported op ${op}`);
            }
          }
          break;
      }
    }
    //console.log(nested[0][0]);

    return sum + nested[0].pop();
  }, 0);
}

function part2(lines) {
  //console.log(lines);
  return lines.reduce((sum, tokens) => {
    //console.log(tokens.join(' '));
    let d = 0;
    let nested = [[]];
    for (let i = 0; i < tokens.length; i++) {
      let t = tokens[i];
      switch (t) {
        case '+':
          nested[d].push(t);
          break;
        case '*':
          nested[d].push(t);
          break;
        case '(':
          d++;
          nested[d] = [];
          break;
        case ')': {
          let ans = evaluate(nested[d]);
          d--;
          nested[d].push(ans);
          break;
        }
        default:
          nested[d].push(+t);
      }
    }
    //console.log(nested, '\n');
    let a = evaluate(nested[0]);

    //console.log(a);

    return sum + a;
  }, 0);
}

function evaluate(tokens) {
  //console.log('evaluate', tokens);
  // addition
  let q = [];
  for (let i = 0; i < tokens.length; i++) {
    let t = tokens[i];
    switch (t) {
      case '+':
        q.push(t);
        break;
      case '*':
        q.push(t);
        break;
      default:
        if (q.length === 0 || q[q.length - 1] == '*') {
          q.push(t);
        } else {
          // add
          q.pop();
          q[q.length - 1] += t;
        }
    }
  }

  // then multiplication
  return q.filter(t => t != '*').reduce((a, b) => a * b, 1);
}
