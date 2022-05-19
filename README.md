
Track your poses across time with a dictionary using an iOS App on Xcode
# RecordPose
An app that gathers data on a person's pose(Sit/Stand) each minute along their Gender and Age

The dataset is collated and trained by myself on Python Jupyter Notebook with TuriCreate

The MLModel must be Neural Network Classifier, which the CreateML framework cannot create

Or else the app will crash

--------------------------------------------------------------------------------------
```
#To use TuriCreate

you need to type these codes into your terminal (I am using Mac)
pip install virtualenv

#Create a Python virtual environment

cd ~

virtualenv venv

virtualenv venv -p python37

#Activate your virtual environment

source ~/venv/bin/activate

pip install -U turicreate

pip install --upgrade pip

pip install jupyter notebook

pip install -U turicreate

pip3 install jupyter notebook

pip3 install -U turicreate

jupyter notebook
```
--------------------------------------------------------------------------------------
The codes above will set up the notebook that enable you to use TuriCreate

Remember to use /venv in the notebook

You will need two ipynb files (will be uploaded)

1. turi.python.ipynb (Load dataset)

2. turi_train.python.ipynb (Train dataset)
--------------------------------------------------------------------------------------
# How the Gender and Age detection works
The programme places a rectangle/square over a person's face according to their nose coordinates

Returns this image to the ML Model

ML Model classifies the gender and age for each person
![IMG_0002 2](https://user-images.githubusercontent.com/100278023/167801735-d47a71b4-919e-4a7c-a68a-6655b077b542.PNG)

Reason for not using face detection function which is available on Xcode:

Due to the wearing of masks, face detection will not work

However, the respective body parts (such as nose, eyes, ears) will always be detected regardless of wearing masks

Hence it is more reliable to use the coordinate method and also to be able to track and match each person to their coordinates and information


--------------------------------------------------------------------------------------
Data collection will be recorded in a dictionary as key:data as seen in the image
[date + time][Number of people x : [coordinates pose gender age]]
1 person data: ![Screenshot 2022-05-11 at 2 35 07 PM](https://user-images.githubusercontent.com/100278023/167784981-4c463605-7f5b-4529-b9d5-9058fb3a898b.png)
Multiple person data: ![Screenshot 2022-05-11 at 4 12 17 PM](https://user-images.githubusercontent.com/100278023/167801493-28997daf-ddc2-4c20-87d7-9a6e2e0e6cd6.png)

The data is recorded for every second.
It works for multiple people.
Click the button on screen to print the dictionary onto console.
To upload onto a cloud, you would need to encode the dictionary into a json file first.
(I may be uploading another version that creates and uploads the json data to AWS bucket along with the steps)

--------------------------------------------------------------------------------------
# code for converting dictionary into encoded dictionary (json data) then uploading into a json file
(not included in this project file)
 ```
    do {
           let encodedDictionary = try? JSONEncoder().encode(thedict)

            print(encodedDictionary as Any)
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let pathWithFileName = documentDirectory.appendingPathComponent("myJsonData.json")
                do {
                    try? encodedDictionary!.write(to: pathWithFileName)
                    print("printed to file")
 }
```
--------------------------------------------------------------------------------------

Possible uses for this app is if you wish to track people (see how many people are accessing a certain space)

and what they are doing in an area(sit or stand)

and to know their demographics (gender and age)


--------------------------------------------------------------------------------------
