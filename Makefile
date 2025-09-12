# Development scripts for Current Dance Wave Tidbyt app

# Render the app to see how it looks
render:
	pixlet render app.star

# Serve the app locally for development
serve:
	pixlet serve app.star --port 8081

# Check the app for errors
check:
	pixlet check app.star

# Render with specific configuration
render-config:
	pixlet render app.star --config city="Denver"

# Serve with specific configuration
serve-config:
	pixlet serve app.star --config city="Denver"

# Clean up generated files
clean:
	rm -f *.webp *.gif

# Install pixlet (Linux)
install-pixlet-linux:
	curl -LO https://github.com/tidbyt/pixlet/releases/latest/download/pixlet_linux_amd64.tar.gz
	tar -xvf pixlet_linux_amd64.tar.gz
	sudo mv pixlet /usr/local/bin/
	rm pixlet_linux_amd64.tar.gz

# Install pixlet (macOS)
install-pixlet-macos:
	brew install tidbyt/tidbyt/pixlet

# Development workflow - render and serve
dev: render serve

.PHONY: render serve check render-config serve-config clean install-pixlet-linux install-pixlet-macos dev
