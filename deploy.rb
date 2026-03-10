branch = ENV['BRANCH_NAME']

puts "Current branch: #{branch}"

# Build Docker image
system("docker build -t nginx-demo .")

if branch == "develop"
  puts "Deploying to DEV environment..."
  system("helm upgrade --install nginx-dev ./helm/nginx-chart")

elsif branch == "main"
  puts "Deploying to PRODUCTION environment..."
  system("helm upgrade --install nginx-prod ./helm/nginx-chart")

else
  puts "Feature branch detected. Skipping deployment."
end
