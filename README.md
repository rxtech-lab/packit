# Packit

Packit is a developer utility designed to consolidate multiple code files into a single, compact file. This tool is particularly useful for developers working with Large Language Models (LLMs) like Claude.ai, where inputting entire codebases or complex projects as prompts can be challenging.

# Building Packit

```bash
make build
```

# Running Packit

## Create a packit.yaml file

Create a `packit.yaml` file in the root directory of your project. This file should contain the following fields:

```yaml
input:
  patterns: ["**/*.swift"]

output:
  file: test.swift
  comment_symbol: "//"
```

```bash
packit
```
