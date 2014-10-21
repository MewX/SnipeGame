/**
 *  Shooting Game - Main
 **
 * Author: MewX
 * Date: 2014.10.21
 * Description: This is the game's main controler file.
 * Skills:
 *     Masks between vectors;
 *     Relative position on view port, reduce calc img size;
 *     Use 'switch' to manage multi game stage, each is dependent;
 *     ... ...
 **/

import java.lang.Math.*;
import ddf.minim.*;

// Define constances
final int SCREEN_WIDTH = 900;
final int SCREEN_HEIGHT = 600;
final int VIEWPORT_WIDTH = 300;
final int VIEWPORT_WIDTH_HALF = VIEWPORT_WIDTH / 2;
final int FONT_SIZE = 14;

// Define stages
final int STAGE_TEST = 0;
final int STAGE_MAIN = 1;
final int STAGE_LEVELSELECTE = 2;
final int STAGE_LEVEL1 = 3;

// Main stage's buttons
Button btnTest = new Button( "Exercise", 200, 50, 40, 15, SCREEN_WIDTH / 2, 300 );
Button btnLevelSelect = new Button( "Levels", 200, 50, 60, 15, SCREEN_WIDTH / 2, 380 );
Button btnExit = new Button( "Exit", 200, 50, 70, 15, SCREEN_WIDTH / 2, 460 );

// Define global variables
Minim minim;
AudioPlayer playerShoot;
PGraphics mask, viewPort;
Cursor cur;
HitMark hm;
PFont font;
float currentWindSpeed = -1.3; // [ - 3.0, 3.0 ]
float currentDistance = 1234; // [ 100, 1800 ]
int thingX, thingY, thingSize;
int currentStage;
int hitCount, missCount, totalScore, myScore;


/**
 *  Main funtions
 **/
void setup( )
{
  size( SCREEN_WIDTH, SCREEN_HEIGHT );
  noStroke( ); // no outline
  noCursor(); // hide cursor
  
  // Init view port related variables
  font = loadFont( "FreeMonoBold-48.vlw" );
  viewPort = createGraphics( VIEWPORT_WIDTH, VIEWPORT_WIDTH );
  mask = createGraphics( VIEWPORT_WIDTH, VIEWPORT_WIDTH );
  mask.beginDraw( );
  mask.smooth( ); // make the ellipse clear
  mask.background( 0 );//background color to target
  mask.fill( 255 );
  mask.ellipse( VIEWPORT_WIDTH_HALF, VIEWPORT_WIDTH_HALF, VIEWPORT_WIDTH, VIEWPORT_WIDTH );
  mask.endDraw( );
  
  // Init global vars
  minim = new Minim( this );
  playerShoot = minim.loadFile("shootcut.wav");
  cur = new Cursor( );
  hm = new HitMark( );
  currentStage = STAGE_MAIN;//STAGE_TEST;
  
  return;
}

void draw( )
{
  switch( currentStage ) {
    case STAGE_TEST:
      background( 0 );
      LoadTestStage( );
      break;
      
    case STAGE_MAIN:
      background( 0 );
      LoadMainStage( );
      hm.drawHitMark( );
      cur.drawCursor( true );
      break;
      
    case STAGE_LEVELSELECTE:
      background( 255 );
      LoadLevelStage( );
      hm.drawHitMark( );
      cur.drawCursor( false );
      break;
      
    default:
      break;
  }
  
  return;
}

void keyReleased( )
{
  if( key == '`' || key == '~' ) {
    switch( currentStage ) {
      case STAGE_TEST: currentStage = STAGE_MAIN; break;
      case STAGE_LEVELSELECTE: currentStage = STAGE_MAIN; break;
      default: break;
    }
  }
  return;
}

