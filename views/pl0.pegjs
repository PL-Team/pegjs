/*
 * Classic example grammar, which recognizes simple arithmetic expressions like
 * "2*(3+4)". The parser generated from this grammar then AST.
 */

{
  var tree = function(f, r) {
    if (r.length > 0) {
      var last = r.pop();
      var result = {
        type:  last[0],
        left: tree(f, r),
        right: last[1]
      };
    }
    else {
      var result = f;
    }
    return result;
  }
}

//Programa

//conjunto de bloques acabado en .
blocks = b:block POINT { return b; }

//conjunto de posible constantes y variables , seguido de procedimientos y sentencias
block   =   cons:(consts)? vari:(varias)? proc:(procedure)* s:statement {
			var str = [];
			if(cons) str = str.concat(cons);
			if(vari) str = str.concat(vari);
			if(proc) str = str.concat(proc);
			return str.concat([s]);
	    }

//posibles sentencias
statement   = i:ID ASSIGN e:expression { return {type: '=', left: i, right: e}; }
            / CALL i:ID argumentos:stArg? { return argumentos? {type: "CALL", arguments: argumentos, value: i} : {type: "CALL", value: i}; }
            / BEGIN s1:statement s2:(POINTCOMA s:statement {return s;})* END  { return {type: "BEGIN", value: [s1].concat(s2)};}
            / IF c:condition THEN st_true:statement ELSE st_false:statement   { return {type: "IFELSE", condition: c, true_statement: st_true, false_statement: st_false}; }
            / IF c:condition THEN s:statement  { return {type: "IF", condition: c, statement: s}; }
            / WHILE c:condition DO s:statement { return {type: "WHILE", condition: c, statement: s}; }

            
//RULES

consts               = c1:consta c2:const_plus* POINTCOMA {return [c1].concat(c2); }

consta        = CONST i:ID ASSIGN n:NUM { return {type: "CONST", left: i, right: n}; }

const_plus        = COMMA i:ID ASSIGN n:NUM { return {type: "CONST", left: i, right: n}; }

varias               = c1:varia c2:varia_plus* POINTCOMA {return [c1].concat(c2); }

varia        = VAR i:ID { return {type: "VAR", value: i}; }

varia_plus        = COMMA i:ID { return {type: "VAR", value: i}; }

procedure               = PROCEDURE i:PROC_ID arg:block_proc_parameters? POINTCOMA b:block POINTCOMA {return arg != null? {type: "PROCEDURE", value: i, parameters: arg, block: b} :{type: "PROCEDURE", value: i, block: b }; }

block_proc_parameters    = LEFTPAR i:(i1:ID i2:( COMMA i:ID {return{type:"VAR", value:i;}} )* {return [i1].concat(i2)})? RIGHTPAR {return i};

stArg    = LEFTPAR i:(i1:(ID/NUM) i2:( COMMA i:(ID/NUM) {return i;} )* {return [i1].concat(i2)})? RIGHTPAR {return i};

condition   = ODD e:expression                          { return {type: "ODD", value: e}; }
            / e1:expression op:COMPARISON e2:expression { return {type: op, left: e1, right: e2}; }

expression  = t:(p:ADD? t:term {return p?{type: p, value: t} : t;})   r:(ADD term)* { return tree(t, r); }

factor      = NUM
            / ID
            / LEFTPAR t:expression RIGHTPAR   { return t; }
term        = f:factor r:(MUL factor)* { return tree(f,r); }

_           = $[ \t\n\r]*

CALL      = _"CALL"_

CONST     = _"CONST"_

PROCEDURE = _"PROCEDURE"_

VAR       = _"VAR"_

BEGIN     = _"BEGIN"_

END       = _"END"_

WHILE     = _"WHILE"_

DO        = _"DO"_

ODD       = _"ODD"_

COMMA     = _","_

POINTCOMA = _";"_

POINT       = _"."_

COMPARISON = _ op:$([=<>!]'='/[<>])_  { return op; }

ASSIGN    = _ op:'=' _  { return op; }

ADD       = _ op:[+-] _ { return op; }

MUL       = _ op:[*/] _ { return op; }

ID	  = _ id:$([a-zA-Z_][a-zA-Z_0-9]*) _ { return id; }

PROC_ID   = _ id:ID  { return { type: 'PROCEDURE ID', value: id }; }

IDENT        = _ id:ID  { return { type: 'ID', value: id }; }

LEFTPAR   = _"("_

RIGHTPAR  = _")"_

IF        = _"IF"_

THEN      = _"THEN"_

ELSE      = _"ELSE"_

NUM       = _ digits:$[0-9]+ _              { return { type: 'NUM', value: parseInt(digits, 10) }; }