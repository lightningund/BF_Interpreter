import java.util.Arrays;

final boolean goFast = false;

final Character[] commands = {',', '.', '>', '<', '+', '-', '[', ']'};
final ArrayList<Character> comList = new ArrayList<Character>(Arrays.asList(commands));

int cellInd, progPos, steps = 0;
ArrayList<Integer> cells, callStack;
char[] program;

boolean loaded = false;

void setup() {
  //size(10, 10);
  size(500, 500);
  cellInd = 0;
  progPos = 0;
  cells = new ArrayList<Integer>();
  cells.add(0);
  cells.add(0);
  callStack = new ArrayList<Integer>();
  frameRate(60);
  selectInput("Select a program to load:", "loadProg");
}

void go() {
  noLoop();
  while(progPos < program.length) {

    //Shift the cells to create an 'infinite' array
    while(cellInd <= 0) {
      cellInd++;
      cells.add(cells.get(cells.size() - 1));
      for(int i = cells.size() - 2; i >= 0; i--) {
        cells.set(i + 1, cells.get(i));
      }
    }

    while(cellInd > cells.size() - 1) {
      cells.add(0);
    }

    step();
  }

  println();
  println(steps);

  exit();
}

void loadProg(File filename) {
  try {
    ArrayList<Character> tempP = new ArrayList<Character>();
    BufferedReader reader = createReader(filename);
    String line = null;

    try {
      line = reader.readLine();
      while(line != null) {
        for(char c : line.toCharArray()) {
          if(comList.contains(c)) {
            tempP.add(c);
          }
        }

        line = reader.readLine();
      }
    } catch(IOException e) {
      println("Error" + e);
    }

    program = new char[tempP.size()];

    for(int a = 0; a < tempP.size(); a ++) {
      program[a] = tempP.get(a);
    }

    println();
    loaded = true;

    if(goFast) go();
  } catch (Exception e) {
    exit();
  }
}

int findClosingBracket(int startingPoint) {
  int bracketCounter = 1;
  int checkingIndex = startingPoint + 1;

  while(bracketCounter != 0 && checkingIndex < program.length) {
    char progChar = program[checkingIndex];
    if(progChar == '[') {
      bracketCounter ++;
    } else if(progChar == ']') {
      bracketCounter --;
    }

    checkingIndex ++;
  }

  return checkingIndex - 1;
}

void step() {
  //Step Through the actual program
  char progChar = program[progPos];
  int currCellVal = cells.get(cellInd);
  //println(progChar, progPos);

  // Increment the number of steps taken so far in the program as long as it isn't a bracket
  if(progChar != '[' && progChar != ']') steps ++;

  switch (progChar) {
    case '.':
      print(char(currCellVal));
      break;
    case ',':
      break;
    case '>':
      cellInd++;
      break;
    case '<':
      cellInd --;
      break;
    case '+':
      currCellVal ++;
      cells.set(cellInd, currCellVal);
      break;
    case '-':
      currCellVal --;
      cells.set(cellInd, currCellVal);
      break;
    case '[':
      // If we can enter the loop, then add the starting bracket the to stack and keep moving
      if(currCellVal != 0) callStack.add(progPos);

      // Otherwise move ahead to the corresponding closing bracket, skipping over the loop
      else progPos = findClosingBracket(progPos);
      break;
    case ']':
      // It's the end of the loop and so we need to remove the starting bracket from the stack
      int prevBracket = callStack.remove(callStack.size() - 1);

      // Head to the bracket at the start of our current loop
      // We subtract 1 because we add one at the end
      progPos = prevBracket - 1;
      break;
  }

  progPos ++;
}

void draw() {
  if(loaded) {
    //Shift the cells to create an 'infinite' array
    while(cellInd <= 0) {
      cellInd ++;
      cells.add(cells.get(cells.size() - 1));
      for(int i = cells.size() - 2; i >= 0; i --) {
        cells.set(i + 1, cells.get(i));
      }
    }

    while(cellInd > cells.size() - 1) {
      cells.add(0);
    }

    //Drawing
    push();
    rectMode(CORNER);
    background(128);
    stroke(0);
    strokeWeight(3);
    fill(200);
    rect(width / 3, 10, width / 3, height - 20);
    pop();

    push();
    translate(width / 2, height / 2);
    rectMode(CENTER);
    textFont(createFont("Consolas", 30));
    textAlign(CENTER, CENTER);

    for(int i = -2; i < 3; i ++) {
      if(cellInd + i < 0 || cellInd + i > cells.size() - 1) {
        continue;
      }

      fill(0, 200, 200);
      rect(i * width / 5, 0, width / 5, height / 10);
      fill(0);
      text(cells.get(cellInd + i), i * width / 5, 0);
      text(cellInd + i, i * width / 5, 50);
    }
    pop();

    if(progPos < program.length) {
      step();
    } else {
      println();
      println(steps);
      exit();
    }
  }
}

void mouseClicked() {
  draw();
}
