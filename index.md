---
layout: default
title: Clearvana POC - Data Model
---

<div style="text-align: center;">
  <img src="docs/assets/clearvana%203_2.png" alt="Clearvana Logo" />
</div>

------------------------------------------------------------------------

# Clearvana POC - Data Model

Welcome to the Clearvana Proof of Concept (POC) Data Model documentation. This site contains comprehensive information about the analytic data model designed for Clearvana, a company focused on combating disinformation on the Web.

## Overview

This POC demonstrates the data model architecture, schema design, and testing framework for analyzing and tracking disinformation patterns across web platforms.

<div style="text-align: center;">
  <img src="docs/assets/Lineage.png" alt="Data Lineage Diagram" />
  <p><em>Data lineage showing the flow and transformation of data across the system</em></p>
</div>

<div style="text-align: center;">
  <img src="docs/assets/Srate_lineage.png" alt="Success Rate Lineage" />
  <p><em>Success rate lineage tracking data quality and validation metrics</em></p>
</div>

<div style="text-align: center;">
  <img src="docs/assets/Success_rate.png" alt="Success Rate Visualization" />
  <p><em>Visualization of success rate metrics across different data pipelines</em></p>
</div>

## Quick Links

- [Data Roadmap](clearvana_data_roadmap.md) - Strategic roadmap for data infrastructure and analytics
- [Schema Design](Schema_desc.md) - Explore the database schema and entity relationships
- [Documentation](documentation.md) - Detailed documentation of the data model components
- [Test Lineage](test-lineage.md) - Test coverage and data lineage tracking
- [Models Directory](https://github.com/Eddieelos/Clearvana-Data-POC/tree/main/models) - dbt models for data transformations
- [Column Descriptions](docs/column_descriptions.md) - Detailed descriptions of all data columns
- [Metric Definitions](docs/metric_definitions.md) - Definitions of key metrics and KPIs

## Project Goals

1. **Data Model Design** - Create a scalable and efficient data model for disinformation tracking
2. **Schema Documentation** - Provide clear documentation of all entities and relationships
3. **Test Coverage** - Ensure comprehensive testing and data lineage tracking
4. **Proof of Concept** - Validate the approach with real-world scenarios

## About Clearvana

Clearvana is dedicated to identifying and addressing disinformation on the Web, providing tools and analytics to combat false information and improve information quality online.

---

*Last Updated: {{ site.time | date: '%B %d, %Y' }}*
