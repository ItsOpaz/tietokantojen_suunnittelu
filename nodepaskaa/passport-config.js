
const LocalStrategy = require('passport-local').Strategy

function initPassport(passport, getUserById) {

    const authenticateUser = (username, password, done) => {
        const user = getUserById(username)
        console.log(user)


        if (user == null) {
            return done(null, false, { message: "No user found" })
        } else {
            console.log('perkele');

        }

        try {
            if (user.password == password) {
                return done(null, user)
            } else {
                return done(null, false, { message: "Password incorrect" })
            }
        } catch (e) {
            return done(e)
        }
    }

    passport.use(new LocalStrategy({ usernameField: 'text' }, authenticateUser))

    passport.serializeUser((user, done) => {
        return done(null, user.id)
    })
    passport.deserializeUser((id, done) => {
        return done(null, getUserById(id))
    })
}

module.exports = initPassport