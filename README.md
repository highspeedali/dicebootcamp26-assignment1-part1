# Part 1 Docker file Creation, GitHub and Docker Hub Integration
## Step 1 Identify a Sample Application
&nbsp;
This code defines a simple FastAPI application with a single root endpoint that returns a JSON greeting message. 
&nbsp;
We are going to dockerize it so it can run consistently in a containerized environment, making deployment and scaling easier.
```
import uvicorn
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
def read_root():
    return {"Hello from assignment1-part1!"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
```
&nbsp;
## Step 2 Identify the Dependencies
