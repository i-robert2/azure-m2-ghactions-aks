import test from "node:test";
import assert from "node:assert";
import { validateTitle } from "./notes";

test("validateTitle trims a valid title", () => {
  assert.equal(validateTitle("  hello  "), "hello");
});

test("validateTitle rejects empty", () => {
  assert.throws(() => validateTitle("   "));
});

test("validateTitle rejects non-string", () => {
  assert.throws(() => validateTitle(42));
});
