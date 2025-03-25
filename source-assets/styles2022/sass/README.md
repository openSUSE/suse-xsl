# The SUSE SASS stylesheets

SASS (or SCSS) is "is a preprocessor scripting language that is interpreted or compiled
into Cascading Style Sheets." (according to https://sass-lang.com).

To have a consistent look and feel, the SUSE stylesheet uses the Bulma CSS framework.
It is available as SASS files and can be customized.

## Requirements

There are many SASS preprocessors, but we use the package `sassc`. It comes with a
tool `sassc` (same name). Install it with `sudo zypper install sassc`.

Keep in mind, using different SASS preprocessors can be an issue:

* They support different levels of the syntax.
* They create a different set of changes and lead to a bigger diff when switching
  from `sassc` to another one.


## Directory layout

This subdirectory contains a couple of files and directories:

```
.
├── bulma-<VERSION>/
├── custom/
├── README.md
├── color.sass
├── style-new.sass
└── style.sass
```

* `bulma-<VERSION>/`

  This folder contains the Bulma framework from https://bulma.io.

* `custom/`

  This folder contains our customizations to Bulma to make the CSS stylesheet
  look like SUSE layout.

* `color.sass`

  The SUSE color palette defined as SASS variables. Included in the driver files.

* `style.sass` and `style-new.sass`

  The driver files to include all Bulma and custom files.


## Compiling SASS to CSS

Before you can use the result CSS, execute the following steps to compile SASS into CSS:

1. Ensure you have installed the `sassc` compiler (see Requirement section).
1. Modify the custom SASS files to your needs or switch to an existing branch.
1. Compile the SASS files to CSS with a SASS preprocessor using the following commands
   from this directory:

       sassc --precision 5 --sass style.sass ../../../suse2022-ns/static/css/style.css
       sassc --precision 5 --sass style-new.sass ../../../suse2022-ns/static/css/style-new.css

1. Build your documentation. As the documentation doesn't change, you can use a shortcut
   and just copy the `style.css` and `style-new.css` files into your `build/` directory.
1. Reload your browser.
1. If you want to create a new stylesheet release, follow the README in the root directory.

