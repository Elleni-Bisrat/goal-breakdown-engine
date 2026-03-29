
export const calculateTotalDays = (startDate, endDate) => {
  const start = new Date(startDate);
  const end = new Date(endDate);

  const diffTime = Math.abs(end - start);

  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));

  return diffDays;
};

const generateMilestones = (goalTitle, startDate, endDate, totalDays) => {
  const milestones = [];

  const weeks = Math.ceil(totalDays / 7);

  const currentStart = new Date(startDate);

  for (let i = 1; i <= weeks; i++) {
    const milestoneEnd = new Date(currentStart);

    milestoneEnd.setDate(milestoneEnd.getDate() + 6);

    milestones.push({
      title: `Week ${i}: ${goalTitle} Milestone`,

      startDate: new Date(currentStart),

      endDate: new Date(milestoneEnd),

      completed: false,
    });

    currentStart.setDate(currentStart.getDate() + 7);
  }

  return milestones;
};

const generateTasksForMilestone = (milestone, milestoneIndex, goalTitle) => {
  const tasks = [];

  const startDate = new Date(milestone.startDate);

  const endDate = new Date(milestone.endDate);

  const daysInMilestone = Math.ceil(
    (endDate - startDate) / (1000 * 60 * 60 * 24),
  );

  for (let day = 0; day <= daysInMilestone; day++) {
    const taskDate = new Date(startDate);

    taskDate.setDate(startDate.getDate() + day);

    tasks.push({
      title: `Day ${day + 1}: Work on ${goalTitle}`,

      description: `Complete daily ${goalTitle} tasks - Milestone ${milestoneIndex + 1}`,

      dueDate: taskDate,

      milestoneIndex: milestoneIndex,

      status: "pending",
    });
  }

  return tasks;
};

export const breakdownGoal = (goal) => {
  const totalDays = calculateTotalDays(goal.startDate, goal.endDate);

  const milestones = generateMilestones(
    goal.title,
    goal.startDate,
    goal.endDate,
    totalDays,
  );

  let allTasks = [];

  milestones.forEach((milestone, index) => {
    const tasks = generateTasksForMilestone(milestone, index, goal.title);

    allTasks = [...allTasks, ...tasks];
  });

  return {
    milestones,
    tasks: allTasks,
    totalDays,
    totalMilestones: milestones.length,
    totalTasks: allTasks.length,
  };
};
