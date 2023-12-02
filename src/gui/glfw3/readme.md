
# GLFW 3 bindings

This package implements bindings for GLFW version 3.3.

## Config

- `GLFW_SHARED`: Link with shared version of glfw3 library.
- `GLFW_SYSTEM`: Link with the system version of glfw3 library (linux only).

## Status

- [x] All base functions have a wrapper
- [ ] Can be used with OpenGL packages
- [ ] Can be used with Vulkan packages
- [ ] Linux native functions
- [ ] Darwin native functions
- [ ] Windows native functions

## Supported platforms

- [x] `windows_amd64`
- [x] `windows_i386`
- [x] `linux_amd64`
- [ ] `linux_i386`
- [ ] `linux_arm64`
- [ ] `linux_arm32`
- [x] `darwin_arm64`
- [x] `darwin_amd64`

## Notes

The linux binaries have been built both with support for X11 and wayland.