void mouseClicked( )
{
  // Play sound
  playerShoot.cue( 0 );
  playerShoot.play( ); 
  
  switch( currentStage ) {
    case STAGE_TEST:
      // Shoot it!
      hm.updateHitMark( (int)( mouseX + ( currentWindSpeed > 0 ? 1 : -1 ) * ( VIEWPORT_WIDTH_HALF - 30 ) / 3 * abs( currentWindSpeed ) ),
                        (int)( mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 1500.0 * currentDistance ) );
      int thisShootScore = judgeInCircle( (int)( mouseX + ( currentWindSpeed > 0 ? 1 : -1 ) * ( VIEWPORT_WIDTH_HALF - 30 ) / 3 * abs( currentWindSpeed ) ),
              (int)( mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 1500.0 * currentDistance ), thingX, thingY, thingSize );
      if( 10 - thisShootScore <= 0 ) missCount ++;
      else {
        hitCount ++;
        myScore += 10 - thisShootScore;
      }
      totalScore += 10;
      resetThing( );
      break;
      
    case STAGE_MAIN:
      if( btnTest.testMouseOn( ) ) {
        // Here init the game var
        hitCount = missCount = totalScore = myScore = 0;
        resetThing( );
        currentStage = STAGE_TEST;
      }
      else if( btnLevelSelect.testMouseOn( ) ) {
        currentStage = STAGE_LEVELSELECTE;
      }
      else if( btnExit.testMouseOn( ) ) {
        exit( );
      }
      else { hm.updateHitMark( mouseX, mouseY ); }
      break;
    
    case STAGE_LEVELSELECTE:
      currentStage = STAGE_MAIN;
      break;
    
    default:
      break;
  }
  
  return;
}


/**
 * Util draw functions
 **/
int getRandomBetween( int a, int b )
{
  randomSeed( (int)millis( ) );
  return (int)random( a, b );
}

int judgeInCircle( int mX, int mY, int cX, int cY, int cR ) {
  // if in the circle, return true; else return false
  return (int)sqrt( ( ( mX - cX ) * ( mX - cX ) + ( mY - cY ) * ( mY - cY ) * 1.0 ) - cR / 2 );
}

void resetThing( )
{
  currentWindSpeed = getRandomBetween( 0, 60 ) / 10.0 - 3.0;
  currentDistance = getRandomBetween( 100, 1800 );
  thingX = getRandomBetween( VIEWPORT_WIDTH_HALF, SCREEN_WIDTH - VIEWPORT_WIDTH_HALF );
  thingY = getRandomBetween( VIEWPORT_WIDTH, SCREEN_HEIGHT - 30 );
  thingSize = getRandomBetween( 8, 30 );
  
  return;
}

