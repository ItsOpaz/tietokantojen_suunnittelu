import React, { useState } from 'react'
import { Redirect } from 'react-router-dom'




const Login = (props) => {
    const [redirect, setRedirect] = useState(false)
    const [errmsg, setErrmsg] = useState("")

    const [kayttajatunnus, setKayttajatunnus] = useState("")
    const [salasana, setSalasana] = useState("")

    const handleSignIn = (event) => {
        event.preventDefault()

        setErrmsg("JOkin meni vikaan...")
        console.log(event)
        setRedirect(true)
    }

    const renderRedirect = () => {
        if (redirect) {
            return <Redirect to='/' />
        }
    }

    return (
        <div className="login">
            <h3>IFLAC</h3>

            <h5>Kirjaudu</h5>

            <form onSubmit={handleSignIn}>

                <input type="text" name={kayttajatunnus} onChange={} placeholder="Käyttäjätunnus" />
                <input type="text" name={salasana} placeholder="Salasana" />
                <input type="submit" value="Kirjaudu"></input>
            </form>

            <h4>{errmsg}</h4>
            {renderRedirect()}

        </div>
    )
}

export default Login

