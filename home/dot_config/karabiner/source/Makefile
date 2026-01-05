YAML_SOURCE = karabiner.yml
JSON_OUT = $(HOME)/.config/karabiner/assets/complex_modifications/karabiner.json

compile:
	@echo "Compiling YAML to JSON..."
	@mkdir -p $(dir $(JSON_OUT))
	@# Check if yq (mikefarah Go version) is available
	@if ! yq --version 2>&1 | grep -q "mikefarah"; then \
		echo "[ERROR] This requires yq (Go version by mikefarah)"; \
		echo "        Install with: brew install yq"; \
		echo "        Current yq: $$(which yq)"; \
		exit 1; \
	fi
	@# Convert YAML to JSON, removing x-parameters section
	@yq eval 'del(.x-parameters)' $(YAML_SOURCE) -o=json > $(JSON_OUT)
	@echo "✓ Compiled: $(JSON_OUT)"

install: compile
	@echo "✓ Configuration ready at: $(JSON_OUT)"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Open Karabiner-Elements"
	@echo "  2. Go to 'Complex Modifications' tab"
	@echo "  3. Click 'Add rule' and enable the rules you want"

clean:
	@rm -f $(JSON_OUT)
	@echo "✓ Cleaned generated files"

.PHONY: compile install clean