void drawViewPort( PGraphics vp )
{
  if( vp == null ) return; // bad input
  
  // Init values needed
  textFont( font, FONT_SIZE );
  fill( 0 );
  
  // Draw outline
  PImage img = vp.get( );
  img.mask( mask );
  imageMode( CORNER );
  image( img, mouseX - VIEWPORT_WIDTH_HALF, mouseY - VIEWPORT_WIDTH_HALF );
  
  
  // Draw cross line
  // If I put them into a PGraphic, then the text cannot be drawn!
  stroke( 0 );
  strokeWeight( 1 );
  color( 0, 0, 0 );
  line( mouseX - VIEWPORT_WIDTH_HALF, mouseY, mouseX + VIEWPORT_WIDTH_HALF, mouseY );
  line( mouseX, mouseY - VIEWPORT_WIDTH_HALF, mouseX, mouseY + VIEWPORT_WIDTH_HALF);
  
  // Draw distance marks and numbers
  line( mouseX - 10, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 3, mouseX + 10, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 3 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 1, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 1 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 2, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 2 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 3, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 3 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 4, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 4 );
  text( " 500m",  mouseX - 60, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 3 + FONT_SIZE / 2 );
  
  line( mouseX - 10, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) * 2 / 3, mouseX + 10, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) * 2 / 3 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 6, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 6 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 7, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 7 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 8, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 8 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 9, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 9 );
  text( "1000m",  mouseX - 60, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) * 2 / 3 + FONT_SIZE / 2 );
  
  line( mouseX - 10, mouseY + VIEWPORT_WIDTH_HALF - 30, mouseX + 10, mouseY + VIEWPORT_WIDTH_HALF - 30 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 11, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 11 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 12, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 12 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 13, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 13 );
  line( mouseX - 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 14, mouseX + 5, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 15 * 14 );
  text( "1500m",  mouseX - 60, mouseY + VIEWPORT_WIDTH_HALF - 30 + FONT_SIZE / 2 );
  
  // Draw wind speed marks and numbers
  line( mouseX - ( VIEWPORT_WIDTH_HALF - 30 ) / 3, mouseY - 10, mouseX - ( VIEWPORT_WIDTH_HALF - 30 ) / 3, mouseY );
  text( "1.0",  mouseX - ( VIEWPORT_WIDTH_HALF - 30 ) / 3 - FONT_SIZE, mouseY - FONT_SIZE );
  line( mouseX - ( VIEWPORT_WIDTH_HALF - 30 ) / 3 * 2, mouseY - 10, mouseX - ( VIEWPORT_WIDTH_HALF - 30 ) / 3 * 2, mouseY );
  text( "2.0",  mouseX - ( VIEWPORT_WIDTH_HALF - 30 ) / 3 * 2 - FONT_SIZE, mouseY - FONT_SIZE );
  line( mouseX - ( VIEWPORT_WIDTH_HALF - 30 ), mouseY - 10, mouseX - ( VIEWPORT_WIDTH_HALF - 30 ), mouseY );
  text( "3.0",  mouseX - ( VIEWPORT_WIDTH_HALF - 30 ) - FONT_SIZE, mouseY - FONT_SIZE );
  
  line( mouseX + ( VIEWPORT_WIDTH_HALF - 30 ) / 3, mouseY - 10, mouseX + ( VIEWPORT_WIDTH_HALF - 30 ) / 3, mouseY );
  text( "1.0",  mouseX + ( VIEWPORT_WIDTH_HALF - 30 ) / 3 - FONT_SIZE, mouseY - FONT_SIZE );
  line( mouseX + ( VIEWPORT_WIDTH_HALF - 30 ) / 3 * 2, mouseY - 10, mouseX + ( VIEWPORT_WIDTH_HALF - 30 ) / 3 * 2, mouseY );
  text( "2.0",  mouseX + ( VIEWPORT_WIDTH_HALF - 30 ) / 3 * 2 - FONT_SIZE, mouseY - FONT_SIZE );
  line( mouseX + ( VIEWPORT_WIDTH_HALF - 30 ), mouseY - 10, mouseX + ( VIEWPORT_WIDTH_HALF - 30 ), mouseY );
  text( "3.0",  mouseX + ( VIEWPORT_WIDTH_HALF - 30 ) - FONT_SIZE, mouseY - FONT_SIZE );
  
  
  // Draw Assist Line
  if( keyPressed && ( key == 'x' || key == 'X' ) ) {
    int direct = currentWindSpeed > 0 ? 1 : -1;
    
    stroke( 0, 0, 255 );
    line( mouseX + direct * ( VIEWPORT_WIDTH_HALF - 30 ) / 3 * abs( currentWindSpeed ), mouseY,
          mouseX + direct * ( VIEWPORT_WIDTH_HALF - 30 ) / 3 * abs( currentWindSpeed ), mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 1500.0 * currentDistance );
    line( mouseX, mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 1500.0 * currentDistance,
          mouseX + direct * ( VIEWPORT_WIDTH_HALF - 30 ) / 3 * abs( currentWindSpeed ), mouseY + ( VIEWPORT_WIDTH_HALF - 30 ) / 1500.0 * currentDistance );
  }
  
  // Last work
  fill( 0, 255, 255 );
  text( "~ Mission: Hit red circle ~", 10, height - 40 );
  text( "~ Press \'X\' to get hint ~", 10, height - 25 );
  text( "~ Press \'`/~\' to back to main menu ~", 10, height - 10 );
  
  fill( 255, 255, 0 );
  text( "Wind Speed: " + (int)abs(currentWindSpeed) + "." + (int)(abs(currentWindSpeed)*10) % 10 + " m/s ( " + ( currentWindSpeed > 0.0 ? "->" : "<-" ) + " )", 10, 20 );
  text( "Distance  : " + currentDistance + " m" , 10, 35 );
  
  textFont( font, 20 );
  text( "Hit : " + hitCount, SCREEN_WIDTH - 200, 30 );
  text( "Miss: " + missCount, SCREEN_WIDTH - 200, 50 );
  text( "Scr : " + myScore + " / " + totalScore, SCREEN_WIDTH - 200, 70 );
  
  // Draw hit mark
  hm.drawHitMark( );
  
  return;
}


