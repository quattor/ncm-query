object template load;

prefix "/level1";
"hello" = "level1";
"{/unescape/}" = "unescape";
"{/more/unescape/}/yeah" = "/more/unescape";

prefix "/level1/level2";
"string" = "string";
"long" = 10;
"boolean" = true;
"double" = 0.5;
"list" = list(1,2,3);
"nlist" = nlist("nlist", "ok");

"level3/hello" = "level3";
