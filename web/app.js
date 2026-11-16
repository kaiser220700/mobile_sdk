const paths = {
  overview:
    '<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/>',
  packages:
    '<path d="m12 3 9 5v9l-9 5-9-5V8l9-5Z"/><path d="m3 8 9 5 9-5M12 13v9M7.5 5.5l9 5"/>',
  showcase:
    '<rect x="3" y="4" width="18" height="14" rx="2"/><path d="M8 22h8m-4-4v4m-8-11h16M8 4v14"/>',
  dependencies:
    '<rect x="8" y="2" width="8" height="6" rx="1"/><rect x="2" y="16" width="7" height="6" rx="1"/><rect x="15" y="16" width="7" height="6" rx="1"/><path d="M12 8v4H5v4m7-4h7v4"/>',
  docs: '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6Z"/><path d="M14 2v6h6M8 13h8m-8 4h5"/>',
  arrow: '<path d="M5 12h14m-5-5 5 5-5 5"/>',
  external:
    '<path d="M14 3h7v7m0-7L10 14m-1-9H5a2 2 0 0 0-2 2v12a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-4"/>',
  search: '<circle cx="10.5" cy="10.5" r="6.5"/><path d="m16 16 5 5"/>',
  warning:
    '<path d="m10.3 3.5-8 14a2 2 0 0 0 1.7 3h16a2 2 0 0 0 1.7-3l-8-14a2 2 0 0 0-3.4 0Z"/><path d="M12 8v5m0 3v.5"/>',
  code: '<path d="m7 7-5 5 5 5m10-10 5 5-5 5m-4-14-2 18"/>',
  service: '<path d="m13 2-3 8H5l6 12 3-8h5L13 2Z"/>',
  tool: '<path d="m14 6 4 4m-4-4 1-3a6 6 0 0 0-7 7L2 16a3 3 0 0 0 4 4l6-6a6 6 0 0 0 9-7l-3 3"/>',
  check: '<path d="m5 12 4 4L19 6"/>',
};
const icon = (name) =>
  `<svg viewBox="0 0 24 24" aria-hidden="true">${paths[name] ?? paths.packages}</svg>`;
