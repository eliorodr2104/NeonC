//
//  LSPClient.swift
//  NeonC
//
//  Created by Eliomar Alejandro Rodriguez Ferrer on 21/08/25.
//

import Foundation

final class LSPClient {
    private var process: Process?
    private var stdinHandle: FileHandle?
    private var stdoutHandle: FileHandle?
    private var readQueue = DispatchQueue(label: "lsp.read")
    private var writeQueue = DispatchQueue(label: "lsp.write")
    private var nextId: Int = 1
    private let jsonEncoder = JSONEncoder()
    private var responseHandlers: [Int: (Data?) -> Void] = [:]
    private var readBuffer = Data()
    private var expectedContentLength: Int?

    private struct JSONRPCRequest<T: Encodable>: Encodable {
        let jsonrpc: String = "2.0"
        let id: Int
        let method: String
        let params: T?
        
    }
    private struct JSONRPCNotification<T: Encodable>: Encodable {
        let jsonrpc: String = "2.0"
        let method: String
        let params: T?
        
    }

    private struct EmptyParams: Encodable {}

    func start(clangdPath: String = "/usr/bin/clangd", projectRoot: URL) throws {
        stop()
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: clangdPath) else {
            print("Error: clangd not found at \(clangdPath)")
            return
        }

        let proc = Process()
        proc.executableURL = URL(fileURLWithPath: clangdPath)
        proc.arguments = [
            // "--log=verbose",
            "--compile-commands-dir=\(projectRoot.appendingPathComponent("build").path)"
        ]

        let inPipe = Pipe()
        let outPipe = Pipe()
        let errorPipe = Pipe()

        proc.standardInput = inPipe
        proc.standardOutput = outPipe
        proc.standardError = errorPipe

        func attachReader(_ handle: FileHandle, prefix: String) {
            var buffer = ""
            
            handle.readabilityHandler = { fh in
                let data = fh.availableData
                
                if data.count == 0 {
                    
                    // EOF
                    fh.readabilityHandler = nil
                    return
                    
                }
                
                if let chunk = String(data: data, encoding: .utf8) {
                    buffer += chunk
                    let lines = buffer.components(separatedBy: "\n")

                    buffer = lines.last ?? ""
                    for i in 0..<(lines.count - 1) {
                        let line = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
                        
                        if !line.isEmpty {
                            print("\(prefix) \(line)")
                            
                        }
                    }
                } else {
                    print("\(prefix) <non-utf8 data: \(data.count) bytes>")
                    
                }
            }
        }

        attachReader(outPipe.fileHandleForReading, prefix: "clangd out:")
        attachReader(errorPipe.fileHandleForReading, prefix: "clangd err:")

        try proc.run()

        self.process = proc
        self.stdinHandle = inPipe.fileHandleForWriting
        self.stdoutHandle = outPipe.fileHandleForReading

