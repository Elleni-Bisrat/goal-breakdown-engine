import { GoogleGenAI } from '@google/genai';
import dotenv from 'dotenv';

dotenv.config();
const ai = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
});

const calculateTotalDays = (startDate, endDate) => {
  const start = new Date(startDate);
  const end = new Date(endDate);
  const diffTime = Math.abs(end - start);
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  return diffDays;
};

const detectGoalCategory = (title, description) => {
  const text = `${title} ${description || ''}`.toLowerCase();
  const categories = {
    fitness: ['muscle', 'workout', 'gym', 'fitness', 'exercise', 'lift', 'strength', 'cardio', 'run', 'running', 'yoga', 'weight', 'bodybuilding'],
    coding: ['code', 'programming', 'developer', 'app', 'software', 'javascript', 'python', 'java', 'react', 'node', 'flutter', 'backend', 'frontend'],
    learning: ['learn', 'course', 'study', 'exam', 'certification', 'degree', 'class', 'tutorial', 'read', 'book'],
    career: ['job', 'career', 'interview', 'resume', 'portfolio', 'promotion', 'leadership', 'management'],
    health: ['diet', 'nutrition', 'healthy', 'meal', 'cook', 'recipe', 'meditation', 'sleep', 'wellness'],
    finance: ['save', 'budget', 'investment', 'stock', 'crypto', 'money', 'financial', 'debt'],
    creative: ['draw', 'paint', 'design', 'music', 'instrument', 'write', 'blog', 'photography', 'video', 'edit'],
    productivity: ['organize', 'plan', 'productivity', 'routine', 'habit', 'morning', 'schedule'],
    language: ['language', 'speak', 'fluent', 'vocabulary', 'grammar', 'spanish', 'french', 'mandarin'],
    personal: ['confidence', 'mindset', 'meditate', 'journal', 'gratitude', 'self', 'growth']
  };
  for (const [category, keywords] of Object.entries(categories)) {
    if (keywords.some(keyword => text.includes(keyword))) {
      return category;
    }
  }
  return 'general';
};

const getMilestoneTemplates = (category, goalTitle) => {
  const templates = {
    fitness: [
      `Week 1: Assessment & Foundation`,
      `Week 2: Building Consistency`,
      `Week 3: Increasing Intensity`,
      `Week 4: Strength & Endurance`,
      `Week 5: Advanced Techniques`,
      `Week 6: Peak Performance`
    ],
    coding: [
      `Setup & Fundamentals`,
      `Core Concepts & APIs`,
      `Database Integration`,
      `Authentication & Security`,
      `Testing & Optimization`,
      `Deployment & Final Project`
    ],
    learning: [
      `Introduction & Overview`,
      `Core Knowledge Building`,
      `Deep Dive & Practice`,
      `Application & Projects`,
      `Review & Reinforcement`,
      `Mastery & Assessment`
    ],
    career: [
      `Skills Assessment & Planning`,
      `Skill Development`,
      `Networking & Branding`,
      `Application Preparation`,
      `Interview Practice`,
      `Job Search & Follow-up`
    ],
    health: [
      `Assessment & Goal Setting`,
      `Building Healthy Habits`,
      `Nutrition & Meal Planning`,
      `Consistency & Tracking`,
      `Overcoming Challenges`,
      `Long-term Maintenance`
    ],
    finance: [
      `Financial Assessment`,
      `Budget Creation`,
      `Debt & Expense Management`,
      `Saving & Investing`,
      `Income Optimization`,
      `Financial Freedom Planning`
    ],
    creative: [
      `Inspiration & Planning`,
      `Skill Building`,
      `Daily Practice`,
      `Project Development`,
      `Refinement & Polish`,
      `Showcase & Share`
    ],
    productivity: [
      `Audit & Analysis`,
      `System Setup`,
      `Habit Formation`,
      `Optimization`,
      `Automation`,
      `Sustainability`
    ],
    language: [
      `Alphabet & Basics`,
      `Essential Vocabulary`,
      `Grammar Fundamentals`,
      `Conversation Practice`,
      `Reading & Writing`,
      `Fluency Building`
    ],
    personal: [
      `Self-Reflection & Awareness`,
      `Mindset Shift`,
      `Daily Practices`,
      `Growth & Learning`,
      `Resilience Building`,
      `Integration & Maintenance`
    ],
    general: [
      `Introduction & Setup`,
      `Core Concepts`,
      `Practical Application`,
      `Advanced Topics`,
      `Project Work`,
      `Mastery & Review`
    ]
  };
  
  return templates[category] || templates.general;
};

