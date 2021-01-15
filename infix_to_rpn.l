%{
    #include <iostream>
    #include <map>
    #include <string>

    using namespace std;

    int token;
    int row = 1, current_column = 1, previous_column = 0;

    enum {
        tk_num=256, tk_id, tk_string, tk_print
    };

    map<int, string> token_names = {
        {tk_num,    "número"},
        {tk_id,     "identificador"},
        {tk_string, "string"},
        {tk_print,  "print"}
    };
    
    /* Grammar rules */
    void InitialNonTerminal();

    void Print();

    /* Attribution */
    void Attr();
    void Expr(); // General expression for either Numbers or Text

    /* Operations with numbers */
    void Expr();
    void SumExpr();
    void PrecExpr(); // used to implement product precedence over additon
    void MulExpr();
    void Unary();

    /* Function calls */
    void Name();
    void Call();
    void Params();
    void ParamList();

    /* Not grammar rules */
    void consume(int);
    
    void error(string);

    string token_name(int);
%}

DIGIT       [0-9]
SIGN        [+\-]
ALPHABETIC  [A-Za-z_]

INT         {DIGIT}+
ID          {ALPHABETIC}({ALPHABETIC}|{DIGIT})*

DECIMAL     \.{INT}
EXPONENT    [eE]{SIGN}?{INT}

NUMBER      {INT}{DECIMAL}?{EXPONENT}?

STRING      \"(\\\"|\"\"|[^\"])*\"

%%

" "         { previous_column = current_column++; }
"\t"        { previous_column = current_column; current_column += 2; }
"\n"        { row++; previous_column = current_column; current_column = 1; }

"print"     { return tk_print; }

{NUMBER}    { return tk_num; }

{STRING}    { return tk_string; }

{ID}        { return tk_id; }

.           { return yytext[0]; }

%%

void InitialNonTerminal() {
    switch ( token ) {
        case tk_print : {
            Print(); InitialNonTerminal();
            break;
        }
        case tk_id : {
            Attr(); InitialNonTerminal();
            break;
        }
    }
}

void Print() {
    consume(tk_print);
    
    Expr();
    printf("print # ");
    
    consume(';');
}

void Attr() {
    string temp(yytext);

    consume(tk_id);
    consume('=');
    printf("%s ", temp.c_str());
    
    Expr();
    printf("= ");

    consume(';');
}

void Expr() {
    PrecExpr();
    SumExpr();
}

void SumExpr() {
    switch ( token ){
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
    switch ( token ){
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

void Unary() {
    switch ( token ) {
        case '+' : 
        case '-' : {
            string sign(yytext);
            consume(token);
            printf("%s", sign.c_str());
        }
        case tk_num : {
            string temp(yytext);
            consume(tk_num);
            printf("%s ", temp.c_str());
            break;
        }
        case tk_id : {
            string temp(yytext);
            consume(tk_id);
            bool callable = token == '(';
            Call();
            printf("%s %c ", temp.c_str(), callable ? '#' : '@');
            break;
        }
        case tk_string : {
            string temp(yytext);
            consume(tk_string);
            printf("%s ", temp.c_str());
            break;
        }
        case '(' : {
            consume('(');
            Expr();
            consume(')');
            break;
        }
    }
}

void Call() {
    if ( token == '(' ) {
        consume('(');
        Params();
    }
}

void Params() {
    if ( token == ')' ) {
        consume(')');
    }
    else {
        Expr();
        ParamList();
    }
}

void ParamList() {
    if ( token == ',' ) {
        consume(',');
        Expr();
    }
    Params();
}

string token_name( int token ) {
    if( token_names.find( token ) != token_names.end() )
        return token_names[token];
    else {
        string r;
        r = (char) token;

        return "'" + r + "'";
    }
}

void consume (int expected_token) {
    if ( token == expected_token ) {
        token = yylex();
    }
    else {
        error("Esperado " + token_name(expected_token) + 
                ", encontrado " + token_name(token));
    }
}

void error( string msg ) {
    cout << "*** Erro: ***" << endl
        << "linha: " << row << ", coluna: " << previous_column << endl
        << msg << endl;
    exit( 1 );
}

int main () {
    token = yylex();
    InitialNonTerminal();
    printf("\n");

    if ( token == 0 ) {
        // cout << "Sintaxe ok" << endl;
    }
    else {
        cout << "Caracteres encontrados após o fim do programa!" << endl;
    }

    return 0;
}