javaLangClass :: (CNm, ClassFile)
javaLangClass = parse "predefined.jvm/java/lang/Class"


javaLangClassLoader :: (CNm, ClassFile)
javaLangClassLoader = parse "predefined.jvm/java/lang/ClassLoader"

javaLangString :: (CNm, ClassFile)
javaLangString = parse "predefined.jvm/java/lang/String"

javaLangComparable :: (CNm, ClassFile)
javaLangComparable = parse "predefined.jvm/java/lang/Comparable"

javaLangClassNotFoundException :: (CNm, ClassFile)
javaLangClassNotFoundException 
   = parse "predefined.jvm/java/lang/ClassNotFoundException"

javaLangArray :: (CNm, ClassFile)
javaLangArray = parse "predefined.jvm/java/lang/Array"

javaLangObjectOrg :: (CNm, ClassFile)
javaLangObjectOrg = parse "predefined.jvm/java/lang/Object"

javaLangObject :: [Instr] -> (CNm, ClassFile)
javaLangObject start = 
  let (cNm,CFile(c,isIface,ms,_,sigInfo,ifaces,fields,methods)) = 
             javaLangObjectOrg
      methods' = methods +<< 
           { (("<entrypoint>",[]), MDec({Static}, TJVoid, (start ++ [Halt]) 
                                  ,[startExc], (1,0)))
           }
      startExc = Exc(0, 2, 2, (sysLd,"java/lang/Throwable"))
  in (cNm,CFile(c,isIface,ms,Nothing,sigInfo,ifaces,fields,methods'))




