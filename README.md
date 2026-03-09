# golem_shiny

This is just a test app and it might still have a few bugs. Entire project is available on Github [here](https://github.com/vikram-rawat/r_golem_app).

## To run the app

For a developer these functions will come in handy:

```r
devtools::document()
devtools::load_all()
golem_shiny::run_app()
```

## Functionality

1. The app loads the data from duckDB
2. It validates the data and shows any errors in the notification system.
3. The data is displayed in a handsontable.js table.
4. The user can edit the data in the table and save it to the database.
5. The user can also reset the data to the original data from the database.
6. The app also shows a summary of the data which is calculated from the current dataset. Which dynamically updates as the data is edited.
7. Created a Module to display the table
8. All DataManagement and State management is done Via R6 classes.
9. Table has dark and light theme with sorting and filtering capabilities.

## Extra Accomplishments

1. **renv Added:** I added `renv` to the project to manage the dependencies of the project. This will help in keeping the project isolated and reproducible.

2. **duckDB Manager:** I added an R6 class as an interface to duckDB so that migration to a different database becomes easy.
   you can find the class in `R/duckdb_manager.R`. It has methods to connect to the database, execute queries, and disconnect from the database.

3. **data store:** I added an R6 class as a Store for the table because of which we can validate the data,
   reset the data back to original or save the data in the database. This class also calculates the summary
   of the data. You can find the class in `R/data_store.R`.

4. **data validation:** I added a data validation method in the Store class which checks for duplicate entries and missing values in the data.
   It returns a list of errors if any are found.

5. **Notifications:** I added a notification system to the app which shows a notification
   everytime you save data to backend or reset data or even if the data validation fails or something breaks.

6. **Edge Cases:** I handled some edge cases like if you accidently change to a NULL value or cut the Row etc...

7. **\_brand.yml:** It was an overkill for this app but I added a brand.yml file so that we can change the themes of the app anytime.

8. **Theme Setter handsontable.js:** I added some extra css files to change the theme of the handsontable.js table. You can find the css files in `inst/app/www/css/`.
   I also added a DropDown in the app to switch the theme of handsontable.

9. **Dark Theme:** I added a dark theme to the app which can be switched from the dropdown in the app. This is default for the app.

10. **Custom CSS:** I added some custom CSS to the app to make it look better. You can find the CSS file in `inst/app/www/main.css`.

With this I achieved the Goal of creating a Shiny app with a handsontable.js table that can be edited and saved to a duckDB database. The app also has a notification system and a theme switcher.

Thanks for this wonderful experience.
