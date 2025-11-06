package tasks

import (
	"context"
	"errors"
	"os/exec"
	"path/filepath"
	"runtime"
	"time"
)

var (
	// ErrUnknownTask signals a task name that is not registered.
	ErrUnknownTask = errors.New("unknown task")
)

// TaskResult is a generic result payload.
type TaskResult struct {
	Name   string `json:"name"`
	Output string `json:"output,omitempty"`
	OK     bool   `json:"ok"`
	TookMs int64  `json:"took_ms"`
}

// registry of safe tasks -> script path or inline action
var registry = map[string]func(context.Context) (TaskResult, error){
	"blink_led": blinkLED,
	"scan_wifi": scanWiFi,
}

// List returns available task names.
func List() []string {
	keys := make([]string, 0, len(registry))
	for k := range registry {
		keys = append(keys, k)
	}
	return keys
}

// Run executes a registered task by name.
func Run(ctx context.Context, name string) (TaskResult, error) {
	fn, ok := registry[name]
	if !ok {
		return TaskResult{}, ErrUnknownTask
	}
	start := time.Now()
	res, err := fn(ctx)
	res.TookMs = time.Since(start).Milliseconds()
	return res, err
}

// blinkLED delegates to a tiny Python script using RPi.GPIO (only on Pi).
func blinkLED(ctx context.Context) (TaskResult, error) {
	py := filepath.Join("scripts", "gpio_blink.py")
	cmd := exec.CommandContext(ctx, "python3", py, "17", "3") // GPIO17, 3 blinks
	out, err := cmd.CombinedOutput()
	return TaskResult{Name: "blink_led", Output: string(out), OK: err == nil}, err
}

// scanWiFi uses shell to call iwlist (lightweight, no extra deps).
// Requires: sudo apt install wireless-tools
func scanWiFi(ctx context.Context) (TaskResult, error) {
	bin := "iwlist"
	if runtime.GOOS == "darwin" || runtime.GOOS == "windows" {
		// Not supported outside Linux; return quickly
		return TaskResult{Name: "scan_wifi", Output: "unsupported OS", OK: true}, nil
	}
	cmd := exec.CommandContext(ctx, bin, "wlan0", "scan")
	out, err := cmd.CombinedOutput()
	return TaskResult{Name: "scan_wifi", Output: string(out), OK: err == nil}, err
}
