# kubectl

set -eu

TMP_DIR="$(mktemp -d)"

pushd "$TMP_DIR"
	curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
	install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
popd

rm -rf "$TMP_DIR"