const getTaskTemplates = (category, weekNum) => {
  const templates = {
    fitness: {
      0: [
        "Take body measurements and photos",
        "Research workout routines for beginners",
        "Set up workout space and gather equipment",
        "Learn proper form for basic exercises",
        "Complete first full body workout",
        "Track your starting strength levels",
        "Plan weekly workout schedule"
      ],
      1: [
        "Complete strength training workout",
        "30 minutes cardio session",
        "Track protein intake for the day",
        "Rest day with light stretching",
        "Increase weights by 5-10%",
        "Core strengthening exercises",
        "Log workout performance"
      ],
      2: [
        "Full body compound lifts",
        "HIIT cardio session",
        "Track daily calorie intake",
        "Mobility and flexibility work",
        "Increase workout intensity",
        "Try new exercise variation",
        "Recovery and sleep optimization"
      ]
    },
    coding: {
      0: [
        "Set up development environment",
        "Learn basic syntax and concepts",
        "Build a simple hello world app",
        "Practice with coding challenges",
        "Read documentation and best practices",
        "Complete first mini-project",
        "Review and debug code"
      ],
      1: [
        "Implement core features",
        "Connect to database",
        "Create API endpoints",
        "Add error handling",
        "Write unit tests",
        "Code review and refactor",
        "Document your code"
      ]
    },
    learning: {
      0: [
        "Gather learning materials and resources",
        "Create study schedule",
        "Learn fundamental concepts",
        "Take detailed notes",
        "Practice with exercises",
        "Review and quiz yourself",
        "Summarize key takeaways"
      ],
      1: [
        "Deep dive into complex topics",
        "Complete practice problems",
        "Create study guides",
        "Teach concepts to someone else",
        "Take practice tests",
        "Identify weak areas",
        "Review and reinforce"
      ]
    },
    health: {
      0: [
        "Schedule health checkup",
        "Set realistic health goals",
        "Research nutrition basics",
        "Plan weekly meals",
        "Start food diary",
        "Set water intake goal",
        "Establish sleep schedule"
      ],
      1: [
        "Prepare healthy meals for week",
        "30 minutes physical activity",
        "Track daily nutrition",
        "Practice mindful eating",
        "Try new healthy recipe",
        "Monitor energy levels",
        "Adjust plan as needed"
      ]
    },
    career: {
      0: [
        "Update LinkedIn profile",
        "Review resume and cover letter",
        "Research industry trends",
        "Set career goals",
        "Identify skill gaps",
        "Find learning resources",
        "Create development plan"
      ],
      1: [
        "Complete online course module",
        "Work on portfolio project",
        "Network with professionals",
        "Apply to 3 positions",
        "Prepare for interviews",
        "Practice interview questions",
        "Follow up on applications"
      ]
    },
    creative: {
      0: [
        "Gather inspiration and references",
        "Set up creative workspace",
        "Learn basic techniques",
        "Create first rough draft",
        "Practice daily for 30 minutes",
        "Share work for feedback",
        "Document creative process"
      ],
      1: [
        "Develop project concept",
        "Work on detailed execution",
        "Experiment with new styles",
        "Refine and edit work",
        "Get constructive critique",
        "Make improvements",
        "Prepare final version"
      ]
    },
    finance: {
      0: [
        "Track all expenses for today",
        "Review bank statements",
        "List all income sources",
        "Identify spending patterns",
        "Set savings goal",
        "Research budgeting apps",
        "Create basic budget"
      ],
      1: [
        "Categorize all expenses",
        "Cut unnecessary spending",
        "Set up automatic savings",
        "Research investment options",
        "Pay off smallest debt",
        "Build emergency fund",
        "Review progress"
      ]
    },
    productivity: {
      0: [
        "Time audit your day",
        "Identify top 3 priorities",
        "Set up task management system",
        "Create daily schedule",
        "Remove distractions",
        "Use Pomodoro technique",
        "End of day review"
      ],
      1: [
        "Batch similar tasks",
        "Delegate or outsource",
        "Set boundaries and say no",
        "Automate repetitive tasks",
        "Optimize workflow",
        "Take strategic breaks",
        "Plan tomorrow today"
      ]
    }
  };
  
  const defaultTasks = [
    `Work on ${category} goal for 30 minutes`,
    `Track progress and adjust plan`,
    `Review yesterday's achievements`,
    `Complete daily priority task`,
    `Learn one new thing about ${category}`,
    `Practice consistency and discipline`,
    `Reflect on challenges and solutions`
  ];
  
  const categoryTasks = templates[category];
  if (categoryTasks && categoryTasks[weekNum]) {
    return categoryTasks[weekNum];
  }
  
  if (categoryTasks && categoryTasks[0]) {
    return categoryTasks[0];
  }
  
  return defaultTasks;
};

