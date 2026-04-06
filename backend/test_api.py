import requests
import json

def test_openai_api():
    """Test if the OpenAI API key is working"""
    
    # Read the API key from .env file
    try:
        with open('.env', 'r') as f:
            for line in f:
                if line.startswith('OPENAI_API_KEY='):
                    api_key = line.split('=', 1)[1].strip()
                    break
    except FileNotFoundError:
        print("❌ .env file not found")
        return
    
    if api_key == 'sk-your-openai-api-key-here':
        print("❌ Please update your OpenAI API key in .env file")
        print("📝 Get your key from: https://platform.openai.com/api-keys")
        return
    
    # Test the API
    headers = {
        'Authorization': f'Bearer {api_key}',
        'Content-Type': 'application/json',
    }
    
    data = {
        'model': 'gpt-4o-mini',
        'messages': [
            {
                'role': 'user',
                'content': 'Say "Hello! OpenAI API is working!" in JSON format: {"message": "text"}'
            }
        ],
        'response_format': {'type': 'json_object'}
    }
    
    try:
        response = requests.post(
            'https://api.openai.com/v1/chat/completions',
            headers=headers,
            json=data,
            timeout=10
        )
        
        if response.status_code == 200:
            result = response.json()
            message = json.loads(result['choices'][0]['message']['content'])
            print(f"✅ OpenAI API is working!")
            print(f"🤖 Response: {message.get('message', 'No message')}")
        else:
            print(f"❌ API Error: {response.status_code}")
            print(f"📄 Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Connection Error: {e}")
        print("🌐 Check your internet connection")
    except json.JSONDecodeError as e:
        print(f"❌ JSON Error: {e}")
        print("📄 Invalid response format")

if __name__ == "__main__":
    print("🔑 Testing OpenAI API Configuration...")
    print("=" * 50)
    test_openai_api()
    print("=" * 50)
    print("\n📖 See SETUP.md for complete instructions")