const escape = (value) =>
  String(value ?? "").replace(
    /[&<>"']/g,
    (char) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[
        char
      ],
  );
const groupLabels = {
  "app-library": "Thư viện ứng dụng",
  "service-adapter": "Service adapters",
  "developer-tool": "Developer tools",
  compatibility: "Compatibility",
  uncatalogued: "Chưa phân nhóm",
};
const stageLabels = {
  candidate: "Release candidate",
  development: "Development",
  experimental: "Experimental",
  stable: "Stable",
  unregistered: "Chưa đăng ký",
};
const views = {
  overview: "Tổng quan",
  packages: "Packages",
  showcase: "UI Showcase",
  dependencies: "Dependencies",
  docs: "Tài liệu",
};
const main = document.querySelector("#main");
const dialog = document.querySelector("#package-dialog");
let catalog;
let currentView = "overview";
let query = "";
let group = "all";
let stage = "all";
let selectedComponent = "";
let componentQuery = "";
let viewport = "desktop";
let selectedDoc = "README.md";
let detailPackage;
let detailTab = "readme";
let notificationTimeout;

function route() {
  const [view, params = ""] = location.hash.slice(1).split("?");
  currentView = Object.hasOwn(views, view) ? view : "overview";
  selectedComponent = new URLSearchParams(params).get("component") ?? "";
  render();
}

async function load() {
  const refresh = document.querySelector("#refresh");
  refresh.disabled = true;
  try {
    const response = await fetch("./api/catalog.json", { cache: "no-store" });
    if (!response.ok) throw new Error("Không tải được dữ liệu package.");
    catalog = await response.json();
    document.querySelector("#sync-time").textContent =
      `Đọc repo lúc ${new Date(catalog.generatedAt).toLocaleTimeString("vi-VN", { hour: "2-digit", minute: "2-digit" })}`;
    route();
  } catch (error) {
    main.innerHTML = `<div class="empty-state error-state"><strong>Chưa đọc được workspace</strong>${escape(error.message)}<br><button class="button retry" data-action="retry">Thử lại</button></div>`;
  } finally {
    refresh.disabled = false;
  }
}

function badge(pkg) {
  const status = pkg.exists ? pkg.stage : "missing";
  return `<span class="badge ${escape(status)}">${escape(pkg.exists ? (stageLabels[pkg.stage] ?? pkg.stage) : "Thiếu package")}</span>`;
}

function packageIcon(pkg) {
  const [symbol, color] = {
    "app-library": [
      pkg.name === "mobile_ui_kit" ? "showcase" : "packages",
      pkg.name === "mobile_ui_kit" ? "" : "blue",
    ],
    "service-adapter": ["service", "orange"],
    "developer-tool": ["tool", "green"],
    compatibility: ["code", "gray"],
  }[pkg.group] ?? ["packages", "gray"];
  return `<span class="package-icon ${color}">${icon(symbol)}</span>`;
}

function heading(eyebrow, title, subtitle, actions = "") {
  return `<div class="page-heading"><div><p class="eyebrow"><span class="status-dot"></span>${eyebrow}</p><h1>${title}</h1><p>${subtitle}</p></div><div class="heading-actions">${actions}</div></div>`;
}

function warnings() {
  const affected = catalog.packages.filter((pkg) => pkg.issues.length);
  if (!affected.length) return "";
  return `<div class="notice">${icon("warning")}<div><strong>${affected.length} package cần kiểm tra</strong><p>${affected.map((pkg) => `<a href="#packages" data-package="${escape(pkg.name)}">${escape(pkg.name)}</a>: ${escape(pkg.issues.map((issue) => issue.message).join(" "))}`).join("<br>")}</p></div></div>`;
}

function stats() {
  const present = catalog.packages.filter((pkg) => pkg.exists);
  const values = [
    [
      "Packages",
      catalog.packages.length,
      `${present.length} có trong checkout hiện tại`,
      "packages",
    ],
    [
      "UI components",
      catalog.components.length,
      "Có preview tương tác bằng Flutter",
      "showcase",
    ],
    [
      "Release candidate",
      present.filter((pkg) => pkg.stage === "candidate").length,
      "Phiên bản theo từng package",
      "check",
    ],
    [
      "Nhóm thư viện",
      new Set(catalog.packages.map((pkg) => pkg.group)).size,
      "Chọn độc lập theo nhu cầu",
      "dependencies",
    ],
  ];
  return `<div class="stats">${values.map(([label, value, note, symbol]) => `<div class="stat"><div class="stat-top">${label}<span class="stat-icon">${icon(symbol)}</span></div><div class="stat-value">${value}</div><div class="stat-note ${symbol === "showcase" ? "accent" : ""}">${note}</div></div>`).join("")}</div>`;
}

function filters() {
  return `<div class="filters"><label class="search-box">${icon("search")}<input id="package-search" type="search" aria-label="Tìm package" placeholder="Tìm package, chức năng…" value="${escape(query)}"></label><select id="group-filter" class="filter-select" aria-label="Lọc theo nhóm"><option value="all">Tất cả nhóm</option>${Object.entries(
    groupLabels,
  )
    .map(
      ([id, label]) =>
        `<option value="${id}" ${group === id ? "selected" : ""}>${label}</option>`,
    )
    .join(
      "",
    )}</select><select id="stage-filter" class="filter-select" aria-label="Lọc theo trạng thái"><option value="all">Tất cả trạng thái</option>${Object.entries(
    stageLabels,
  )
    .map(
      ([id, label]) =>
        `<option value="${id}" ${stage === id ? "selected" : ""}>${label}</option>`,
    )
    .join(
      "",
    )}<option value="missing" ${stage === "missing" ? "selected" : ""}>Thiếu package</option></select><span id="result-count" class="result-count" aria-live="polite"></span></div>`;
}

function card(pkg) {
  const local = pkg.dependencies.filter((dep) => dep.source === "local").length;
  const dependencyNote = !pkg.exists
    ? "Chưa đọc được dependency"
    : local
      ? `${local} local dependenc${local === 1 ? "y" : "ies"}`
      : "Không có dependency local";
  return `<article class="package-card"><div class="card-top">${packageIcon(pkg)}${badge(pkg)}</div><h3><button class="package-title" data-package="${escape(pkg.name)}">${escape(pkg.name)}</button></h3><p class="package-description">${escape(pkg.purpose || pkg.description)}</p><div class="card-meta"><span class="version">${escape(pkg.version ?? "—")}</span><span class="meta-dot"></span><span>${escape(pkg.type)}</span>${pkg.issues.length ? '<span class="badge issue">Cần kiểm tra</span>' : ""}</div><div class="card-bottom"><span>${dependencyNote}</span><button data-package="${escape(pkg.name)}" aria-label="Chi tiết ${escape(pkg.name)}">Chi tiết ${icon("arrow")}</button></div></article>`;
}

function updatePackages() {
  const packages = catalog.packages.filter(
    (pkg) =>
      (group === "all" || pkg.group === group) &&
      (stage === "all" ||
        (stage === "missing"
          ? !pkg.exists
          : pkg.stage === stage && pkg.exists)) &&
      `${pkg.name} ${pkg.purpose} ${pkg.description}`
        .toLowerCase()
        .includes(query.toLowerCase()),
  );
  const ordered = [...packages].sort(
    (a, b) =>
      Number(b.name === "mobile_ui_kit") - Number(a.name === "mobile_ui_kit") ||
      Number(b.exists) - Number(a.exists),
  );
  document.querySelector("#package-grid").innerHTML =
    ordered.map(card).join("") ||
    '<div class="empty-state"><strong>Không tìm thấy package</strong>Thử từ khóa hoặc bộ lọc khác.</div>';
  document.querySelector("#result-count").textContent =
    `${packages.length} / ${catalog.packages.length} packages`;
}

function overview() {
  main.innerHTML =
    heading(
      "YOUR LIBRARY, CONNECTED",
      "Một workspace. Từng package độc lập.",
      "Khám phá thư viện, theo dõi dependency và thử UI ngay trong trình duyệt.",
      `<a class="button" href="#docs">${icon("docs")} Tài liệu</a><a class="button primary" href="#showcase">${icon("showcase")} Mở UI Showcase</a>`,
    ) +
    stats() +
    warnings() +
    `<div class="section-header"><div><h2>Package directory</h2><p>Các thư viện dùng chung trong repository</p></div><a class="text-link" href="#dependencies">Xem dependencies ${icon("arrow")}</a></div>` +
    filters() +
    '<div id="package-grid" class="package-grid"></div>' +
    `<div class="showcase-promo"><span class="promo-icon">${icon("showcase")}</span><div class="promo-content"><h2>Từ package đến trải nghiệm thật.</h2><p>${catalog.components.length} UI components. Thử state, đổi theme và kiểm tra ở nhiều kích thước màn hình.</p></div><a class="button" href="#showcase">Khám phá showcase ${icon("arrow")}</a></div>`;
  bindFilters();
}

function packages() {
  main.innerHTML =
    heading(
      "PACKAGE DIRECTORY",
      "Packages",
      "Version, trạng thái và tài liệu được đọc từ các package trong repo.",
    ) +
    warnings() +
    filters() +
    '<div id="package-grid" class="package-grid"></div>';
  bindFilters();
}

function bindFilters() {
  document
    .querySelector("#package-search")
    .addEventListener("input", (event) => {
      query = event.target.value;
      updatePackages();
    });
  document
    .querySelector("#group-filter")
    .addEventListener("change", (event) => {
      group = event.target.value;
      updatePackages();
    });
  document
    .querySelector("#stage-filter")
    .addEventListener("change", (event) => {
      stage = event.target.value;
      updatePackages();
    });
  updatePackages();
}

function dependencies() {
  main.innerHTML =
    heading(
      "THE CONNECTIONS",
      "Dependency explorer",
      "Xem các package kết nối với nhau và dependency bên ngoài.",
    ) +
    warnings() +
    '<p class="dependency-legend">Màu tím: package local · Màu cam: dependency bị thiếu · Màu xám: SDK hoặc thư viện bên ngoài. Bấm package local để xem chi tiết.</p>' +
    `<div class="dependency-list">${catalog.packages.map((pkg) => `<article class="dependency-row"><div><button class="package-title" data-package="${escape(pkg.name)}">${escape(pkg.name)}</button><div class="source-label">${escape(pkg.version ?? "Thiếu trong checkout")}</div></div><div class="dependency-targets"><span class="dependency-arrow">→</span>${pkg.dependencies.map((dep) => (dep.target ? `<button class="dependency-chip local ${dep.missing ? "missing" : ""}" data-package="${escape(dep.target)}">${escape(dep.name)}${dep.missing ? " · missing" : ""}</button>` : `<span class="dependency-chip ${dep.missing ? "missing" : ""}">${escape(dep.name)} <code>${escape(dep.version || dep.source)}</code></span>`)).join("") || `<span class="muted" style="font-size:11px">${pkg.exists ? "Không có dependency runtime." : "Không đọc được dependency."}</span>`}</div></article>`).join("")}</div>`;
}

function componentUrl() {
  return `./showcase/${selectedComponent ? `?component=${encodeURIComponent(selectedComponent)}` : ""}`;
}

function showcase() {
  const component = catalog.components.find(
    (item) => item.id === selectedComponent,
  );
  main.innerHTML =
    heading(
      "BUILT WITH FLUTTER",
      "UI Showcase",
      "Widget thật từ mobile_ui_kit. Tương tác, đổi theme và xem từng trạng thái.",
      `<a class="button" href="${componentUrl()}" target="_blank" rel="noopener">${icon("external")} Mở riêng</a>`,
    ) +
    `<div class="showcase-layout"><aside class="component-sidebar" aria-label="Danh sách UI component"><label class="search-box">${icon("search")}<input id="component-search" type="search" placeholder="Tìm component…" aria-label="Tìm component" value="${escape(componentQuery)}"></label><div id="component-list"></div></aside><section class="preview-panel" aria-label="Flutter component preview"><div class="preview-toolbar"><span class="preview-name">${escape(component?.flutterWidget ?? "mobile_ui_kit · all components")}</span><div class="size-controls" aria-label="Kích thước preview">${[
      ["phone", "Phone"],
      ["tablet", "Tablet"],
      ["desktop", "Full width"],
    ]
      .map(
        ([id, label]) =>
          `<button data-viewport="${id}" class="${viewport === id ? "active" : ""}" aria-pressed="${viewport === id}">${label}</button>`,
      )
      .join(
        "",
      )}</div><button class="icon-button" data-action="reload-preview" aria-label="Tải lại preview">↻</button></div><div class="preview-stage">${catalog.showcaseReady ? `<iframe class="${viewport}" title="Flutter UI Kit showcase" src="${componentUrl()}" allow="clipboard-write"></iframe>` : '<div class="showcase-not-ready"><h2>Build showcase để bắt đầu</h2><p>Chạy lệnh sau ở thư mục gốc, sau đó bấm làm mới dữ liệu:</p><pre>npm run showcase:build</pre><p>Nếu Flutter chưa có trên PATH, đặt biến <code>FLUTTER_BIN</code> trỏ đến Flutter SDK.</p><button class="button" data-action="retry">Làm mới dữ liệu</button></div>'}</div><div class="preview-caption"><span><span class="status-dot"></span> Flutter Web · ${escape(component?.id ?? `${catalog.components.length} components`)}</span><span>Theme và state được điều chỉnh trong preview</span></div>${component ? `<div class="preview-states"><span class="muted">States trong component map</span>${component.states.map((state) => `<span class="badge">${escape(state)}</span>`).join("")}</div>` : ""}</section></div>`;
  updateComponents();
  document
    .querySelector("#component-search")
    .addEventListener("input", (event) => {
      componentQuery = event.target.value;
      updateComponents();
    });
}

function updateComponents() {
  const components = catalog.components.filter((item) =>
    `${item.id} ${item.flutterWidget} ${item.category}`
      .toLowerCase()
      .includes(componentQuery.toLowerCase()),
  );
  const categories = [...new Set(components.map((item) => item.category))];
  document.querySelector("#component-list").innerHTML =
    `<button class="component-button ${!selectedComponent ? "selected" : ""}" data-component="">Tất cả components <span class="muted">(${catalog.components.length})</span></button>` +
    categories
      .map(
        (category) =>
          `<div class="component-category">${escape(category)}</div>${components
            .filter((item) => item.category === category)
            .map(
              (item) =>
                `<button class="component-button ${selectedComponent === item.id ? "selected" : ""}" data-component="${escape(item.id)}">${escape(item.id)}</button>`,
            )
            .join("")}`,
      )
      .join("") +
    (!components.length
      ? '<p class="muted" style="font-size:11px;padding:8px">Không tìm thấy component.</p>'
      : "");
}

function docs() {
  const doc =
    catalog.docs.find((item) => item.path === selectedDoc) ?? catalog.docs[0];
  main.innerHTML =
    heading(
      "WORKSPACE KNOWLEDGE",
      "Tài liệu",
      "Hướng dẫn tích hợp, tổ chức thư viện và quy trình release trong repository.",
    ) +
    `<div class="docs-layout"><nav class="docs-nav" aria-label="Tài liệu workspace">${catalog.docs.map((item) => `<button class="doc-button ${doc.path === item.path ? "selected" : ""}" data-doc="${escape(item.path)}">${escape(item.path)}</button>`).join("")}</nav><article class="document"><div class="document-heading">${escape(doc.path)} · Markdown source</div><pre>${escape(doc.content || "Chưa có tài liệu.")}</pre></article></div>`;
}

function render() {
  if (!catalog) return;
  document.querySelector("#breadcrumb").textContent = views[currentView];
  document.title = `${views[currentView]} · Mobile SDK`;
  document.querySelector("#navigation").innerHTML = Object.entries(views)
    .map(
      ([id, label]) =>
        `<a href="#${id}" class="${id === currentView ? "active" : ""}" ${id === currentView ? 'aria-current="page"' : ""}>${icon(id)}${label}${id === "packages" ? `<span class="nav-count">${catalog.packages.length}</span>` : ""}</a>`,
    )
    .join("");
  ({ overview, packages, showcase, dependencies, docs })[currentView]();
}

function openPackage(name) {
  detailPackage = catalog.packages.find((pkg) => pkg.name === name);
  if (!detailPackage) return;
  detailTab = "readme";
  renderDetail();
  if (!dialog.open) dialog.showModal();
}

function renderDetail() {
  const pkg = detailPackage;
  document.querySelector("#package-detail").innerHTML =
    `<div class="detail-header"><div><h2 id="detail-title">${escape(pkg.name)}</h2><p>${escape(pkg.description)}</p>${badge(pkg)}</div><button class="close-dialog" data-action="close-dialog" aria-label="Đóng chi tiết">×</button></div><div class="detail-body"><div class="detail-info"><span class="version">${escape(pkg.version ?? "Không có version")}</span><span>${escape(pkg.type)}</span><span>${escape(groupLabels[pkg.group] ?? pkg.group)}</span><span>${escape(pkg.path)}/</span>${pkg.tests ? "<span>Có thư mục test</span>" : ""}</div>${pkg.issues.map((issue) => `<div class="detail-issue">${escape(issue.message)}</div>`).join("")}<div class="detail-tabs" role="tablist" aria-label="Nội dung package">${[
      ["readme", "README"],
      ["changelog", "Changelog"],
      ["pubspec", "pubspec.yaml"],
    ]
      .map(
        ([id, label]) =>
          `<button role="tab" aria-selected="${detailTab === id}" class="${detailTab === id ? "active" : ""}" data-detail-tab="${id}">${label}</button>`,
      )
      .join(
        "",
      )}</div><pre class="detail-document" role="tabpanel">${escape(pkg.documents[detailTab] || "Chưa có nội dung trong checkout hiện tại.")}</pre><div class="detail-action-row"><button class="button" data-action="copy-name">${icon("code")} Sao chép tên package</button>${pkg.name === "mobile_ui_kit" ? '<button class="button primary" data-action="open-showcase">Mở UI Showcase →</button>' : ""}</div></div>`;
}

function notify(message) {
  const node = document.querySelector("#notification");
  node.textContent = message;
  node.classList.add("visible");
  clearTimeout(notificationTimeout);
  notificationTimeout = setTimeout(
    () => node.classList.remove("visible"),
    2600,
  );
}

document.addEventListener("click", async (event) => {
  const button = event.target.closest(
    "[data-package],[data-action],[data-component],[data-viewport],[data-doc],[data-detail-tab]",
  );
  if (!button) return;
  if (button.dataset.package) {
    event.preventDefault();
    openPackage(button.dataset.package);
  }
  if (Object.hasOwn(button.dataset, "component"))
    location.hash = `showcase${button.dataset.component ? `?component=${encodeURIComponent(button.dataset.component)}` : ""}`;
  if (button.dataset.viewport) {
    viewport = button.dataset.viewport;
    document.querySelectorAll("[data-viewport]").forEach((node) => {
      const active = node.dataset.viewport === viewport;
      node.classList.toggle("active", active);
      node.setAttribute("aria-pressed", active);
    });
    const frame = document.querySelector("iframe");
    if (frame) frame.className = viewport;
  }
  if (button.dataset.doc) {
    selectedDoc = button.dataset.doc;
    docs();
  }
  if (button.dataset.detailTab) {
    detailTab = button.dataset.detailTab;
    renderDetail();
  }
  if (button.dataset.action === "close-dialog") dialog.close();
  if (button.dataset.action === "retry") await load();
  if (button.dataset.action === "reload-preview") {
    const frame = document.querySelector("iframe");
    if (frame) frame.src = componentUrl();
    else await load();
  }
  if (button.dataset.action === "copy-name") {
    try {
      await navigator.clipboard.writeText(detailPackage.name);
      notify("Đã sao chép tên package.");
    } catch {
      notify("Không sao chép được. Bạn có thể chọn tên package để copy.");
    }
  }
  if (button.dataset.action === "open-showcase") {
    dialog.close();
    location.hash = "showcase";
  }
});
dialog.addEventListener("click", (event) => {
  if (event.target === dialog) {
    const bounds = dialog.getBoundingClientRect();
    if (
      event.clientX < bounds.left ||
      event.clientX > bounds.right ||
      event.clientY < bounds.top ||
      event.clientY > bounds.bottom
    )
      dialog.close();
  }
});
document.querySelector("#refresh").addEventListener("click", load);
window.addEventListener("hashchange", route);
load();
