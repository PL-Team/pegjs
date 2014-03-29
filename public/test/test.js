var assert = chai.assert;

suite('Tests', function(){

  test('Resta', function(){
    obj = pl0.parse("a = 1-3-5 .")
    assert.equal(obj[0].right.left.type, "-") 
  });
  test('Darling Else', function(){
    obj = pl0.parse('IF a == 3  THEN IF b == 3 THEN b=2 ELSE b = 3 .')
    assert.equal(obj[0].condition.type, "==")
  });


  test('block', function(){
    obj = pl0.parse("CONST a = 3; VAR b; PROCEDURE p; a = a + 3; CALL p.")
    assert.equal(obj[0].right.type, "NUM")
    assert.equal(obj[1].type, "VAR")
    assert.equal(obj[2].type, "PROCEDURE")
  });

  test('PROCEDURE con argumentos', function(){
    obj = pl0.parse("VAR x, squ; PROCEDURE square(a,b,c); BEGIN squ = x*x END; CALL a. ")
    assert.equal(obj[2].parameters[0].value, "a")
  });

  test ('PROCEDURE sin argumentos', function(){
    obj = pl0.parse("VAR x, squ; PROCEDURE square; BEGIN squ = x * x END; CALL a.")
    assert.equal(obj[3].arguments, undefined)
  });

});
