git clone --depth 1 https://github.com/ollama/ollama.git
cd ollama
go generate ./...
go build .
