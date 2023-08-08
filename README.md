# Greenhouse Twin Project

Repository containing other repositories related to the greenhouse digital twin project

## Table of Contents

<!-- TODO: add simulations part -->

- [Project Overview](#project-overview)
- [Tools Overview](#tools-overview)
  - [InfluxDB](#influxdb)
  - [Python influxdb-client](#python-influxdb-client)
  - [Python sensors libraries](#python-sensors-libraries)
  - [OWL](#owl)
  - [SMOL language](#smol-language)
- [Project Architecture](#project-architecture)
  - [Physical Architecture](#physical-architecture)
    - [Greenhouse](#greenhouse)
    - [Assets - Sensors](#assets---sensors)
    - [Data collectors](#data-collectors)
    - [Host computer](#host-computer)
  - [Software Components](#software-components)
    - [Sensors Scripts](#sensors-scripts)
    - [Data Collectors Python program](#data-collectors-python-program)
    - [Greenhouse asset model](#greenhouse-asset-model)
    - [SMOL Twinning program](#smol-twinning-program)
    - [SMOL scheduler](#smol-scheduler)
  - [Execution flow](#execution-flow)
- [Project setup](#project-setup)
  - [Data Controllers](#data-collectors-setup)
  - [Host Computer](#host-computer-setup)
- [How to run](#how-to-run)
  - [Demo](#run-demo)
  - [Main](#run-project)

<!-- For reports also: results, discussion, conclusion -->

## Project Overview

Digital twins have emerged as a promising technology that enables virtual replicas of physical assets, allowing for real-time monitoring, analysis, and simulation. These virtual replicas can be applied across various fields, including agriculture, manufacturing, healthcare, and more. In this research project, our focus is on building a digital twin for a greenhouse as an example to showcase the capabilities of this technology.

Our approach involves developing a digital twin for a greenhouse using a combination of Python programming, SMOL language, and Raspberry Pi.

The Python program is designed to interact with InfluxDB, a time-series database, to collect and store sensor data, while the SMOL language is used to create a representation of the assets and a knowledge graph that captures the relationships between different components of the greenhouse. The sensors, connected to various Raspberry Pi, are set up to collect data on various environmental parameters such as temperature, humidity, light, and soil moisture, providing a rich dataset for analysis.

The primary objective of this research project is to create a functional example of a digital twin that can showcase its potential in monitoring and managing a greenhouse environment. By creating a virtual replica of the greenhouse, we can simulate and analyze its behavior, and gain insights into how different components interact with each other. This digital twin can serve as a valuable tool for optimizing greenhouse operations, improving resource utilization, and enhancing overall crop yield.

In this report, we will provide a detailed overview of the methodology used to develop the digital twin, present the results of our data analysis, discuss the implications of our findings, and highlight the potential applications of digital twins in various fields beyond agriculture. This research contributes to the growing body of knowledge on digital twins and serves as a practical example of their application in a real-world setting.

## **Tools Overview**

### **InfluxDB**

[InfluxDB](https://www.influxdata.com/products/influxdb-overview/) is a time-series database that is used to store the data collected by the data collectors.

It is composed of buckets which contain measurements.
Each measurement is composed by:

- measurement name
- tags
  - Used as keys by us to identify the data
- fields
  - Used by us to store the actual data from sensors
- timestamp

and represents a single data point at a specific time.

This particular structure allows getting data for a specific time range and performing aggregations on it (e.g. mean)

<!--
TO ADD IN ANOTHER SECTION
There is a single bucket in the database that is used to store all the data collected by the data collectors.
Measurements from different assets have their own measurement name in the database.
Each measurement has a set of fields that represent the data collected by the sensors, related to that asset. -->

### **Python influxdb-client**

The [Python influxdb-client](https://influxdb-client.readthedocs.io/en/latest/) is a Python library that is used to interact with the InfluxDB database.

It is used by the data collectors to send data to the influxDB instance running on the host computer.

### **Python sensors libraries**

<!-- TODO what should we say about the required libraries for the sensors other than they are listed all in greenhouse-data-collector/requirements.txt ? -->

### **OWL**

[OWL](https://www.w3.org/TR/owl-ref/) is a knowledge representation language that is used to represent the asset model of the greenhouse. In other words is used to create a formal representation of the greenhouse physical structure.

The asset model is used to represent the assets described in [Assets - Sensors](#assets---sensors) and the relationships between them.

### **SMOL Language**

[SMOL](https://smolang.org/) (Semantic Modeling Object Language) is an object-oriented language that, among others, allows to

- Interact with influxDB to read data from the database
- Read and query a knowledge graph, mapping the data read to objects in the language
- Map the whole program state to a knowledge graph by means of the _semantic lifting_. The program state can then be queried to extract information
- Represent and run simulations (FMO) and interact with modelica <!-- TODO: add information when we get it-->

In our case, it is used to connect the asset model to the data collected by the data collectors,
perform the semantic lifting of the program state
and interact with simulations to create the digital twin of the greenhouse.

## Project Architecture

### **Physical Architecture**

#### **Greenhouse**

The specific greenhouse we are working with has the following characteristics:

- The greenhouse is divided in two shelves.
- Each shelf is composed of 1 group of plants.
- A single water pump waters each group of plants.
- 2 plants of the same type compose a group of plants.
- Each plant is put inside a pot.

#### **Assets - Sensors**

Here is a list of assets we are representing for our architecture, along with the sensors we are using to collect data on them:

- Greenhouse
  - <!-- Put sensor names for each sensor --> Light
- Shelves
  - Temperature
  - Air Humidity
- Pots
  - Soil Moisture
- Plants
  - Infrared camera: it calculates the NDVI (Normalized Difference Vegetation Index) of the plant. We will use this data to determine the health of the plant.
- Water pumps
  - Water flow

#### **Data collectors**

The data collectors are Raspberry Pi devices that collect data from the sensors and send it to the DB.
Each data collector is associated to a greenhouse shelf and is responsible for collecting data on the assets that are located on that shelf.

#### **Host computer**

The host computer runs

- An InfluxDB instance that holds data retrieved from the [Data Collectors](#data-collectors)
- A [Java program](#smol-scheduler) that periodically executes the [SMOL Twinning program](#smol-twinning-program), which is responsible for creating the digital twin of the greenhouse.

The user can interact with the digital twin though the host computer.

<!-- When we know: add also responsible for simulations (modelica) -->

### **Software Components**

#### **Sensors Scripts**

They consist in python scripts that are run on the data collectors and are responsible for collecting data from the sensors and sending them to the influxDB instance on the host computer.

All the scripts are grouped in the `greenhouse-data-collector` project in the [sensors'](greenhouse-data-collector/collector/sensors) module. We chose to apply an OO approach to the problem where each measurement (Humidity, Moisture, Temperature...) is represented with a class. When not strictly coupled, physical sensor controllers and measurements are separated from each other, making the code more modular. Each class contains a `read()` method which returns the value, when needed the class may call an `Interpreter` to convert the raw value, in that case the mapping can be configured by modifying the [config.ini](greenhouse-data-collector/collector/config.ini.example) file.

<!-- TODO talk about NDVI, there are a lot of steps to take to make the number returned by the call to numpy.mean() significant -->

#### **Data collectors Python program**

Python program that is run on the data collectors and is responsible for collecting data from the sensors and sending them to the influxDB instance on the host computer.

It achieves this by:

- A virtual representation of the various assets in the greenhouse is created (E.g., Plants in the greenhouse).
- Each virtual asset is connected to a set of physical sensors (E.g., Virtual plants are connected to the appropriate camera that retrieves plant health and growth).
- Virtual assets periodically collect data from the sensors, create a data point containing the asset identifiers and the sensors' detection and send it to the host computer.

### **Greenhouse Asset Model**

The Greenhouse Asset Model is an OWL file
representing the physical structure of the greenhouse and the relationships between the various assets in the greenhouse.

The SMOL program uses the asset model individuals as a starting point for twinning the greenhouse.

Here follows a picture of the asset model:

<!-- TODO: add picture of the asset model -->

### **SMOL Twinning program**

The SMOL program is run by the host computer and is responsible for creating the digital twin of the greenhouse.

It achieves this by:

- Reading the asset model from the OWL file
- Generating SMOL objects from the asset model individuals
- For each asset object, retrieves sensor detections for that specific asset from the influxDB database (E.g., Retrieve moisture data for a specific pot).
- After retrieving the data, the program performs the semantic lifting of the program state, creating a knowledge graph that represents the state of the assets in the greenhouse.

### **SMOL scheduler**

The SMOL program is run periodically by the host computer to retrieve the digital shadow of the greenhouse.
A simple Java program is used to schedule the execution of the SMOL program.

## **Execution Flow**

Assuming that the host computer and the data collectors are already running as specified in the [Project Setup](#project-setup) section, the execution flow is the following:

1. The data collectors periodically collect data from the sensors and send them to the influxDB database.
2. the SMOL Scheduler periodically runs The SMOL program.
3. The SMOL program retrieves the asset model from the OWL file and generates SMOL objects from the asset model individuals.
4. For each asset object, the SMOL program retrieves sensor detections for that specific asset from the influxDB database.
5. After retrieving the data, the SMOL program performs the semantic lifting of the program state, creating a knowledge graph that represents the state of the assets in the greenhouse.
6. The SMOL scheduler retrieves the digital shadow of the greenhouse from the SMOL program and sends it to the user.

## **Project Setup**

We assume that Raspberry Pi OS is installed on all three systems

## **Data Collectors Setup**

For a complete guide on how to set up the controllers,
refer to the [controller setup](setup-instructions/controller-instructions.md)

## **Actuator Setup**

For a complete guide on how to set up the actuators,
refer to the [actuator setup](setup-instructions/actuators-setup.md)

## **Host Computer Setup**

- **InfluxDB**
  - You can install influxDB on your host computer by following the [official guide](https://docs.influxdata.com/influxdb/v2.7/install/?t=Linux).
  - You can run the following command:

```bash
sudo apt-get update && sudo apt-get install influxdb2
```

- **Java**
  - Install JAVA jdk and jre using the following command:

```bash
sudo apt install openjdk-17-jdk openjdk-17-jre
```

## **How to Run**

### **Run Demo**

#### **Data collector**

TODO: add here the parts about the configuration file

To execute a demo of the interaction between data collectors and host machine, first pull the [data-collector repository](https://github.com/N-essuno/greenhouse-data-collector) from GitHub

```bash
git pull https://github.com/N-essuno/greenhouse-data-collector.git
```

Then run the following command from the root of the data-collector project:

```bash
python3 -m collector --demo
```

The demo will create a bucket named `demo` and will populate it with:

- Pot measurements with decreasing moisture, simulating a real life scenario which triggers the actuator to water the pot.
- Plant measurements

The pot measurements refer to a pot with

- shelf_floor = 1
- group_position = left
- pot_position = right
- plant_id = 1

The plant measurements refer to a plant with

- plant_id = 1
- group_position = left
- pot_position = right

<br>

#### **Actuator**

The actuator script is a python script used to physically trigger different components of the greenhouse (as the moment only the pump).

First you need to pull the [actuator repository](https://github.com/MarcoAmato/greenhouse_actuator) from GitHub
```bash
git pull https://github.com/MarcoAmato/greenhouse_actuator.git
```

**Run the script**
It takes as input the following parameters:

- `command`: the command to execute. At the moment only `water` is supported to trigger the water pump
- if `command = water`:
  - `GPIO_pin`: the GPIO pin activate for starting the pump
  - `seconds`: the number of seconds to keep the pump on

> **Note:** the mapping between GPIO_pin and actuator component is modeled in the asset model and based on this information the right component will always be activated. 

<br>

#### **SMOL scheduler**

To run a demo of the SMOL scheduler system

1. Pull the [SMOL scheduler repository](https://github.com/N-essuno/smol_scheduler) from GitHub

```bash
git pull https://github.com/N-essuno/smol_scheduler.git
```

1. Setup the configuration files in `smol_scheduler/demo/` according to your network setup
    - More information about the configuration files are available further down
2. Run the following commands from the root of the `smol_scheduler` project:

Execute:

```bash
./gradlew demo
```

> **Note:** if `./gradlew demo` fails it's possible to proceed doing the following:
> 1. Run `./gradlew build`
> 2. Copy the jar generated from `smol_scheduler/build/libs/` to your folder of choice (e.g., `smol_scheduler/demo/`)
> 3. Proceed setting up the configuration files as described further down
> 4. Run using `java -jar <jar_name>` from the folder where the jar is located

The smol_scheduler will periodically run a SMOL program, which analyzes the data collected by the data collectors and triggers the actuation system when needed.

When the moisture of a pot is below a certain threshold, the actuator will be triggered and the pot will be watered.
The threshold is fixed in the asset model.

In particular it will repeat the following steps every `n` seconds (`n` is fixed in the configuration file):

- Run the SMOL program to get the plants to be watered
- Run a SPARQL query on the SMOL program state
  - The program state is a knowledge graph representing, among other information, also the state of the greenhouse
  - It will contain some triples with the predicate `PlantToWater_plantId`. The object of each of this triple is the id of a plant to be watered.
- Retrieve, using the SPARQL query, the `PlantToWater_plantId` objects from the lifted state (which are the ids of the plants to be watered)
- If there are plants to be watered it will trigger the actuation system for each of them. The trigger is done by:
  - Connecting via SSH to the actuator controlling the pump in the greenhouse
  - Executing the command to start the pump

**Self-adaptation**

This program will also run periodically a task which:

1. Checks if the asset model has been changed
2. If it has been changed then updates the configuration files used by the data-collectors
    - E.g. information about which plant is in which pot and which sensor (pin/channel) is used to measure the pot moisture
3. Sends the updated files to the data-collectors

<br>

**SMOL scheduler needed files**

To run the SMOL Scheduler you need to provide also

- The SMOL file to be run
- The asset model (Turtle file)
- 3 configuration files for the scheduler
- 2 configuration files used by the data-collectors (one for each)
    - They will be overwritten from the SMOL schduler in case of self-adaptation

> **Note:** the data-collector configuration files are not used if running the data-collector demo version but they are needed always to run the SMOL scheduler

More information on each point further down in this document.

**SMOL program**

The SMOL program run in the demo is the `test_check_moisture.smol` file.

It will:

- Retrieve the plants from the asset model creating `Plant` objects with the following fields:
  - `plantId`
  - `idealMoisture`
- This first step is done using an `AssetModel` object
  - It contains a `getPlants()` method which runs a SPARQL query and returns a list of `Plant` objects structured as described above
- Retrieve from influxDB database the last `moisture` measurement of the pot in which the plant is placed
  - This is done calling the `getPotMoisture()` method of the `Plant` object. It runs a Flux query to get the last measurement.
- For each plants which has `moisture < idealMoisture`:
  - Create a `PlantToWater` object representing a plant to be watered. The object contains just the id of the plant.

> NOTE: the `PlantToWater` object is created in order to be represented in the knowledge graph once the semantical lifting of the program state is performed. <br>
> It will be used by the SMOL scheduler to trigger the actuation system.

<br>

**Asset model**

The asset model used in the demo is the `greenhouse.ttl` file. <br>
As the moment it contains more information than needed. The relevant and used information for the demo is the following:

Classes:

- `Plant`
  - `plantId`: the id of the plant
  - `idealMoisture`: the ideal moisture of the plant
  - Subclasses
    - `Basilicum`
- `Pot`
  - `shelfFloor`: the shelf floor in which the pot is placed (1 or 2)
  - `groupPosition`: the group on the shelf in which the pot is placed (left or right)
  - `potPosition`: the pot position with respect to the group in which the pot is placed (left or right)
  - `plantId`: the id of the plant placed in the pot
  - `moistureAdcChannel`: the ADC channel used by the sensor to measure the moisture of the pot
  - `pump`: the pump used to water the pot
- `Pump`
  - `pumpGpioPin`: the GPIO pin used to activate the pump

Individuals:

- `basilicum1`
  - `plantId = 1`
  - `idealMoisture = 50`
- `pot1`
  - `shelfFloor = 1`
  - `groupPosition = left`
  - `potPosition = left`
  - `plantId = 1`
- `pump1`
  - `pumpGpioPin = 18`

<br>

**Configuration files**

The configuration files need to stay in the same folder as the SMOL Scheduler JAR file.

The templates are available in the `smol_scheduler/src/main/resources` folder

- `config_local.yml`: used by the SMOL program to access to influxDB
  - NOTE: it is used by the SMOL program and as now it's hardcoded in the SMOL program. You could need to change it.
- `config_scheduler.yml`: used by the SMOL scheduler to get the following information:
  - Path of the SMOL program
  - Path of the asset model
  - Path of the lifted state output directory (no more used)
  - Name of the lifted state output file (no more used)
  - Path of the asset model file (.ttl file)
  - Domain prefix URI
  - Seconds between every execution of the SMOL program
  - Local path of data-collectors config files (used by the self-adaptation task)
  - Remote path of data-collectors config files (used by the self-adaptation task)
- `config_ssh.yml`: used by the SMOL scheduler to get the following information:
    - IP address (host), username and password for
      - Actuator
      - Each data-collector
- `config_shelf_1`: used by the data-collector on the first shelf to map sensor-data with assets and upload it in influxDB. It is structured as following (sample):
  - `[influx2]`
    - `url`: URL of the influxDB database
    - `org`: organization name
    - `token`: token to access the database
  - `[sensor_switches]`
    - `use_infrared_sensor`: boolean value to enable/disable the infrared sensor (in case not present)
    - `use_light_sensor`: boolean value to enable/disable the light sensor (in case not present)
  - `[moisture_values]`
    - `XP`: array that can contain up to 100 values for the mapping between voltage registered by the sensor and moisture percentage
  - `[light_level_values]`
    - `XP`: array that can contain up to 100 values for the mapping to light level percentage (add more information)
  - `[shelves]`
    - `shelf_1`: JSON dictionary containing the mapping between a shelf and the GPIO pins corresponding to humidity and temperature sensors for that shelf
      - Note: if a data collector controls more than one shelf, there will be a dictionary for each shelf
  - `[pots]`
    - `pot_1`: JSON dictionary containing the mapping between a pot (position), the ADC channel corresponding to the moisture sensor for that pot and the plant in that pot
      - Note: if a data collector controls more than one pot, there will be a dictionary for each pot
  - `[plants]`
    - `plant_1`: JSON dictionary containing the plant id of a plant on the shelf of the data collector
      - Note: if a data collector controls more than one plant, there will be a dictionary for each plant
- `config_shelf_2`: same as before but for data collector in second shelf. It is needed because we assume there will be 2 shelves in the greenhouse, each one with its own data collector.

<br>

---

### **Run Project**

#### **Run Data Collectors**

For the reference on how to set up and run the data collectors refer to the [greenhouse-data-collector repository](https://github.com/N-essuno/greenhouse-data-collector)

#### **Run Host Computer**

##### **InfluxDB**

If you are running a linux distribution, there is no need to start influxDB manually;
it will start automatically after the installation.

##### **SMOL Scheduler**

The entry point of the project is the [SMOL scheduler](#smol-scheduler), which is responsible for running the SMOL program and sending the digital shadow to the user (eventually through an interface).
Use the following commands to build and run the SMOL scheduler:

  ```bash
  cd ./smol_runner
  ./gradlew build
  java -jar ./build/libs/smol_scheduler.jar
  ```

<!-- TODO add info on how to run the SMOL scheduler, implement JAR creation and instructions on how to run JAR, add info about JRE installation on host computer-->
