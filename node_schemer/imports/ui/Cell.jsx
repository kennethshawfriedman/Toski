import React, { Component, PropTypes } from 'react';
var BiwaScheme = require("biwascheme");
 
// Task component - represents a single todo item
export default class Cell extends Component {
  constructor(props) {
  	super(props);
  	this.state = {
  		program: props.cell.program,
  		output: BiwaScheme.run(props.cell.program),
  	};
  	this.run();
  }

  render() {
    return (
      <div className="cell">
        <textarea className="program" defaultValue={this.state.program} onChange={this.setProgram.bind(this)}></textarea>
        <div className="output">{this.state.output}</div>
        <input className="run" value="Run" type="button" onClick={this.run.bind(this)} />
      </div>
    );
  }

  run() {
  	this.setState({
  		program: this.state.program,
  		output: BiwaScheme.run(this.state.program),
  	})
  }

  setProgram(event) {
  	this.setState({
  		program: event.target.value,
  		output: this.state.output,
  	});
  }
}
 
Cell.propTypes = {
  // This component gets the text to display through a React prop.
  // We can use propTypes to indicate it is required
  program: PropTypes.object.isRequired,
  output: PropTypes.object.isRequired,
};