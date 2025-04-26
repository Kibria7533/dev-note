Locust Distributed Load Testing Notes

1. Setup Locust for Keycloak Load Testing

1.1 Create locustfile.py

```
from locust import HttpUser, task, between

class KeycloakUser(HttpUser):
    wait_time = between(1, 2)
    
    def on_start(self):
        self.login()
    
    def login(self):
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
            self.client.headers.update({"Authorization": f"Bearer {token}"})
    
    @task
    def get_admin_console(self):
        self.client.get("/admin/master/console/")
```

2. Run Locust in Docker Compose (Single Instance)

2.1 Create docker-compose.yml

```
version: "3.8"

services:
  locust:
    image: locustio/locust
    ports:
      - "8089:8089"
    volumes:
      - .:/mnt/locust
    command: -f /mnt/locust/locustfile.py --host=http://142.132.216.196:30949
```

2.2 Start Locust

```docker-compose up```

Open http://localhost:8089 in a browser.

Enter number of users and ramp-up rate.

Click Start to begin testing.

3. Running Locust in Distributed Mode (Master-Worker Setup)

3.1 Modify docker-compose.yml for Distributed Testing


```
version: "3.8"

services:
  locust-master:
    image: locustio/locust
    ports:
      - "8089:8089"
    volumes:
      - .:/mnt/locust
    command: -f /mnt/locust/locustfile.py --master --expect-workers=2 --host=http://142.132.216.196:30949

  locust-worker:
    image: locustio/locust
    volumes:
      - .:/mnt/locust
    command: -f /mnt/locust/locustfile.py --worker --master-host=locust-master
    deploy:
      replicas: 2
```

3.2 Start Distributed Locust with Multiple Workers

```docker-compose up --scale locust-worker=4```

This starts 1 master + 4 workers.

Open http://localhost:8089 and start the test.

Running Locust on Multiple Laptops (Distributed Workers)


4.1 Start the Master on One Laptop

```docker run -p 8089:8089 -p 5557:5557 --name locust-master -v $PWD:/mnt/locust locustio/locust -f /mnt/locust/locustfile.py --master
```

4.2 Start Workers on Other Laptops
```docker run --name locust-worker -v $PWD:/mnt/locust locustio/locust -f /mnt/locust/locustfile.py --worker --master-host=172.31.28.147```

