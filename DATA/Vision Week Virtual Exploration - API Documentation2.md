# Vision Week Virtual Exploration - API Documentation

## Overview

The Vision Week Virtual Exploration API provides comprehensive access to animal data, categories, and exploration features. This RESTful API supports the virtual exploration application with secure, scalable endpoints.

## Base URL

```
Production: https://api.vision-week.com
Staging: https://staging-api.vision-week.com
Development: http://localhost:8080/api
```

## Authentication

The API uses JWT (JSON Web Tokens) for authentication. Include the token in the Authorization header:

```http
Authorization: Bearer <your-jwt-token>
```

### Getting a Token

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "your-password"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expires_in": 3600,
    "user": {
      "id": 1,
      "email": "user@example.com",
      "role": "user"
    }
  }
}
```

## Rate Limiting

API requests are rate-limited to ensure fair usage:

- **General endpoints**: 100 requests per minute
- **Authentication endpoints**: 5 requests per minute
- **Search endpoints**: 50 requests per minute

Rate limit headers are included in responses:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640995200
```

## Response Format

All API responses follow a consistent format:

### Success Response
```json
{
  "success": true,
  "data": {
    // Response data
  },
  "meta": {
    "timestamp": "2024-01-01T12:00:00Z",
    "version": "2.0.0"
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": 400,
    "message": "Validation failed",
    "details": {
      "field": "name",
      "issue": "Name is required"
    }
  },
  "meta": {
    "timestamp": "2024-01-01T12:00:00Z",
    "version": "2.0.0"
  }
}
```

## HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | OK - Request successful |
| 201 | Created - Resource created successfully |
| 400 | Bad Request - Invalid request data |
| 401 | Unauthorized - Authentication required |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource not found |
| 409 | Conflict - Resource already exists |
| 422 | Unprocessable Entity - Validation failed |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server error |

## Endpoints

### Animals

#### Get All Animals

```http
GET /api/animals
```

**Parameters:**
- `page` (integer, optional): Page number (default: 1)
- `limit` (integer, optional): Items per page (default: 20, max: 100)
- `category_id` (integer, optional): Filter by category
- `conservation_status` (string, optional): Filter by conservation status
- `sort` (string, optional): Sort field (name, created_at, updated_at)
- `order` (string, optional): Sort order (asc, desc)

**Example:**
```http
GET /api/animals?page=1&limit=10&category_id=1&sort=name&order=asc
```

**Response:**
```json
{
  "success": true,
  "data": {
    "animals": [
      {
        "id": 1,
        "uuid": "550e8400-e29b-41d4-a716-446655440000",
        "name": "African Lion",
        "scientific_name": "Panthera leo",
        "category": {
          "id": 1,
          "name": "Mammals"
        },
        "description": "The African lion is a large cat native to Africa.",
        "habitat": "Savanna and grasslands",
        "diet": "Carnivore",
        "conservation_status": "Vulnerable",
        "average_lifespan": 15,
        "weight_range": "120-250 kg",
        "height_range": "0.9-1.2 m",
        "fun_facts": [
          "Known as the 'King of the Jungle'",
          "Lives in prides of 10-15 individuals"
        ],
        "image_url": "https://example.com/images/lion.jpg",
        "created_at": "2024-01-01T12:00:00Z",
        "updated_at": "2024-01-01T12:00:00Z"
      }
    ]
  },
  "pagination": {
    "total": 150,
    "page": 1,
    "limit": 10,
    "pages": 15,
    "has_next": true,
    "has_prev": false
  }
}
```

#### Get Animal by ID

```http
GET /api/animals/{id}
```

