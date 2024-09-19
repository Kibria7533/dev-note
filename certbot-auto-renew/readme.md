To install Let's Encrypt in Nginx and integrate automatic certificate renewal, follow these steps:

1. Install Certbot and Nginx Plugin
   On Ubuntu/Debian-based systems, you can install Certbot and the Nginx plugin using:

bash
Copy code
```
sudo apt update
sudo apt install certbot python3-certbot-nginx
```
2. Obtain an SSL Certificate
   Run Certbot to automatically configure SSL for your Nginx server:

bash
Copy code
```
sudo certbot --nginx
```
You will be prompted to enter your email address and agree to the terms of service. Certbot will automatically detect your Nginx configuration and ask which domain(s) you want to activate HTTPS for.

If your Nginx configuration is not detected or you want to manually specify the domain, use:

bash
Copy code
```
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```
3. Verify SSL Installation
   Once the certificate is issued, Certbot will configure Nginx to use the SSL certificate. You can check if your SSL is working by visiting your website using https://yourdomain.com.

4. Enable Auto Renewal
   Certbot comes with a cron job or a systemd timer to automatically renew the certificate. You can check if the timer is enabled by running:

bash
Copy code
```
sudo systemctl status certbot.timer
```
To test the renewal process, run:

bash
Copy code
```
sudo certbot renew --dry-run
```
If the dry run is successful, Certbot will automatically renew your certificates before they expire.