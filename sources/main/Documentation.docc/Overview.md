# Overview

Overview documentation for the project.  

## Start

![Start](start.png)

MainCoordinator is a coordinator of coordinators. 

- It starts the login screen if accesss token is missing.
- It starts the home screen otherwise. 

## Home

![Home](home.png)

Home feature
- HomeViewController: displays posts and offers logout.
- HomeDomain: requests posts and logs out.
- HomeRepository: request and persist posts.

![TableViewController](tableViewController.png)

## API

![TumblrAPI](TumblrAPI.png)

All responses are wrapped in a TumblrResponse object.

![TumblrResponse](TumblrResponse.png)

The response object is a Codable object on success or an empty array on error. For instance, an authorization error is:
```json
{
    "meta": {
        "status": 401,
        "msg": "Unauthorized"
    },
    "response": [

    ],
    "errors": [
        {
            "title": "Unauthorized",
            "code": 1017,
            "detail": "Unable to authorize"
        }
    ]
}
```
