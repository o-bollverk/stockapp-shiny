import json

data_dir = "/home/revilo/shinyapp-data/"
list_of_files = ["Bitcoin_new.json", "Apple_new.json"]
list_of_files = [data_dir + x for x in list_of_files]

def clean_json(filename="bitcointweet.json"):
    data_dict = {"sentiment":[], "datetime":[]}
    with open(filename, 'r+') as f:
        news = json.load(f)
        for news_item in news:
            data_dict["sentiment"] = data_dict["sentiment"] + [news_item["sentiment"]]
            data_dict["datetime"] = data_dict["datetime"] + [news_item["datetime"]]

            print("------------------------------------")

    print(data_dict)
    return data_dict

def save_dict_to_json(filename, input_list):
    with open(filename, 'w') as file:
        json.dump(input_list, file)

for filename in list_of_files:
    print(filename)
    clean_json(filename)
    save_dict_to_json(filename[:-5] + "cleaned.json")


