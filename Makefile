# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# SOVEREIGN ORCHESTRATOR BUILD SYSTEM
# Zero-dependency compilation for air-gapped deployment

CC = gcc
CFLAGS = -std=c99 -Wall -Wextra -Wpedantic -O2 -march=native
CFLAGS_DEBUG = -std=c99 -Wall -Wextra -Wpedantic -g -O0 -DDEBUG
CFLAGS_VERIFY = -std=c99 -Wall -Wextra -Wpedantic -O0 -fsanitize=address,undefined

TARGET = sovereign_orchestrator
SRC = sovereign_orchestrator.c
OBJ = $(SRC:.c=.o)

# Lean 4 verification
LEAN = lake
LEAN_PROJECT = formal/orchestrator

.PHONY: all clean verify test run debug help

all: $(TARGET)

$(TARGET): $(SRC)
	@echo "=== Building Sovereign Orchestrator ==="
	$(CC) $(CFLAGS) -o $@ $<
	@echo "✓ Build complete: $@"
	@echo ""

debug: $(SRC)
	@echo "=== Building Debug Version ==="
	$(CC) $(CFLAGS_DEBUG) -o $(TARGET)_debug $<
	@echo "✓ Debug build complete: $(TARGET)_debug"
	@echo ""

verify: $(SRC)
	@echo "=== Building with Sanitizers ==="
	$(CC) $(CFLAGS_VERIFY) -o $(TARGET)_verify $<
	@echo "✓ Verification build complete: $(TARGET)_verify"
	@echo ""

run: $(TARGET)
	@echo "=== Running Sovereign Orchestrator ==="
	@echo ""
	./$(TARGET)

test: verify
	@echo "=== Running Verification Tests ==="
	@echo ""
	./$(TARGET)_verify
	@echo ""
	@echo "✓ All tests passed"

lean-verify:
	@echo "=== Verifying Lean 4 Proofs ==="
	@if [ -d "$(LEAN_PROJECT)" ]; then \
		cd $(LEAN_PROJECT) && $(LEAN) build; \
	else \
		echo "Lean project not found at $(LEAN_PROJECT)"; \
	fi

clean:
	@echo "=== Cleaning Build Artifacts ==="
	rm -f $(TARGET) $(TARGET)_debug $(TARGET)_verify $(OBJ)
	@echo "✓ Clean complete"

help:
	@echo "Sovereign Orchestrator Build System"
	@echo "===================================="
	@echo ""
	@echo "Targets:"
	@echo "  all          - Build release version (default)"
	@echo "  debug        - Build debug version with symbols"
	@echo "  verify       - Build with address/undefined sanitizers"
	@echo "  run          - Build and run release version"
	@echo "  test         - Build and run verification tests"
	@echo "  lean-verify  - Verify Lean 4 formal proofs"
	@echo "  clean        - Remove all build artifacts"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Requirements:"
	@echo "  - GCC 4.9+ or Clang 3.5+ (C99 support)"
	@echo "  - No external dependencies"
	@echo "  - Optional: Lean 4 for formal verification"
	@echo ""

# Made with Bob
