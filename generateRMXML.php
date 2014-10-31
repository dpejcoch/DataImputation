<?php

$path = "r:\\ROOT\\wamp\\www\\dataqualitycz\\vyzkum\\Imputace\\data\\missings\\";
$opath = "r:\\ROOT\\wamp\\www\\dataqualitycz\\vyzkum\\Imputace\\data\\imputed\\";
$codepath = "r:\\ROOT\\wamp\\www\\dataqualitycz\\vyzkum\\Imputace\\RMProjects\\";
$runtime = "r:\\ROOT\\wamp\\www\\dataqualitycz\\vyzkum\\Imputace\\RMProjects\\";
$minerpath = "r:\\ROOT\\install\\kdd\\RapidMiner\\rapidminer\\scripts\\rapidminer";
$ext="bat";

/*
$path = "g:\\root\\data\\missings\\";
$opath = "g:\\root\\data\\imputed\\";
$codepath = "r:\\ROOT\\wamp\\www\\dataqualitycz\\vyzkum\\Imputace\\RMProjects\\";
$runtime = "g:\\root\\data\\RMProjects\\";
$minerpath = "g:\\root\\bin\\rapidminer\\scripts\\rapidminer";
$ext="bat";
*/

/*
$path = "/home/dpejcoch/data/missings/";
$opath = "/home/dpejcoch/data/imputed/";
$codepath = "r:\\ROOT\\wamp\\www\\dataqualitycz\\vyzkum\\Imputace\\RMProjects\\localhost\\";
$runtime = "/home/dpejcoch/data/RMProjects/";
$minerpath = "/home/dpejcoch/install/rapidminer/scripts/rapidminer";
$ext ="sh";
*/

/*
$path = "C:\\root\\data\\missings\\";
$opath = "C:\\root\\data\\imputed\\";
$codepath = "R:\\root\\wamp\\www\\dataqualitycz\\vyzkum\\Imputace\\RMProjects\\EBNB\\";
$runtime = "C:\\root\\RMProjects\\";
$minerpath = "C:\\root\\bin\\rapidminer\\scripts\\rapidminer";
$ext="bat";
*/
$host = 'localhost';
$user = 'root';
$pwd = '';
$db = 'cdm';

$methods = 37;

$link = mysql_connect($host,$user,$pwd);
$dblink = mysql_select_db($db,$link);
if (!$dblink) {
    echo 'Could not run query: ' . mysql_error();
    exit;
}

$RMMethods = array(8,9,10,11,12,13,14,15,16,17,18,19,25,26,27,28,29,30,31,32,34);


