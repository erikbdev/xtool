#!/usr/bin/env node

import fs from 'fs';

function update(schema, value) {
  for (const key in value) {
    const val = value[key];
    if (val === null) {
      delete schema[key];
    } else if (Array.isArray(val)) {
      schema[key] = (schema[key] ?? []).concat(val);
    } else if (typeof val === 'object') {
      if (schema[key] === undefined) {
        schema[key] = {};
      }
      update(schema[key], val);
    } else {
      schema[key] = val;
    }
  }
}

// in-place update
function replace(schema, value) {
  Object.keys(schema).forEach(k => delete schema[k]);
  Object.assign(schema, value);
}

function clone(schema) {
  return JSON.parse(JSON.stringify(schema));
}

function makeOpen(enumSchema) {
  replace(enumSchema, {
    anyOf: [
      clone(enumSchema),
      { type: 'string' },
    ]
  });
}

function patch(schema) {
  const schemas = schema.components.schemas;
  
  // this field is required when using the private Xcode API
  update(schemas.BundleIdCapabilityCreateRequest.properties.data.properties.relationships, {
    properties: {
      capability: {
        type: 'object',
        properties: {
          data: {
            type: 'object',
            properties: {
              type: {
                type: 'string',
                enum: ['capabilities'],
              },
              id: { $ref: '#/components/schemas/CapabilityType' },
            },
            required: ['id', 'type'],
          },
        },
        required: ['data'],
      }
    },
    required: ['capability'],
  })
  
  // we don't use this but it triggers a deprecation warning. see:
  // https://github.com/apple/swift-openapi-generator/issues/715
  schemas.App.properties.relationships.properties.inAppPurchases.deprecated = false;
  
  // openapi-generator expects response enums to be exhaustive. Apple's ASC OpenAPI spec
  // misses some cases that they do, actually, return.
  // https://swiftpackageindex.com/apple/swift-openapi-generator/1.7.2/documentation/swift-openapi-generator/useful-openapi-patterns#Open-enums-and-oneOfs
  makeOpen(schemas.BundleIdPlatform);
  makeOpen(schemas.CapabilityType);
  makeOpen(schemas.CertificateType);
  makeOpen(schemas.Device.properties.attributes.properties.deviceClass);
  
  return schema;
}

const text = fs.readFileSync(process.stdin.fd, 'utf8');
const json = JSON.parse(text);
const patched = patch(json);
const patchedText = JSON.stringify(patched);
console.log(patchedText);
