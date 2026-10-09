import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mobile_devtool/mobile_devtool.dart";

void main() {
  test("resolves a host-owned menu without imposing SDK presentation", () {
    final entries = MobileDevToolMenu.resolve(
      items: [
        MobileDevToolMenuItem(
          id: "network",
          label: "Network",
          order: 10,
          onSelect: () {},
        ),
        MobileDevToolMenuItem(
          id: "toast",
          label: "Toast",
          order: 20,
          onSelect: () {},
        ),
        MobileDevToolMenuItem(
          id: "push",
          label: "Push",
          order: 30,
          onSelect: () {},
        ),
      ],
      configuration: MobileDevToolConfiguration(
        hiddenMenuItemIds: {"toast", "push"},
        menuItems: [
          MobileDevToolMenuItem(
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
    final entries = MobileDevToolMenu.resolve(
      items: [
        MobileDevToolMenuItem(id: "network", label: "Network", onSelect: () {}),
      ],
      configuration: MobileDevToolConfiguration(
        menuItems: [
          MobileDevToolMenuItem(
            id: "network",
            label: "First replacement",
            onSelect: () {},
          ),
          MobileDevToolMenuItem(
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
    final entries = MobileDevToolMenu.resolve(
      items: const [],
      configuration: MobileDevToolConfiguration(
        hiddenMenuItemIds: {"debug"},
        menuItems: [
          MobileDevToolMenuItem(id: "debug", label: "Debug", onSelect: () {}),
        ],
      ),
    );

    expect(entries, isEmpty);
  });
}
