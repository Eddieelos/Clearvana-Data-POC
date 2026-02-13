# Clearvana-Data-POC

This is a Proof of Concept (POC) Analytic Data Model for Clearvana, a company that deals with disinformation on the Web.

## GitHub Pages Site

This repository is configured as a GitHub Pages site with comprehensive documentation:

🌐 **Visit the site**: [https://eddieelos.github.io/Clearvana-Data-POC](https://eddieelos.github.io/Clearvana-Data-POC)

## Contents

- **Schema Design**: Database schema and entity relationships for tracking disinformation
- **Documentation**: Comprehensive documentation of the data model architecture
- **Test Lineage**: Test coverage and data lineage tracking

## Quick Start

The GitHub Pages site is automatically deployed when changes are pushed to the `main` branch. The site uses Jekyll with the Cayman theme.

### Local Development

To run the site locally:

```bash
# Install Jekyll (requires Ruby)
gem install bundler jekyll

# Serve the site locally
jekyll serve

# View at http://localhost:4000/ClearvanaPOC_info
```

## About Clearvana

Clearvana is dedicated to identifying and addressing disinformation on the Web, providing tools and analytics to combat false information and improve information quality online.

## Project Structure

```
.
├── _config.yml           # Jekyll configuration
├── index.md              # Home page
├── schema-design.md      # Schema documentation
├── documentation.md      # Detailed documentation
├── test-lineage.md       # Test and lineage info
└── .github/
    └── workflows/
        └── jekyll-gh-pages.yml  # Deployment workflow
```

## Contributing

This is a proof of concept project. For questions or suggestions, please open an issue. 
