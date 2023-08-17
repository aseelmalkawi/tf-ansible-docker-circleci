FROM nginx:stable

#Copy the HTML, CSS, and JavaScript files into the container
COPY src/ /usr/share/nginx/html

#Expose port 80 for the Nginx server
EXPOSE 80

#Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]
