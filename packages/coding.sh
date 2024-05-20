#!/bin/sh

# github-desktop-bin
artix_coding_install() {
    echo 'esbuild git-filter-repo github-cli jdk17-openjdk jdk8-openjdk jdk-openjdk rust shellcheck'
}

arch_coding_install() {
    echo 'esbuild git-filter-repo github-cli jdk17-openjdk jdk8-openjdk jdk-openjdk rust shellcheck'
}

artix_coding_configure() {
    archlinux-java set java-17-openjdk
}

arch_coding_configure() {
    archlinux-java set java-17-openjdk
}

