import mongoose, { Schema, Document, Mongoose } from "mongoose";
import { v4 as uuidv4 } from "uuid";
import User from "./user";

export interface ITask extends Document {
    id: string;
    title: string;
    description: string;
    hexColor: string;
    userId: Schema.Types.ObjectId;
    dueAt: Date;
    createdAt: Date;
    updatedAt: Date;
}

const taskSchema: Schema<ITask> = new Schema(
    {
        id: {
            type: String,
            default: uuidv4,
            unique: true,
        },
        title: {
            type: String,
            required: true,
            trim: true,
        },
        description: {
            type: String,
            required: true,
            trim: true,
        },
        hexColor: {
            type: String,
            required: true,
        },
        userId: {
            type: Schema.Types.ObjectId,
            ref: User
        },
        dueAt: {
            type: Date,
            default: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
        },
        createdAt: {
            type: Date,
            default: Date.now,
            immutable: true,
        },
        updatedAt: {
            type: Date,
            default: Date.now,
        },
    },
    {
        timestamps: true,
    }
);

taskSchema.pre<ITask>("save", function (next) {
    this.updatedAt = new Date();
    next();
});

const Task = mongoose.model<ITask>("Task", taskSchema);

export default Task;