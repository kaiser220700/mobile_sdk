import { createServer } from "node:http";
import { spawnSync } from "node:child_process";
import {
  existsSync,
  readFileSync,
  readdirSync,
  statSync,
  mkdirSync,
  cpSync,
  writeFileSync,
  realpathSync,
  rmSync,
} from "node:fs";
import { dirname, resolve, sep, extname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { parse } from "yaml";

export const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const read = (path) => (existsSync(path) ? readFileSync(path, "utf8") : "");
const inside = (root, path) => path === root || path.startsWith(root + sep);

export function loadCatalog(root = ROOT) {
  const entries = JSON.parse(
    readFileSync(join(root, "docs/package-catalog.json"), "utf8"),
  ).packages;
  // Discover new libraries even before their release metadata is registered.
  for (const directory of readdirSync(root, { withFileTypes: true })) {
    if (
      !directory.isDirectory() ||
      entries.some((entry) => entry.path === directory.name)
    )
      continue;
    const file = join(root, directory.name, "pubspec.yaml");
    if (!existsSync(file) || directory.name.endsWith("example")) continue;
    const pubspec = parse(read(file));
    entries.push({
      name: pubspec.name,
      path: directory.name,
      group: "uncatalogued",
      stage: "unregistered",
      purpose: pubspec.description ?? "",
    });
  }
  const packages = entries.map((entry) => {
    if (!/^[a-zA-Z0-9_-]+$/.test(entry.path))
      throw new Error("Invalid package catalog path");
    const folder = join(root, entry.path);
    if (existsSync(folder) && !inside(realpathSync(root), realpathSync(folder)))
      throw new Error("Package path leaves the repository");
    const source = read(join(folder, "pubspec.yaml"));
    const pubspec = parse(source) ?? {};
    const dependencies = Object.entries(pubspec.dependencies ?? {}).map(
      ([name, spec]) => {
        const localPath = spec && typeof spec === "object" ? spec.path : null;
        const target = localPath ? resolve(folder, localPath) : null;
        const localEntry = target
          ? entries.find((item) => resolve(root, item.path) === target)
          : null;
        return {
          name,
          source: localPath
            ? "local"
            : spec?.sdk
              ? "sdk"
              : spec?.git
                ? "git"
                : "hosted",
          version: typeof spec === "string" ? spec : (spec?.version ?? ""),
          path: localPath,
          target: localEntry?.name ?? null,
          missing: Boolean(
            target &&
              (!inside(root, target) ||
                !existsSync(join(target, "pubspec.yaml"))),
          ),
        };
      },
    );
    const issues = [];
    if (!source)
      issues.push({
        kind: "missing",
        message: "Không tìm thấy pubspec.yaml trong checkout.",
      });
    for (const dep of dependencies.filter((dep) => dep.missing))
      issues.push({
        kind: "dependency",
        message: `Thiếu dependency local: ${dep.name} (${dep.path}).`,
      });
    if (entry.group === "uncatalogued")
      issues.push({
        kind: "catalog",
        message: "Package chưa có trong docs/package-catalog.json.",
      });
    return {
      ...entry,
      exists: Boolean(source),
      version: pubspec.version ?? null,
      description: pubspec.description ?? entry.purpose,
      environment: pubspec.environment ?? {},
      type: !source
        ? "Chưa xác định"
        : pubspec.flutter?.plugin
          ? "Native plugin"
          : pubspec.dependencies?.flutter || pubspec.environment?.flutter
            ? "Flutter package"
            : "Dart package",
      dependencies,
      issues,
      tests: existsSync(join(folder, "test")),
      documents: {
        readme: read(join(folder, "README.md")),
        changelog: read(join(folder, "CHANGELOG.md")),
        pubspec: source,
      },
    };
  });
  const componentMap = JSON.parse(
    read(join(root, "mobile_ui_kit/preview/component_map.json")) ||
      '{"components":[]}',
  );
  const previewSource = read(join(root, "mobile_ui_kit/example/lib/main.dart"));
  const demos = new Map(
    [
      ...previewSource.matchAll(
        /PreviewDefinition\(\s*id:\s*["']([^"']+)["'],\s*category:\s*["']([^"']+)["'],[\s\S]*?flutterWidget:\s*["']([^"']+)["']/g,
      ),
    ].map((match) => [match[1], { category: match[2], widget: match[3] }]),
  );
  return {
    generatedAt: new Date().toISOString(),
    packages,
    components: (componentMap.components ?? [])
      .filter((component) => demos.has(component.id))
      .map((component) => ({
        ...component,
        flutterWidget: demos.get(component.id).widget,
      })),
    showcaseReady: existsSync(
      join(root, "mobile_ui_kit/example/build/web/index.html"),
    ),
    docs: [
      "README.md",
      "docs/package-organization.md",
      "docs/release-workflow.md",
      "docs/sdk-api-naming.md",
      "docs/ui-api-naming.md",
    ].map((path) => ({ path, content: read(join(root, path)) })),
  };
}

const mime = {
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".mjs": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".svg": "image/svg+xml",
  ".png": "image/png",
  ".wasm": "application/wasm",
  ".woff2": "font/woff2",
  ".ttf": "font/ttf",
};

export function createPortalServer(root = ROOT) {
  return createServer((request, response) => {
    try {
      if (!["GET", "HEAD"].includes(request.method)) {
        response.writeHead(405, { Allow: "GET, HEAD" }).end();
        return;
      }
      const url = new URL(request.url, "http://localhost");
      if (["/api/catalog", "/api/catalog.json"].includes(url.pathname)) {
        const body = JSON.stringify(loadCatalog(root));
        response
          .writeHead(200, {
            "Content-Type": mime[".json"],
            "Cache-Control": "no-store",
          })
          .end(request.method === "HEAD" ? undefined : body);
        return;
      }
      // Serve only portal assets and the compiled showcase, never the repo itself.
      const showcase = url.pathname.startsWith("/showcase/");
      const base = showcase
        ? join(root, "mobile_ui_kit/example/build/web")
        : join(root, "web");
      const path = decodeURIComponent(
        showcase
          ? url.pathname.slice("/showcase/".length)
          : url.pathname.slice(1),
      );
      const file = resolve(base, path || "index.html");
      if (
        !inside(base, file) ||
        !existsSync(file) ||
        !statSync(file).isFile() ||
        !inside(realpathSync(base), realpathSync(file))
      ) {
        response
          .writeHead(404, { "Content-Type": "text/plain; charset=utf-8" })
          .end("Không tìm thấy tài nguyên.");
        return;
      }
      response.writeHead(200, {
        "Content-Type": mime[extname(file)] ?? "application/octet-stream",
        "Cache-Control": "no-store",
      });
      response.end(request.method === "HEAD" ? undefined : readFileSync(file));
    } catch (error) {
      console.error(error.message);
      response
        .writeHead(500, { "Content-Type": mime[".json"] })
        .end(
          JSON.stringify({
            error:
              "Không đọc được dữ liệu repo. Kiểm tra pubspec.yaml và package catalog.",
          }),
        );
    }
  });
}

function flutterCommand() {
  if (process.env.FLUTTER_BIN)
    return { command: process.env.FLUTTER_BIN, prefix: [] };
  const local = join(ROOT, ".fvm/flutter_sdk/bin/flutter");
  if (existsSync(local)) return { command: local, prefix: [] };
  if (spawnSync("flutter", ["--version"], { stdio: "ignore" }).status === 0)
    return { command: "flutter", prefix: [] };
  return { command: "fvm", prefix: ["flutter"] };
}

function buildShowcase() {
  const { command, prefix } = flutterCommand();
  const result = spawnSync(
    command,
    [
      ...prefix,
      "build",
      "web",
      "--release",
      "--base-href",
      "/showcase/",
      "--no-web-resources-cdn",
    ],
    { cwd: join(ROOT, "mobile_ui_kit/example"), stdio: "inherit" },
  );
  if (result.error || result.status !== 0)
    throw new Error(
      "Build showcase thất bại. Cài Flutter theo .fvmrc hoặc đặt FLUTTER_BIN=/đường/dẫn/bin/flutter rồi thử lại.",
    );
}

export function buildPortal(root = ROOT) {
  const catalog = loadCatalog(root);
  if (!catalog.showcaseReady)
    throw new Error(
      "Chưa có Flutter showcase. Chạy npm run showcase:build trước.",
    );
  const output = join(root, "dist");
  rmSync(output, { recursive: true, force: true });
  mkdirSync(join(output, "api"), { recursive: true });
  cpSync(join(root, "web"), output, { recursive: true });
  cpSync(
    join(root, "mobile_ui_kit/example/build/web"),
    join(output, "showcase"),
    { recursive: true },
  );
  writeFileSync(join(output, "api/catalog.json"), JSON.stringify(catalog));
  console.log(
    "Đã build portal và Flutter showcase vào dist/. Dữ liệu package là snapshot tại lúc build.",
  );
}

if (
  process.argv[1] &&
  pathToFileURL(resolve(process.argv[1])).href === import.meta.url
) {
  try {
    const mode = process.argv[2] ?? "serve";
    if (mode === "showcase") buildShowcase();
    else if (mode === "build") {
      buildShowcase();
      buildPortal();
    } else if (mode === "serve") {
      const port = Number(process.env.PORT ?? 4173);
      const server = createPortalServer();
      server.on("error", (error) => {
        console.error(error.message);
        process.exitCode = 1;
      });
      server.listen(port, "127.0.0.1", () => {
        console.log(`Mobile SDK workspace: http://localhost:${port}`);
        if (!loadCatalog().showcaseReady)
          console.log(
            "Chạy npm run showcase:build trong terminal khác để bật showcase UI.",
          );
      });
    } else throw new Error(`Lệnh không hợp lệ: ${mode}`);
  } catch (error) {
    console.error(error.message);
    process.exitCode = 1;
  }
}
