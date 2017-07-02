/* TODO"
 * - Be able to read config file for running in smaller parts (or infer current progress)
 * - Reduce the output by removing symmetries (hz-f, v-f, r90, r180, r270?, combinations?)
 */

import std.stdio;

// Default if not otherwise set
enum GRID_SIZE = 25;

// Used to determine valid previous states in the grid.
// This table if populated by fillTbl.
bool[9][] lookupTbl;

void main(string[] args) {
    fillTbl();

    Grid g;
    if (args.length > 1) {
        writeln("Reading from file: ", args[1]);
        g = readGrid(args[1]);
    } else {
        writeln("Starting from scratch.");

        g = Grid(GRID_SIZE);
        g[] = CellState.UNKNOWN;

        // // 101
        // // 101
        // // 101
        // g[$/2-1..$/2+2, $/2-1] = CellState.ALIVE;
        // g[$/2-1..$/2+2, $/2]   = CellState.DEAD;
        // g[$/2-1..$/2+2, $/2+1] = CellState.ALIVE;

        // 111
        // 000
        // 111
        g[$/2-1, $/2-1..$/2+2] = CellState.ALIVE;
        g[$/2,   $/2-1..$/2+2] = CellState.DEAD;
        g[$/2+1, $/2-1..$/2+2] = CellState.ALIVE;
    }

    writeln(g);
    writeln;
    stepback(g);
}

/// Represents the states that a cell can be in
enum CellState {
    DEAD,
    ALIVE,
    UNKNOWN,
}

/// Represents a grid for GoL.
struct Grid {
    private:

    size_t height, width;
    size_t gridSize, groupSize;
    CellState[] gridArr;

    public:

    /// Shortcut for creating a square grid
    this(size_t size) {
        this(size, size);
    }

    /// Create a new grid with the specified height and width
    this(size_t height, size_t width) {
        this.height = height;
        this.width = width;

        this.gridArr.length = height * width;
    }

    /// Postblit constructor
    this(this) {
        // Make sure that changes from making a copy of a grid are not visible
        gridArr = gridArr.dup;
    }

    /// Get the height of the grid
    size_t getHeight() const {
        return this.height;
    }

    /// Get the width of the grid
    size_t getWidth() const {
        return this.width;
    }

    /// Get the index of the last element.
    @property int opDollar(size_t DIM)() const
    if (DIM >= 0 && DIM < 2) {
        static if (0 == DIM) return this.height;
        else return this.width;
    }

    /// Allow for slicing rows
    int[2] opSlice(size_t DIM : 0)(int start, int end) const
    in {
        import std.exception;
        enforce(start>=0 && start<this.height, "The start index is invalid");
        enforce(end>=0 && end<this.height, "The end index is invalid");
    } body {
        return [start, end];
    }

    /// Allow for slicing columns
    int[2] opSlice(size_t DIM : 1)(int start, int end) const
    in {
        import std.exception;
        enforce(start>=0 && start<this.width, "The start index is invalid");
        enforce(end>=0 && end<this.width, "The end index is invalid");
    } body {
        return [start, end];
    }

    /// Get the cell at the specified coordinates
    CellState opIndex(int y, int x) const {
        if (y < 0 || y >= this.height
         || x < 0 || x >= this.width) {
            return CellState.DEAD;
        }
        int idx = x + this.width * y;
        return gridArr[idx];
    }

    /// Overwrite all cells with the specified state
    void opIndexAssign(CellState state) {
        foreach(ref cell; gridArr) {
            cell = state;
        }
    }

    /// Overwrite a single cell with the specified state
    void opIndexAssign(CellState state, int y, int x) {
        if (CellState.DEAD == state) {
            if (x < 0 || x >= this.width) {
                // Do nothing
                return;
            }
            if (y < 0 || y >= this.height) {
                // Do nothing
                return;
            }
        } else {
            import std.exception;
            enforce(y>=0 && y<this.height, "The y-coordinate is invalid");
            enforce(x>=0 && x<this.width, "The x-coordinate is invalid");
        }

        int idx = x + this.width * y;
        gridArr[idx] = state;
    }

