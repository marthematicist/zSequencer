
class Metronome {
  boolean isOn;                // bool: outputting beats?
  boolean beatEstablished;     // has beat been established?
  boolean newBeatReady;
  float measureLength;             // measure length in ms
  RollingAverageInt RA;        // rolling average object
  float beatStartTime;         // time of beat start
  float beatEndTime;           // time measure will end
  int lastInputTime;         // time of last input
  float minNextInput;          // earliest time next input will be accepted (if beatEstablished)
  float maxNextInput;          // latest time next input will be accepted (if beatEstablished)
  float inputThreshold;        // portion of measureLength before and after next predicted beat where input is accepted
  int inputStringLength;       // number of inputs
  int beat;
  // constructor
  Metronome ( ) {
    this.isOn = true;
    this.beatEstablished = false;
    this.newBeatReady = false;
    this.measureLength = 0;
    this.RA = new RollingAverageInt( RAnum );
    this.beatStartTime = 0;
    this.beatEndTime = 9999999.0;
    this.lastInputTime = 0;
    this.minNextInput = 0;
    this.maxNextInput = 999999999.0;
    this.inputThreshold = 0.4;
    this.inputStringLength = 0;
    this.beat = 0;
  }
  
  void evolve ( ) {
    float t = float( millis() );
    if( this.beatEstablished && t > this.beatEndTime ) {
      this.beatStartTime = this.beatEndTime;
      this.beatEndTime = this.beatStartTime + 0.25*this.measureLength;
      beatTriggered = true;
      this.beat++;
      this.beat %= 4;
    }
  }
  
  void triggerInput ( int t ) {
    // t is current time
    // if the beat is not yet established
    if( !this.beatEstablished || !this.newBeatReady ) {
      // if the input string is empty
      if( this.inputStringLength == 0 ) {
        println( "beat sync starting..." );
      } else {
        // else input string has 1 measure
        // include measure length in rolling average
        this.RA.addEntry( t - this.lastInputTime );
        // compute measure length
        this.measureLength = this.RA.ravg();
        // beat has been established
        this.beatEstablished = true;
        this.newBeatReady = true;
        // sync the beat
        this.sync( t );
        // set threshold for next input
        this.minNextInput = t + this.measureLength*( 1 - this.inputThreshold );
        this.maxNextInput = t + this.measureLength*( 1 + this.inputThreshold );
        println( "Beat established. BMP = " + 60000/(this.measureLength*0.25) );
      }
      // increment inputStringLength
      inputStringLength++;
    } else {
      // otherwise, beat has been established
      // if the current input time is within threshold...
      if( t > this.minNextInput && t < this.maxNextInput ) {
        // include measure length in rolling average
        this.RA.addEntry( t - this.lastInputTime );
        // compute measure length
        this.measureLength = this.RA.ravg();
        println( "Beat modified.  BMP = " + 60000/(this.measureLength*0.25) + " ; num data points: " + this.RA.N );
        // increment inputStringLength  
        inputStringLength++;
      } else {
        // otherwise current input time is out of threshold. 
        // reset the input string (this is first input)
        this.inputStringLength = 1;
      }
      // set threshold for next input
      this.minNextInput = t + this.measureLength*( 1 - this.inputThreshold );
      this.maxNextInput = t + this.measureLength*( 1 + this.inputThreshold );
    }
    // set lastInputTime
    this.lastInputTime = t;
  }
  
  // method to sync beat to current time
  void sync ( int t ) {
    // t is current time
    // set current input time as beatStartTime
      this.beatStartTime = float( t );
      // calculate predicted end time
      this.beatEndTime = t + 0.25*this.measureLength;
      beatTriggered = true;
      this.beat = 0;
  }
  
  // method to reset the metronome
  void reset ( ) {
    this.isOn = true;
    this.newBeatReady = false;
    this.RA = new RollingAverageInt( RAnum );
    this.lastInputTime = 0;
    this.minNextInput = 0;
    this.maxNextInput = 999999999;
    this.inputStringLength = 0;
    this.beat = 0;
  }
}

// maintains a rolling average of integer numbers
class RollingAverageInt {
  int N;         // number of entries
  int maxN;      // max number of entries
  IntList x;     // list of entries
  int s;         // sum of all entries
  
  RollingAverageInt ( int maxNin ) {
    this.maxN = maxNin;
    this.N = 0;
    this.x = new IntList();
    this.s = 0;
  }
  // method to include a new entry
  void addEntry( int xin ) {
    // append to x
    this.x.append( xin );
    this.N++;
    this.s += xin;
    // if there are too many entries, remove the oldest
    if( this.N > this.maxN ) {
      this.s -= x.remove( 0 );
      this.N--;
    }
  }
  // method to compute the rolling average
  float ravg () {
    return float( this.s ) / float( this.N );
    
  }
  
}