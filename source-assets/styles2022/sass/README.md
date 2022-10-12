# The SUSE SASS stylesheets

SASS (or SCSS) is "is a preprocessor scripting language that is interpreted or compiled
into Cascading Style Sheets." (according to https://sass-lang.com).


## Requirements

There are many SASS preprocessors, but we use the package `sassc`. It comes with a
tool `sassc` (same name).

Keep in mind, different SASS preprocessors can support different levels of the syntax.


## Directory layout

This subdirectory contains a couple of files and directories:

```
.
├── bulma-<VERSION>/
├── custom/
├── README.md
└── style.sass
```

* `bulma-<VERSION>/`

  This folder contains the Bulma framework from https://bulma.io.

* `custom/`

  This folder contains our customizations to Bulma to make the CSS stylesheet
  look like SUSE layout.

* `style.sass`

  The driver file to include all Bulma and custom files.


## Compiling SASS to CSS

Before you can use the result CSS, execute the following steps to compile SASS into CSS:

1. Modify the custom SASS files to your needs.
2. Compile the SASS files to CSS with a SASS preprocessor using the following command
   from this directory:

       sassc --precicion 5 --sass style.sass ../../../suse2022-ns/static/css/style.css

3. Manually copy the CSS file from the previous step into your target directory.


