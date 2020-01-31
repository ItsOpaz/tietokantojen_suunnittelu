import React from 'react';
import './App.css';

import { Route, Link } from 'react-router-dom'
import Login from './Login';
import Home from './Home';
import Laskutus from './Laskutus';
import Mainoskampanjat from './Mainoskampanjat';
import Mainosesitysraportit from './Mainosesitysraportit';
import Mainostajatiedot from './Mainostajatiedot';
import Kuukausiraportit from './Kuukausiraportit';

function App() {
  return (
    <div className="App">
      <Route exact path="/" component={Home} />
      <Route exact path="/login" component={Login} />
      <Route exact path="/laskutus" component={Laskutus} />
      <Route exact path="/mainoskampanjat" component={Mainoskampanjat} />
      <Route exact path="/mainosesitysraportit" component={Mainosesitysraportit} />
      <Route exact path="/mainostajatiedot" component={Mainostajatiedot} />
      <Route exact path="/kuukausiraportit" component={Kuukausiraportit} />
    </div>
  );
}

export default App;
