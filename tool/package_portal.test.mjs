import test from "node:test";
import assert from "node:assert/strict";
import {
  mkdtempSync,
  mkdirSync,
  writeFileSync,
  rmSync,
  symlinkSync,
  existsSync,
  readFileSync,
} from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname } from "node:path";
import {
  loadCatalog,
  createPortalServer,
  buildPortal,
} from "./package_portal.mjs";

function fixture(t) {
  const root = mkdtempSync(join(tmpdir(), "sdk-portal-"));
  t.after(() => rmSync(root, { recursive: true, force: true }));
  const write = (path, text) => {
    mkdirSync(dirname(join(root, path)), { recursive: true });
    writeFileSync(join(root, path), text);
  };
  write(
    "docs/package-catalog.json",
    JSON.stringify({
      packages: [
        {
          name: "alpha",
          path: "alpha",
          stage: "candidate",
          group: "app-library",
        },
        {
          name: "removed",
          path: "removed",
          stage: "development",
          group: "compatibility",
        },
      ],
    }),
  );
  write(
    "alpha/pubspec.yaml",
    'name: alpha\nversion: 1.0.0-rc.1\ndescription: "Actual description"\ndependencies:\n  flutter:\n    sdk: flutter\n  removed:\n    path: ../removed\n  external: ^2.0.0\n',
  );
  write("alpha/README.md", "# Alpha\nActual docs");
  write("web/index.html", "<!doctype html><title>Portal</title>");
  return { root, write };
}

test("reads actual versions, documents and dependency sources, retaining missing packages", (t) => {
  const { root } = fixture(t);
  const catalog = loadCatalog(root);
  assert.equal(catalog.packages.length, 2);
  const alpha = catalog.packages.find((pkg) => pkg.name === "alpha");
  assert.equal(alpha.version, "1.0.0-rc.1");
  assert.equal(alpha.documents.readme, "# Alpha\nActual docs");
  assert.equal(alpha.type, "Flutter package");
  assert.equal(
    alpha.dependencies.find((dep) => dep.name === "flutter").source,
    "sdk",
  );
  assert.deepEqual(
    alpha.dependencies.find((dep) => dep.name === "removed"),
    {
      name: "removed",
      source: "local",
      version: "",
      path: "../removed",
      target: "removed",
      missing: true,
    },
  );
  assert.equal(
    alpha.dependencies.find((dep) => dep.name === "external").version,
    "^2.0.0",
  );
  assert.equal(alpha.issues[0].kind, "dependency");
  assert.equal(
    catalog.packages.find((pkg) => pkg.name === "removed").exists,
    false,
  );
  assert.equal(catalog.showcaseReady, false);
});

test("discovers new libraries without including example apps and reloads edits", (t) => {
  const { root, write } = fixture(t);
  write("new_library/pubspec.yaml", "name: new_library\nversion: 0.1.0\n");
  write("production_example/pubspec.yaml", "name: production_example\n");
  let catalog = loadCatalog(root);
  assert.equal(catalog.packages.length, 3);
  assert.equal(
    catalog.packages.find((pkg) => pkg.name === "new_library").issues[0].kind,
    "catalog",
  );
  write("new_library/pubspec.yaml", "name: new_library\nversion: 0.2.0\n");
  catalog = loadCatalog(root);
  assert.equal(
    catalog.packages.find((pkg) => pkg.name === "new_library").version,
    "0.2.0",
  );
});

test("lists only implemented preview components and uses their actual widget names", (t) => {
  const { root, write } = fixture(t);
  write(
    "mobile_ui_kit/preview/component_map.json",
    JSON.stringify({
      components: [
        {
          id: "button",
          category: "actions",
          flutterWidget: "OldButton",
          states: ["disabled"],
        },
        { id: "not-implemented", category: "forms", states: [] },
      ],
    }),
  );
  write(
    "mobile_ui_kit/example/lib/main.dart",
    'PreviewDefinition(\n id: "button",\n category: "actions",\n html: "button",\n flutterWidget: "ui.Button",\n)',
  );
  assert.deepEqual(loadCatalog(root).components, [
    {
      id: "button",
      category: "actions",
      flutterWidget: "ui.Button",
      states: ["disabled"],
    },
  ]);
});

test("serves live data and showcase assets while refusing repository files, traversal and symlinks", async (t) => {
  const { root, write } = fixture(t);
  write("secret.txt", "private repository content");
  write("mobile_ui_kit/example/build/web/index.html", "<title>Flutter</title>");
  symlinkSync(join(root, "secret.txt"), join(root, "web/leak.txt"));
  const server = createPortalServer(root);
  await new Promise((resolve) => server.listen(0, "127.0.0.1", resolve));
  t.after(() => new Promise((resolve) => server.close(resolve)));
  const origin = `http://127.0.0.1:${server.address().port}`;
  assert.equal((await fetch(origin)).status, 200);
  const response = await fetch(`${origin}/api/catalog.json`);
  assert.equal(response.headers.get("cache-control"), "no-store");
  assert.equal((await response.json()).packages[0].version, "1.0.0-rc.1");
  assert.equal((await fetch(`${origin}/showcase/`)).status, 200);
  assert.equal((await fetch(`${origin}/secret.txt`)).status, 404);
  assert.equal((await fetch(`${origin}/..%2fsecret.txt`)).status, 404);
  assert.equal((await fetch(`${origin}/leak.txt`)).status, 404);
  assert.equal((await fetch(origin, { method: "POST" })).status, 405);
  assert.equal((await fetch(origin, { method: "HEAD" })).status, 200);
  write("alpha/pubspec.yaml", "name: alpha\nversion: 2.0.0\n");
  assert.equal(
    (await (await fetch(`${origin}/api/catalog`)).json()).packages[0].version,
    "2.0.0",
  );
});

test("rejects catalog paths outside the repository", (t) => {
  const { root, write } = fixture(t);
  write(
    "docs/package-catalog.json",
    '{"packages":[{"name":"outside","path":"../outside"}]}',
  );
  assert.throws(() => loadCatalog(root), /Invalid package catalog path/);
});

test("builds a portable snapshot with the compiled Flutter showcase", (t) => {
  const { root, write } = fixture(t);
  assert.throws(() => buildPortal(root), /showcase/);
  write("mobile_ui_kit/example/build/web/index.html", "<title>Flutter</title>");
  write("mobile_ui_kit/example/build/web/main.dart.js", "compiled");
  buildPortal(root);
  assert.ok(existsSync(join(root, "dist/index.html")));
  assert.ok(existsSync(join(root, "dist/showcase/main.dart.js")));
  assert.equal(
    JSON.parse(readFileSync(join(root, "dist/api/catalog.json"), "utf8"))
      .packages.length,
    2,
  );
});
