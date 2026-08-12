# Playercount forecasting using Steam games

This is a short personal project intended to give a playground in which to apply some of the things I've learnt in the realms of data science, machine learning and eventually deep learning. 

The objective is to take a database of historical playercounts for video games and build a model that is able to predict the playercount at some predefined time into the future.

I have made liberal useage of Claude Code in this project to help speed up the generation of code as well as to clean up and streamline my notebooks and produce a nice looking Quarto report which can be found [here](https://su-jai.github.io/player_forecasting/). The contents of the report however are written solely by myself.


# Objectives completed

* Construct a data processing pipeline to obtain input features from, ensuring data-leakage protection.
* Train and test a few baseline models to give a measuring stick against which to evaluate more sophisticated models.
* Analyse training examples with large errors to identify weakness points in the models/features.


# To do

* Build some basic neural networks using PyTorch and compare performance against traditional ML algorithms.
* Structure a working program that can be run in the terminal, from the contents of the ipynb notebooks.