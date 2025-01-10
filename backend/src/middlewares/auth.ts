import { UUID } from "crypto";
import { NextFunction, Request, Response } from "express";
import User from "../schema/user";
import jwt from "jsonwebtoken";
import { Schema } from "mongoose";

export interface AuthRequest extends Request {
    user?: Schema.Types.ObjectId,
    token?: string
}

export const auth = async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
        const token = req.header('x-auth-token')
        if (!token) {
            res.json({ error: "No Auth Token Provided" });
            return;
        }

        const verified = jwt.verify(token, "MY_JWT_SECRET");

        if (!verified) {
            res.json({ error: "Unauthorized access, Invalid Token" });
            return;
        }

        const verifiedToken = verified as { id: Schema.Types.ObjectId };

        const user = await User.findOne({ _id: verifiedToken.id })
        if (!user) {
            res.status(401).json({ error: "User not found" });
            return;
        }

        req.user = verifiedToken.id
        next()
    } catch (error) {
        res.status(500).json({ error: error })
    }
}