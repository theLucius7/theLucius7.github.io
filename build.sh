#!/usr/bin/env bash
set -euo pipefail

build_temp_dir=""

cleanup() {
  if [[ -n "${build_temp_dir:-}" && -d "${build_temp_dir}" ]]; then
    rm -rf "${build_temp_dir}"
  fi
}
trap cleanup EXIT SIGINT SIGTERM

main() {
  # 在这里修改 Hugo 版本号
  HUGO_VERSION=0.146.0

  export TZ=Asia/Singapore

  build_temp_dir=$(mktemp -d)
  pushd "${build_temp_dir}" > /dev/null

  mkdir -p "${HOME}/.local"

  # 安装 Hugo
  echo "Installing Hugo ${HUGO_VERSION}..."
  curl -sLJO "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
  mkdir -p "${HOME}/.local/hugo"
  tar -C "${HOME}/.local/hugo" -xf "hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
  export PATH="${HOME}/.local/hugo:${PATH}"

  popd > /dev/null

  echo "Hugo: $(hugo version)"

  # 配置 Git（拉取完整历史，用于 lastmod 等功能）
  git config core.quotepath false
  if [ "$(git rev-parse --is-shallow-repository)" = "true" ]; then
    git fetch --unshallow
  fi

  # 构建站点
  echo "Building site..."
  hugo build --gc --minify
}

main "$@"