# 🧪 Simple Request

Simple Request is a demo Elixir project that allows the user to increment a value identified by a given key and an increment value.

- [🧪 Simple Request](#-simple-request)
  - [Prerequisites](#prerequisites)
  - [Start Here](#start-here)
  - [Available Endpoints](#available-endpoints)
  - [Sample](#sample)
  - [Brief](#brief)
  - [Metrics](#metrics)
    - [Application Dashboard](#application-dashboard)
    - [Beam Dashboard](#beam-dashboard)
    - [Ecto Dashboard](#ecto-dashboard)
    - [Phoenix Dashboard](#phoenix-dashboard)
    - [Postgres Dashboard](#postgres-dashboard)
  - [Conclusion](#conclusion)
  - [Future Improvements](#future-improvements)

## Prerequisites

- Postgres server (on port `5432`)
- Elixir v1.12.*
- Docker v20.10.*
- Docker compose v1.28.*

> Make sure the `docker` folder on the root of this repo and all it's subfolders have read/write permissions for any user on your system

## Start Here

Make sure you have ports `3000` (the main application), `3333` (Grafana), `9090` (Prometheus) and `9187` (Postgres Exporter) available on your system.

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Start docker-compose `docker-compose up`
- Start Phoenix endpoint with `mix phx.server`

## Available Endpoints

|Endpoint | Description |  Method  | Payload|
|----------|-------------|:--------:|:------:|
|http://localhost:3333/increment | The main endpoint to increment the passed `key` by passed  `value`.<br/>The first time a given `key` is incremented, a base value of `0` is assigned, and then incremented with the passed increment `value`.  | POST | {"key": "KEY", "value": "VALUE"} |
|[http://localhost:3000](http://localhost:3000) | To access the Grafana portal.  | GET | -|

## Sample

Request:

>`curl  localhost:3333/increment -H "Content-Type: application/json" -X POST -d '{"key": "test1", "value": 2}'`

Response:

>`{"data":{"key":"test1","value":2}}`

## Brief

Early on, creating modular and testable code was a primary concern; breaking down business logic into pure functions wherever possible.

A Phoenix context named *values* was created to hold all the business and data related logic. To address the main requirement of buffering the incremented keys and their respective values in memory, and then syncing the buffered data to the database at fixed time intervals, a GenServer was used.

The created GenServer (Updater.Server) has a recurring "tick" message being called every ten seconds. Another module was created to hold the core business logic (Updater.Core) represented in functions that either transform the data, or invoke the persistence logic.
A Supervisor (Updater.Supervisor) was created to add another layer of separation for the Updater.Server from the application's main supervisor.

When the */increment* endpoint is hit via a POST request, the router would pass the request to the controller's increment action, which in turn calls the interface delegated increment function exposed on the values context module. The increment callback within Updater.Server is eventually triggered via a *call* request, which returns the passed key with its stored value (defaulting to 0) incremented by the passed increment value.

The Updater.Server would invoke the persistence logic for every tick. The persistence logic defined within Update.Core would load the stored entities for the passed in values (buffered in the Update.Server state), perform some preparation and splitting for the state values; splitting the values into two lists: values to update and vales to insert.
The values context functions are used to update and insert the entries if needed (more on that later).

## Metrics

PromEx was used in concert with Prometheus and Grafana to collect and present different metrics from:

- Application
- Beam
- Ecto
- Phoenix

Also, a special exporter was used to export Postgres metrics to Prometheus, and then presented through a Grafana dashboard.

To start the required services for metrics collection and presentation, a docker compose config is provided.

Running `docker-compose up` will start all needed services. Upon running the Elixir application for the first time, some dashboards are added to the Graphana service.

Within Graphana, a number of dashboards are available to inspect the different metrics collected by Prometheus.

The Graphana portal is accessible through [http://locahost:3000](http://locahost:3000).

> Default username and password are set to `admin`

### Application Dashboard

![application dashboard](/readme/application_dashboard.jpg)

### Beam Dashboard

![beam dashboard](/readme/beam_dashboard.jpg)

![beam dashboard2](/readme/beam_dashboard2.jpg)

### Ecto Dashboard

![ecto dashboard](/readme/ecto_dashboard.jpg)

### Phoenix Dashboard

![phoenix dashboard](/readme/phoenix_dashboard.jpg)

![phoenix dashboard2](/readme/phoenix_dashboard2.jpg)

### Postgres Dashboard

![postgres dashboard](/readme/postgres_dashboard.jpg)

## Conclusion

Overall, the development process went smoothly, especially after adding the tests after the first iteration; it exposed some of the logical missteps and helped defining reasonable boundaries for each module.

Choosing the name `values` for the context with the property `value` for the persisted value was something that I wish I had considered earlier as it made it tricker to name some variables down the line -after all, naming things is the hardest problem in programing :).

There were some arguments placed to help with testing, like in the case of Updater.Server where the `name` argument was used to be able to start another GenServer to avoid conflict with the already started server.</br>
Moreover, a helper argument was passed to control the persistence method to be able to manually invoke the persistence, and avoid depending on the interval duration to pass.

Initially, I was going to update the Updater.Server state internally on each increment request, but that meant keeping the values in state for the lifetime of the server, and that could grow with time significantly. So, I preferred to query the database on each increment request to get the stored value of the passed key. It was a compromise that I'm happy with.

The persistence part was a bit tricky, as I tried to initially upsert the values stored in the Updater.Server state in bulk, but I resorted to processing the values to be stored and then persisting the values one by one. That choice might not be the best in terms of the number of queries fired, however, the complexity of shaping the data and handling conflicts proved to be a bit complex for this use case; given the fact that the persistence interval is relatively short and not many values would be buffered for persistence.

I considered creating a struct to house the Updater.Server state, but for the sake of this simple demo it wasn't really necessary.

## Future Improvements

There are multiple places were improvements could be applied.</br>
Persistence (like mentioned previously) where the query could be compressed into a single query or a couple of queries, rather than one for each key-value pair.

Testing was engineered around the idea of creating black boxes, for instance, for the core functionality, so one could reasonably test the Updater.Server callbacks with the assumption that it's tested elsewhere. Some places could have more test coverage, and other places could use a mocked module to stub a function call rather than depending on `Process.sleep` which is good to avoid generally to have more reliable tests.

The Update.Server leverages a call callback to handle the increment request, which inherently introduces some sort of a back-pressure mechanism. There could be room to adding a worker pool with some sort of load balancing which would increase the capacity of accepting more requests (Poolboy could be used for that purpose).

Rate limiting could be added by funneling the increment requests first through a GenServer that would keep in state a record of the requests performed for a given period from a specific IP address. If the IP from which the request is originating haven't passed a given threshold, the request is allowed and the state is updated with the number of requests served for this IP, otherwise, the request will be rejected. A time interval would be used to reset the state of the server effectively allowing any new request. This method is not accurate when it comes to counting the threshold, since the interval is fixed and it doesn't account for the time the request was actually receive, however, functionally it would be efficient enough if ballpark limits are acceptable.

Finally, this implementation would do it's purpose in a production setup given that the traffic would be reasonable. If heavy traffic is to be expected, some of the aforementioned suggestions might be implemented to improve the performance if needed as this process should be typically driven by benchmarks/metrics.