export const generateAIBreakdown = async (goalTitle, goalDescription, startDate, endDate, totalDays) => {
  try {
    if (!process.env.GEMINI_API_KEY) {
      console.log(" No GEMINI_API_KEY found, using fallback");
      return generateFallbackBreakdown(goalTitle, goalDescription, startDate, endDate, totalDays);
    }

    const weeks = Math.ceil(totalDays / 7);
    const category = detectGoalCategory(goalTitle, goalDescription);
    
    const prompt = `
      You are an expert goal planning assistant. Create a detailed breakdown for the following goal:
      
      GOAL: "${goalTitle}"
      DESCRIPTION: "${goalDescription || 'No description provided'}"
      CATEGORY: "${category}"
      TIMEFRAME: ${totalDays} days (from ${new Date(startDate).toLocaleDateString()} to ${new Date(endDate).toLocaleDateString()})
      
      IMPORTANT RULES:
      1. Create ${weeks} weekly milestones that are RELEVANT to ${category}
      2. Create ${totalDays} daily tasks (one for each day) that are SPECIFIC to ${category}
      3. Tasks should be ACTIONABLE and MEANINGFUL for this type of goal
      
      For a "${category}" goal like "${goalTitle}", tasks should be about:
      ${category === 'fitness' ? '- Workout routines, exercises, nutrition, tracking progress, rest days' : ''}
      ${category === 'coding' ? '- Coding exercises, building projects, learning concepts, debugging' : ''}
      ${category === 'learning' ? '- Studying, note-taking, practice problems, review sessions' : ''}
      ${category === 'health' ? '- Meal prep, exercise, sleep tracking, wellness habits' : ''}
      ${category === 'career' ? '- Job applications, networking, skill development, interviews' : ''}
      ${category === 'creative' ? '- Creating, practicing skills, finding inspiration, finishing projects' : ''}
      ${category === 'finance' ? '- Budgeting, saving, tracking expenses, financial planning' : ''}
      ${category === 'productivity' ? '- Time management, task prioritization, workflow optimization' : ''}
      
      Return ONLY valid JSON with this structure:
      {
        "milestones": [
          {"title": "Week 1: [specific title]", "description": "[what you'll achieve]"}
        ],
        "tasks": [
          {"title": "Day 1: [specific task]", "description": "[detailed steps]", "milestoneIndex": 0}
        ]
      }
    `;

    console.log("Calling Gemini API for goal:", goalTitle);
    console.log("Detected category:", category);

    const response = await ai.models.generateContent({
      model: 'gemini-2.0-flash-exp',
      contents: prompt,
      config: {
        temperature: 0.7,
        maxOutputTokens: 4000,
      },
    });

    const responseText = response.text;
    console.log("Gemini response received");

    let parsedResponse;
    try {
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        parsedResponse = JSON.parse(jsonMatch[0]);
      } else {
        parsedResponse = JSON.parse(responseText);
      }
    } catch (error) {
      console.error("Failed to parse AI response:", responseText);
      throw new Error("AI response parsing failed");
    }

    return parsedResponse;
  } catch (error) {
    console.error("Gemini API Error:", error);
    console.log("Falling back to template generation");
    return generateFallbackBreakdown(goalTitle, goalDescription, startDate, endDate, totalDays);
  }
};

