import React from 'react';
import './App.css';

import { Route, Link } from 'react-router-dom'
import Login from './Login';
import Home from './Home';

function App() {
  return (
    <div className="App">
      <Route exact path="/" component={Home} />
      <Route exact path="/login" component={Login} />
    </div>
  );
}

export default App;
