import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_devtool/mobile_devtool.dart" as dev;

void main() {
  test("resolves a host-owned menu without imposing SDK presentation", () {
    final entries = dev.Menu.resolve(
      items: [
        dev.MenuItem(
          id: "network",
          label: "Network",
          order: 10,
          onSelect: () {},
        ),
        dev.MenuItem(id: "toast", label: "Toast", order: 20, onSelect: () {}),
        dev.MenuItem(id: "push", label: "Push", order: 30, onSelect: () {}),
      ],
      configuration: dev.Configuration(
        hiddenMenuItemIds: {"toast", "push"},
        menuItems: [
          dev.MenuItem(
            id: "debug",
            label: "Debug",
            icon: Icons.bug_report_outlined,
            order: 15,
            onSelect: () {},
          ),
        ],
      ),
    );

    expect(entries.map((entry) => entry.id), ["network", "debug"]);
    expect(entries.map((entry) => entry.label), ["Network", "Debug"]);
  });

  test("custom entries replace defaults and final declarations win", () {
    final entries = dev.Menu.resolve(
      items: [dev.MenuItem(id: "network", label: "Network", onSelect: () {})],
      configuration: dev.Configuration(
        menuItems: [
          dev.MenuItem(
            id: "network",
            label: "First replacement",
            onSelect: () {},
          ),
          dev.MenuItem(
            id: "network",
            label: "Final replacement",
            onSelect: () {},
          ),
        ],
      ),
    );

    expect(entries.single.label, "Final replacement");
  });

  test("hidden IDs win over custom entries", () {
    final entries = dev.Menu.resolve(
      items: const [],
      configuration: dev.Configuration(
        hiddenMenuItemIds: {"debug"},
        menuItems: [dev.MenuItem(id: "debug", label: "Debug", onSelect: () {})],
      ),
    );

    expect(entries, isEmpty);
  });
}
