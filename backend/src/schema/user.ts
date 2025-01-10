import mongoose, { Schema, Document } from "mongoose";
import { v4 as uuidv4 } from "uuid"; 

export interface IUser extends Document {
    id: string;
    name: string;
    email: string;
    password: string;
    createdAt: Date;
    updatedAt: Date;
}

const userSchema: Schema<IUser> = new Schema(
    {
        id: {
            type: String,
            default: uuidv4,
            unique: true,
        },
        name: {
            type: String,
            required: true,
            trim: true,
        },
        email: {
            type: String,
            required: true,
            unique: true,
            trim: true,
            lowercase: true,
        },
        password: {
            type: String,
            required: true,
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

userSchema.pre<IUser>("save", function (next) {
    this.updatedAt = new Date();
    next();
});

const User = mongoose.model<IUser>("User", userSchema);

export default User;