    /// General implementation for assigning to a slice of the grid
    void opIndexAssign(CellState state, int[2] ys, int[2] xs)
    in {
        import std.exception;
        assert(ys[0] <= ys[1]);
        enforce(ys[0]>=0 && ys[1]<this.height, "The y-coordinates are invalid");
        assert(xs[0] <= xs[1]);
        enforce(xs[0]>=0 && xs[1]<this.width, "The x-coordinates are invalid");
    } body {
        foreach (y; ys[0]..ys[1]) {
            foreach (x; xs[0]..xs[1]) {
                opIndexAssign(state, y, x);
            }
        }
    }
    /// Row slicing
    auto opIndexAssign(CellState state, int[2] ys, int x) {
        int[2] xs = [x, x+1];
        return opIndexAssign(state, ys, xs);
    }
    /// Column slicing
    auto opIndexAssign(CellState state, int y, int[2] xs) {
        int[2] ys = [y, y+1];
        return opIndexAssign(state, ys, xs);
    }

/*
    // This code create a range that expresses successive generations of GoL

    /// Is the grid empty
    enum empty = false;

    /// What does the current grid look like
    Grid front() {
        return this;
    }

    /// Advance the grid to the next generation
    void popFront() {
        bool isAlive(int y, int x) {
            if (y < 0 || y >= this.height) return false;
            if (x < 0 || x >= this.width) return false;
            return CellState.ALIVE == opIndex(y, x);
        }

        Grid h = Grid(this.height, this.width);
        foreach(y; 0..this.height) {
            foreach(x; 0..this.width) {
                int neighbors;
                if (isAlive(y-1,x-1)) ++neighbors;
                if (isAlive(y-1,x))   ++neighbors;
                if (isAlive(y-1,x+1)) ++neighbors;
                if (isAlive(y,  x-1)) ++neighbors;
                if (isAlive(y,  x+1)) ++neighbors;
                if (isAlive(y+1,x-1)) ++neighbors;
                if (isAlive(y+1,x))   ++neighbors;
                if (isAlive(y+1,x+1)) ++neighbors;

                final switch(opIndex(y, x)) {
                    case CellState.DEAD, CellState.UNKNOWN:
                        if (3 == neighbors) h[y, x] = CellState.ALIVE;
                        else h[y, x] = CellState.DEAD;
                        break;

                    case CellState.ALIVE:
                        if (2 > neighbors || neighbors > 3) h[y, x] = CellState.DEAD;
                        else h[y, x] = CellState.ALIVE;
                        break;
                }
            }
        }
        this.gridArr = h.gridArr;
    }
*/
    int countLiveCells() const {
        int cnt;
        foreach(cell; this.gridArr) {
            if (CellState.ALIVE == cell) {
                ++cnt;
            }
        }
        return cnt;
    }

    /// Format and write to the sink according to the specified format
    void toString(CHAR)(scope void delegate(const(CHAR)[]) sink, FormatSpec!CHAR fmt) const {
        if ('s' == fmt.spec) {
            toString(sink);
        }
        throw new Exception("Unknown format specifier: " + fmt.spec);
    }

    /// Format and write to the sink
    void toString(CHAR)(scope void delegate(const(CHAR)[]) sink) const {
        import std.format;

        void printCellState(CellState cs) {
            final switch(cs) with (CellState) {
                case UNKNOWN:
                    sink("*");
                    break;
                case ALIVE:
                    sink("1");
                    break;
                case DEAD:
                    sink("0");
                    break;
            }
        }

        int row, col;
        void formatCell(CellState cs) {
            printCellState(cs);
            if (++col >= this.width) {
                col = 0;
                if (++row < this.height) {
                    sink("\n");
                }
            }
        }

        auto sSpec = singleSpec("%s");
        formatValue(sink, this.height, sSpec);
        sink(" ");
        formatValue(sink, this.width, sSpec);
        sink("\n");
        foreach(cell; gridArr) {
            formatCell(cell);
        }
    }
}

/// Interface allowing for stateful sinks for grids
interface GridSink {
    void sink(const ref Grid);
}

/// Sink that writes a grid to standard output
class StdoutSink : GridSink {
    void sink(const ref Grid g) {
        writeln(g);
    }
}

/// Sink that writes grids to a specific directory, and a seperate file for each grid written.
class FileSink : GridSink {
    private string folder;
    private int suffix;

    this(string folder) {
        this.folder = folder;
    }

    void sink(const ref Grid g) {
        import std.file;
        import std.format;

        if (!exists(folder)) {
            mkdir(folder);
        }

        auto filename = format!"%s/grid_%04d.txt"(folder, ++suffix);
        auto sout = File(filename, "w");

        sout.writeln(g);
    }
}

/// Determine if a bit is set
bool bitTest(int num, size_t pos) {
    return (num & (1 << pos)) > 0;
}

/// bitTest unittests
unittest {
    assert(!bitTest(0,0));
    assert(bitTest(1,0));

    assert(!bitTest(1,1));
    assert(bitTest(2,1));
}

