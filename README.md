# Acceptance Tests

[back to assignment specification](https://shiny-adventure-eg1molz.pages.github.io/)

I will put here the cucumber features, step definitions, and support files, along with a Gemfile.

0. Put `Gemfile` and `features/` in the root of your project, e.g.:

```
features/
|- step_definitions/
|  |- create_steps.rb
|  |- delete_steps.rb
|  |- ...
|- support/
|  |- helpers.rb
|  |- hooks.rb
|- create.feature
|- delete.feature
|- ...
src/
|- main/
|  |- java/
|  |  |- app/
|  |  |  |- App.java
|  |  |  |- Person.java
|  |  |  |- ...
|- test/
|  |- java/
|  |  |- app/
|  |  |  |- AppTest.java
|  |  |  |- PersonTest.java
|  |  |  |- ...
app
db-reset
Gemfile
pom.xml
test
```


1. [Install ruby](https://www.ruby-lang.org/en/downloads/).  I recommend using [rbenv](https://github.com/rbenv/rbenv), in particular I recommend [rbenv-installer](https://github.com/rbenv/rbenv-installer#rbenv-installer).
   * after installing `rbenv`, you still need to install ruby: `rbenv install 3.3.4` (or whatever version you want)
   * if you are on Windows, I recommend you use [WSL](https://learn.microsoft.com/en-us/windows/wsl/install)

3. Install bundler: `gem install bundler`

4. Install the gems: `bundle install`

5. Run cucumber:
   * all features: `bundle exec cucumber`
   * a single feature: `bundle exec cucumber features/X.feature`, where *X* is the name of the feature file.
   * a single scenario: `bundle exec cucumber features/X.feature:Y`, where *Y* is the line at which the Scenario is defined.
     + *Cucumber will print these commands for each failed scenario, so you can just copy+paste them in the terminal.*

~~Slowly but surely~~ Methodically and inexorably turn the red failing steps into green passing steps.

Do not edit the `Gemfile` or the features or the step definitions or the support files.  You will not submit those files, and if you do, they will be deleted or overwritten.  The features, steps, helpers, and hooks are open for inspection but **closed for modification**.

Notes:
* If you write your code in Ruby, then you need to tell me which gems, if any (probably none...), that you need so I can add them to the Gemfile that the autograder will use.

* The 192 scenarios and their step definitions and support took only a few hours over a couple of days for me to write.  Remember this because you will be expected to write cucumber scenarios for the project and I expect your project to have **many** more scenarios than this little assignment has.
