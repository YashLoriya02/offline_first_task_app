import { Response, Router } from "express";
import { auth, AuthRequest } from "../middlewares/auth";
import Task from "../schema/task";
import { UUID } from "crypto";

const taskRouter = Router()

interface taskBody {
    title: String,
    description: String,
    hexColor: String,
    dueAt: Date
}

interface task {
    title: String,
    description: String,
    hexColor: String,
    userId: String,
    id: UUID,
    createdAt: Date,
    updatedAt: Date,
    dueAt: Date
}

taskRouter.post('/add', auth, async (req: AuthRequest, res: Response) => {
    try {
        const { title, description, hexColor, dueAt }: taskBody = req.body;
        const userId = req.user

        const task = new Task({
            title,
            userId,
            description,
            hexColor,
            dueAt: new Date(dueAt)
        })

        const newTask = await task.save()

        res.status(201).json(newTask);

    } catch (error) {
        res.status(500).json({ error })
    }
})

taskRouter.post('/add/sync', auth, async (req: AuthRequest, res: Response) => {
    try {
        const { tasksList } = req.body;
        const userId = req.user;


        const tasks = tasksList.map(async (task: task) => {
            const { id, title, description, createdAt, updatedAt, dueAt, hexColor } = task;
            const exist = await Task.findOne({ id })
            if (!exist) {
                await Task.create({ id, userId, title, description, createdAt, updatedAt, dueAt, hexColor })
            }
        })

        res.status(201).json(tasks);
    } catch (error) {
        console.log(error)
        res.status(500).json({ error })
    }
})

taskRouter.get('/fetch', auth, async (req: AuthRequest, res: Response) => {
    try {
        const userId = req.user

        const tasks = await Task.find({ userId }).lean()
        if (!tasks || tasks.length == 0) {
            res.status(404).json({ error: "No tasks found for given user." });
        }

        const transformedTasks = tasks.map(({ _id, __v, ...rest }) => ({
            mongoId: _id,
            ...rest
        }));

        res.status(200).json(transformedTasks);
    } catch (error) {
        res.status(500).json({ error })
    }
})

taskRouter.delete('/delete', auth, async (req: AuthRequest, res: Response) => {
    try {
        const { taskId }: { taskId: String } = req.body

        const task = await Task.findByIdAndDelete(taskId);
        if (!task) {
            res.status(404).json({ error: "Task not found." });
        }

        res.status(200).json({ message: "Task Deleted Succesfully." });
    } catch (error) {
        res.status(500).json({ error })
    }
})

export default taskRouter;