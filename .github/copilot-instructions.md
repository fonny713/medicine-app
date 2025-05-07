<!-- Use this file to provide workspace-specific custom instructions to Copilot. -->

# MedScan AI Project Instructions

This is a Flutter mobile application that uses Firebase and OpenAI integration. The project includes:
- Firebase Authentication
- Cloud Firestore for data storage
- Barcode scanning functionality
- OpenAI GPT integration for medicine analysis
- Medicine interaction detection

## Key Features
- Barcode scanner for medicine identification
- Ingredient analysis (naturalness, function, warnings)
- AI-based detection of medicine combinations to avoid
- User medicine list with reminders and notes
- Medication timeline and interaction warnings
- Personalized profile with saved medicines

## Database Structure
- Collection: users (uid, email, username, avatarUrl, medList, createdAt)
- Collection: medicines (id, name, brand, ingredients, naturalness, summary, sideEffects, dosageInfo, interactions, imageUrl, createdAt)
- Collection: interactions (id, med1Id, med2Id, conflictType, description, severity, source)

Please follow the project structure and naming conventions when suggesting code.
