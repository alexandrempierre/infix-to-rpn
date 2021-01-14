%{
    #include <iostream>
    #include <map>
    #include <string>

    using namespace std;

    int token;
    int row = 1, current_column = 1, previous_column = 0;

    enum {
        tk_int=256, tk_float, tk_id, tk_string
    };

    map<int, string> token_names = {
        {tk_int, "número inteiro"},
        {tk_float, "número real"},
        {tk_id, "identificador"},
        {tk_string, "string"}
    };

    /* Operations with numbers */
    void Expr();
    void SumExpr();
    void PrecExpr(); // used to implement product precedence over additon
    void MulExpr();
    void Unary();

    /* Operations with strings */
    void StrExpr();
    void SumStrExpr();
    void StrUnary();

    void consume(int);

    void print(string);
    
    void error(string);

    string token_name( int );
%}

DIGIT       [0-9]
SIGN        [+\-]
ALPHABETIC  [A-Za-z_]

INT         {SIGN}?{DIGIT}+
ID          {ALPHABETIC}({ALPHABETIC}|{DIGIT})*

DECIMAL     \.{DIGIT}+
EXPONENT    [eE]{INT}
FLOAT       {INT}({DECIMAL}{EXPONENT}?|{EXPONENT})

STRING      \"(\\\"|\"\"|[^\"])*\"

%%

" "         { previous_column = current_column++; }
"\t"        { previous_column = current_column; current_column += 2; }
"\n"        { row++; previous_column = current_column; current_column = 1; }

"+"         { return '+'; }

{INT}       { return tk_int; }

{FLOAT}     { return tk_float; }

{STRING}    { return tk_string; }

{ID}        { return tk_id; }

.           { return yytext[0]; }

%%

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
        case tk_int : {
            string temp(yytext);
            consume(tk_int);
            printf("%s ", temp.c_str());
            break;
        }
        case tk_float : {
            string temp(yytext);
            consume(tk_float);
            printf("%s ", temp.c_str());
            break;
        }
        case tk_id : {
            string temp(yytext);
            consume(tk_id);
            printf("%s @ ", temp.c_str());
            break;
        }
        case '(' : {
            consume('(');
            Expr();
            consume(')');
            break;
        }
        default : {
            error("Encontrado token inesperado: " + token_name(token));
        }
    }
}

void StrExpr() {
    StrUnary();
    SumStrExpr();
}

void SumStrExpr() {
    if ( token == '+' ) {
        consume('+');
        StrExpr();
        printf("+ ");
        SumStrExpr();
    }
}

void StrUnary() {
    switch ( token ) {
        case tk_id : {
            string temp(yytext);
            consume(tk_id);
            printf("%s @ ", temp.c_str());
            break;
        }
        case tk_string : {
            string temp(yytext);
            consume(tk_string);
            printf("%s ", temp.c_str());
            break;
        }
        default : {
            error("Encontrado token inesperado: " + token_name(token));
        }
    }
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
       << "row: " << row << ", coluna: " << previous_column << endl
       << msg << endl;
  exit( 1 );
}

int main () {
    token = yylex();
    StrExpr();
    printf("\n");

    if ( token == 0 ) {
        cout << "Sintaxe ok!" << endl;
    }
    else {
        cout << "Caracteres encontrados após o fim do programa!" << endl;
    }

    return 0;
}