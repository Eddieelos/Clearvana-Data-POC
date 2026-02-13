# GitHub Pages Setup Instructions

This repository has been configured to use GitHub Pages with Jekyll. Follow these steps to enable the site.

## Steps to Enable GitHub Pages

1. **Go to Repository Settings**
   - Navigate to: https://github.com/Eddieelos/ClearvanaPOC_info/settings/pages

2. **Configure Pages Source**
   - Under "Build and deployment"
   - Source: Select "GitHub Actions"
   - This will use the workflow at `.github/workflows/jekyll-gh-pages.yml`

3. **Merge this PR to Main Branch**
   - Once merged to main, the workflow will automatically run
   - The site will be deployed to: https://eddieelos.github.io/ClearvanaPOC_info

## Site Structure

The site includes the following pages:

- **Home** (`index.md`) - Project overview and navigation
- **Schema Design** (`schema-design.md`) - Database schema and entity relationships
- **Documentation** (`documentation.md`) - Technical documentation, data dictionary, and API specs
- **Test Lineage** (`test-lineage.md`) - Test coverage and data lineage tracking

## Local Development

To run the site locally:

```bash
# Install dependencies
bundle install

# Serve locally
bundle exec jekyll serve

# View at http://localhost:4000/ClearvanaPOC_info
```

## Customization

### Theme and Styling
- Current theme: Cayman (clean, professional GitHub Pages theme)
- To change theme, edit `theme:` in `_config.yml`
- Available themes: https://pages.github.com/themes/

### Content Updates
- All pages use Markdown format
- Edit `.md` files directly
- Changes pushed to main will auto-deploy

### Navigation
- Edit navigation in `_config.yml` under the `navigation:` section
- Links are relative to the `baseurl`

## Troubleshooting

If the site doesn't appear after enabling:
1. Check Actions tab for workflow status
2. Ensure GitHub Pages is set to "GitHub Actions" source
3. Wait 2-3 minutes for first deployment
4. Check that the repository is public or you have GitHub Pages enabled for private repos

## What's Included

✅ Jekyll configuration with Cayman theme
✅ Comprehensive documentation structure
✅ Schema design documentation
✅ Test lineage and data quality docs
✅ Automated deployment workflow
✅ Local development setup (Gemfile)
✅ Git ignore rules for Jekyll

## Next Steps

After merging this PR:
1. Enable GitHub Pages in repository settings
2. Wait for workflow to complete
3. Visit your site at https://eddieelos.github.io/ClearvanaPOC_info
4. Continue adding content to the documentation pages
5. Add diagrams, images, or additional pages as needed
