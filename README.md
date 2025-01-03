# Bookmark Manager

A privacy-focused, self-hosted bookmark management solution built with Ruby on Rails and Vue.js. Take control of your bookmarks and keep your data private by hosting it on your own infrastructure.

## Demo
Live URL: https://bookmarks.da-vinci-noob.com
```
Username: demo@test.com
Password: demo@test.com
```
> Note: All the Bookmarks and Tags will be deleted everyday

<table align="center">
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/83b81063-0aad-4746-a90e-3f59141bc7f7" alt="Authentication" width="420px" height="300px"></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/2e72f8b3-fb8c-451a-835f-11badda58cea" alt="Homepage" width="420px" height="300px"></td>
  </tr>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/f6d1990f-f0ba-4034-818e-236a0782ae7a" alt="Bookmarks" width="420px" height="300px"></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/5a930c19-b3e9-4b65-858b-cea572183d41" alt="Tags" width="420px" height="140px"></td>
  </tr>
  <tr>
    <td align="center"><img src="https://github.com/user-attachments/assets/73609696-a27a-4fc2-9191-dee116aa6a85" alt="MobileBookmarks" width="220px" height="350px"></td>
    <td align="center"><img src="https://github.com/user-attachments/assets/6043f076-eefd-4dc5-bb83-c74088f6f1a3" alt="MobileTags" width="220px" height="350px"></td>
  </tr>
</table>

## Why Self-Host?

- **Complete Privacy**: Your bookmarks and data stay on your own server
- **No Third-Party Tracking**: No external services or analytics
- **Data Ownership**: Full control over your bookmark data and how it's stored
- **Customizable**: Modify and extend the application to suit your needs
- **Open Source**: Transparent codebase with no hidden functionality

## Features

- Modern, responsive interface built with Vue.js
- Create, edit, and manage bookmarks with ease
- Powerful tagging system for better organization
- Advanced search and filtering capabilities
- Mobile-friendly design with dedicated mobile navigation
- Dark/Light theme support
- Fast and efficient bookmark management
- Secure authentication system

## Tech Stack

### Backend
- Ruby on Rails 7
- PostgreSQL database

### Frontend
- Vue.js 3 with Composition API
- Vite.js for fast development and building
- Tailwind CSS for modern, responsive styling

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
  -e SECRET_KEY_BASE_DUMMY=1 \
  -e DB_HOST=<your-db-host> \
  -e BOOKMARK_MANAGER_DATABASE_USERNAME=<your-db-user> \
  -e BOOKMARK_MANAGER_DATABASE_PASSWORD=<your-db-password> \
  --name bookmark_manager \
  bookmark_manager
```

### Environment Variables

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
      - SECRET_KEY_BASE_DUMMY=1
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

## Configuration

### User Registration

By default, new user registrations are enabled. To disable user registrations (e.g., for a private instance), set the `DISABLE_REGISTRATIONS` environment variable:

```bash
# Disable new user registrations
export DISABLE_REGISTRATIONS=true

# Or in your .env file
DISABLE_REGISTRATIONS=true
```

When registrations are disabled:
- The registration link will be hidden from the login page
- Registration routes will be disabled
- Any attempts to create new users will be blocked

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
  -e SECRET_KEY_BASE_DUMMY=1 \
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
