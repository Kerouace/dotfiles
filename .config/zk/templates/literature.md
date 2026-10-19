---
title: {{json title}}
papis_id: {{extra.papis_id}}
authors: {{json env.CUSTOM_LITERATURE_AUTHORS}}
year: {{extra.year}}
date: {{format-date now}}
tags: []
lang: en-US
---

# {{title}}

{{#if env.CUSTOM_LITERATURE_DOI}}[doi:{{env.CUSTOM_LITERATURE_DOI}}](https://doi.org/{{env.CUSTOM_LITERATURE_DOI}}){{else if env.CUSTOM_LITERATURE_URL}}[{{env.CUSTOM_LITERATURE_URL}}]({{env.CUSTOM_LITERATURE_URL}}){{/if}}

Reference: [{{extra.key}}](papis://{{extra.papis_id}}) · Annotation: [annotate](papis://{{extra.papis_id}}/annotate)

{{content}}
