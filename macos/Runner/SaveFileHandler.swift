import Cocoa
import FlutterMacOS
import UniformTypeIdentifiers

enum SaveFileHandler {
  static func register(with controller: FlutterViewController) {
    let channel = FlutterMethodChannel(
      name: "patterns/file_export",
      binaryMessenger: controller.engine.binaryMessenger
    )

    channel.setMethodCallHandler { call, result in
      DispatchQueue.main.async {
        guard call.method == "saveFile" else {
          result(FlutterMethodNotImplemented)
          return
        }

        guard
          let args = call.arguments as? [String: Any],
          let fileName = args["fileName"] as? String,
          let bytes = args["bytes"] as? FlutterStandardTypedData
        else {
          result(
            FlutterError(
              code: "INVALID_ARGS",
              message: "fileName and bytes are required.",
              details: nil
            )
          )
          return
        }

        let panel = NSSavePanel()
        panel.title = args["dialogTitle"] as? String ?? "Save Patterns Report"
        panel.nameFieldStringValue = fileName
        panel.canCreateDirectories = true
        panel.showsTagField = false

        if let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
          panel.directoryURL = documents
        }

        if #available(macOS 11.0, *) {
          panel.allowedContentTypes = [UTType.pdf]
        } else {
          panel.allowedFileTypes = ["pdf"]
        }

        guard let window = controller.view.window else {
          result(nil)
          return
        }

        panel.beginSheetModal(for: window) { response in
          DispatchQueue.main.async {
            guard response == .OK, let url = panel.url else {
              result(nil)
              return
            }

            let accessing = url.startAccessingSecurityScopedResource()
            defer {
              if accessing {
                url.stopAccessingSecurityScopedResource()
              }
            }

            do {
              try bytes.data.write(to: url, options: .atomic)
              result(url.path)
            } catch {
              result(
                FlutterError(
                  code: "WRITE_FAILED",
                  message: error.localizedDescription,
                  details: nil
                )
              )
            }
          }
        }
      }
    }
  }
}
