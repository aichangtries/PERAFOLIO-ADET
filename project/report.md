Weekly Increment Report
Week of: September 21, 2026

What changed this week

Started moving PeraFolio from the planning/high-fidelity mockup stage into the final Flutter project.
Defined the final MVP around simulated account connection, Dashboard, Activity, Accounts, Transfer, Pay, and supporting profile/settings screens.
Kept real bank integrations and real-money transactions outside the final scope.
Carried the reusable visual system from my revised design into the implementation plan.
Kept Hive CE as the planned local structured storage for the simulated app data.
Started the README and AI usage record so I can update them while I build instead of reconstructing everything at the end.


Why
My goal is to turn the revised PeraFolio design into a working Flutter project without expanding the scope again. I want to build the core flow first before spending too much time polishing individual screens. Keeping the financial interactions simulated also lets me focus on the Flutter skills being graded, including widgets, navigation, state, input, lists, validation, and local persistence.

What broke or what I got stuck on
Layout is still the part that tends to slow me down, especially spacing, placement, and avoiding overflow while translating my mockup into Flutter. I also still need more practice deciding when fixed spacing is enough and when Expanded or Flexible should control the available space.

Persistence is another gap. I chose Hive CE in M7A1, but I still need to test whether I can save structured PeraFolio data and restore it after restarting the app.


What is left
Finish the main screens and reusable components.
Connect the complete navigation flow.
Impleent form validation and state changes.
Implement/test Hive CE persistence.
Finish Transfer and Pay flows.
Test empty states and insufficient-balance validation.
Check Flutter Web for layout/overflow problems.
Keep README screenshots and usage instructions synchronized with the build.
Complete the week 2 security checklist before publication.
Finish testing and presentation materials in week 3.