**Parameters:**
- `id` (integer): Animal ID

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "uuid": "550e8400-e29b-41d4-a716-446655440000",
    "name": "African Lion",
    "scientific_name": "Panthera leo",
    "category": {
      "id": 1,
      "name": "Mammals",
      "description": "Warm-blooded vertebrates"
    },
    "description": "The African lion is a large cat native to Africa.",
    "habitat": "Savanna and grasslands",
    "diet": "Carnivore",
    "conservation_status": "Vulnerable",
    "average_lifespan": 15,
    "weight_range": "120-250 kg",
    "height_range": "0.9-1.2 m",
    "fun_facts": [
      "Known as the 'King of the Jungle'",
      "Lives in prides of 10-15 individuals"
    ],
    "image_url": "https://example.com/images/lion.jpg",
    "gallery": [
      "https://example.com/images/lion-1.jpg",
      "https://example.com/images/lion-2.jpg"
    ],
    "created_at": "2024-01-01T12:00:00Z",
    "updated_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Create Animal

```http
POST /api/animals
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "name": "Snow Leopard",
  "scientific_name": "Panthera uncia",
  "category_id": 1,
  "description": "A large cat native to mountain ranges of Central and South Asia.",
  "habitat": "Mountains",
  "diet": "Carnivore",
  "conservation_status": "Vulnerable",
  "average_lifespan": 18,
  "weight_range": "22-55 kg",
  "height_range": "0.6 m",
  "fun_facts": [
    "Can leap up to 50 feet",
    "Has large paws that act as snowshoes"
  ],
  "image_url": "https://example.com/images/snow-leopard.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 151,
    "uuid": "550e8400-e29b-41d4-a716-446655440001",
    "name": "Snow Leopard",
    "scientific_name": "Panthera uncia",
    "created_at": "2024-01-01T12:00:00Z"
  }
}
```

#### Update Animal

```http
PUT /api/animals/{id}
Authorization: Bearer <token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "description": "Updated description",
  "conservation_status": "Endangered"
}
```

#### Delete Animal

```http
DELETE /api/animals/{id}
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "message": "Animal deleted successfully"
  }
}
```

#### Search Animals

```http
GET /api/animals/search
```

**Parameters:**
- `q` (string, required): Search query
- `limit` (integer, optional): Maximum results (default: 20)
- `category_id` (integer, optional): Filter by category
- `min_score` (float, optional): Minimum relevance score (0-1)

**Example:**
```http
GET /api/animals/search?q=big%20cat&limit=10&category_id=1
```

**Response:**
```json
{
  "success": true,
  "data": {
    "query": "big cat",
    "results": [
      {
        "id": 1,
        "name": "African Lion",
        "scientific_name": "Panthera leo",
        "description": "The African lion is a large cat...",
        "relevance_score": 0.95,
        "image_url": "https://example.com/images/lion.jpg"
      }
    ],
    "total_results": 5,
    "search_time_ms": 45
  }
}
```

### Categories

#### Get All Categories

```http
GET /api/categories
```

**Response:**
```json
{
  "success": true,
  "data": {
    "categories": [
      {
        "id": 1,
        "name": "Mammals",
        "description": "Warm-blooded vertebrates with hair or fur",
        "animal_count": 75,
        "image_url": "https://example.com/images/mammals.jpg"
      },
      {
        "id": 2,
        "name": "Birds",
        "description": "Feathered, winged, bipedal vertebrates",
        "animal_count": 45,
        "image_url": "https://example.com/images/birds.jpg"
      }
    ]
  }
}
```

#### Get Animals by Category

```http
GET /api/categories/{id}/animals
```

**Parameters:**
- `id` (integer): Category ID
- `page` (integer, optional): Page number
- `limit` (integer, optional): Items per page

### Statistics

#### Get Application Statistics

```http
GET /api/statistics
```

**Response:**
```json
{
  "success": true,
  "data": {
    "statistics": {
      "total_animals": 150,
      "total_categories": 5,
      "by_category": {
        "Mammals": 75,
        "Birds": 45,
        "Reptiles": 20,
        "Fish": 8,
        "Amphibians": 2
      },
      "by_conservation_status": {
        "Least Concern": 80,
        "Near Threatened": 25,
        "Vulnerable": 25,
        "Endangered": 15,
        "Critically Endangered": 5
      },
      "recent_additions": 12,
      "last_updated": "2024-01-01T12:00:00Z"
    }
  }
}
```

