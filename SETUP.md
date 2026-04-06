# DevBalance AI - Setup Instructions

## 🚀 Quick Setup Guide

### 1. Get Your OpenAI API Key
1. Go to [OpenAI Platform](https://platform.openai.com/api-keys)
2. Sign up or log in
3. Click "Create new secret key"
4. Copy the key (it starts with `sk-...`)
5. Add it to your `.env` file

### 2. Update Backend Configuration
Edit `backend/.env` and replace:
```
OPENAI_API_KEY=sk-your-openai-api-key-here
```
With your actual key:
```
OPENAI_API_KEY=sk-actual-key-you-copied-from-openai
```

### 3. Start the Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 4. Start the Frontend
```bash
cd myapp
flutter pub get
flutter run -d chrome
```

## 🔑 API Key Requirements

### OpenAI API Key Needed For:
- ✅ **Journal Analysis** - AI analyzes journal entries for mood, stress, burnout risk
- ✅ **Skills Progress** - AI tracks skill development from journal content  
- ✅ **Study Recommendations** - AI provides personalized study tips
- ✅ **Chatbot Responses** - Real AI-powered mental health conversations

### Features That Work With Real AI:
- 🤖 **Smart Journal Analysis** - Real sentiment and stress detection
- 📊 **Burnout Risk Calculation** - AI-powered risk assessment
- 🎯 **Personalized Recommendations** - AI suggests coping strategies
- 💬 **Intelligent Chatbot** - Context-aware mental health support
- 📈 **Skills Progress Tracking** - AI identifies skill development from journals
- 📚 **Study Plan Generation** - AI creates personalized weekly schedules

## 🧪 Test the AI Integration

### Test Journal Analysis:
1. Write a journal entry like: "I'm feeling stressed about my upcoming exams and haven't been sleeping well"
2. Click "Analyze Journal"
3. You should get real AI analysis with mood, stress level, and suggestions

### Test Chatbot:
1. Go to the chatbot screen
2. Type: "I'm feeling overwhelmed with my studies"
3. You should get intelligent, context-aware responses

## 🔍 Troubleshooting

### If AI doesn't work:
1. **Check API Key**: Make sure your OpenAI key is valid and has credits
2. **Backend Running**: Ensure the FastAPI server is running on port 8000
3. **Network Connection**: Check if your app can reach the backend
4. **OpenAI Credits**: Verify your OpenAI account has available credits

### Common Issues:
- **"AI temporarily unavailable"** → Check OpenAI API key and credits
- **"Connection error"** → Make sure backend is running
- **"Invalid API key"** → Replace with correct OpenAI key

## 🎯 Real AI Features vs Demo Mode

| Feature | Demo Mode | Real AI Mode |
|---------|-----------|-------------|
| Journal Analysis | ❌ Mock responses | ✅ Real GPT-4 analysis |
| Chatbot | ❌ Pre-programmed | ✅ Dynamic AI responses |
| Burnout Detection | ❌ Fake calculation | ✅ AI-powered assessment |
| Skills Tracking | ❌ Manual input | ✅ AI extraction from journals |
| Study Plans | ❌ Static templates | ✅ AI-generated schedules |

## 🚀 Ready to Use

Once you add your OpenAI API key, you'll have:
- 🤖 **Real AI-powered journal analysis**
- 💬 **Intelligent mental health chatbot**  
- 📊 **Accurate burnout risk assessment**
- 🎯 **Personalized study recommendations**
- 📈 **Smart skills progress tracking**

The app transforms from a demo into a **real AI-powered mental health and productivity tool**! 🎉
