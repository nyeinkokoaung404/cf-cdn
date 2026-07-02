# Cloudflare Origin CA Certificate Installer

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](http://makeapullrequest.com)

A simple, one-command bash script to securely install and configure a **Cloudflare Origin CA Certificate** on your Linux server. It automates the verification of your certificate and private key, downloads the Cloudflare Origin CA root certificate, updates the system's CA store, and restarts your web server.

## 🚀 Quick Install

Copy and paste this command into your terminal:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nyeinkokoaung404/cf-cdn/main/install.sh)
