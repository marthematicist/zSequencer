
class Metronome {
  boolean isOn;                // bool: outputting beats?
  boolean beatEstablished;     // has beat been established?
  float measureLength;             // measure length in ms
  float beatStartTime;         // time of beat start
  float beatEndTime;           // time measure will end
  float lastInputTime;          // time of last input
  float minNextInput;          // earliest time next input will be accepted (if beatEstablished)
  float maxNextInput;          // latest time next input will be accepted (if beatEstablished)
  float inputThreshold;        // portion of measureLength before and after next predicted beat where input is accepted
  float inputStringStartTime;
  int inputStringLength;       // number of inputs
  int beat;
  // constructor
  Metronome ( ) {
    this.isOn = true;
    this.beatEstablished = false;
    this.measureLength = 0;
    this.beatStartTime = 0;
    this.beatEndTime = 999999999;
    this.lastInputTime = 0;
    this.minNextInput = 0;
    this.maxNextInput = 999999999;
    this.inputThreshold = 0.4;
    this.inputStringStartTime = 0;
    this.inputStringLength = 0;
    this.beat = 0;
  }
  
  void evolve ( ) {
    float t = float( millis() );
    if( t > this.beatEndTime ) {
      this.beatStartTime = t;
      this.beatEndTime = this.beatStartTime + 0.25*this.measureLength;
      beatTriggered = true;
      this.beat++;
      this.beat %= 4;
      
    }
  }
  
  void triggerInput ( float t ) {
    // t is current time
    // if the beat is not yet established
    if( !this.beatEstablished ) {
      // if the input string is empty
      if( this.inputStringLength == 0 ) {
        println( "beat syn starting..." );
        // set inputStingStartTime
        this.inputStringStartTime = t;
        // increment inputStringLength
        inputStringLength++;
      } else if( this.inputStringLength == 1 ) {
        // else input string has 1 measure
        // calculate measureLength
        this.measureLength = ( t - this.inputStringStartTime ) / float( this.inputStringLength );
        // beat has been established
        this.beatEstablished = true;
        // sync the beat
        this.sync( t );
        // set threshold for next input
        this.minNextInput = t + this.measureLength*( 1 - this.inputThreshold );
        this.maxNextInput = t + this.measureLength*( 1 + this.inputThreshold );
        // increment inputStringLength  
        inputStringLength++;
        println( "Beat established" );
      }
    } else {
      // otherwise, beat has been established
      // if the current input time is within threshold...
      if( t > this.minNextInput && t < this.maxNextInput ) {
        // if beat number is a multiple of 4...
        if( (this.inputStringLength) <= 1 ) {
          // update measureLength
          this.measureLength = ( t - this.inputStringStartTime ) / float( this.inputStringLength ) * timingInputWeight1 + this.measureLength*(1 - timingInputWeight1);
          println( "updating measureLength" );
          println( this.measureLength );
          // sync the beat
          this.sync ( t );
        }
        if( (this.inputStringLength) > 1 ) {
          // update measureLength
          this.measureLength = ( t - this.inputStringStartTime ) / float( this.inputStringLength ) * timingInputWeight2 + this.measureLength*(1 - timingInputWeight2);
          println( "setting measureLength" );
          println( this.measureLength );
          // sync the beat
          this.sync ( t );
        } 
        
        // increment inputStringLength  
        inputStringLength++;
      } else {
        // otherwise current input time is out of threshold. 
        // reset the input string (this is first input)
        this.inputStringLength = 1;
        this.inputStringStartTime = t;
      }
      // set threshold for next input
      this.minNextInput = t + this.measureLength*( 1 - this.inputThreshold );
      this.maxNextInput = t + this.measureLength*( 1 + this.inputThreshold );
    }
    

  }
  
  // method to sync beat to current time
  void sync ( float t ) {
    // t is current time
    // set current input time as beatStartTime
      this.beatStartTime = t;
      // calculate predicted end time
      this.beatEndTime = t + 0.25*this.measureLength;
      beatTriggered = true;
      this.beat = 0;
  }
  
  // method to reset the metronome
  void reset ( ) {
    this.isOn = true;
    this.beatEstablished = false;
    this.lastInputTime = 0;
    this.minNextInput = 0;
    this.maxNextInput = 999999999;
    this.inputThreshold = 0.4;
    this.inputStringStartTime = 0;
    this.inputStringLength = 0;
  }
    
}