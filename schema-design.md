---
layout: default
title: Clearvana POC data model
---

# Schema Design

This document outlines the schema design for the Clearvana POC data model.

## Overview

The data model is designed to track and analyze disinformation patterns across various web platforms. It captures content, sources, verification status, and propagation patterns.

## Core Entities

### 1. Content Items
Represents individual pieces of content that may contain disinformation.

**Attributes:**
- `content_id` (Primary Key): Unique identifier
- `content_type`: Type of content (article, post, video, etc.)
- `title`: Content title
- `body`: Content body/text
- `url`: Source URL
- `created_at`: Timestamp of creation
- `updated_at`: Timestamp of last update
- `verification_status`: Status (verified, disputed, false, pending)

### 2. Sources
Tracks the sources of content.

**Attributes:**
- `source_id` (Primary Key): Unique identifier
- `source_name`: Name of the source
- `source_type`: Type (website, social media, news outlet)
- `domain`: Domain name
- `credibility_score`: Calculated credibility metric
- `created_at`: Timestamp

### 3. Propagation
Tracks how content spreads across platforms.

**Attributes:**
- `propagation_id` (Primary Key): Unique identifier
- `content_id` (Foreign Key): Reference to content
- `platform`: Platform name
- `reach_count`: Number of views/impressions
- `engagement_count`: Likes, shares, comments
- `timestamp`: When propagation was recorded

### 4. Verifications
Records verification checks performed on content.

**Attributes:**
- `verification_id` (Primary Key): Unique identifier
- `content_id` (Foreign Key): Reference to content
- `verifier`: Who verified the content
- `verification_date`: When verification was performed
- `result`: Verification result
- `notes`: Additional notes

## Entity Relationships

```
Content Items (1) ─── (N) Propagation
Content Items (N) ─── (1) Sources
Content Items (1) ─── (N) Verifications
```

## Data Flow

1. **Ingestion**: Content is ingested from various sources
2. **Storage**: Content is stored with metadata
3. **Verification**: Content undergoes verification processes
4. **Tracking**: Propagation is tracked across platforms
5. **Analysis**: Data is analyzed for patterns and trends

## Schema Evolution

The schema is designed to be flexible and scalable, allowing for:
- Addition of new content types
- Integration with additional platforms
- Enhanced verification methods
- Advanced analytics capabilities

## Next Steps

- [Documentation](documentation.md) - Detailed field descriptions and business rules
- [Test Lineage](test-lineage.md) - Test coverage for schema components

---

[Back to Home](index.md)