        startReadingLoop()
        initialize()
    }


    func stop() {
        stdinHandle?.closeFile()
        stdoutHandle?.closeFile()
        process?.terminate()
        process = nil
        stdinHandle = nil
        stdoutHandle = nil
        
    }

    private func send<T: Encodable>(_ obj: T) {
        writeQueue.async {
            guard let handle = self.stdinHandle else { return }
            
            do {
                let data = try self.jsonEncoder.encode(obj)
                let header = "Content-Length: \(data.count)\r\n\r\n"
                let headerData = header.data(using: .utf8)!
                handle.write(headerData)
                handle.write(data)
                
            } catch {
                print("LSP encode error: \(error)")
                
            }
        }
    }

    private func sendRequest<T: Encodable>(_ method: String, params: T?, completion: ((Data?) -> Void)? = nil) {
        let id = nextId
        nextId += 1
        if let completion = completion { responseHandlers[id] = completion }
        
        let req = JSONRPCRequest(id: id, method: method, params: params)
        
        send(req)
    }

    private func sendNotification<T: Encodable>(_ method: String, params: T?) {
        let note = JSONRPCNotification(method: method, params: params)
        send(note)
        
    }

    private struct InitializeParams: Encodable {
        let processId: Int?
        let rootUri: String?

    }

    private func initialize() {
        let params = InitializeParams(processId: Int(ProcessInfo.processInfo.processIdentifier), rootUri: nil)
        
        sendRequest("initialize", params: params) { [weak self] _ in
            self?.sendNotification("initialized", params: EmptyParams())
            
        }
    }

    private struct TextDocumentItem: Codable {
        let uri: String
        let languageId: String
        let version: Int
        let text: String
        
    }
    
    private struct DidOpenTextDocumentParams: Codable {
        let textDocument: TextDocumentItem
        
    }
    
    func openDocument(uri: String, languageId: String, text: String) {
        let item = TextDocumentItem(uri: uri, languageId: languageId, version: 1, text: text)
        let params = DidOpenTextDocumentParams(textDocument: item)
        
        sendNotification("textDocument/didOpen", params: params)
        
    }

    private struct VersionedTextDocumentIdentifier: Codable {
        let uri: String
        let version: Int
        
    }
    
    private struct TextDocumentContentChangeEvent: Codable {
        let text: String
        
    }
    
    private struct DidChangeTextDocumentParams: Codable {
        let textDocument: VersionedTextDocumentIdentifier
        let contentChanges: [TextDocumentContentChangeEvent]
        
    }

    func changeDocument(uri: String, text: String, version: Int = 1) {
        let textDocument = VersionedTextDocumentIdentifier(uri: uri, version: version)
        let change = TextDocumentContentChangeEvent(text: text)
        let params = DidChangeTextDocumentParams(textDocument: textDocument, contentChanges: [change])
        
        sendNotification("textDocument/didChange", params: params)
        
    }

    private struct TextDocumentIdentifier: Codable {
        let uri: String
    }
    
    private struct Position: Codable {
        let line: Int
        let character: Int
        
    }
    
    private struct CompletionParams: Codable {
        let textDocument: TextDocumentIdentifier
        let position: Position
        
    }
    
    func requestCompletions(uri: String, line: Int, character: Int) {
        let params = CompletionParams(
            textDocument: TextDocumentIdentifier(uri: uri),
            position: Position(line: line, character: character)
        )
        
        sendRequest("textDocument/completion", params: params)
        
    }

    private func startReadingLoop() {
        guard let handle = stdoutHandle else { return }
        
        readQueue.async { [weak self] in
            guard let self = self else { return }
            
            handle.readabilityHandler = { [weak self] handle in
                guard let self = self else { return }
                let data = handle.availableData
                if data.isEmpty { return }
                
                self.processIncomingData(data)
            }
        }
    }

    private func processIncomingData(_ data: Data) {
        readBuffer.append(data)

        while true {
            if expectedContentLength == nil {

                if let headerEndRange = readBuffer.range(of: Data("\r\n\r\n".utf8)) {
                    let headerData = readBuffer.subdata(in: 0..<headerEndRange.lowerBound)
                    
                    if let headerString = String(data: headerData, encoding: .utf8) {
                        let lines = headerString.split(separator: "\r\n")
                        
                        if let clLine = lines.first(where: { $0.lowercased().hasPrefix("content-length:") }) {
                            let parts = clLine.split(separator: ":")
                            
                            if parts.count >= 2, let contentLength = Int(parts[1].trimmingCharacters(in: .whitespaces)) {
                                expectedContentLength = contentLength

                                readBuffer.removeSubrange(0..<headerEndRange.upperBound)
                                
                            } else {
                                readBuffer.removeAll()
                                break
                                
                            }
                            
                        } else {
                            readBuffer.removeAll()
                            break
                            
                        }
                        
                    } else {
                        readBuffer.removeAll()
                        break
                        
                    }
                    
                } else {
                    break
                    
                }
            }

            if let contentLength = expectedContentLength, readBuffer.count >= contentLength {
                let messageBody = readBuffer.prefix(contentLength)
                
                readBuffer.removeSubrange(0..<contentLength)
                expectedContentLength = nil
                
                handleMessageBody(Data(messageBody))
                
            } else {
                break
                
            }
        }
    }

    private func handleMessageBody(_ body: Data) {
        do {
            let obj = try JSONSerialization.jsonObject(with: body, options: []) as? [String: Any]
            if let obj = obj {
                if let id = obj["id"] as? Int, let handler = responseHandlers[id] {
                    handler(body)
                    responseHandlers.removeValue(forKey: id)
                    
                } else if let method = obj["method"] as? String {
                    if method == "textDocument/publishDiagnostics" {
                        NotificationCenter.default.post(name: .lspDiagnosticsReceived, object: obj)
                        
                    }
                }
            }
        } catch {
            print("LSP parse error: \(error)")
            
        }
    }
}

