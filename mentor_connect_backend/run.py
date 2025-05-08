from flask import Flask
import os
from app import create_app

template_path = os.path.join(os.path.dirname(__file__), 'templates')
app = create_app()

app.template_folder ="/Users/sahasramereddy/Desktop/mentor_connect_backend/templates"

if __name__ == '__main__':
    
     app.run(host='0.0.0.0', port=5000, debug=True)