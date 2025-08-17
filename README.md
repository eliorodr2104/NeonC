# NeonC — Native C/C++ IDE for macOS (work in progress)

NeonC is a lightweight C and C++ IDE built with Swift and SwiftUI, featuring a Liquid Glass–based interface. It aims to deliver a modern, fluid experience that’s deeply integrated with macOS and the system toolchain.

Status: experimental • Base: Liquid Glass • Compatibility: macOS 26+ • Language: Swift

Compatibility note: NeonC is currently supported and tested only on macOS 26. Earlier versions are not supported at this time.

---

## Why NeonC (once development matures)

- macOS‑native: smooth UI, familiar shortcuts, and tight integration with Apple’s toolchain (clang/LLDB).
- C/C++ focused: syntax highlighting, compiler diagnostics, and a streamlined edit–build–run loop.
- Lightweight and straightforward: optimized for “code and build,” with minimal setup.

---

## Features

Available (baseline):
- Open existing folders/projects.
- Editor with tree view for subfolders.
- Integration with the system toolchain (Xcode Command Line Tools, clang/clang++, make, CMake, and Ninja).
- Create C projects with selectable language version.

Planned / in progress:
- Syntax highlighting for C/C++.
- Build and run from the UI (minimal configuration).
- Autocomplete and diagnostics via LSP (clangd).
- Integrated debugging with LLDB (breakpoints, stepping, watch).
- Build configuration management (Release/Debug, custom flags).
- Integrated terminal and output panel.
- Themes (light/dark) and font customization.
- Project templates (executable, static/dynamic library, tests).
- Symbol navigation, “Go to Definition,” “Find References.”
- Basic refactoring (rename symbol).
- CMake and compilation database (compile_commands.json) support.

---

## Requirements

- macOS 26.
- Xcode 26 installed (for clang/LLDB toolchain and SDK).
- Xcode Command Line Tools:
  ```bash
  xcode-select --install
  ```

---

## Build from source

1) Clone the repository:
```bash
git clone https://github.com/eliorodr2104/NeonC.git
cd NeonC
```

2) Open the project in Xcode:
- Open `NeonC.xcodeproj` or `NeonC.xcworkspace` if present.
- Alternatively, open the folder in Xcode and create a build scheme.

3) Build & Run from Xcode:
- Select the app scheme and press ⌘R.
- Ensure “Signing & Capabilities” are configured if Xcode prompts you.

---

## Usage (alpha)

- Open a folder that contains C/C++ source files.
- Create a new C project from the app, choosing the desired language version.
- Open the project and browse files via the tree view.

Note: many features are under active development and may be incomplete or subject to change.