/* iterativni projiti vsech metod */
for($m=18;$m<=/*$methods*/19;$m++) {
    $method = "M".$m;
    
    /* jedna se o metodu, ktera ma byt spustena v Rapid Mineru */
    if(in_array($m,$RMMethods)) {
        
        /* pouzij parametry pro vytvoreni workflow */
        $dirFile = fopen($codepath."".$method."batch.".$ext."", "w") or die("Unable to open file!");
       
        /* iterativni projiti vsech data setu */
        $b=0;
        for($b=1;$b<=12;$b++) {
            
            /* ==== Naplneni deskriptivnich poli pro rizeni generovani kodu === */
            
            
            /* lookup pro dulezite atributy z MDR pro promenne, ktere mohou byt pro danou metodu v roli prediktoru */
             $qstr = "select trim(NAME), trim(RM_type)  from mdr";
             $qstr.=" where trim(MEMNAME)='DS".$b."' and (M".$m."='Y' or M".$m."_C='Y') order by idx";
             /*".$m."*/
             echo $qstr."\n";
             
             $result = mysql_query($qstr);
             
             if (!$result) {
                echo 'Could not run query: ' . mysql_error();
                exit;
            }
             
             $xi = 1;
             while(list($name,$type)=mysql_fetch_row($result)) {
                $allAttr[$xi] = $name;
                $allType[$xi] = $type;
                echo $allAttr[$xi]." | ".$allType[$xi]."\n";
                $xi++;
             }
            
            unset($qstr);
            unset($result);
            unset($xi);
            
            /* lookup pro dulezite atributy z MDR pro promenne, ktere mohou byt pro danou metodu v roli prediktoru */
             $qstr = "select trim(NAME), trim(RM_type)  from mdr";
             $qstr.=" where trim(MEMNAME)='DS".$b."' and M".$m."='Y' order by idx";
             /*".$m."*/
             echo $qstr."\n";
             
             $result = mysql_query($qstr);
             
             if (!$result) {
                echo 'Could not run query: ' . mysql_error();
                exit;
            }
             
             $xi = 1;
             while(list($name,$type)=mysql_fetch_row($result)) {
                $attr[$xi] = $name;
                $atype[$xi] = $type;
                echo $attr[$xi]." | ".$atype[$xi]."\n";
                $xi++;
             }
             
            unset($qstr);
            unset($result);
            unset($xi);
             
             /* lookup pro dulezite atributy z MDR pro promenne, ktere mohou byt pro danou metodu v roli tridy / cilove promenne */
             $qstr = "select trim(NAME), trim(RM_type)  from mdr";
             $qstr.=" where trim(MEMNAME)='DS".$b."' and M".$m."_C='Y' order by idx";
             /*".$m."*/
             echo $qstr."\n";
             
             $result = mysql_query($qstr);
             
             if (!$result) {
                echo 'Could not run query: ' . mysql_error();
                exit;
            }
             
             $xi = 1;
             while(list($name,$type)=mysql_fetch_row($result)) {
                $cattr[$xi] = $name;
                $catype[$xi] = $type;
                echo $xi." | ".$cattr[$xi]." | ".$catype[$xi]."\n";
                $xi++;
             }
             
            unset($qstr);
            unset($result);
            unset($xi);
            
            echo "cattr count: ".count($cattr)."\n";
            echo "attr count: ".count($attr)."\n";
            echo "================================================\n";
            echo "cattr dump: \n";
            echo var_dump($cattr);
            echo "\n";
            echo "================================================\n";
            echo "attr dump: \n";
            echo var_dump($attr);
            echo "\n";
            
            /* iterativni prochazeni vsech variant missingu */
            for($z=1;$z<=10;$z++) {
                $w = $z * 5;
            
                $myfile = fopen($codepath."ds".$b."_".$method."_".$w.".rmp", "w") or die("Unable to open file!");
                $dirPartFile = fopen($codepath."ds".$b."_".$method."_".$w.".".$ext."", "w") or die("Unable to open file!");
                
                fwrite($myfile,"<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n");
                fwrite($myfile,"<process version=\"5.3.013\">v");
                  fwrite($myfile,"<context>\n");
                  fwrite($myfile,"<input/>\n");
                  fwrite($myfile,"<output/>\n");
                  fwrite($myfile,"<macros/>\n");
                  fwrite($myfile,"</context>\n");
                  
                fwrite($myfile,"<operator activated=\"true\" class=\"process\" compatibility=\"5.3.013\" expanded=\"true\" name=\"Process\">\n");
                fwrite($myfile,"<parameter key=\"logverbosity\" value=\"all\"/>\n");
                fwrite($myfile,"<parameter key=\"logfile\" value=\"".$runtime."ds".$b."_".$w."_".$method.".log\"/>\n");

                fwrite($myfile,"<process expanded=\"true\">\n");
                
                /* operator Read CSV */
                fwrite($myfile,"<operator activated=\"true\" class=\"read_csv\" compatibility=\"5.3.013\" expanded=\"true\" height=\"60\" name=\"Read CSV\" width=\"90\" x=\"45\" y=\"30\">\n");
                fwrite($myfile,"<parameter key=\"csv_file\" value=\"".$path."ds".$b."_".$w."_".$method."_prep.csv\"/>\n");
                fwrite($myfile,"<parameter key=\"column_separators\" value=\",\"/>\n");
                fwrite($myfile,"<parameter key=\"first_row_as_names\" value=\"false\"/>\n");
                fwrite($myfile,"<list key=\"annotations\">\n");
                fwrite($myfile,"<parameter key=\"0\" value=\"Name\"/>\n");
                fwrite($myfile,"</list>\n");
                
                /* definice vstupnich parametru */
                fwrite($myfile,"<parameter key=\"encoding\" value=\"windows-1250\"/>\n");
                fwrite($myfile,"<list key=\"data_set_meta_data_information\">\n");
                
                fwrite($myfile,"<parameter key=\"0\" value=\"idx.true.integer.id\"/>\n");
                      
                for($i=1;$i<=count($allAttr);$i++) {
                    $str = "<parameter key=\"".$i."\" value=\"".$allAttr[$i].".true.".$allType[$i].".attribute\"/>\n";
                    fwrite($myfile,$str);
                }
                fwrite($myfile,"</list>\n");
                fwrite($myfile,"</operator>\n"); 
                
                /* uzlove body pro zpracovani jednotlivych promennych - vsech v roli class */
                for($i=1;$i<=count($cattr);$i++) {
                    $restOfVars='';
                    $allOfVars='';
                    
                    /* nastaveni cilove promenne */
                    $class = $cattr[$i];
                    $prs1 = explode('_',$class);
                    
                    for($j=1;$j<=count($allAttr);$j++) {                        
                        if($j==1) {$allOfVars.=$allAttr[$j];} else {$allOfVars.="|".$allAttr[$j];}
                    }
                    
                    fwrite($myfile,"<operator activated=\"true\" class=\"subprocess\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"".$class."\" width=\"90\" x=\"179\" y=\"30\">\n");
                        fwrite($myfile,"<process expanded=\"true\">\n");
                          fwrite($myfile,"<operator activated=\"true\" class=\"set_role\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"NTBC: Label (3)\" width=\"90\" x=\"45\" y=\"30\">\n");
                            fwrite($myfile,"<parameter key=\"attribute_name\" value=\"".$class."\"/>\n");
                            fwrite($myfile,"<parameter key=\"target_role\" value=\"label\"/>\n");
                            fwrite($myfile,"<list key=\"set_additional_roles\">\n");                          
                            /* nastaveni roli ostatnich trid*/
                            for($j=1;$j<=count($cattr);$j++) {
                                $maxJ = $j;
                                if($j!=$i) {
                                    fwrite($myfile,"<parameter key=\"".$cattr[$j]."\" value=\"ignore".$j."\"/>\n");
                                    $restOfVars.="|".$cattr[$j];
                                }
                            }
                            for($j=1;$j<=count($attr);$j++) {
                                $prs2 = explode('_',$attr[$j]);
                               if(!in_array($attr[$j],$cattr)){
                                    if ($prs2[0]!=$class and $attr[$j]!=$class and $prs1[0]!=$prs2[0]) {
                                         $restOfVars.="|".$attr[$j];
                                         
                                    }
                                    else {
                                        $vv = $maxJ + $j;
                                        fwrite($myfile,"<parameter key=\"".$attr[$j]."\" value=\"ignore".$vv."\"/>\n");
                                        $restOfVars.="|".$attr[$j];
                                    }
                               }
                            }
                            fwrite($myfile,"</list>\n"); 
                            
                          fwrite($myfile,"</operator>\n");
                          fwrite($myfile,"<operator activated=\"true\" class=\"filter_examples\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Filter Examples (5)\" width=\"90\" x=\"180\" y=\"30\">\n");
                            fwrite($myfile,"<parameter key=\"condition_class\" value=\"no_missing_labels\"/>\n");
                          fwrite($myfile,"</operator>\n");
                          fwrite($myfile,"<operator activated=\"true\" class=\"multiply\" compatibility=\"5.3.013\" expanded=\"true\" height=\"94\" name=\"Multiply\" width=\"90\" x=\"313\" y=\"30\"/>\n");
                          fwrite($myfile,"<operator activated=\"true\" class=\"filter_examples\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Filter Examples (31)\" width=\"90\" x=\"313\" y=\"30\">\n");
                            fwrite($myfile,"<parameter key=\"condition_class\" value=\"no_missing_attributes\"/>\n");
                          fwrite($myfile,"</operator>\n");
                          fwrite($myfile,"<operator activated=\"true\" class=\"x_validation\" compatibility=\"5.3.013\" expanded=\"true\" height=\"112\" name=\"Validation (3)\" width=\"90\" x=\"447\" y=\"30\">\n");
                            fwrite($myfile,"<parameter key=\"average_performances_only\" value=\"false\"/>\n");
                            
                            /* parametr pro sampling behem x-validace */
                            /* linear <= spojita cilova promenna */
                            /* stratified <= kategorialni cilova promenna, stratified je default, tudiz nevyzaduje explicitne definovat */
                            fwrite($myfile,"<parameter key=\"sampling_type\" value=\"shuffled sampling\"/>\n");
                            /* shuffled */
                            /*<parameter key="sampling_type" value="shuffled sampling"/>*/
                            /* fwrite($myfile,"<parameter key=\"sampling_type\" value=\"linear sampling\"/>\n");*/
                            
                            switch($method) {
                                case "M1":
                                    
                                break;
                                case "M2":
                                    
                                break;
                                case "M3":
                                    
                                break;
                                case "M4":
                                    
                                break;
                                case "M5":
                                    
                                break;
                                case "M6":
                                    
                                break;
                                case "M7":
                                    
                                break;
                                case "M8":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"k_nn\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"k-NN (3)\" width=\"90\" x=\"106\" y=\"30\">\n");
                                    fwrite($myfile,"<parameter key=\"k\" value=\"2\"/>\n");
                                    fwrite($myfile,"<parameter key=\"weighted_vote\" value=\"true\"/>\n");
                                    fwrite($myfile,"</operator>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"k-NN (3)\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"k-NN (3)\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"</process>\n");
                                break;
                                    case "M9":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"weka:W-NNge\" compatibility=\"5.3.001\" expanded=\"true\" height=\"76\" name=\"W-NNge\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"W-NNge\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"W-NNge\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                   fwrite($myfile," </process>\n");
                                break;
                                case "M10":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"linear_regression\" compatibility=\"5.3.013\" expanded=\"true\" height=\"94\" name=\"Linear Regression\" width=\"90\" x=\"179\" y=\"30\"/>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"Linear Regression\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"Linear Regression\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                  fwrite($myfile,"</process>\n");
                                break;
                                case "M11":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"naive_bayes\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Naive Bayes\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"Naive Bayes\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"Naive Bayes\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"</process>\n");
                                break;
                                case "M12":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"weka:W-BayesNet\" compatibility=\"5.3.001\" expanded=\"true\" height=\"76\" name=\"W-BayesNet\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"W-BayesNet\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"W-BayesNet\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"</process>\n");
                                break;
                                case "M13":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"weka:W-MultilayerPerceptron\" compatibility=\"5.3.001\" expanded=\"true\" height=\"76\" name=\"W-MultilayerPerceptron\" width=\"90\" x=\"112\" y=\"30\">\n");
                                    fwrite($myfile,"<parameter key=\"L\" value=\"0.1\"/>\n");
                                    fwrite($myfile,"<parameter key=\"N\" value=\"100.0\"/>\n");
                                    fwrite($myfile,"<parameter key=\"B\" value=\"true\"/>\n");
                                    fwrite($myfile,"<parameter key=\"I\" value=\"true\"/>\n");
                                    fwrite($myfile,"<parameter key=\"R\" value=\"true\"/>\n");
                                    fwrite($myfile,"</operator>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"W-MultilayerPerceptron\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"W-MultilayerPerceptron\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"</process>\n");
                                break;
                                case "M14":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"weka:W-RBFNetwork\" compatibility=\"5.3.001\" expanded=\"true\" height=\"76\" name=\"W-RBFNetwork\" width=\"90\" x=\"179\" y=\"30\"/>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"W-RBFNetwork\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"W-RBFNetwork\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"</process>\n");
                                break;
                                case "M15":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"weka:W-Logistic\" compatibility=\"5.3.001\" expanded=\"true\" height=\"76\" name=\"W-Logistic\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"W-Logistic\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"W-Logistic\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"</process>\n");
                                break;
                                case "M16":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"support_vector_machine\" compatibility=\"5.3.013\" expanded=\"true\" height=\"112\" name=\"SVM\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                   fwrite($myfile," <connect from_port=\"training\" to_op=\"SVM\" to_port=\"training set\"/>\n");
                                   fwrite($myfile," <connect from_op=\"SVM\" from_port=\"model\" to_port=\"model\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"</process>\n");
                                break;
                                case "M17":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"support_vector_machine_pso\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"SVM\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"SVM\" to_port=\"training set\"/>\n");
                                   fwrite($myfile," <connect from_op=\"SVM\" from_port=\"model\" to_port=\"model\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"</process>\n");
                                break;
                                case "M18":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"linear_discriminant_analysis\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"LDA\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"LDA\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"LDA\" from_port=\"model\" to_port=\"model\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                   fwrite($myfile," </process>\n");
                                break;
                                case "M19":
                                   fwrite($myfile," <process expanded=\"true\">\n");
                                   fwrite($myfile,"<operator activated=\"true\" class=\"quadratic_discriminant_analysis\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"QDA\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                   fwrite($myfile," <connect from_port=\"training\" to_op=\"QDA\" to_port=\"training set\"/>\n");
                                   fwrite($myfile,"<connect from_op=\"QDA\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"</process>\n");
                                break;
                                case "M20":
                                    
                                break;
                                case "M21":
                                    
                                break;
                                case "M22":
                                    
                                break;
                                case "M23":
                                    
                                break;
                                case "M24":
                                    
                                break;
                                case "M25":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"id3\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"ID3\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"ID3\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"ID3\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                   fwrite($myfile," </process>\n");
                                break;
                                case "M26":
                                   fwrite($myfile," <process expanded=\"true\">\n");
                                   fwrite($myfile," <operator activated=\"true\" class=\"chaid\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"CHAID\" width=\"90\" x=\"112\" y=\"30\">\n");
                                   fwrite($myfile," <parameter key=\"minimal_gain\" value=\"0.2\"/>\n");
                                   fwrite($myfile," </operator>\n");
                                   fwrite($myfile," <connect from_port=\"training\" to_op=\"CHAID\" to_port=\"training set\"/>\n");
                                   fwrite($myfile," <connect from_op=\"CHAID\" from_port=\"model\" to_port=\"model\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                   fwrite($myfile," </process>\n");
                                break;
                                case "M27":                      
                                    fwrite($myfile," <process expanded=\"true\">\n");
                                    fwrite($myfile," <operator activated=\"true\" class=\"random_forest\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Random Forest\" width=\"90\" x=\"45\" y=\"30\">\n");
                                    fwrite($myfile," <parameter key=\"number_of_trees\" value=\"2\"/>\n");
                                    fwrite($myfile," <parameter key=\"criterion\" value=\"accuracy\"/>\n");
                                    fwrite($myfile," <parameter key=\"no_pruning\" value=\"true\"/>\n");
                                    fwrite($myfile," </operator>\n");
                                    fwrite($myfile," <connect from_port=\"training\" to_op=\"Random Forest\" to_port=\"training set\"/>\n");
                                    fwrite($myfile," <connect from_op=\"Random Forest\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile," <portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile," <portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile," <portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                    fwrite($myfile," </process>\n");

                                break;
                                case "M28":
                                   fwrite($myfile," <process expanded=\"true\">\n");
                                   fwrite($myfile," <operator activated=\"true\" class=\"weka:W-RandomTree\" compatibility=\"5.3.001\" expanded=\"true\" height=\"76\" name=\"W-RandomTree (2)\" width=\"90\" x=\"112\" y=\"75\"/>\n");
                                   fwrite($myfile," <connect from_port=\"training\" to_op=\"W-RandomTree (2)\" to_port=\"training set\"/>\n");
                                   fwrite($myfile," <connect from_op=\"W-RandomTree (2)\" from_port=\"model\" to_port=\"model\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                  fwrite($myfile,"</process>\n");
                                break;
                                case "M29":
                                   fwrite($myfile,"<process expanded=\"true\">\n");
                                   fwrite($myfile," <operator activated=\"true\" class=\"decision_stump\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Decision Stump\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                   fwrite($myfile," <connect from_port=\"training\" to_op=\"Decision Stump\" to_port=\"training set\"/>\n");
                                   fwrite($myfile," <connect from_op=\"Decision Stump\" from_port=\"model\" to_port=\"model\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                   fwrite($myfile," </process>\n");
                                break;
                                case "M30":
                                  fwrite($myfile,"  <process expanded=\"true\">\n");
                                  fwrite($myfile,"  <operator activated=\"true\" class=\"weka:W-ConjunctiveRule\" compatibility=\"5.3.001\" expanded=\"true\" height=\"76\" name=\"W-ConjunctiveRule\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                  fwrite($myfile,"  <connect from_port=\"training\" to_op=\"W-ConjunctiveRule\" to_port=\"training set\"/>\n");
                                  fwrite($myfile,"  <connect from_op=\"W-ConjunctiveRule\" from_port=\"model\" to_port=\"model\"/>\n");
                                  fwrite($myfile,"  <portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                  fwrite($myfile,"  <portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                  fwrite($myfile,"  <portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                  fwrite($myfile,"  </process>\n");
                                break;
                                case "M31":
                                  fwrite($myfile,"  <process expanded=\"true\">\n");
                                 fwrite($myfile,"   <operator activated=\"true\" class=\"weka:W-M5Rules\" compatibility=\"5.3.001\" expanded=\"true\" height=\"76\" name=\"W-M5Rules\" width=\"90\" x=\"179\" y=\"30\"/>\n");
                                  fwrite($myfile,"  <connect from_port=\"training\" to_op=\"W-M5Rules\" to_port=\"training set\"/>\n");
                                  fwrite($myfile,"  <connect from_op=\"W-M5Rules\" from_port=\"model\" to_port=\"model\"/>\n");
                                  fwrite($myfile,"  <portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                   fwrite($myfile," <portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                  fwrite($myfile,"  <portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                   fwrite($myfile," </process>\n");
                                break;
                                case "M32":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"weka:W-JRip\" compatibility=\"5.3.001\" expanded=\"true\" height=\"76\" name=\"W-JRip\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"W-JRip\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"W-JRip\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"</process>\n");
                                break;
                                case "M33":
                                    
                                break;
                                case "M34":
                                    fwrite($myfile,"<process expanded=\"true\">\n");
                                    fwrite($myfile,"<operator activated=\"true\" class=\"decision_tree\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Decision Tree\" width=\"90\" x=\"112\" y=\"30\"/>\n");
                                    fwrite($myfile,"<connect from_port=\"training\" to_op=\"Decision Tree\" to_port=\"training set\"/>\n");
                                    fwrite($myfile,"<connect from_op=\"Decision Tree\" from_port=\"model\" to_port=\"model\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"source_training\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_model\" spacing=\"0\"/>\n");
                                    fwrite($myfile,"<portSpacing port=\"sink_through 1\" spacing=\"0\"/>\n");
                                   fwrite($myfile," </process>\n");
                                break;
                                
                            }
                                        
                            fwrite($myfile,"<process expanded=\"true\">\n");
                              fwrite($myfile,"<operator activated=\"true\" class=\"apply_model\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Apply Model (5)\" width=\"90\" x=\"45\" y=\"30\">\n");
                                fwrite($myfile,"<list key=\"application_parameters\"/>\n");
                              fwrite($myfile,"</operator>\n");
                              fwrite($myfile,"<operator activated=\"true\" class=\"performance\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Performance (3)\" width=\"90\" x=\"192\" y=\"30\"/>\n");
                              fwrite($myfile,"<connect from_port=\"model\" to_op=\"Apply Model (5)\" to_port=\"model\"/>\n");
                              fwrite($myfile,"<connect from_port=\"test set\" to_op=\"Apply Model (5)\" to_port=\"unlabelled data\"/>\n");
                              fwrite($myfile,"<connect from_op=\"Apply Model (5)\" from_port=\"labelled data\" to_op=\"Performance (3)\" to_port=\"labelled data\"/>\n");
                              fwrite($myfile,"<connect from_op=\"Performance (3)\" from_port=\"performance\" to_port=\"averagable 1\"/>\n");
                              fwrite($myfile,"<portSpacing port=\"source_model\" spacing=\"0\"/>\n");
                              fwrite($myfile,"<portSpacing port=\"source_test set\" spacing=\"0\"/>\n");
                              fwrite($myfile,"<portSpacing port=\"source_through 1\" spacing=\"0\"/>\n");
                              fwrite($myfile,"<portSpacing port=\"sink_averagable 1\" spacing=\"0\"/>\n");
                              fwrite($myfile,"<portSpacing port=\"sink_averagable 2\" spacing=\"0\"/>\n");
                            fwrite($myfile,"</process>\n");
                          fwrite($myfile,"</operator>\n");
                          fwrite($myfile,"<operator activated=\"true\" class=\"filter_examples\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Filter Examples (6)\" width=\"90\" x=\"179\" y=\"165\">\n");
                            fwrite($myfile,"<parameter key=\"condition_class\" value=\"missing_labels\"/>\n");
                          fwrite($myfile,"</operator>\n");
                          fwrite($myfile,"<operator activated=\"true\" class=\"select_attributes\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"NTBC: Filter (5)\" width=\"90\" x=\"313\" y=\"165\">\n");
                            fwrite($myfile,"<parameter key=\"attribute_filter_type\" value=\"subset\"/>\n");
                            fwrite($myfile,"<parameter key=\"attributes\" value=\"idx".$restOfVars."\"/>\n");
                            fwrite($myfile,"<parameter key=\"include_special_attributes\" value=\"true\"/>\n");
                          fwrite($myfile,"</operator>\n");
                          fwrite($myfile,"<operator activated=\"true\" class=\"apply_model\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Apply Model (6)\" width=\"90\" x=\"447\" y=\"165\">\n");
                            fwrite($myfile,"<list key=\"application_parameters\"/>\n");
                          fwrite($myfile,"</operator>\n");
                          fwrite($myfile,"<operator activated=\"true\" class=\"select_attributes\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"NTBC: Filter (6)\" width=\"90\" x=\"581\" y=\"210\">\n");
                            fwrite($myfile,"<parameter key=\"attribute_filter_type\" value=\"subset\"/>\n");
                            fwrite($myfile,"<parameter key=\"attributes\" value=\"idx|prediction(".$class.")".$restOfVars."\"/>\n");
                            fwrite($myfile,"<parameter key=\"include_special_attributes\" value=\"true\"/>\n");
                          fwrite($myfile,"</operator>\n");
                          fwrite($myfile,"<operator activated=\"true\" class=\"rename\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"NTBC: Rename Pred (3)\" width=\"90\" x=\"715\" y=\"210\">\n");
                            fwrite($myfile,"<parameter key=\"old_name\" value=\"prediction(".$class.")\"/>\n");
                            fwrite($myfile,"<parameter key=\"new_name\" value=\"".$class."\"/>\n");
                            fwrite($myfile,"<list key=\"rename_additional_attributes\"/>\n");
                          fwrite($myfile,"</operator>\n");
                          fwrite($myfile,"<operator activated=\"true\" class=\"append\" compatibility=\"5.3.013\" expanded=\"true\" height=\"94\" name=\"Append (3)\" width=\"90\" x=\"581\" y=\"30\">\n");
                            fwrite($myfile,"<parameter key=\"datamanagement\" value=\"sparse_map\"/>\n");
                          fwrite($myfile,"</operator>\n");
                          
                          /* at the end of process change roles */
                          fwrite($myfile,"<operator activated=\"true\" class=\"set_role\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"NTBC: Unrole (3)\" width=\"90\" x=\"715\" y=\"30\">\n");
                            fwrite($myfile,"<parameter key=\"attribute_name\" value=\"".$class."\"/>\n");
                            fwrite($myfile,"<list key=\"set_additional_roles\">\n");
                            
                            /* nastaveni roli ostatnich trid*/
                            for($j=1;$j<=count($cattr);$j++) {
                                            
                                
                                    fwrite($myfile,"<parameter key=\"".$cattr[$j]."\" value=\"regular\"/>\n");
                             
                            }
                            for($j=1;$j<=count($attr);$j++) {
                                $prs2 = explode('_',$attr[$j]);
                                
                                if(!in_array($attr[$j],$cattr)){
                                    fwrite($myfile,"<parameter key=\"".$attr[$j]."\" value=\"regular\"/>\n");
                                }
                            }
                            fwrite($myfile,"</list>\n"); 
                            fwrite($myfile,"</operator>\n");
                          
                          /* change order of variables */
                          fwrite($myfile,"<operator activated=\"true\" class=\"order_attributes\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Reorder Attributes (3)\" width=\"90\" x=\"849\" y=\"30\">\n");
                            fwrite($myfile,"<parameter key=\"attribute_ordering\" value=\"".$allOfVars."\"/>\n");
                            fwrite($myfile,"<parameter key=\"handle_unmatched\" value=\"prepend\"/>\n");
                          fwrite($myfile,"</operator>\n");
                          
                          /* free memory */
                          fwrite($myfile,"<operator activated=\"true\" class=\"free_memory\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Free Memory\" width=\"90\" x=\"782\" y=\"30\"/>\n");

                          fwrite($myfile,"<connect from_port=\"in 1\" to_op=\"NTBC: Label (3)\" to_port=\"example set input\"/>\n");
                          fwrite($myfile,"<connect from_op=\"NTBC: Label (3)\" from_port=\"example set output\" to_op=\"Filter Examples (5)\" to_port=\"example set input\"/>\n");
                          fwrite($myfile,"<connect from_op=\"Filter Examples (5)\" from_port=\"example set output\" to_op=\"Multiply\" to_port=\"input\"/>\n");
                          fwrite($myfile,"<connect from_op=\"Filter Examples (5)\" from_port=\"original\" to_op=\"Filter Examples (6)\" to_port=\"example set input\"/>\n");
                          fwrite($myfile,"<connect from_op=\"Multiply\" from_port=\"output 1\" to_op=\"Append (3)\" to_port=\"example set 1\"/>\n");
                          fwrite($myfile,"<connect from_op=\"Multiply\" from_port=\"output 2\" to_op=\"Filter Examples (31)\" to_port=\"example set input\"/>\n");
                          fwrite($myfile,"<connect from_op=\"Filter Examples (31)\" from_port=\"example set output\" to_op=\"Validation (3)\" to_port=\"training\"/>\n");
                          fwrite($myfile,"<connect from_op=\"Validation (3)\" from_port=\"model\" to_op=\"Apply Model (6)\" to_port=\"model\"/>\n");
                          fwrite($myfile,"<connect from_op=\"Filter Examples (6)\" from_port=\"example set output\" to_op=\"NTBC: Filter (5)\" to_port=\"example set input\"/>\n");
                          fwrite($myfile,"<connect from_op=\"NTBC: Filter (5)\" from_port=\"example set output\" to_op=\"Apply Model (6)\" to_port=\"unlabelled data\"/>\n");
                          fwrite($myfile,"<connect from_op=\"Apply Model (6)\" from_port=\"labelled data\" to_op=\"NTBC: Filter (6)\" to_port=\"example set input\"/>\n");
                          fwrite($myfile,"<connect from_op=\"NTBC: Filter (6)\" from_port=\"example set output\" to_op=\"NTBC: Rename Pred (3)\" to_port=\"example set input\"/>\n");
                          fwrite($myfile,"<connect from_op=\"NTBC: Rename Pred (3)\" from_port=\"example set output\" to_op=\"Append (3)\" to_port=\"example set 2\"/>\n");
                          fwrite($myfile,"<connect from_op=\"Append (3)\" from_port=\"merged set\" to_op=\"NTBC: Unrole (3)\" to_port=\"example set input\"/>\n");
                          fwrite($myfile,"<connect from_op=\"NTBC: Unrole (3)\" from_port=\"example set output\" to_op=\"Reorder Attributes (3)\" to_port=\"example set input\"/>\n");                          
                          fwrite($myfile,"<connect from_op=\"Reorder Attributes (3)\" from_port=\"example set output\" to_op=\"Free Memory\" to_port=\"through 1\"/>\n");
                        fwrite($myfile,"<connect from_op=\"Free Memory\" from_port=\"through 1\" to_port=\"out 1\"/>\n");

                          
                          fwrite($myfile,"<portSpacing port=\"source_in 1\" spacing=\"0\"/>\n");
                          fwrite($myfile,"<portSpacing port=\"source_in 2\" spacing=\"0\"/>\n");
                          fwrite($myfile,"<portSpacing port=\"sink_out 1\" spacing=\"0\"/>\n");
                          fwrite($myfile,"<portSpacing port=\"sink_out 2\" spacing=\"0\"/>\n");
                        fwrite($myfile,"</process>\n");
                      fwrite($myfile,"</operator>\n");
                }
                
                /* definice Write CSV */
                  fwrite($myfile,"<operator activated=\"true\" class=\"write_csv\" compatibility=\"5.3.013\" expanded=\"true\" height=\"76\" name=\"Write CSV\" width=\"90\" x=\"849\" y=\"30\">\n");
                  fwrite($myfile,"<parameter key=\"csv_file\" value=\"".$opath."ds".$b."_".$w."_".$method."_imp_.csv\"/>\n");
                  fwrite($myfile,"<parameter key=\"column_separator\" value=\",\"/>\n");
                  fwrite($myfile,"</operator>\n");
                
                
                /* vazby mezi nody */
                /* propojeni vstupnich dat na cyklus imputaci */
                fwrite($myfile,"<connect from_op=\"Read CSV\" from_port=\"output\" to_op=\"".$cattr[1]."\" to_port=\"in 1\"/>\n");
    
                for($i=1;$i<=count($cattr);$i++) {
                    if ($i<count($cattr)) {
                        $a=$i+1;
                        $str = "<connect from_op=\"".$cattr[$i]."\" from_port=\"out 1\" to_op=\"".$cattr[$a]."\" to_port=\"in 1\"/>\n";
                        fwrite($myfile,$str);
                    } else {
                         fwrite($myfile,"<connect from_op=\"".$cattr[$i]/*$attr[count($attr)]*/."\" from_port=\"out 1\" to_op=\"Write CSV\" to_port=\"input\"/>\n");
                         
                    }
                    
                }
                fwrite($myfile,"<connect from_op=\"Write CSV\" from_port=\"through\" to_port=\"result 1\"/>\n");
                
                /* dodatecne parametry */
                fwrite($myfile,"<portSpacing port=\"source_input 1\" spacing=\"0\"/>\n");
                fwrite($myfile,"<portSpacing port=\"sink_result 1\" spacing=\"0\"/>\n");
                fwrite($myfile,"</process>\n");
                fwrite($myfile,"</operator>\n");
                fwrite($myfile,"</process>\n");
                fclose($myfile);
                $out="\"".$minerpath."\" -f \"".$runtime."ds".$b."_".$method."_".$w.".rmp\"\n";
                fwrite($dirPartFile,$out);
                fclose($dirPartFile);
                fwrite($dirFile,$runtime."ds".$b."_".$method."_".$w.".".$ext."\n");
            }
             unset($cattr);
             unset($catype);
             unset($attr);
             unset($atype);
             unset($allAttr);
             unset($allType);
 
        }
        fclose($dirFile);
    }
}

?>
