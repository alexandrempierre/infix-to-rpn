%{
    #include <iostream>
    #include <map>
    #include <string>

    using namespace std;

    int token;
    int row = 1, current_column = 1, previous_column = 0;

    enum {
        tk_id = 256, tk_num
    };

    map<int, string> token_names = {
        { tk_id,  "function name" },
        { tk_num, "number" }
    };

    /* Grammar rules */

    // Expressions
    void Expr();
    void SumExpr();
    void PrecExpr();
    void MulExpr();
    void SignUnary();
    void Unary();

    // Functions
    void Call();
    void Params();
    void ParamsList();

    /* Not grammar rules */
    void consume(int);

    void error(string);

    string token_name(int);
%}

DIGIT           [0-9]
SIGN            [+\-]
ALPHABETIC      [A-Za-z_]

WHOLE           {DIGIT}+
IDENTIFIER      {ALPHABETIC}({ALPHABETIC}|{DIGIT})*

DECIMAL         \.{WHOLE}
EXPONENT        [eE]{SIGN}?{WHOLE}

NUMBER          {WHOLE}{DECIMAL}?{EXPONENT}?

%%

" "             { previous_column = current_column++; }
"\t"            {  }
"\n"            {  }

{NUMBER}        { return tk_num; }

{IDENTIFIER}    { return tk_id; }

.               { return yytext[0]; }

%%

/* Grammar rules */
void Expr() {
    PrecExpr();
    SumExpr();
}

void SumExpr() {
    switch ( token ) {
        case '+' : {
            consume('+');
            PrecExpr();
            printf("+ ");
            SumExpr();
            break;
        }
        case '-' : {
            consume('-');
            PrecExpr();
            printf("- ");
            SumExpr();
            break;
        }
    }
}

void PrecExpr() {
    Unary();
    MulExpr();
}

void MulExpr() {
    switch ( token ) {
        case '*' : {
            consume('*');
            Unary();
            printf("* ");
            MulExpr();
            break;
        }
        case '/' : {
            consume('/');
            Unary();
            printf("/ ");
            MulExpr();
            break;
        }
    }
}

void SignUnary() {
    switch ( token ) {
        case '+' : {
            consume('+');
            printf("+");
            Unary();
            break;
        }
        case '-' : {
            consume('-');
            printf("-");
            Unary();
            break;
        }
        default : {
            Unary();
        }
    }
}

void Unary() {
    switch (token) {
        case tk_num : {
            string temp(yytext);
            consume(tk_num);
            printf("%s ", temp.c_str());
            break;
        }
        case tk_id : {
            string temp(yytext);
            consume(tk_id);
            Call();
            printf("%s ", temp.c_str());
            break;
        }
        case '(' : {
            consume('(');
            Expr();
            consume(')');
            break;
        }
        default : {
            error("Expected number, function call or valid expression"
                ", found " + token_name(token));
        }
    }
}

void Call() {
    consume('(');
    Params();
}

void Params() {
    if ( token == ')' ) {
        consume(')');
    }
    else {
        Expr();
        ParamsList();
    }
}

void ParamsList() {
    if ( token == ',' ) {
        consume(',');
        printf(" ");
        Expr();
    }
    Params();
}

/* Not grammar rules */
void consume (int expected_token) {
    if ( token == expected_token ) {
        token = yylex();
    }
    else {
        error("Expected " + token_name(expected_token) + 
                ", found " + token_name(token));
    }
}

void error (string msg) {
    cout << "*** Error: ***" << endl
        << "row: " << row << ", column: " << previous_column << endl
        << msg << endl;
    exit( 1 );
}

string token_name (int token) {
    if( token_names.find( token ) != token_names.end() )
        return token_names[token];
    else {
        string r;
        r = (char) token;

        return "'" + r + "'";
    }
}

int main () {
    token = yylex();
    Expr();
    printf("\n");

    if ( token == 0 ) {
        cout << "Syntax ok" << endl;
    }
    else {
        cout << "Found characters after the end of the file!" << endl;
    }

    return 0;
}
