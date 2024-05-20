#!/bin/sh

# github-desktop-bin
artix_coding_install() {
    echo 'eclipse-java git-filter-repo github-cli jdk17-openjdk jdk8-openjdk jdk-openjdk rust shellcheck typescript-language-server eslint-language-server eslint esbuild'
}

arch_coding_install() {
    echo 'eclipse-java git-filter-repo github-cli jdk17-openjdk jdk8-openjdk jdk-openjdk rust shellcheck typescript-language-server esbuild'
}

artix_coding_configure() {
    archlinux-java set java-17-openjdk
}

arch_coding_configure() {
    archlinux-java set java-17-openjdk
}

