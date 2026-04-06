import google.generativeai as genai
import os

def test_google_ai():
    """Test if the Google AI API key is working"""
    
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
    
    if api_key == 'AIzaSyDMuzHvJk-BKYhcEZt03zeVaI-l_G8OJV0':
        print("✅ Using your provided Google API key")
        print("🔑 Key: AIzaSyDMuzHvJk-BKYhcEZt03zeVaI-l_G8OJV0")
    else:
        print(f"🔑 Found API key: {api_key[:20]}...")
    
    # Test the API
    try:
        genai.configure(api_key=api_key)
        
        # List available models first
        print("\n📋 Available models:")
        for m in genai.list_models():
            if 'generateContent' in m.supported_generation_methods:
                print(f"  ✅ {m.name}")
            else:
                print(f"  ❌ {m.name} (no generateContent)")
        
        # Try with an available model
        model = genai.GenerativeModel('gemini-2.0-flash')
        
        response = model.generate_content('Say "Hello! Google AI is working!"')
        
        print("\n✅ Google AI API is working!")
        print(f"🤖 Response: {response.text}")
        
    except Exception as e:
        print(f"❌ API Error: {e}")
        print("🌐 Check your API key and internet connection")

if __name__ == "__main__":
    print("🔑 Testing Google AI (Gemini) API Configuration...")
    print("=" * 60)
    test_google_ai()
    print("=" * 60)
    print("\n🚀 If successful, your app will have real AI features!")
