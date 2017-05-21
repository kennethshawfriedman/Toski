import React, { Component } from 'react';
 
import Cell from './Cell.jsx';
 
// App component - represents the whole app
export default class App extends Component {
  getCells() {
    return [
      { _id: 1, program: '(define x 3)\n(* x x)', output: '0'},
      { _id: 2, program: '(* 4 x)', output: '0'},
    ];
  }
 
  renderCells() {
    return this.getCells().map((cell) => (
      <Cell key={cell._id} cell={cell} />
    ));
  }
 
  render() {
    return (
      <div className="container">
        <header>
          <h1>Schemer</h1>
        </header>
 
        
        {this.renderCells()}
        
      </div>
    );
  }
}