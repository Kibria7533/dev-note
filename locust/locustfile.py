from locust import HttpUser, task, between

class KeycloakUser(HttpUser):
    wait_time = between(1, 2)
    
    def on_start(self):
        # Simulate login to Keycloak by requesting an access token.
        self.login()
    
    def login(self):
        # POST request to the token endpoint.
        response = self.client.post(
            "/auth/realms/master/protocol/openid-connect/token",
            data={
                "client_id": "admin-cli",
                "username": "admin",
                "password": "admin",
                "grant_type": "password"
            }
        )
        if response.status_code == 200:
            token = response.json().get("access_token")
            # Optionally, use the token in subsequent requests.
            self.client.headers.update({"Authorization": f"Bearer {token}"})
        else:
            print("Login failed:", response.status_code, response.text)
    
    @task
    def get_admin_console(self):
        # For example, load the admin console page.
        # (Update this endpoint if needed for your environment.)
        self.client.get("/admin/master/console/")