/**
 * UI Classes
 **/
class Cursor {
  float rotationAngle;
  PGraphics p;
  boolean isCurrentWhite;
  
  final int CURSOR_SIZE = 100;
  final float ROTATE_SPEED = PI / 360.0 * 12;
  
  Cursor( ) {
    rotationAngle = 0.0;
    isCurrentWhite = true;
    
    // init cursor style
    p = createGraphics( CURSOR_SIZE, CURSOR_SIZE );
    initToWhite( );
    
    return;
  }
  
  private void initToWhite( ) {
    p.beginDraw( );
    p.background( 0, 0, 0, 0.0 );
    p.noStroke( );
    p.fill( 255 );
    p.triangle( CURSOR_SIZE / 2 - 5, 0, CURSOR_SIZE / 2 + 5, 0, CURSOR_SIZE / 2, CURSOR_SIZE / 2 - 10 );
    p.triangle( CURSOR_SIZE, CURSOR_SIZE / 2 - 5, CURSOR_SIZE, CURSOR_SIZE / 2 + 5, CURSOR_SIZE / 2 + 10, CURSOR_SIZE / 2 );
    p.triangle( CURSOR_SIZE / 2 - 5, CURSOR_SIZE, CURSOR_SIZE / 2 + 5, CURSOR_SIZE, CURSOR_SIZE / 2, CURSOR_SIZE / 2 + 10 );
    p.triangle( 0, CURSOR_SIZE / 2 - 5, 0, CURSOR_SIZE / 2 + 5, CURSOR_SIZE / 2 - 10, CURSOR_SIZE / 2 );
    p.noFill( );
    p.stroke( 255, 255, 255 );
    p.strokeWeight( 10 );
    p.ellipse( CURSOR_SIZE / 2, CURSOR_SIZE / 2, CURSOR_SIZE - 30, CURSOR_SIZE - 30 );
    p.endDraw( );
    return;
  }
  
  private void initToBlack( ) {
    p.beginDraw( );
    p.background( 0, 0, 0, 0.0 );
    p.noStroke( );
    p.fill( 0 );
    p.triangle( CURSOR_SIZE / 2 - 5, 0, CURSOR_SIZE / 2 + 5, 0, CURSOR_SIZE / 2, CURSOR_SIZE / 2 - 10 );
    p.triangle( CURSOR_SIZE, CURSOR_SIZE / 2 - 5, CURSOR_SIZE, CURSOR_SIZE / 2 + 5, CURSOR_SIZE / 2 + 10, CURSOR_SIZE / 2 );
    p.triangle( CURSOR_SIZE / 2 - 5, CURSOR_SIZE, CURSOR_SIZE / 2 + 5, CURSOR_SIZE, CURSOR_SIZE / 2, CURSOR_SIZE / 2 + 10 );
    p.triangle( 0, CURSOR_SIZE / 2 - 5, 0, CURSOR_SIZE / 2 + 5, CURSOR_SIZE / 2 - 10, CURSOR_SIZE / 2 );
    p.noFill( );
    p.stroke( 0, 0, 0 );
    p.strokeWeight( 10 );
    p.ellipse( CURSOR_SIZE / 2, CURSOR_SIZE / 2, CURSOR_SIZE - 30, CURSOR_SIZE - 30 );
    p.endDraw( );
    return;
  }
  
  private void initCursor( boolean isWhite ) {
    p.clear();
    if( isWhite ) initToWhite( );
    else initToBlack( );
    
    isCurrentWhite = isWhite; // save status
    return;
  }
  
