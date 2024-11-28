# Bookmark Manager

A privacy-focused, self-hosted bookmark management solution built with Ruby on Rails and Vue.js. Take control of your bookmarks and keep your data private by hosting it on your own infrastructure.

## Why Self-Host?

- **Complete Privacy**: Your bookmarks and data stay on your own server
- **No Third-Party Tracking**: No external services or analytics
- **Data Ownership**: Full control over your bookmark data and how it's stored
- **Customizable**: Modify and extend the application to suit your needs
- **Open Source**: Transparent codebase with no hidden functionality

## Features

- Create and manage bookmarks
- Organize bookmarks with tags
- Search and filter bookmarks
- Responsive Vue.js frontend

## Tech Stack

- Backend: Ruby on Rails
- Frontend: Vue.js
- Database: PostgreSQL
- Styling: Tailwind CSS

## Prerequisites

- Ruby
- Node.js and Yarn
- PostgreSQL

## Initial Setup

Before running the application, you'll need to set up your Rails master key. You can generate it using Docker without installing Rails locally:

1. Remove the existing credentials file as it won't work with a new master key:
```bash
rm config/credentials.yml.enc
```

2. Generate a secure key using OpenSSL:
```bash
openssl rand -hex 32
```

3. Create a new file named `config/master.key` with the generated key:
```bash
echo "your-generated-key" > config/master.key
```

4. Keep your `master.key` secure - it's automatically ignored by git for security.

## Setup

1. Clone the repository:
```bash
git clone git@github.com:your-username/bookmark-manager.git
cd bookmark-manager
```

2. Install dependencies:
```bash
bundle install
yarn install
```

3. Setup database:
```bash
rails db:create db:migrate
```

4. Start the servers:
```bash
./bin/dev
```

The application will be available at http://localhost:3000

## Docker Setup

The project includes a production-ready Dockerfile for easy deployment. You can deploy the application using Docker with these steps:

1. Build the Docker image:
```bash
docker build -t bookmark_manager .
```

2. Run the container:
```bash
docker run -d \
  -p 80:80 \
  -e RAILS_MASTER_KEY=<your-master-key> \
  -e DB_HOST=your-db-host \
  -e BOOKMARK_MANAGER_DATABASE_USERNAME=your-db-user \
  -e BOOKMARK_MANAGER_DATABASE_PASSWORD=your-db-password \
  --name bookmark_manager \
  bookmark_manager
```

### Environment Variables

- `RAILS_MASTER_KEY`: Your Rails master key (from the `config/master.key` file you generated)
- `DB_HOST`: PostgreSQL database host
- `BOOKMARK_MANAGER_DATABASE_USERNAME`: Database username
- `BOOKMARK_MANAGER_DATABASE_PASSWORD`: Database password
- `RAILS_ENV`: Set to "production" by default

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  web:
    build: .
    ports:
      - "80:80"
    environment:
      - RAILS_MASTER_KEY=<your-master-key>
      - DB_HOST=db
      - BOOKMARK_MANAGER_DATABASE_USERNAME=postgres
      - BOOKMARK_MANAGER_DATABASE_PASSWORD=password
    depends_on:
      - db
    restart: unless-stopped

  db:
    image: postgres:15
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=bookmark_manager
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    restart: unless-stopped

volumes:
  postgres_data:
```

Then run:
```bash
docker-compose up -d
```

The application will be available at http://localhost

### Security Notes

- Always use strong passwords in production
- Store sensitive environment variables securely
- Consider using Docker secrets or environment files
- Keep your Docker images updated

## Link Preview Setup

To enable automatic thumbnail generation for your bookmarks:

1. Sign up for a free API key at [LinkPreview.net](https://www.linkpreview.net)
2. After signing up, copy your API key from the dashboard
3. Add the API key to your environment variables:

For local development, add to your `.env` file:
```bash
LINK_PREVIEW_API_KEY=your_api_key_here
```

For Docker deployment, add the environment variable:
```bash
docker run -d \
  -p 80:80 \
  -e RAILS_MASTER_KEY=<your-master-key> \
  -e DB_HOST=your-db-host \
  -e BOOKMARK_MANAGER_DATABASE_USERNAME=your-db-user \
  -e BOOKMARK_MANAGER_DATABASE_PASSWORD=your-db-password \
  -e LINK_PREVIEW_API_KEY=your_api_key_here \
  --name bookmark_manager \
  bookmark_manager
```

If using Docker Compose, add to the web service environment:
```yaml
services:
  web:
    environment:
      - LINK_PREVIEW_API_KEY=your_api_key_here
      # ... other environment variables
```

Note: LinkPreview.net offers a free tier suitable for personal use, which includes:
- 60 Requests / per hour
- SSL encryption
- Preview image URLs
- Meta tags extraction

## Development

- Rails API endpoints are defined in `config/routes.rb`
- Vue.js components are located in `app/frontend/components`
- Database configuration is in `config/database.yml`

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).
