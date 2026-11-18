# MySql Atlas for Android

**Developer: Ifshita · Version 1.2.0**

I built MySql Atlas to bring SQL practice, error explanations and database shortcuts into one Android app. A beginner can write a query against a practice table, inspect the result, and save the query as a snippet to revisit later.

[Download the Android APK](https://github.com/ifshita12/ifshita12/raw/refs/heads/main/MySql-Atlas-1.2.0.apk)

## Inside the app

| Feature | What you can do |
| --- | --- |
| Offline SQL workspace | Create tables, insert rows, run queries and inspect results using the bundled SQLite engine. Import and export data, review query history and save snippets. |
| Four database interfaces | Switch between MySQL, PostgreSQL, Oracle and SQL Server layouts. The local practice engine is SQLite across all four layouts. |
| Error explorer | Search 44,387 bundled reference entries across the four database systems, compare related errors and consult suggested corrections. |
| Guided practice | Explore 55 command entries, work through 16 challenges and practice with quizzes and puzzles. |
| Shortcut reference | Browse 390 client-specific shortcut entries. |
| SQL tutor | Use the offline tutor, or configure the optional Gemini-powered tutor for online questions. |

## Runtime check

A test against the SQL engine bundled in this APK created a campaign table, inserted three rows and grouped leads by channel. The query returned seven leads for search and two for social. This check covered the local engine. Android UI behavior and live Gemini responses were not tested in this review.
