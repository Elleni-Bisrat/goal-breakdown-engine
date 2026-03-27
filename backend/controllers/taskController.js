import Task from '../models/Task.js'
export const getTaskByGoal = async(req, res)=>{
    try {
        const tasks = await Task.find({
            goal: req.params.goalId,
            user: req.user._id,
        });

        if(!tasks){
            return res.status(404).json({ message: "Task not found" })
        }

        res.status(200).json(tasks)
    }catch(err){
        res.status(500).json({ message: err.message })
    }
}

export const updateTask = async(req, res) => {
    try{
        const task = await Task.findById(req.params.id);

        if(!task){
            return res.status(404).json({ message: "Task not found" })
        }

        if (task.user.toString() !== req.user._id.toString()){
            return res.status(401).json({message: "Not authorized"})
        }
        
        task.title = req.body.title || task.title
        task.dueDate = req.body.dueDate || task.dueDate

        const updatedTask = await task.save()
        res.json(updatedTask)
    }catch(err){
        res.status(500).json({ message: err.message })
    }
}