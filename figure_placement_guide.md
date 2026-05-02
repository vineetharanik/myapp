# DevBalance AI - Figure Placement Guide for IEEE Paper

## 📊 **Screenshots to Include**

### **1. Main Dashboard Screenshot**
- **What**: Complete dashboard showing journal entry form, AI analysis results, and navigation
- **Where**: Section 4 (Methodology) - after System Implementation
- **Figure Caption**: "DevBalance AI main dashboard interface showing journal entry form and real-time AI analysis results"
- **Size**: 0.45 column width

### **2. Journal Entry with AI Analysis**
- **What**: Journal entry screen with completed form and AI-generated insights
- **Where**: Section 5 (Results) - after Performance Evaluation table
- **Figure Caption**: "Journal entry interface with AI-generated burnout risk assessment and personalized recommendations"
- **Size**: 0.45 column width

### **3. Analytics Dashboard**
- **What**: Analytics screen showing study patterns, skill progress, and burnout trends
- **Where**: Section 5 (Results) - after User Study Results
- **Figure Caption**: "Analytics dashboard displaying study patterns, skill development progress, and burnout risk trends over 12-week period"
- **Size**: 0.45 column width

### **4. Chatbot Interface**
- **What**: Chatbot conversation showing contextual responses based on user data
- **Where**: Section 4 (Methodology) - after AI Processing Service description
- **Figure Caption**: "AI-powered chatbot interface providing personalized support based on user's journal history and current context"
- **Size**: 0.45 column width

## 📈 **Generated Graphs Placement**

### **1. System Architecture Diagram**
- **File**: `system_architecture_diagram.pdf`
- **Where**: Section 3 (Methodology) - after System Implementation subsection
- **Figure Reference**: Figure 1
- **Size**: 0.45 column width
- **Caption**: "DevBalance AI system architecture showing frontend, backend, AI/ML, and storage layers"

### **2. Workflow Diagram**
- **File**: `workflow_diagram.pdf`
- **Where**: Section 3 (Methodology) - after System Architecture diagram
- **Figure Reference**: Figure 2
- **Size**: 0.45 column width
- **Caption**: "Complete workflow diagram showing user interaction flow from authentication to AI analysis"

### **3. Accuracy vs Epoch Graph**
- **File**: `accuracy_vs_epoch.png`
- **Where**: Section 5 (Results) - after Performance Evaluation table
- **Figure Reference**: Figure 3
- **Size**: 0.45 column width
- **Caption**: "Model accuracy progression during training showing convergence after 45 epochs"

### **4. Loss vs Epoch Graph**
- **File**: `loss_vs_epoch.png`
- **Where**: Section 5 (Results) - after Accuracy graph
- **Figure Reference**: Figure 4
- **Size**: 0.45 column width
- **Caption**: "Training and validation loss curves demonstrating effective model convergence"

### **5. Model Comparison Bar Chart**
- **File**: `model_comparison.png`
- **Where**: Section 5 (Results) - after Loss graph
- **Figure Reference**: Figure 5
- **Size**: 0.45 column width
- **Caption**: "Performance comparison of different models showing CNN-Transformer superiority"

### **6. User Study Results**
- **File**: `user_study_results.png`
- **Where**: Section 5 (Results) - after Model Comparison
- **Figure Reference**: Figure 6
- **Size**: 0.45 column width
- **Caption**: "User study results showing significant improvements in mental health and academic metrics"

## 📐 **LaTeX Figure Placement Code**

```latex
% In Methodology Section
\begin{figure}[h]
\centering
\includegraphics[width=0.45\textwidth]{system_architecture_diagram.pdf}
\caption{DevBalance AI system architecture showing frontend, backend, AI/ML, and storage layers}
\label{fig:architecture}
\end{figure}

\begin{figure}[h]
\centering
\includegraphics[width=0.45\textwidth]{workflow_diagram.pdf}
\caption{Complete workflow diagram showing user interaction flow from authentication to AI analysis}
\label{fig:workflow}
\end{figure}

% In Results Section
\begin{figure}[h]
\centering
\includegraphics[width=0.45\textwidth]{accuracy_vs_epoch.png}
\caption{Model accuracy progression during training showing convergence after 45 epochs}
\label{fig:accuracy}
\end{figure}

\begin{figure}[h]
\centering
\includegraphics[width=0.45\textwidth]{loss_vs_epoch.png}
\caption{Training and validation loss curves demonstrating effective model convergence}
\label{fig:loss}
\end{figure}

\begin{figure}[h]
\centering
\includegraphics[width=0.45\textwidth]{model_comparison.png}
\caption{Performance comparison of different models showing CNN-Transformer superiority}
\label{fig:comparison}
\end{figure}

\begin{figure}[h]
\centering
\includegraphics[width=0.45\textwidth]{user_study_results.png}
\caption{User study results showing significant improvements in mental health and academic metrics}
\label{fig:user_study}
\end{figure}
```

## 🎯 **Best Practices for IEEE Papers**

### **Figure Quality:**
- **Resolution**: Minimum 300 DPI for all images
- **Format**: PNG for screenshots, PDF for diagrams
- **Size**: Keep figures within column width (3.25 inches) or page width (7 inches)

### **Figure Captions:**
- **Style**: Concise but descriptive
- **Content**: Explain what the figure shows and why it's important
- **Format**: "Figure X: Description" (capitalize first word)

### **Placement Strategy:**
- **Top of page**: Place important figures first
- **Text flow**: Insert figures after first reference
- **Balance**: Distribute figures evenly throughout paper

### **Screenshot Guidelines:**
- **Consistency**: Use same device/screen resolution
- **Privacy**: Blur or remove personal information
- **Clarity**: Ensure text is readable in published version
- **Relevance**: Show key features mentioned in text

## 📋 **Final Checklist**

- [ ] All figures are 300+ DPI
- [ ] Figure captions are descriptive and concise
- [ ] Figures are referenced in text before appearance
- [ ] Figure files are named appropriately
- [ ] Screenshots show relevant features
- [ ] Graphs have clear labels and legends
- [ ] All figures fit within column width requirements
- [ ] Figure placement follows IEEE guidelines
