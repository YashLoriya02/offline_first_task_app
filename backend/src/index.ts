import dotenv from "dotenv"
dotenv.config()
import express from "express"
import cors from "cors"
import authRouter from "./routes/auth"
import connectDB from "./db/db"
import taskRouter from "./routes/task"

const app = express()

app.use(express.json())
app.use(cors({
    origin : "*"
}))

app.use('/task', taskRouter)
app.use('/auth', authRouter)

connectDB()

app.listen(8000, () => {
    console.log("Server Running on Port 8000")
})