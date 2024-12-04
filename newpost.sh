#!/bin/bash

# Prompt for the date, slug, and title
read -p "Enter the date (format: yyyy-mm-dd): " post_date
read -p "Enter the slug: " post_slug
read -p "Enter the title: " post_title

# Create the file paths
markdown_file="content/posts/${post_date}-${post_slug}.markdown"
uploads_dir="static/uploads/${post_date}-${post_slug}"

# Create the markdown file with the header
cat <<EOL > "$markdown_file"
---
title: "${post_title}"
date: ${post_date}
published: false
---
EOL

# Create the uploads directory
mkdir -p "$uploads_dir"

# Provide feedback to the user
echo "Post created at: $markdown_file"
echo "Uploads directory created at: $uploads_dir"
