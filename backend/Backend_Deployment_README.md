BACKEND CHANGES GUIDE: GITHUB, SERVER UPDATE, WINSCP, AND RESTART
=================================================================

This guide explains the full backend workflow:
1. Pull project/code from GitHub
2. Make changes locally
3. Push changes back to GitHub
4. Update the server using WinSCP
5. Restart the backend server

PROJECT DETAILS USED IN THIS GUIDE
----------------------------------
GitHub repo name: OT-Scheduler
Branch Name: abhishek-pathfinder
(Amrita) local Server user: souvik
(Amrita) Server IP: 10.125.50.200
Server project path: /home/souvik/OT_Scheduling
Python virtual environment on server: ot_venv


============================================================
PULL / DOWNLOAD PROJECT FROM GITHUB TO LOCAL MACHINE
============================================================

OPTION A: If project is already available on your local machine
-------------------------------------------------------------
Open Git Bash / Terminal / VS Code terminal and go to your local project folder: cd <<PATH>>

Check current branch: git branch

Pull latest code from GitHub: git pull origin abhishek-pathfinder

If you are using main branch, use: git pull origin main


OPTION B: If project is NOT available locally yet
------------------------------------------------
Clone the project from GitHub: git clone <github-repo-url>

Example: git clone https://github.com/<username>/OT-Scheduler.git

Then go inside the project: cd OT-Scheduler

Switch to the correct branch if needed: git checkout abhishek-pathfinder

Pull latest code: git pull origin abhishek-pathfinder


============================================================
PUSH YOUR CHANGES TO GITHUB
============================================================

Check changed files: git status

Add changed files: git add .

Commit changes: git commit -m "<<Comment>>"

Push changes to GitHub: git push origin abhishek-pathfinder

If using main branch: git push origin main

IMPORTANT:
If your GitHub page says your branch is ahead of main, then your latest code is in that branch, not main.
So deploy from the same branch you are using.


============================================================
OPEN WINSCP AND CONNECT TO SERVER
============================================================

1. Open WinSCP.

2. Enter connection details:

    File protocol: SFTP
    Host name: <<IP ADDRESS>>
    User name: <<USER NAME>>
    Password: your server password

3. Click Login.

4. On the server side, open this path: /home/souvik/OT_Scheduling

5. On the local side, open your updated project folder.


============================================================
UPDATE SERVER CODE USING WINSCP
============================================================

METHOD 1: Upload only selected files manually
--------------------------------------------
Use this when you know exactly which files changed.

1. On the left side, select the changed local files.
2. Drag and drop them to the right side server folder.
3. Confirm overwrite when WinSCP asks.

Example files you may upload:

    views.py
    urls.py
    models.py
    serializers.py
    settings.py
    requirements.txt

DO NOT upload these unless you are 100% sure:

    db.sqlite3
    ot_venv/
    __pycache__/
    .env


METHOD 2: Use Synchronize option
--------------------------------
Use this when multiple files changed.

1. In WinSCP, open local folder on left: D:\OT_Scheduler\OT_Scheduling

2. Open server folder on right:  /home/souvik/OT_Scheduling

3. Click: Commands -> Synchronize

4. Choose:

    Direction/Target directory: Remote
    Mode: Synchronize files
    Preview changes: Checked
    Delete files: Unchecked

5. Click OK.

6. WinSCP will show a Synchronization checklist.

7. In the checklist:

    Checked files = will be uploaded/updated on server
    Unchecked files = ignored
    Green arrow = upload local file to server
    Red mark = ignored or not selected

8. Keep these unchecked:

    db.sqlite3
    ot_venv/
    __pycache__/
    .env

9. Select only required changed code files.

10. Click OK to upload selected files.

WARNING:
WinSCP sync has no automatic undo. If you overwrite a file, you must restore it from backup or GitHub.


============================================================
AFTER UPLOAD, RUN SERVER COMMANDS
============================================================

Open terminal from WinSCP: Commands -> Open Terminal

Or use SSH from your local terminal: ssh <<USER NAME>>@<<IP ADDRESS>>

Go to project folder: cd /home/souvik/OT_Scheduling

Activate virtual environment: source ot_venv/bin/activate

If requirements.txt changed, install dependencies:

    pip install -r requirements.txt

If models.py changed, run migrations:

    python manage.py makemigrations
    python manage.py migrate


============================================================
RESTART THE BACKEND SERVER
============================================================

Restart service:

    sudo systemctl restart ot_gunicorn.service

Check status:

    sudo systemctl status ot_gunicorn.service

For Logs:

    sudo journalctl -u ot_gunicorn.service -f



============================================================
VERIFY DEPLOYMENT
============================================================

After restart:

1. Open the backend URL in browser.
2. Test APIs in browser/Postman.
3. Check logs if something is wrong.

For systemd service logs:

    sudo journalctl -u ot_gunicorn.service -f

For Django runserver, check terminal output.
