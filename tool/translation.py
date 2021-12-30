from tkinter import filedialog
import tkinter as tk
import re
import json

#打开文件对象(通过GUI操作)
class Opener():
    def __init__(self): 
        #限制文件类型为文本文件
        self.texttype = [('文本文件','*.txt'),('文本文件','*.s'),('文本文件','*.mips')]    

    #文件文档打开方法
    def opentext_by_gui(self,texttype=''):
        root = tk.Tk()             #初始化窗口
        root.withdraw()            #隐藏主窗口
        if texttype:
            self.texttype = texttype       

        #打开文件对话框
        file_path = filedialog.askopenfilename( title = '请选择文本文件！' , filetypes = self.texttype )

        return file_path

        #文件文档保存方法
    def savetext_by_gui(self,texttype=''):
        root = tk.Tk()             #初始化窗口
        root.withdraw()            #隐藏主窗口
        if texttype:
            self.texttype = texttype       

        #打开文件对话框
        file_path = filedialog.asksaveasfilename( title = '保存为文本文件！' , filetypes = self.texttype )

        return file_path


#指令翻译类
class Translation():
    def __init__(self):

        # 加载指令机器码对应json文件
        with open('op.json','r',encoding='utf-8') as f:
            self.__op_dict = json.load(f)

        # 加载寄存器别名json文件
        with open('reg.json','r',encoding='utf-8') as f:
            self.__reg_dict = json.load(f)

        # 初始化指令对应的翻译方法字典
        self.__fun_dict = {
            'r':self._R_translation,
            'i':self._I_translation,
            'j':self._J_translation,
            'b':self._B_translation,
            'regimm':self._REGIMM_translation,
            'lb':self._LB_translation
        }

        self.__addr = 0

        self.__tempfile = "temp.txt"

    # MIPS汇编预编译方法，f_code为代码文件的文件操作符
    def pre_translation(self,instruction):
        pass                                                           # 有点麻烦，暂时保留       

    #指令翻译方法,具有很弱的代码格式化能力
    def translation(self,instruction):
        instruction = re.sub(r'#.*', '', instruction)                  #去掉注释
        instruction = instruction.lower()                              #指令全部转小写
        instruction = re.sub(r',', " ", instruction)                   #将逗号变为一个空格
        instruction = re.sub(r' +', " ", instruction)                  #将连续空格变为一个空格
        instruction = re.sub(r' *(\S)', r'\1', instruction, count=1)   #去掉指令前面的空格
        segements = instruction.split(' ')                             #将指令助记符，寄存器号和立即数分开

        #结尾可能存在空格，因此导致末尾存在一个无效切割，除去
        if not segements[-1] or segements[-1] == '\n' :
            del segements[-1]

        #空行直接返回
        if not segements:
            return ''

        try :
            instruction_form = self.__op_dict[ segements[0] ]                #指令操作符对应格式

        except KeyError:
            print('不存在该关键字',segements[0])                            #如果有异常，则助记符写错了
            return

        #调用指令对应格式的翻译方法
        result = self.__fun_dict[ instruction_form['ins_kind'] ](segements[1:],instruction_form)     

        return result

    #寄存器译码方法
    def _reg_translation(self,segements,zeros_reg,orders):

        i = 0
        result = [ ]
        for flag in zeros_reg:
            if flag == '0':
                try:
                    string = re.sub(r'\$', r'', segements[i])            # 去掉$
                    if not string.isdecimal():                           # 如果寄存器名为别名，进行处理
                        string = self.__reg_dict[string]

                    # 把标号转为2进制,并加入
                    result.append( "{:0>5b}".format( int(string) ) )   
                    i = i + 1
                except IndexError:
                    print("该指令寄存器数量异常")
                    exit(-1)
            else:
                result = result.append( "00000" )                        # 标志为1则为零号寄存器

        temp = [ None for _ in range(len(orders))]

        for order,reg in zip(orders,result):
            temp[ int( order ) - 1 ] = reg

        result = ''.join(temp)
        print(result)

        return result

    #指令对应格式的翻译方法如下
    def _R_translation(self,segements,instruction_form):

        result = instruction_form['op']                               # 加入操作码

        # 寄存器译码
        result = result + self._reg_translation(segements,instruction_form['zeros_reg'],instruction_form['orders']) 

        #加入偏移段
        if instruction_form['shamt']:
            result = result + "{:0>5b}".format( int( segements[-1] ) )
        else:
            result = result + '00000'

        #加入操作码附加段
        result = result + instruction_form['funt']

        return result

    def _I_translation(self,segements,instruction_form):

        result = instruction_form['op']                                # 加入操作码

        # 寄存器译码
        result = result + self._reg_translation(segements,instruction_form['zeros_reg'],instruction_form['orders'])

        #加入立即数
        result = result + "{:0>16b}".format( int( segements[-1] ) )

        return result

    def _J_translation(self,segements,instruction_form):
        result = instruction_form['op']                                # 加入操作码

        #加入地址
        result = result + "{:0>26b}".format( int( segements[-1] ) )

        return result

    def _B_translation(self,segements,instruction_form):

        result = instruction_form['op']                                # 加入操作码

        # 寄存器译码
        result = result + self._reg_translation(segements,instruction_form['zeros_reg'],instruction_form['orders'])

        #加入偏移量
        result = result + "{:0>16b}".format( int( segements[-1] ) ) 

        return result

    def _REGIMM_translation(self,segements,instruction_form):

        result = instruction_form['op']                                # 加入操作码

        temp = re.findall(r'.{2}',instruction_form['special_reg'])     # 按两位切割

        segements = temp + segements                                   # 拼接寄存器标号和偏移量

        # 寄存器译码
        result =  result + self._reg_translation(segements,instruction_form['zeros_reg'],instruction_form['orders'])

        #加入偏移量
        result = result + "{:0>16b}".format( int( segements[-1] ) ) 

        return result

    def _LB_translation(self,segements,instruction_form):

        result = instruction_form['op']     # 加入操作码

        # 寄存器译码
        reg = self._reg_translation(segements,instruction_form['zeros_reg'],instruction_form['orders'])

        # 基址寄存器译码
        base = re.search(r'\(.*\)',segements[-1]).group()                       # 寻找基址寄存器
        base = re.sub(r'\((.*)\)',r'\1',base)                                   # 去掉小括号
        base = self._reg_translation([base],"0")                                # 基址寄存器译码
        result = result + base

        # 加入寄存器
        result = result + reg

        #加入偏移量
        segements[-1] = re.sub(r'\(.*\)',r'',segements[-1] )
        result = result + "{:0>16b}".format( int( segements[-1] ) ) 

        return result

if __name__ == '__main__':
    opener = Opener()                                        #初始化打开文件对象(通过GUI操作)
    file_path = opener.opentext_by_gui()                     #调用文件文档打开方法
    translation = Translation()                              #初始化指令翻译对象
    save_path = ''
    if file_path:                                            #如果文件打开成功
        with open(file_path,'r',encoding='utf-8') as f:      #以只读方式打开，请保证文件是UTF-8编码
            save_path = opener.savetext_by_gui()
            with open(save_path,'w',encoding='utf-8') as w:      #创建保存文件
                for line in f:                                   #读取文件的每一行
                    if line != '':                               #读取到有效行
                        temp = translation.translation(line)     #指令译码
                        if temp:                                 #有效译码
                            print(temp)
                            temp = re.findall(r'.{4}',temp)      #按四个二进制数切割，准备转换为十六进制
                            # 二进制转为十六进制
                            temp = [ "{:x}".format( int(binary,2) ) for binary in temp ] 
                            temp = ''.join(temp)                 #列表拼接为字符串
                            w.write(temp+'\n')                   #写入文件
    else:
        print("文件被占用或无效")
        exit(-1)
    print( "文件成功保存为" + save_path )
