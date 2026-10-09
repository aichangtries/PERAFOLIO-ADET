Reflection Journal
Week of: October 4, 2026

My goal this week
My goal this week was to move PeraFolio past being a fully local prototype. I wanted two things: make each bank and e-wallet easy to recognize at a glance, and connect the app to a real Supabase database so accounts, balances and activity are saved per user instead of only on one browser.

What I did
I gave each provider its own brand color: GCash (#007DFE), GoTyme (#00F1FB), MariBank (#ED5F00), Maya (#22F99F) and BPI (#940005). I kept all five in one place in the theme so every badge (account cards, account pickers, activity rows and the review screens) uses the same color for the same bank. I also replaced BDO with GoTyme in the demo data so the accounts match the banks I chose.

For Supabase, I separated the app's data layer from Hive. AppState now talks to one shared interface, and there are two versions behind it: a Supabase version for the real app and the existing Hive version for offline use and tests. Sign-up, log-in and password reset now use Supabase Auth with real passwords instead of the simulated log-in. I wrote a schema file that creates the tables, turns on Row Level Security for every table, and adds a trigger that creates a profile when someone signs up. Each new account still starts with fictional demo balances. The Supabase keys are passed in when the app runs and are kept in a gitignored file, so no key is committed.

I used AI to help plan the data layer, write the schema and update the README, documentation and security checklist. I recorded this in my AI usage notes, and I went through the code to make sure I could explain how sign-in, saving and the security policies work.

What blocked me
The main difficulty was that Supabase works differently from Hive. Hive saved and read data instantly, while Supabase needs network requests, so every load and save had to become asynchronous. Times were another problem: the database returns them in UTC, so I had to convert them back to local time or the activity times would be off by eight hours.

I also had to change the tests because data now loads only after signing in. Once I updated them, all the tests passed and the project analyzed with no issues. The pubspec.yaml problem from last week is also behind me, since the project now runs and builds properly.

What I learned
I learned that a real database adds security work that a local prototype never needed. With Hive, everything stayed on one device. With Supabase, I have to make sure one user can never read another user's data, which is why Row Level Security matters. I also learned that the publishable key is meant to be public, and the real protection comes from the database policies, not from hiding the key.

Next week
I still need to connect the app to my actual Supabase project and test it live. That includes checking that a signed-out user cannot read any data and that a second account cannot see the first account's data, which is still marked "To verify" in my security checklist. I also want to handle network errors outside the log-in screen and look into saving transfers in one step, so a dropped connection cannot leave two balances out of sync.