/// Reads a grid configuration
Grid readGrid(string filename) {
    import std.exception;
    import std.file;
    import std.format;
    import std.string;
    enforce(exists(filename), "Could not find the specified file");

    auto src = File(filename, "r");
    int height, width;

    string leader = src.readln();
    leader.formattedRead!"%s %s"(height, width);

    Grid g = Grid(height, width);
    foreach(row; 0..height) {
        auto line = chomp(src.readln);
        foreach (col, ch; line) {
            switch(ch) {
                case '0':
                    g[row, col] = CellState.DEAD;
                    break;
                case '1':
                    g[row, col] = CellState.ALIVE;
                    break;
                default:
                    g[row, col] = CellState.UNKNOWN;
                    break;
            }
        }
    }

    return g;
}

/// Write all possible previous states to the provided grid
void stepback(Grid g) {
    Grid p = Grid(g.getHeight, g.getWidth);
    p[] = CellState.UNKNOWN;
    p[$/2-1..$/2+2,$/2-1..$/2+2] = CellState.DEAD;

    // GridSink gs = new StdoutSink();
    GridSink gs = new FileSink("gen.00");
    stepbackImpl(g, p, 0, 0, gs);
}

/// Write to the sink all grids that could have preceeded g. The parameter q is a partial (or complete) solution
/// that has been assembled to this point
void stepbackImpl(const ref Grid g, ref Grid q, int row, int col, GridSink gs) {
    foreach(int i; row..g.height) {
        foreach(int j; col..g.width) {
            if (CellState.ALIVE == g[i,j]) {
                foreach (k,entry; lookupTbl) {
                    if (eq(q[i-1,j-1], entry[0]) && eq(q[i-1,j], entry[1]) && eq(q[i-1,j+1], entry[2])
                     && eq(q[i,  j-1], entry[3]) && eq(q[i,  j], entry[4]) && eq(q[i,  j+1], entry[5])
                     && eq(q[i+1,j-1], entry[6]) && eq(q[i+1,j], entry[7]) && eq(q[i+1,j+1], entry[8])) {
                        Grid temp = q;

                        setNeighbor(temp, i-1, j-1, entry[0]);
                        setNeighbor(temp, i-1, j,   entry[1]);
                        setNeighbor(temp, i-1, j+1, entry[2]);

                        setNeighbor(temp, i,   j-1, entry[3]);
                        setNeighbor(temp, i,   j,   entry[4]);
                        setNeighbor(temp, i,   j+1, entry[5]);

                        setNeighbor(temp, i+1, j-1, entry[6]);
                        setNeighbor(temp, i+1, j,   entry[7]);
                        setNeighbor(temp, i+1, j+1, entry[8]);

                        stepbackImpl(g, temp, i, j + 1, gs);
                    }
                }

                // Bail out since we have now done all variations on the parent grid
                return;
            }
        }

        // Forcably reset the initial column position os that the solution space is properly traversed
        // May want to figure out a better traversal method.
        col = 0;
    }

    // No more live cells have been observed
    // Write the changes that have been made to q in the previous stack frame
    gs.sink(q);
}

/// Construct a lookup table for what neigbors previously allow for a live cell now
void fillTbl() {
    import core.bitop;
    foreach(num; 0..256) {
        auto cnt = popcnt(num);

        debug auto base = ((num & 0xF0) << 1) | (num & 0x0F);
        // 2,3 to keep a live cell alive
        // 3 to bring a dead cell to life
        if (cnt == 2) {
            debug writefln("%08b | %09b", num, base | 0x10);
            lookupTbl ~= [
                bitTest(num, 7), bitTest(num, 6), bitTest(num, 5), bitTest(num, 4),
                true,
                bitTest(num, 3), bitTest(num, 2), bitTest(num, 1), bitTest(num, 0)
            ];
        } else if (cnt == 3) {
            debug writefln("%08b | %09b", num, base);
            lookupTbl ~= [
                bitTest(num, 7), bitTest(num, 6), bitTest(num, 5), bitTest(num, 4),
                false,
                bitTest(num, 3), bitTest(num, 2), bitTest(num, 1), bitTest(num, 0)
            ];
            debug writefln("%08b | %09b", num, base | 0x10);
            lookupTbl ~= [
                bitTest(num, 7), bitTest(num, 6), bitTest(num, 5), bitTest(num, 4),
                true,
                bitTest(num, 3), bitTest(num, 2), bitTest(num, 1), bitTest(num, 0)
            ];
        }
    }
}

/// Determine if a cell state can be equal to a boolean (alive or dead)
bool eq(CellState a, bool b) {
    return  (b && CellState.DEAD != a)
        || (!b && CellState.ALIVE != a);
}

/// Alter a grid at the specifying coordinates
void setNeighbor(ref Grid g, int row, int col, bool value) {
    if (value) {
        g[row,col] = CellState.ALIVE;
    } else {
        g[row,col] = CellState.DEAD;
    }
}
