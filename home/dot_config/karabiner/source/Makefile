YAML_SOURCES = main.yml config/parameters.yml config/basic.yml config/hyper.yml config/space.yml
JSON_OUT = ../assets/complex_modifications/karabiner.json
INSTALL_DIR = $(HOME)/.config/karabiner/assets/complex_modifications/

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
	@# Merge YAML files using yq
	@yq eval-all '. as $$item ireduce ({}; . * $$item)' $(YAML_SOURCES) | \
	 yq eval 'del(.x-parameters)' | \
	 yq eval -o=json > $(JSON_OUT)
	@echo "✓ Compiled: $(JSON_OUT)"

install: compile
	@echo "Installing to Karabiner-Elements..."
	@mkdir -p $(INSTALL_DIR)
	@cp $(JSON_OUT) $(INSTALL_DIR)
	@echo "✓ Installed: $(INSTALL_DIR)karabiner.json"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Open Karabiner-Elements"
	@echo "  2. Go to 'Complex Modifications' tab"
	@echo "  3. Click 'Add rule' and enable the rules you want"

clean:
	@rm -f $(JSON_OUT)
	@echo "✓ Cleaned generated files"

.PHONY: compile install clean
