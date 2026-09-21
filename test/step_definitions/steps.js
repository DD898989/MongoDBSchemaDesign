const { Given, When, Then } = require('@cucumber/cucumber');
const assert = require('assert');

function resolvePlaceholders(str, variables) {
  return str.replace(/\{([a-zA-Z0-9_]+)\}/g, (match, varName) => {
    if (varName in variables) {
      return variables[varName];
    }
    return match;
  });
}

function matchPattern(actual, expected, variables = {}) {
  if (typeof expected === 'string' && expected.startsWith('{') && expected.endsWith('}')) {
    const varName = expected.slice(1, -1);
    if (!(varName in variables)) {
      variables[varName] = actual;
    } else {
      assert.strictEqual(actual, variables[varName], `Value mismatch for variable ${varName}: expected "${variables[varName]}", got "${actual}"`);
    }
    return;
  }

  if (typeof expected !== typeof actual) {
    throw new assert.AssertionError({
      message: `Type mismatch: expected ${typeof expected} (${JSON.stringify(expected)}), got ${typeof actual} (${JSON.stringify(actual)})`,
      actual,
      expected
    });
  }

  if (expected === null || actual === null) {
    assert.strictEqual(actual, expected);
    return;
  }

  if (typeof expected === 'object') {
    if (Array.isArray(expected)) {
      if (!Array.isArray(actual)) {
        throw new assert.AssertionError({ message: 'Expected an array', actual, expected });
      }
      assert.strictEqual(actual.length, expected.length, `Array length mismatch: expected ${expected.length}, got ${actual.length}`);
      for (let i = 0; i < expected.length; i++) {
        matchPattern(actual[i], expected[i], variables);
      }
    } else {
      for (const key of Object.keys(expected)) {
        if (!(key in actual)) {
          throw new assert.AssertionError({ message: `Missing expected key: ${key}`, actual, expected });
        }
        matchPattern(actual[key], expected[key], variables);
      }
    }
  } else {
    assert.strictEqual(actual, expected);
  }
}

// Background
Given('測試的 API 服務主機為 {string}', async function (hostUrl) {
  this.host = hostUrl;
  this.variables = {};
  this.lastResponse = null;

  const res = await fetch(`${this.host}/api/clear`, { method: 'POST' });
  if (!res.ok) {
    throw new Error('Failed to clear database');
  }
});

// Generic assertion step
Then('回傳：', function (docString) {
  const expected = JSON.parse(docString);
  matchPattern(this.lastResponse, expected, this.variables);
});

// Generic Side-by-Side POST step (Requests on the left, Responses on the right)
When('我對 {string} 發送 POST 請求，對照如下：', async function (path, docString) {
  const lines = docString.split('\n');
  const leftLines = [];
  const rightLines = [];

  for (const line of lines) {
    const pipeIndex = line.indexOf('|');
    if (pipeIndex !== -1) {
      leftLines.push(line.substring(0, pipeIndex));
      rightLines.push(line.substring(pipeIndex + 1));
    } else {
      leftLines.push(line);
    }
  }

  const cleanLeft = leftLines
    .filter(l => !/REQ\s*\(|Request/i.test(l))
    .join('\n')
    .trim();

  const cleanRight = rightLines
    .filter(l => !/RESP\s*\(|Response/i.test(l))
    .join('\n')
    .trim();

  const resolvedLeft = resolvePlaceholders(cleanLeft, this.variables);
  const reqBody = JSON.parse(resolvedLeft);
  const expectedRes = JSON.parse(cleanRight);

  // Side-effect: If this is the extended reference user creation API, store the user name
  if (path.includes('extended-references/users') && reqBody.name) {
    this.variables['createdUserName'] = reqBody.name;
  }

  const actualPath = resolvePlaceholders(path, this.variables);
  const res = await fetch(`${this.host}${actualPath}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(reqBody)
  });
  this.lastResponse = await res.json();

  matchPattern(this.lastResponse, expectedRes, this.variables);
});

// Sequential, multi-block Side-by-Side POST step
When('我對 {string} 依序發送 POST 請求，對照如下：', async function (path, docString) {
  const blocks = docString.split(/\n\s*-{10,}\s*\n/);

  for (const block of blocks) {
    if (block.trim() === '') continue;

    const lines = block.split('\n');
    const leftLines = [];
    const rightLines = [];

    for (const line of lines) {
      const pipeIndex = line.indexOf('|');
      if (pipeIndex !== -1) {
        leftLines.push(line.substring(0, pipeIndex));
        rightLines.push(line.substring(pipeIndex + 1));
      } else {
        leftLines.push(line);
      }
    }

    const cleanLeft = leftLines
      .filter(l => !/REQ\s*\(|Request/i.test(l))
      .join('\n')
      .trim();

    const cleanRight = rightLines
      .filter(l => !/RESP\s*\(|Response/i.test(l))
      .join('\n')
      .trim();

    if (cleanLeft === '' && cleanRight === '') continue;

    const resolvedLeft = resolvePlaceholders(cleanLeft, this.variables);
    const reqBody = JSON.parse(resolvedLeft);
    const expectedRes = JSON.parse(cleanRight);

    const actualPath = resolvePlaceholders(path, this.variables);
    const res = await fetch(`${this.host}${actualPath}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(reqBody)
    });
    this.lastResponse = await res.json();

    matchPattern(this.lastResponse, expectedRes, this.variables);
  }
});


