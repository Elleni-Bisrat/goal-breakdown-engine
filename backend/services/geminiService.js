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

export const generateAIBreakdown = async (goalTitle, goalDescription, startDate, endDate, totalDays) => {
  try {
    if (!process.env.GEMINI_API_KEY) {
      console.log("⚠️ No GEMINI_API_KEY found, using fallback");
      return generateFallbackBreakdown(goalTitle, startDate, endDate, totalDays);
    }

    const weeks = Math.ceil(totalDays / 7);
    const prompt = `
      You are an expert goal planning assistant. Create a detailed breakdown for the following goal:
      GOAL: "${goalTitle}"
      DESCRIPTION: "${goalDescription || 'No description provided'}"
      TIMEFRAME: ${totalDays} days (from ${new Date(startDate).toLocaleDateString()} to ${new Date(endDate).toLocaleDateString()})
      IMPORTANT RULES:
      1. Create ${weeks} weekly milestones
      2. Create ${totalDays} daily tasks (one for each day)
      3. Tasks should be SPECIFIC and MEANINGFUL
      
      Return ONLY valid JSON with this structure:
      {
        "milestones": [
          {"title": "Week 1: [specific title]", "description": "[what you'll learn]"}
        ],
        "tasks": [
          {"title": "Day 1: [specific task]", "description": "[detailed steps]", "milestoneIndex": 0}
        ]
      }
    `;

    console.log("Calling Gemini API for goal:", goalTitle);

    const response = await ai.models.generateContent({
      model: 'gemini-2.0-flash-exp',
      contents: prompt,
      config: {
        temperature: 0.7,
        maxOutputTokens: 4000,
      },
    });

    const responseText = response.text;
    console.log("✅ Gemini response received");

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
    console.log("⚠️ Falling back to template generation");
    return generateFallbackBreakdown(goalTitle, startDate, endDate, totalDays);
  }
};

export const generateFallbackBreakdown = (goalTitle, startDate, endDate, totalDays) => {
  const milestones = [];
  const tasks = [];
  const weeks = Math.ceil(totalDays / 7);
  const startDateTime = new Date(startDate);
  
  const goalLower = goalTitle.toLowerCase();
  let milestoneTemplates = [];
  
  if (goalLower.includes('node') || goalLower.includes('express') || goalLower.includes('backend')) {
    milestoneTemplates = [
      `Setup & Fundamentals`,
      `Core Concepts & APIs`,
      `Database Integration`,
      `Authentication & Security`,
      `Testing & Optimization`,
      `Deployment & Final Project`
    ];
  } else if (goalLower.includes('flutter') || goalLower.includes('mobile')) {
    milestoneTemplates = [
      `Environment Setup & Basics`,
      `UI Development`,
      `State Management`,
      `API Integration`,
      `Advanced Features`,
      `Testing & Publishing`
    ];
  } else if (goalLower.includes('react') || goalLower.includes('frontend')) {
    milestoneTemplates = [
      `React Fundamentals`,
      `Components & Props`,
      `State & Hooks`,
      `Routing & APIs`,
      `Advanced Patterns`,
      `Build Complete App`
    ];
  } else {
    milestoneTemplates = [
      `Introduction & Setup`,
      `Core Concepts`,
      `Practical Applications`,
      `Advanced Topics`,
      `Project Work`,
      `Mastery & Review`
    ];
  }
  
  for (let i = 0; i < weeks; i++) {
    const templateIndex = i % milestoneTemplates.length;
    milestones.push({
      title: `Week ${i + 1}: ${milestoneTemplates[templateIndex]}`,
      description: `Complete ${milestoneTemplates[templateIndex].toLowerCase()} for ${goalTitle}`
    });
  }
  
  const taskActions = [
    "Watch tutorials and take notes",
    "Complete hands-on exercises",
    "Build a small practice project",
    "Review and document learnings",
    "Practice with real examples",
    "Solve coding challenges",
    "Implement a feature independently"
  ];
  
  for (let day = 0; day < totalDays; day++) {
    const taskDate = new Date(startDateTime);
    taskDate.setDate(startDateTime.getDate() + day);
    const weekNum = Math.floor(day / 7);
    const actionIndex = day % taskActions.length;
    
    tasks.push({
      title: `Day ${day + 1}: ${taskActions[actionIndex]}`,
      description: `Focus on ${milestoneTemplates[weekNum % milestoneTemplates.length].toLowerCase()} for ${goalTitle}`,
      milestoneIndex: weekNum,
      dueDate: taskDate,
      status: "pending"
    });
  }
  
  return { milestones, tasks };
};