### Health Check

#### Application Health

```http
GET /api/health
```

**Response:**
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "timestamp": "2024-01-01T12:00:00Z",
    "version": "2.0.0",
    "services": {
      "database": "healthy",
      "redis": "healthy",
      "storage": "healthy"
    },
    "uptime": 86400
  }
}
```

## Error Handling

### Validation Errors

```json
{
  "success": false,
  "error": {
    "code": 422,
    "message": "Validation failed",
    "validation_errors": {
      "name": ["Name is required"],
      "scientific_name": ["Scientific name must be in format 'Genus species'"],
      "category_id": ["Category must be a valid integer"]
    }
  }
}
```

### Authentication Errors

```json
{
  "success": false,
  "error": {
    "code": 401,
    "message": "Authentication required",
    "details": "Token is missing or invalid"
  }
}
```

### Rate Limit Errors

```json
{
  "success": false,
  "error": {
    "code": 429,
    "message": "Rate limit exceeded",
    "details": "Too many requests. Try again in 60 seconds.",
    "retry_after": 60
  }
}
```

## SDKs and Libraries

### JavaScript/TypeScript

```bash
npm install @vision-week/api-client
```

```javascript
import { VisionWeekAPI } from '@vision-week/api-client';

const api = new VisionWeekAPI({
  baseURL: 'https://api.vision-week.com',
  apiKey: 'your-api-key'
});

// Get all animals
const animals = await api.animals.getAll({ page: 1, limit: 10 });

// Search animals
const results = await api.animals.search('lion');

// Get animal by ID
const animal = await api.animals.getById(1);
```

### PHP

```bash
composer require vision-week/api-client
```

```php
use VisionWeek\ApiClient;

$api = new ApiClient([
    'base_url' => 'https://api.vision-week.com',
    'api_key' => 'your-api-key'
]);

// Get all animals
$animals = $api->animals()->getAll(['page' => 1, 'limit' => 10]);

// Search animals
$results = $api->animals()->search('lion');

// Get animal by ID
$animal = $api->animals()->getById(1);
```

## Webhooks

The API supports webhooks for real-time notifications:

### Webhook Events

- `animal.created` - New animal added
- `animal.updated` - Animal information updated
- `animal.deleted` - Animal removed
- `category.created` - New category added

### Webhook Payload

```json
{
  "event": "animal.created",
  "timestamp": "2024-01-01T12:00:00Z",
  "data": {
    "id": 151,
    "name": "Snow Leopard",
    "scientific_name": "Panthera uncia"
  }
}
```

## API Versioning

The API uses URL versioning:

- Current version: `v2` (default)
- Previous version: `v1` (deprecated)

```http
GET /api/v2/animals
GET /api/v1/animals  # Deprecated
```

## Testing

### Postman Collection

Import our Postman collection for easy API testing:

```
https://api.vision-week.com/postman/collection.json
```

### OpenAPI Specification

View the complete OpenAPI 3.0 specification:

```
https://api.vision-week.com/openapi.json
```

## Support

For API support and questions:

- **Documentation**: https://docs.vision-week.com
- **Email**: api-support@vision-week.com
- **GitHub Issues**: https://github.com/kvnbbg/vision-week-virtual-exploration/issues
- **Discord**: https://discord.gg/vision-week

## Changelog

### Version 2.0.0 (Current)
- Added JWT authentication
- Improved search functionality
- Added pagination to all list endpoints
- Enhanced error handling
- Added rate limiting
- Introduced webhooks

### Version 1.0.0 (Deprecated)
- Initial API release
- Basic CRUD operations
- Simple authentication

