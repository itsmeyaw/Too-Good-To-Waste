# Too Good To Waste

It seems trivial to throw some rotten food into the trash. 
But if 7 billions people do it for 365 days, we get a global food waste 
problem. The UN Environment Programme mentioned in 2021 that
the global food waste estimated to contribute in the production of 8-10% preventable global 
greenhouse gasses [[1]](https://www.unep.org/resources/report/unep-food-waste-index-report-2021) .
In the same report, they showed that household produces the most 
food waste compared to food services and retails. This problem calls 
for immediate solution on food waste prevention using considering this problem costs 
the global economy more than US$ 1 trillion per year [[2]](https://champions123.org/sites/default/files/2023-10/2023%20Champions%20Progress%20Report.pdf)
.

Understanding the magnitude of this problem, we
introduced Too Good To Waste as a solution that target 
the most prevalent source of food waste — households.
We aim to not only provide a one-time solution on
reducing food waste, but also educating our user into
a healthy and responsible consumption behavior.
We also hope that a better consumption behavior also 
drives a better production behavior.

Our application has the following features:
- Keep track of pantries 
- Notification of expiring items
- Share groceries with other people
- Histories of thrown, shared, and consumed food for motivation and progress tracking
- Points system for motivating user to throw less food
- Automatically scan receipt to import items to database using AI
- Automatically suggest the expiry date based on the category of item using AI


## Architecture

For the system, we use Flutter for our frontend as its offer 
seamless development for multiple mobile OSes (Android and iOS). 
This allows us to reach far more users without 
blowing the development complexities.

As for the backend, we use the Firebase as it
has excellent integration with the Flutter system.



## Deployment

### Firebase

You have to install and configure the [Firebase CLI](https://firebase.google.com/docs/cli).
After that, you just need to run the following command in
project root directory.
```shell
firebase deploy
```

### Flutter

The flutter code is included 
in the `frontend` directory. Make sure that you 
already installed the flutter and configured 
a virtual device.
Like other usual Flutter applications, you need to run the 
following command inside `frontend` directory.
```shell
flutter run
```

## Screenshots

<iframe width="315" height="560" src="https://www.youtube.com/embed/V8854hzOuY8" title="Too Good To Waste – AI Import" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## A Vision for the Future

We, the Too Good To Waste Team, believe in 
a world without food waste. We know, that it is a long 
shot ahead, but we trust in every little step that
we make today towards a better future.

As the next step, we want 
