Description [This is a WIP]
---------------------------


This command line utility allow you to optimize images using the MiniMagic gem. The script read a json file with an specific format
(described) bellow, download the images and optimize them based on the values of the flags you use.

**NOTE:**

The structure of the file wasn't a personal decision, it was just to avoid extra work while doing a optimization process inside
the company I work on.


Getting starting
----------------

* Make sure the `optimized_images` and `original_images` exists.

You can use the script with and without a JSON config file.

Using a JSON config file
========================


* Create a json file with the following structure:

```js

  [
    {
      "mainImage": {
      "original": <image-path>,
      "hero": <image-path>,
      "box": <image-path>,
      "card": <image-path>
      }
    },
    {
      "mainImage": {
      "original": <image-path>,
      "hero": <image-path>,
      "box": <image-path>,
      "card": <image-path>
      }
    }
  ]

```

The `original`, `box`, `hero` and `card` keys inside the `mainImage` key can be the keys you want, you only have to ensure
that you pass the right option to the command line utility.

* After creating the json file you just have to run the command line utility with the right options:

`ruby optimaze_images.rb --resources-info <path-to-json-file-with-image-locations> --kind-of-image  <original|hero|box|card>`


Hints
------


* `--kind-of-image` value could be any value you put inside the `mainImage` key.
* You have to run the script inside the folder of the project.

Without config JSON file
========================

You can run the script without a config json file. What the script is going to do is optimize the images inside the `original_images`
folder and output the new images in the `optimize_images` folder. Only options related with image optimization are going to be used.

Ex. `ruby optimaze_images.rb -q 80`


Available command flags
------------------------

These are available flags for the command:

**flag**          | **shortcut** | **description**
----------------- |-----------   | --------------------
--resource-info   | -ri          | path to the json path to read images locations
--kind-of-image   | -ki          | key inside the `mainImage` key (json file)
--skip-download   | -sd          | If you already download the images described inside the json file, skip download to save time
--width           | -w           | width to resize image
--height          | -h           | height to resize image
--quality         | -q           | quality to resize image
--extension       | -e           | extension of the resized image
