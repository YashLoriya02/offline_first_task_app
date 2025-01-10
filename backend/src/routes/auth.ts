import { Router, Request, Response, NextFunction } from "express";
import bcryptjs from "bcryptjs";
import jwt from "jsonwebtoken";
import User, { IUser } from "../schema/user";
import { auth, AuthRequest } from "../middlewares/auth";

const router = Router()

interface SignUpBody {
    name: string,
    email: string,
    password: string,
}

interface LoginBody {
    email: string,
    password: string,
}

router.post("/signup", async (req: Request<{}, {}, SignUpBody>, res: Response) => {
    try {
        const { name, email, password } = req.body;

        const userExist = await User.findOne({ email })
        if (userExist) {
            res.status(400).json({ error: "User with the same email already exists!" });
            return
        }

        const hashedPassword = await bcryptjs.hash(password, 8);

        const newUser: IUser = new User({
            name,
            email,
            password: hashedPassword
        });

        const user = await newUser.save();
        res.status(201).json(user);
    } catch (error) {
        console.log("Inside Catch")
        res.status(500).json({ error });
    }
});

router.post("/login", async (req: Request<{}, {}, LoginBody>, res: Response) => {
    try {
        const { email, password } = req.body;

        const existingUser = await User.findOne({ email })
        if (!existingUser) {
            res.status(400).json({ error: "User with this email does not exist!" });
            return;
        }

        const isMatch = await bcryptjs.compare(password, existingUser.password);
        if (!isMatch) {
            res.status(400).json({ error: "Incorrect password!" });
            return;
        }

        const token = jwt.sign({ id: existingUser._id }, "MY_JWT_SECRET");

        const { _id, name, id, createdAt, updatedAt } = existingUser

        res.json({ token, _id, name, email: existingUser.email, id, createdAt, updatedAt });
    } catch (e) {
        console.log(e)
        res.status(500).json({ error: e });
    }
});

router.post("/tokenIsValid", async (req, res) => {
    try {
        const token = req.header("x-auth-token");
        if (!token) {
            res.json(false);
            return;
        }

        const verified = jwt.verify(token, "MY_JWT_SECRET");
        if (!verified) {
            res.json(false);
            return;
        }

        const verifiedToken = verified as { id: string };

        const user = await User.findOne({ _id: verifiedToken.id })
        if (!user) {
            res.json(false);
            return;
        }

        res.json(true);
    } catch (e) {
        res.status(500).json(false);
    }
});

router.get("/", auth, async (req: AuthRequest, res) => {
    try {
        if (!req.user) {
            res.status(401).json({ error: "User not found!" });
            return;
        }

        const user = await User.findOne({ id: req.user });

        res.json(user);
    } catch (e) {
        res.status(500).json(false);
    }
});

export default router