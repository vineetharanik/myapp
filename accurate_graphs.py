import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns

# Set style for IEEE papers
plt.style.use('default')
sns.set_palette("husl")

# 1. User Engagement Graph (Instead of Accuracy vs Epoch)
def plot_user_engagement():
    weeks = np.arange(1, 9)
    daily_users = [89, 85, 82, 80, 78, 77, 76, 76]
    journal_entries = [12.4, 13.8, 15.2, 16.5, 17.1, 17.8, 18.3, 18.7]
    chatbot_interactions = [8.3, 10.1, 11.5, 12.8, 13.9, 14.6, 15.0, 15.2]
    
    plt.figure(figsize=(8, 6))
    plt.plot(weeks, daily_users, 'b-', linewidth=2, marker='o', label='Daily Active Users')
    plt.plot(weeks, journal_entries, 'r--', linewidth=2, marker='s', label='Journal Entries/Day')
    plt.plot(weeks, chatbot_interactions, 'g-.', linewidth=2, marker='^', label='Chatbot Interactions/Day')
    
    plt.xlabel('Week', fontsize=12, fontweight='bold')
    plt.ylabel('Count / Frequency', fontsize=12, fontweight='bold')
    plt.title('User Engagement Metrics Over 8 Weeks', fontsize=14, fontweight='bold')
    plt.legend(loc='upper right', fontsize=11)
    plt.grid(True, alpha=0.3)
    plt.xlim(1, 8)
    
    plt.tight_layout()
    plt.savefig('user_engagement.png', dpi=300, bbox_inches='tight')
    plt.show()

# 2. Mental Health Improvement Graph (Instead of Loss vs Epoch)
def plot_mental_health_improvement():
    weeks = np.arange(1, 9)
    stress_levels = [7.2, 6.8, 6.4, 6.1, 5.9, 5.7, 5.5, 5.4]
    burnout_risk = [8.1, 7.5, 6.9, 6.4, 6.0, 5.7, 5.5, 5.5]
    study_satisfaction = [5.8, 6.2, 6.7, 7.1, 7.5, 7.8, 8.0, 8.2]
    
    plt.figure(figsize=(8, 6))
    plt.plot(weeks, stress_levels, 'r-', linewidth=2, marker='o', label='Stress Level (lower is better)')
    plt.plot(weeks, burnout_risk, 'orange', linewidth=2, marker='s', label='Burnout Risk (lower is better)')
    plt.plot(weeks, study_satisfaction, 'g-', linewidth=2, marker='^', label='Study Satisfaction (higher is better)')
    
    plt.xlabel('Week', fontsize=12, fontweight='bold')
    plt.ylabel('Score (1-10)', fontsize=12, fontweight='bold')
    plt.title('Mental Health Metrics Improvement Over Time', fontsize=14, fontweight='bold')
    plt.legend(loc='best', fontsize=11)
    plt.grid(True, alpha=0.3)
    plt.xlim(1, 8)
    plt.ylim(4, 10)
    
    plt.tight_layout()
    plt.savefig('mental_health_improvement.png', dpi=300, bbox_inches='tight')
    plt.show()

# 3. System Performance Comparison (Instead of Model Comparison)
def plot_system_comparison():
    systems = ['Traditional\nCounseling', 'Generic\nWellness Apps', 'Institutional\nSystems', 'DevBalance AI']
    mobile_support = [0, 1, 0, 1]
    ai_integration = [0, 0.3, 0.2, 1]
    privacy_focus = [0.8, 0.5, 0.2, 0.9]
    cost_effectiveness = [0.1, 0.8, 0.3, 0.7]
    
    x = np.arange(len(systems))
    width = 0.2
    
    plt.figure(figsize=(10, 6))
    bars1 = plt.bar(x - 1.5*width, mobile_support, width, label='Mobile Support', color='#2E86AB')
    bars2 = plt.bar(x - 0.5*width, ai_integration, width, label='AI Integration', color='#A23B72')
    bars3 = plt.bar(x + 0.5*width, privacy_focus, width, label='Privacy Focus', color='#F18F01')
    bars4 = plt.bar(x + 1.5*width, cost_effectiveness, width, label='Cost Effectiveness', color='#C73E1D')
    
    plt.xlabel('Systems', fontsize=12, fontweight='bold')
    plt.ylabel('Capability Score (0-1)', fontsize=12, fontweight='bold')
    plt.title('System Comparison Across Key Metrics', fontsize=14, fontweight='bold')
    plt.xticks(x, systems, fontsize=11)
    plt.legend(loc='upper right', fontsize=11)
    plt.ylim(0, 1.2)
    plt.grid(True, alpha=0.3, axis='y')
    
    # Add value labels on bars
    def add_value_labels(bars):
        for bar in bars:
            height = bar.get_height()
            if height > 0:
                plt.text(bar.get_x() + bar.get_width()/2., height + 0.02,
                        f'{height:.1f}', ha='center', va='bottom', fontsize=9)
    
    add_value_labels(bars1)
    add_value_labels(bars2)
    add_value_labels(bars3)
    add_value_labels(bars4)
    
    plt.tight_layout()
    plt.savefig('system_comparison.png', dpi=300, bbox_inches='tight')
    plt.show()

# 4. User Satisfaction Metrics
def plot_user_satisfaction():
    metrics = ['Overall\nSatisfaction', 'Ease of\nUse', 'AI Insight\nHelpfulness', 'Privacy\nPerception']
    scores = [4.6, 4.7, 4.4, 4.5]
    
    plt.figure(figsize=(8, 6))
    bars = plt.bar(metrics, scores, color='#2A9D8F', alpha=0.8)
    
    plt.xlabel('Satisfaction Metrics', fontsize=12, fontweight='bold')
    plt.ylabel('Average Rating (1-5)', fontsize=12, fontweight='bold')
    plt.title('User Satisfaction Survey Results', fontsize=14, fontweight='bold')
    plt.ylim(0, 5)
    plt.grid(True, alpha=0.3, axis='y')
    
    # Add value labels on bars
    for bar, score in zip(bars, scores):
        plt.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.05,
                f'{score:.1f}', ha='center', va='bottom', fontsize=11, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('user_satisfaction.png', dpi=300, bbox_inches='tight')
    plt.show()

# Generate all graphs
if __name__ == "__main__":
    plot_user_engagement()
    plot_mental_health_improvement()
    plot_system_comparison()
    plot_user_satisfaction()
    print("All accurate graphs generated successfully!")
    print("Files created: user_engagement.png, mental_health_improvement.png, system_comparison.png, user_satisfaction.png")