  public void drawCursor( boolean isWhite ) {
    if( isWhite != isCurrentWhite ) initCursor( isWhite );
    
    // draw this rotate cursor
    //image( p, mouseX - CURSOR_SIZE / 2, mouseY - CURSOR_SIZE / 2 );
    imageMode( CENTER );
    translate( mouseX, mouseY );
    rotate( rotationAngle );
    image( p, 0, 0 );
    
    rotationAngle += ROTATE_SPEED;
    if( rotationAngle > PI * 10.0 ) rotationAngle -= PI * 10.0; // prevent overflow
    return;
  }
}

class Button {
  String t;
  int w, h, o_x, o_y, p_x, p_y; // o_* means the text showing offset
  
  Button( String txt, int size_w, int size_h, int off_x, int off_y, int pos_x, int pos_y ) {
    t = new String( txt );
    w = size_w;
    h = size_h;
    o_x = off_x; // calc from btn's bottom
    o_y = off_y; // calc from btn's bottom
    p_x = pos_x; // btn position x
    p_y = pos_y; // btn position y
    return;
  }
  
  public void drawButton( ) {
    if( testMouseOn( ) ) {
      // This stands the mouse is in the button area
      fill( 255 );
      stroke( 255 );
      strokeWeight( 4 );
      rect( p_x - w / 2, p_y - h / 2, w, h );
      fill( 0 );
    }
    else {
      // This button is in the common status
      noFill( );
      stroke( 255 );
      strokeWeight( 4 );
      rect( p_x - w / 2, p_y - h / 2, w, h );
      fill( 255 );
    }
    text( t, p_x - w / 2 + o_x, p_y + h / 2 - o_y );
    
    return;
  }
  
  public boolean testMouseOn( )
  {
    // Judge whether the mouse is on the button
    return p_x - w / 2 < mouseX && mouseX < p_x + w / 2 && p_y - h / 2 < mouseY && mouseY < p_y + h / 2;
  }
}

class HitMark {
  int lastX, lastY;
  
  HitMark( ) {
    lastX = -10;
    lastY = -10;
    return;
  }
  
  public void updateHitMark( int posX, int posY ) {
    lastX = posX;
    lastY = posY;
    return;
  }
  
  void drawHitMark( ) {
    stroke( 0, 255, 255 );
    strokeWeight( 1 );
    line( lastX - 5, lastY - 5, lastX + 5, lastY + 5 );
    line( lastX - 5, lastY + 5, lastX + 5, lastY - 5 );
    return;
  }
}


/**
 *  Stage function
 **/
void LoadMainStage( )
{
  
  textFont( font, 48 );
  fill( 255 );
  text( "~  Shoot Game!  ~", 200, 150 );
  
  textFont( font, 24 );
  text( "Author: MewX", 500, 180 );
  
  // Draw Buttons
  btnTest.drawButton( );
  btnLevelSelect.drawButton( );
  btnExit.drawButton( );
  
  return;
}

void LoadTestStage( )
{
  // Draw view port content
  viewPort.beginDraw( );
  viewPort.background( 255 );
  viewPort.stroke( 255 );
  viewPort.fill( 255, 0, 0 );
  viewPort.smooth( );
  viewPort.ellipse( thingX - mouseX + VIEWPORT_WIDTH_HALF, thingY - mouseY + VIEWPORT_WIDTH_HALF, thingSize, thingSize );
  viewPort.endDraw( );
  
  // Make masked image from vectors
  drawViewPort( viewPort );
  
  return;
}

void LoadLevelStage( )
{
  textFont( font, 36 );
  fill( 0 );
  text( "Sorry, this part has not finished...", 50, 150 );
  text( "But I designed:", 50, 250 );
  text( "    In this section, you CANNOT use", 50, 300 );
  textFont( font, 48 );
  text( "\"HINT\"", 400, 350 );
  textFont( font, 24 );
  text( "So, press \'`/~\' or just click to back to main menu.", 50, 500 );
  
  stroke( 0 );
  strokeWeight( 5 );
  line( 400 - 20, 350 - 15, 400 + 190, 350 - 15 );
  
  return;
}
