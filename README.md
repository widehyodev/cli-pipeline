# CLI Pipeline

A high-performance web scraping and data processing pipeline for extracting and processing content from news.hada.io. This project implements a complete ETL (Extract, Transform, Load) pipeline using shell scripts and various command-line tools.

## 🚀 Overview

This pipeline scrapes articles from news.hada.io, extracts content using multiple processing strategies, and converts HTML content to structured CSV data. It supports both sequential and parallel processing modes for optimal performance.

## 📋 Table of Contents

- [Features](#-features)
- [Architecture](#-architecture)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Pipeline Stages](#-pipeline-stages)
- [Performance Optimization](#-performance-optimization)
- [Output Formats](#-output-formats)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)

## ✨ Features

- **Multi-stage ETL Pipeline**: Complete data extraction, transformation, and loading process
- **Parallel Processing**: Multiple processing strategies (xargs, parallel, sequential)
- **TMPFS Support**: Memory-based storage for high-performance temporary file operations
- **Rate Limiting**: Intelligent handling of HTTP rate limits and request throttling
- **Multiple Output Formats**: CSV, compressed archives, and database-ready formats
- **Error Handling**: Robust error detection and recovery mechanisms
- **Progress Monitoring**: Real-time progress tracking and performance metrics

## 🏗 Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Sitemap       │───▶│   HTML Pages    │───▶│   Processed     │
│   Fetching      │    │   Download      │    │   Content       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Topic CSV     │    │   HTML Parsing  │    │   CSV Output    │
│   Generation    │    │   (htmlq/lynx)  │    │   & Database    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔧 Prerequisites

### Required Tools
- **bash** (4.0+)
- **curl** - HTTP requests
- **jq** - JSON processing
- **htmlq** - HTML parsing
- **lynx** - HTML to text conversion
- **csvkit** - CSV processing tools
- **parallel** (GNU parallel) - Parallel processing
- **yq** - YAML/XML processing

### System Requirements
- Linux/Unix environment
- Minimum 4GB RAM (8GB+ recommended for large datasets)
- 10GB+ available disk space
- Optional: TMPFS mount for performance optimization

## 📦 Installation

### 1. Clone Repository
```bash
git clone <repository-url>
cd cli-pipeline
```

### 2. Install Dependencies
```bash
# Run the installation script
make 0_install_tools

# Or install manually:
pip install yq csvkit
curl https://sh.rustup.rs -sSf | sh
source "$HOME/.cargo/env"
cargo install htmlq
```

### 3. Create Environment Configuration
```bash
# Create .env file
cat > .env << 'EOF'
SITEMAP_URL=https://news.hada.io/sitemap/sitemap.xml
BASE_DIR=/path/to/cli-pipeline
DATA_DIR=/path/to/cli-pipeline/data
SHELL_DIR=/path/to/cli-pipeline/shell
RESULT_DIR=/path/to/cli-pipeline/data/result
PARSED_HTML_DIR=/path/to/cli-pipeline/data/parsed
HTML_DIR=/path/to/cli-pipeline/data/html
TMPFS_DIR=/tmp/tmpfs
EOF
```

### 4. Setup TMPFS (Optional but Recommended)
```bash
# Create TMPFS mount for better performance
sudo mkdir -p /tmp/tmpfs
sudo mount -t tmpfs -o size=8G tmpfs /tmp/tmpfs
```

## ⚙️ Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `SITEMAP_URL` | Target sitemap URL | `https://news.hada.io/sitemap/sitemap.xml` |
| `BASE_DIR` | Project root directory | Current directory |
| `DATA_DIR` | Data storage directory | `${BASE_DIR}/data` |
| `SHELL_DIR` | Scripts directory | `${BASE_DIR}/shell` |
| `RESULT_DIR` | Output directory | `${DATA_DIR}/result` |
| `PARSED_HTML_DIR` | Parsed HTML storage | `${DATA_DIR}/parsed` |
| `HTML_DIR` | Raw HTML storage | `${DATA_DIR}/html` |
| `TMPFS_DIR` | Temporary file storage | `/tmp/tmpfs` |

## 🎯 Usage

### Quick Start
```bash
# Run complete pipeline
make 1_fetch_sitemap
make 2_parse_sitemap
make 3_make_topic_csv
make 4_fetch_html
make 6_parse_html_parallel
make 8_convert_html_xargs_lynx
make 9_clean_csv
```

### Individual Stages
```bash
# Fetch sitemap
make 1_fetch_sitemap

# Parse sitemap and extract topic URLs
make 2_parse_sitemap

# Generate topic CSV
make 3_make_topic_csv

# Download HTML pages
make 4_fetch_html

# Handle rate limiting (if needed)
make 5_treat_too_many_request

# Parse HTML (choose processing method)
make 6_parse_html_parallel    # Fastest
make 6_parse_html_xargs       # Balanced
make 6_parse_html_sequential  # Most reliable

# Convert to CSV
make 8_convert_html_xargs_lynx  # Parallel conversion
make 8_convert_html_seq_lynx    # Sequential conversion

# Clean and validate CSV
make 9_clean_csv
```

## 📊 Pipeline Stages

### Stage 1: Sitemap Fetching
- Downloads sitemap from news.hada.io
- Validates XML structure
- **Output**: `data/sitemap.xml`

### Stage 2: Sitemap Parsing
- Extracts individual topic sitemap URLs
- Downloads topic-specific sitemaps
- **Output**: `data/topic_*.xml`

### Stage 3: Topic CSV Generation
- Parses topic sitemaps
- Extracts article URLs and metadata
- **Output**: `data/topics.csv`

### Stage 4: HTML Fetching
- Downloads HTML pages for each article
- Implements rate limiting and retry logic
- **Output**: `data/html/*.html`

### Stage 5: Rate Limit Handling
- Monitors and handles HTTP 429 responses
- Implements exponential backoff
- Resumes failed downloads

### Stage 6: HTML Parsing
Multiple processing strategies available:

#### Parallel Processing (`6_parse_html_parallel`)
- Uses GNU parallel for maximum throughput
- Best for high-performance systems
- **Fastest option**

#### Xargs Processing (`6_parse_html_xargs`)
- Uses xargs with parallel execution
- Balanced performance and reliability
- **Recommended for most cases**

#### Sequential Processing (`6_parse_html_sequential`)
- Single-threaded processing
- Most reliable for large datasets
- **Best for memory-constrained systems**

### Stage 7: HTML Compression (Optional)
- Compresses HTML files to save space
- **Output**: `data/html_compressed.tar.zst`

### Stage 8: Content Conversion
Converts HTML to structured CSV:

#### Lynx-based Conversion
- Uses lynx for HTML to text conversion
- Preserves Korean text encoding
- Supports both parallel and sequential modes

### Stage 9: CSV Cleaning
- Validates CSV structure
- Removes malformed rows
- **Output**: `data/result/cleaned.csv`

### Stage 10-11: Database Operations
- Database initialization
- Bulk data insertion

## ⚡ Performance Optimization

### TMPFS Usage
The pipeline automatically detects and uses TMPFS for temporary files:

```bash
# The script will show:
✓ TMPFS detected: /tmp/tmpfs is mounted as tmpfs
  Size: 8.0G, Available: 7.2G
```

### Processing Strategies Comparison

| Method | Speed | Memory Usage | Reliability | Best For |
|--------|-------|--------------|-------------|----------|
| Parallel | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | High-performance systems |
| Xargs | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | General use |
| Sequential | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Large datasets, limited resources |

### Performance Tips
1. **Use TMPFS**: Mount tmpfs for temporary files
2. **Adjust Parallelism**: Modify `nproc` based on system capabilities
3. **Monitor Memory**: Watch memory usage during processing
4. **Disk Space**: Ensure adequate space for intermediate files

## 📄 Output Formats

### CSV Structure
```csv
id,url,title,content
1001,"https://news.hada.io/topic?id=1001","Article Title","Article content..."
```

### Compressed Archives
- **xargs_lynx_out.zst**: Zstandard compressed CSV
- **html_compressed.tar.zst**: Compressed HTML files

## 🔍 Troubleshooting

### Common Issues

#### TMPFS Not Detected
```bash
⚠ WARNING: /tmp/tmpfs is NOT a mount point
Using regular filesystem - performance may be slower
```
**Solution**: Create and mount TMPFS:
```bash
sudo mkdir -p /tmp/tmpfs
sudo mount -t tmpfs -o size=8G tmpfs /tmp/tmpfs
```

#### Rate Limiting
```bash
HTTP 429: Too Many Requests
```
**Solution**: Run rate limit handler:
```bash
make 5_treat_too_many_request
```

#### Memory Issues
```bash
Cannot allocate memory
```
**Solutions**:
1. Use sequential processing: `make 6_parse_html_sequential`
2. Reduce parallel workers
3. Increase system memory or swap

#### CSV Validation Errors
```bash
Row X has Y columns, expected Z
```
**Solution**: Run CSV cleaner:
```bash
make 9_clean_csv
```

### Logs and Debugging
- Check individual script outputs for detailed error messages
- Monitor system resources: `htop`, `free -h`, `df -h`
- Validate intermediate files before proceeding to next stage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

### Development Guidelines
- Follow shell scripting best practices
- Add error handling for new features
- Update documentation for API changes
- Test with both small and large datasets

## 📝 License

This project is licensed under the terms specified in the LICENSE file.

## 📊 Performance Metrics

Typical performance on a modern system (8 cores, 16GB RAM, SSD):
- **Sitemap processing**: ~30 seconds
- **HTML download**: ~2-4 hours (depending on rate limits)
- **HTML parsing**: ~15-30 minutes (parallel mode)
- **Content conversion**: ~45-90 minutes (parallel mode)
- **CSV cleaning**: ~5-10 minutes

---

For questions, issues, or contributions, please open an issue in the repository.
