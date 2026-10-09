Reflection Journal
Week of: September 27, 2026

My goal this week
My goal this week was to move PeraFolio further from the planning and design stage into an actual working Flutter implementation. I wanted to focus less on changing the design and more on making the screens, navigation, reusable components, validation, and simulated interactions work together. I also wanted to start testing the project in Flutter Web so I could catch layout and overflow problems earlier instead of waiting until the final testing stage.

What I did
I continued using the revised PeraFolio proposal, mockup, and design system as the foundation for the implementation. I worked around the main application flow of Dashboard, Activity, Accounts, Transfer, and Pay, while keeping the onboarding and Profile/Settings screens as supporting parts of the application. I worked on the simulated Transfer and Pay flows, including input handling and validation. I also started thinking about how account balances and transaction data should change when a simulated transaction is completed.

Another important part of this week was trying to run the Flutter project locally. While troubleshooting the project, I discovered that the current repository structure does not yet have a pubspec.yaml in the expected Flutter project directory. This prevented commands such as flutter pub get and flutter run -d chrome from working. Instead of creating another project immediately, I checked the existing folders to avoid accidentally overwriting or separating the work I already have.

What blocked me
The biggest blocker this week was the local Flutter project structure. I initially expected the flutter directory to be the Flutter project root, but Flutter could not find a pubspec.yaml file there. After checking the repository, I found that the project currently contains a mixture of Flutter-related files and an existing web project structure.

This means I need to properly organize or locate the actual Flutter project before I can fully test the application using Flutter commands.

What I learned
This week taught me that getting the project structure right is just as important as writing the UI code. I was focused on getting the screens implemented, but when I tried to run the project, the missing pubspec.yaml showed that I needed to verify the actual Flutter project root first.

I also learned that implementation exposes problems that are easy to miss during design. A mockup can show exactly where an element should appear, but Flutter requires me to consider how that element behaves when the available space changes, when text is longer, or when different UI states appear.