export const generateFallbackBreakdown = (goalTitle, goalDescription, startDate, endDate, totalDays) => {
  const milestones = [];
  const tasks = [];
  const weeks = Math.ceil(totalDays / 7);
  const startDateTime = new Date(startDate);
  
  const category = detectGoalCategory(goalTitle, goalDescription);
  const milestoneTemplates = getMilestoneTemplates(category, goalTitle);
  
  console.log(`📋 Generating ${category} plan for: ${goalTitle}`);
  
  for (let i = 0; i < weeks; i++) {
    const templateIndex = i % milestoneTemplates.length;
    milestones.push({
      title: `Week ${i + 1}: ${milestoneTemplates[templateIndex]}`,
      description: `Focus on ${milestoneTemplates[templateIndex].toLowerCase()} for your ${category} goal`
    });
  }
  
  for (let day = 0; day < totalDays; day++) {
    const taskDate = new Date(startDateTime);
    taskDate.setDate(startDateTime.getDate() + day);
    const weekNum = Math.floor(day / 7);
    
    const taskTemplates = getTaskTemplates(category, weekNum);
    const taskIndex = day % taskTemplates.length;
    
    let taskTitle = "";
    let taskDescription = "";
    
    if (day === 0) {
      if (category === 'fitness') {
        taskTitle = "Day 1: Set up your fitness plan";
        taskDescription = `Take initial measurements, set up workout space, and plan your ${goalTitle} journey`;
      } else if (category === 'health') {
        taskTitle = "Day 1: Health assessment & planning";
        taskDescription = `Schedule checkup, set realistic health goals, and prepare for ${goalTitle}`;
      } else if (category === 'career') {
        taskTitle = "Day 1: Career assessment";
        taskDescription = `Review current skills, update LinkedIn, and plan your ${goalTitle} strategy`;
      } else {
        taskTitle = `Day 1: Start your ${goalTitle} journey`;
        taskDescription = `Create a plan, gather resources, and prepare for success`;
      }
    } else if (day === totalDays - 1) {
      if (category === 'fitness') {
        taskTitle = "Final Day: Review & celebrate progress";
        taskDescription = `Take final measurements, review achievements, and plan next fitness goals`;
      } else {
        taskTitle = `Final Day: Complete ${goalTitle} & plan next steps`;
        taskDescription = `Review your progress, celebrate achievements, and plan what's next`;
      }
    } else {
      taskTitle = `Day ${day + 1}: ${taskTemplates[taskIndex]}`;
      
      if (category === 'fitness') {
        taskDescription = `Complete today's workout, track nutrition, and stay consistent with your ${goalTitle} plan`;
      } else if (category === 'health') {
        taskDescription = `Follow your health routine, track progress, and make healthy choices today`;
      } else if (category === 'career') {
        taskDescription = `Take concrete steps toward your ${goalTitle} career goals today`;
      } else if (category === 'creative') {
        taskDescription = `Spend dedicated time creating and developing your ${goalTitle} skills`;
      } else if (category === 'finance') {
        taskDescription = `Take action on your financial ${goalTitle} goals today`;
      } else if (category === 'learning') {
        taskDescription = `Study, practice, and reinforce your ${goalTitle} knowledge`;
      } else {
        taskDescription = `Make progress on your ${goalTitle} goal with focused effort today`;
      }
    }
    
    tasks.push({
      title: taskTitle,
      description: taskDescription,
      milestoneIndex: weekNum,
      dueDate: taskDate,
      status: "pending"
    });
  }
  
  console.log(` Generated ${milestones.length} milestones and ${tasks.length} tasks for ${category} goal`);
  
  return { milestones, tasks };
};