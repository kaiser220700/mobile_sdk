import "package:flutter_test/flutter_test.dart";
import "package:mobile_devtool/mobile_devtool.dart" as dev;

void main() {
  test("recorder uses the host controller and detaches cleanly", () {
    final controller = dev.Controller();
    addTearDown(controller.dispose);
    addTearDown(dev.Recorder.detachInstance);
    dev.Recorder.attachInstance(controller);
    dev.Recorder.trace("Host initialized");
    expect(controller.traces, ["Host initialized"]);
    dev.Recorder.detachInstance();
    dev.Recorder.trace("Ignored after detach");
    expect(controller.traces, ["Host initialized"]);
  });

  test("records and completes a network request", () {
    final controller = dev.Controller();
    final id = controller.startNetwork(
      const dev.NetworkRequest(
        label: "Load profile",
        endpoint: "/profile",
        method: "GET",
      ),
    );

    expect(controller.networkEntries.single.status, dev.NetworkStatus.pending);

    controller.completeNetwork(
      id,
      statusCode: 200,
      response: const {"ok": true},
    );

    expect(controller.networkEntries.single.status, dev.NetworkStatus.success);
    expect(controller.networkEntries.single.statusCode, 200);
  });

  test("records traces and clears diagnostics", () {
    final controller = dev.Controller();
    controller.recordTrace("route:home");

    expect(controller.traces, ["route:home"]);

    controller.clear();

    expect(controller.traces, isEmpty);
    expect(controller.networkEntries, isEmpty);
  });

  test("evicts oldest network entries at capacity", () {
    final controller = dev.Controller(maxEntries: 1);
    controller.startNetwork(
      const dev.NetworkRequest(label: "first", endpoint: "/1", method: "GET"),
    );
    controller.startNetwork(
      const dev.NetworkRequest(label: "second", endpoint: "/2", method: "GET"),
    );

    expect(controller.networkEntries.single.request.label, "second");
  });

  test("disabled controller discards network and trace calls", () {
    final controller = dev.Controller.disabled();

    final id = controller.startNetwork(
      const dev.NetworkRequest(label: "ignored", endpoint: "/x", method: "GET"),
    );
    controller.recordTrace("ignored");

    expect(id, "");
    expect(controller.networkEntries, isEmpty);
    expect(controller.traces, isEmpty);
  });

  test("builds a GraphQL curl command", () {
    final controller = dev.Controller();
    final id = controller.startNetwork(
      const dev.NetworkRequest(
        label: "Load profile",
        endpoint: "GetProfile",
        method: "POST",
        kind: dev.NetworkKind.graphql,
        document: "query GetProfile { me { id } }",
        request: {"variables": <String, dynamic>{}},
      ),
    );

    final curl = controller.networkEntries.single.toCurl(
      graphQlUrl: "https://api.example.com/graphql",
      restBaseUrl: "https://api.example.com",
      bearerToken: "token123",
    );

    expect(curl, contains("https://api.example.com/graphql"));
    expect(curl, contains("Bearer token123"));
    expect(id, isNotEmpty);
  });
}
