# Rescue Rover Application

A production-ready Android application and backend for the Rescue Rover system.

## Project Structure

- `/backend`: FastAPI Python backend server.
- `/frontend`: Flutter mobile application.
- `/database`: MySQL initialization scripts.

## Backend Setup

1. Make sure Python 3.9+ is installed.
2. Navigate to `/backend`.
3. Create a virtual environment: `python3 -m venv venv`
4. Activate the virtual environment: `source venv/bin/activate`
5. Install dependencies: `pip install -r requirements.txt`
6. Run the server: `uvicorn main:app --reload` (The API will run at http://localhost:8000).

Note: The backend defaults to a local SQLite database for easy testing (`rescuerover.db`). To use MySQL, set the `SQLALCHEMY_DATABASE_URL` environment variable:
`export SQLALCHEMY_DATABASE_URL="mysql+pymysql://user:password@localhost/rescuerover"`

## Database Setup (MySQL)

If using MySQL, you can initialize the tables using the provided script:
```bash
mysql -u root -p < database/init.sql
```
Otherwise, SQLAlchemy will automatically create the tables in SQLite on first run.

## Frontend Setup (Flutter)

1. Make sure the Flutter SDK is installed and configured in your path.
2. Navigate to the `/frontend` directory.
3. If the Android/iOS platform folders are missing, run: `flutter create .`
4. Install dependencies: `flutter pub get`
5. Run the app on an emulator or device: `flutter run`

## Building the APK

You can build the APK by running the provided shell script from the project root:
```bash
bash build_apk.sh
```
This will generate the release APK in `frontend/build/app/outputs/flutter-apk/app-release.apk`.
