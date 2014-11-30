object template load;

prefix "/level0";
"hello" = "level0";
"{/unescape/}" = "unescape";
"{/more/unescape/}/yeah" = "/more/unescape";

prefix "/level0/level1";
"string" = "string";
"long" = 10;
"boolean" = true;
"double" = 0.5;
"list" = list(1,2,3);
"nlist" = nlist("nlist", "ok");

"level2/hello" = "level2";
