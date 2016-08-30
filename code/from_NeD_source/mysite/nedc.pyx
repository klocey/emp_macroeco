from django.template import RequestContext
from django.http import HttpResponse
from django.shortcuts import render_to_response
from django.core.servers.basehttp import FileWrapper
from django import forms
from numpy import array, mean, std, arange,zeros,where,transpose,isnan
from numpy.linalg import eigvals
import numpy.ma
from string import*
from random import sample, shuffle, random,randint
from time import gmtime
from os import listdir, remove
from os.path import getmtime
from time import time
import png

#try:
#	import image as Image
#except:
#	import Image




###Function to approximate floating value to the third decimal position 
def app(n):
	try:
		return str(round(n,3))
	except:
		return n



###Functions to handle errors when computing max and/or min of an empty list
def maximum(L):
	try:
		return max(L)
	except ValueError:
		return 'nan'


def minimum(L):
	try:
		return min(L)
	except ValueError:
		return 'nan'



####Function to generate sample random matrix 
def RMAT(S,N):
	R=int(S)
	C=int(S)
	N=int(N)
	MM=[]
	for i in range(R):
		row=[]
		for i in range(C):
			row.append(1)
		MM.append(row)
	for i in range(len(MM)):
		for j in range(len(MM[i][:-(i+1)])):
			MM[i][-(j+1)]=0
	shuffle(MM)
	MM=TR(MM)
	shuffle(MM)
	MM=TR(MM)
	for i in range(int(R*C*((1.0/(N+1)-0.1)))):
		rr=sample(range(R),1)[0]
		rc=sample(range(C),1)[0]
		rv=sample([0,1],1)[0]
		MM[rr][rc]=rv
	return MM,[],[]
		

####Function to compute integral of y=f(x) in the interval a:b 
def simple_integral(func,a,b,y,dx = 0.001):
	return sum(map(lambda x:dx*x, func(arange(a,b,dx),y)))


####Function to get current date
def gettime():
	d=gmtime()
	return(str(d[2])+"_"+str(d[1])+"_"+str(d[0]))


####Class to upload matrix file
class UploadFileForm(forms.Form):
	title=forms.CharField(max_length=50)
	file=forms.FileField()

import string
###Function to automatical recognition of matrix format
def auto_format(f):		#f is the matrix file
	CN_tot=[]
	for i in f:
		CN_tot.append (i)
	CN_tot=CN_tot[0][:]		#rows in f are appended to CN_tot; then only the first row in CN_tot is retained, to be tested for the presence of column names 
	CSV='no'
	if ',' in CN_tot and ' ' in CN_tot:
		CN_tot=CN_tot.replace(' ','').replace(',',' ')
		CSV='yes'
	if ',' in CN_tot:
		CN_tot=CN_tot.replace(',',' ')
		CSV='yes'
	if CSV=='yes':
		ff=[]
		for i in f:
			ff.append(i.replace(' ','').replace(',',' '))
	else:
		ff=f	
	CN=[]
	CN_sc=0
	if len(CN_tot.split())>1:
		for i in CN_tot.split():
			if i not in ['0','1'] and i not in string.whitespace:
				CN_sc+=1	#the script checks if the first line of the file contains column names; if it does, the script checks if these names are separated by spaces or tabulations; if they are, the script includes column names in the list 'CN'.
	elif len(CN_tot.split())==1:
		for i in CN_tot:
			if i not in ['0','1'] and i not in string.whitespace:
				CN_sc+=1 #if column names are not separated by spaces or tabulations, the script assumes that column names consist of a single character, and includes them in the list 'CN'.
				print i	
	if CN_sc<1:
		CN=[]			#if the script does not detect column names 'CN' is emptied for safety.
	else:
		if len(CN_tot.split())>1:			
			for i in CN_tot.split():
				CN.append(i)
		elif len(CN_tot.split())==1:
			for i in CN_tot:
				CN.append(i)
			CN=CN[:-1]	
	RN_sc=0
	for i in ff:
		if len(i.split())>1:
			try:
				if (i.split()[0]!='0' and i.split()[0]!='1'): 		####the same procedure is repeated for row names
					RN_sc=RN_sc+1
			except:
				continue
		elif len(i.split())==1:
			try:
				if (i[0]!='0' and i[0]!='1'): 		####the same procedure is repeated for row names
					RN_sc=RN_sc+1
			except:
				continue
	RN=[]
	if RN_sc>1:
		for i in ff:
			if len(i.split())>1:	
				RN.append(i.split()[0])		###row names separated by spaces or tabulations are appended to 'RN'.			
			elif len(i.split())==1:
				RN.append(i[0])		####row names not separated by spaces or tabulations are appended to 'RN'.
		if CN_sc>1:
			RN=RN[1:]		###if column names are present, the first element of 'RN' is not considered as a row name.			
	M=[]		###the matrix included in f is created in 'M', by keeping into account (see next comments):
	for i in ff:
		row=[]				
		if RN_sc>1:		### The presence of row names;				
			if len(i.split())>1:		### The presence of spaces and/or tabulations between matrix cells;
				for j in i.split()[1:]:
					if j=='0' or j=='1':		### The content of each cell; 
						row.append(int(j))
			elif len(i.split())==1:		### The presence of spaces and/or tabulations between matrix cells;
				for j in i[1:]:
					if j=='0' or j=='1':		### The content of each cell;
						row.append(int(j))						
		else:
			if len(i.split())>1:		### The presence of spaces and/or tabulations between matrix cells;
				for j in i.split():
					if j=='0' or j=='1':
						row.append(int(j))
			elif len(i.split())==1:		### The presence of spaces and/or tabulations between matrix cells;
				for j in i:
					if '0' in j or '1' in j:		### The content of each cell;
						row.append(int(j))						
		M.append(row)
	if CN_sc>1:		###The presence of column names.
		M=M[1:]
	if len(CN)==len(M[0])+1:
		CN=CN[1:]
	return M,RN,CN		###The script finally return the lists respectively containing the matrix, the row names, and the column names.



###Function to pack the matrix, i.e. to order it according to row and column sums.
def pack(m,rownames=[],colnames=[],PACK='yes'):
	if PACK=='no':
		return m,rownames,colnames
	else:
		prownames=[]
		pcolnames=[]
		sr=[]
		for i in range(len(m)):
			sr.append([sum(m[i]),i])
		sr.sort(reverse=True)
		M_sr=[]
		for i in sr:
			M_sr.append(m[i[1]])
			if len(rownames)>0:
				prownames.append(rownames[i[1]])
		Mpr=TR(M_sr)
		sc=[]
		for i in range(len(Mpr)):
			sc.append([sum(Mpr[i]),i])
		sc.sort(reverse=True)
		Mpc=[]
		for i in sc:
			Mpc.append(Mpr[i[1]])
			if len(colnames)>0:
				pcolnames.append(colnames[i[1]])
		Mp=TR(Mpc)
		return Mp,prownames,pcolnames





####Function to find root of a mathematical function

def FindRoot( fun, a, b, tol = 0.005 ):
	a = float(a)
	b = float(b)
	c = (a+b)/2
	while float(abs(fun( c ))) > tol:
		if a == c or b == c: 
			break
		if (fun(c))*(fun(b))>0:
			b = c
		else:
			a = c
		c = (a+b)/2
	return c




###Function to transpose a matrix
def TR(m):
	return map(list, zip(*m))


###Function to erase empty rows and columns
def NO_EMPTY(m):
	EM=[]
	for i in m:
		if sum(i)!=0:
			EM.append(i)
	EM_t=TR(EM)
	EM=[]		
	for i in EM_t:
		if sum(i)!=0:
			EM.append(i)
	M=TR(EM)
	return M

###Function to obtain adjacency matrix of a matrix

def adjac(M):
	l=[]
	for rrr in range(len(M)):
		for ccc in range(len(M[rrr])):
			if M[rrr][ccc]==1:
				if ['R'+str(rrr),'C'+str(ccc)] not in l:
					l.append(['R'+str(rrr),'C'+str(ccc)])
	RN=[]
	CN=[]
	for i in l:
		RN.append(i[0])
		CN.append(i[1])
	RN=list(set(RN))
	CN=list(set(CN))
	RN.sort()
	CN.sort()
	L=RN+CN
	size=len(L)
	M=zeros(shape=(size,size))
	for i in l:
		r=L.index(i[0])
		c=L.index(i[1])
		M[r][c]=1
		M[c][r]=1
	return M







###NULL MODELS USED TO GENERATE RANDOM MATRICES NECESSARY TO COMPUTE Z SCORES

###Null model 1 - Equiprobable row and column sums
def NM1(matrix,nm1_pool):
	shuffle(nm1_pool)	
	R=len(matrix)
	C=len(matrix[0])	
	sM=[]
	for i in range(R):
		row=[]
		for j in range(C):
			row.append(nm1_pool[i*C+j])
		sM.append(row)
	return sM

###Null model 2 - CE
def NM2(matrix):
	Ctot=list(sum(array(matrix)))
	Rtot=list(sum(array(TR(matrix))))	
	R=len(matrix)
	C=len(matrix[0])	
	sM=[]
	for i in range(R):
		row=[]
		for j in range(C):
			if random()<=((float(Rtot[i])/C+float(Ctot[j])/R)/2.0):
				row.append(1)
			else:
				row.append(0)
		sM.append(row)	
	return sM



###Null model 3 - FE
def NM3(matrix):
	sM=[]
	for i in matrix:
		sr=i
		shuffle(sr)
		sM.append(sr)
	return sM



###Null model 4 - EF
def NM4(matrix):
	matrix=TR(matrix)
	tsM=[]
	for i in matrix:
		row=i
		shuffle(row)
		tsM.append(row)
	sM=TR(tsM)
	return sM 
	


###Null model 5 - FF
def NM5(matrix):
	sM=matrix	
	rn=range(len(sM))	
	cn=range(len(sM[0]))
	swaps=len(sM)*len(sM[0])
	if swaps>30000:
		swaps=30000
	for i in range(swaps):
		r=sample(rn,2)
		c=sample(cn,2)
		if sM[r[0]][c[0]]!=sM[r[1]][c[0]] and sM[r[0]][c[1]]!=sM[r[1]][c[1]] and sM[r[0]][c[1]]!=sM[r[0]][c[0]]:
			sM[r[0]][c[0]],sM[r[0]][c[1]]=sM[r[0]][c[1]],sM[r[0]][c[0]]
			sM[r[1]][c[0]],sM[r[1]][c[1]]=sM[r[1]][c[1]],sM[r[1]][c[0]]
	return sM




###Null model 6 - Babe Ruth (Strona et al. unpublished)
def find_presences(input_matrix):
	num_rows, num_cols = len(input_matrix),len(input_matrix[0])
	hp = []
	iters = num_rows if num_cols >= num_rows else num_cols
	if num_cols >= num_rows:
		input_matrix_b = input_matrix
	else:
		input_matrix_b = TR(input_matrix)
	for r in range(iters):
		hp.append(where(array(input_matrix_b[r]) == 1)[0])
	return hp



def NM6(m,r_hp,num_iterations=-1):
	num_rows, num_cols = len(m),len(m[0])
	l = range(len(r_hp))
	num_iters = 5 * min(num_rows, num_cols) if num_iterations == -1 else num_iterations
	for rep in range(num_iters):
		ab = sample(l, 2)
		a = ab[0]
		b = ab[1]
		ab = set(r_hp[a]) & set(r_hp[b])
		a_ba = set(r_hp[a]) - ab
		if len(a_ba) != 0:
			b_aa = set(r_hp[b]) - ab
			if len(b_aa) != 0:
				ab = list(ab)
				a_ba = list(a_ba)
				b_aa = list(b_aa)
				shuffle(a_ba)
				shuffle(b_aa)
				swap_extent = randint(1, min(len(a_ba), len(b_aa)))
				r_hp[a] = ab+a_ba[:-swap_extent]+b_aa[-swap_extent:]
				r_hp[b] = ab+b_aa[:-swap_extent]+a_ba[-swap_extent:]
	out_mat = zeros([num_rows, num_cols], dtype='int8') if num_cols >= num_rows else zeros([num_cols,num_rows], dtype='int8')
	for r in range(min(num_rows, num_cols)):
		out_mat[r, r_hp[r]] = 1
	result = out_mat if num_cols >= num_rows else out_mat.T
	return result





####NESTEDNESS METRICS

###Compute Matrix NODF (total, among rows, among columns)
def NODF(m):
	m1=array(m).copy()
	R_nes=[]
	for i in range(len(m1)):
		for j in range(len(m1)):
			if i<j:
				try:
					R_nes.append((sum(m1[i]*m1[j])/float(sum(m1[j])))*(sum(m1[i])>sum(m1[j])))
				except:
					pass
	m2=m1.transpose()
	C_nes=[]
	for i in range(len(m2)):
		for j in range(len(m2)):
			if i<j:
				try:
					C_nes.append((sum(m2[i]*m2[j])/float(sum(m2[j])))*(sum(m2[i])>sum(m2[j])))	
				except:
					pass
	if C_nes==[] or R_nes==[]:
		print m
	return(mean(R_nes+C_nes)*100,mean(R_nes)*100,mean(C_nes)*100)









####Compute Matrix Temperature

def TEMP(m):
	nrow=len(m)
	ncol=len(m[0])
	r=[]
	for i in range(1,nrow+1):
		r.append((i-0.5)/(nrow))
	c=[]
	for i in range(1,ncol+1):
		c.append((i-0.5)/(ncol))
	dis=[]
	for i in range(nrow):
		row=[]
		for j in range(ncol):
			row.append(r[i])
		dis.append(row)
	outer=[]
	for i in r:
		row=[]
		for j in c:
			row.append(i-j)
		outer.append(row)
	outer=array(outer)
	totdis=1-abs(outer)
	tot=0.0
	for i in m:
		for j in i:	
			if j==1:
				tot=tot+1
	global fill
	fill=tot/(nrow*ncol)
	def fillfun(x,p):
		return(1 - (1-(1-x)**p)**(1/p))
	def intfun(p):
		return(simple_integral(fillfun,0,1,p)-fill)		
	p=FindRoot(intfun,0,20)
	def nfillfun(x):
		return(fillfun(x,p)-a-x)
	out=[]
	for i in r:
		row=[]
		for j in c:
			row.append(0)
		out.append(row)
	for i in range(len(r)):
		for j in range(len(c)):
			a=c[j]-r[i]
			out[i][j]=FindRoot(nfillfun,0,1)
	u=list((array(dis)-array(out))/totdis)
	for i in range(nrow):
		row=[]
		for j in range(ncol):
			if (u[i][j]<0 and m[i][j]==1) or (u[i][j]>0 and m[i][j]==0):
				u[i][j]=0
	u=array(u)**2
	temp=(sum(sum(u))*100)/float(nrow*ncol)/0.04145
	if temp>100:
		temp=100
	return temp






####Compute Brualdi and Sanderson's discrepancy index
def BR(ma):
	a=ma[:]
	m=[]
	for i in range(len(a)):
		row=[]
		for j in range(len(a[i])):
			row=row+[a[i][j]]
		m.append(row)
	for j in m:
		j.sort(reverse=True)
	br=0
	for i in range(len(m)):
		for j in range(len(m[i])):
			if a[i][j]==1 and m[i][j]==0:
				br=br+1
	return br






#### Compute nestedness according to Staniczenko et al. (2013, The ghost of nestedness in ecological networks, Nature Communications 4,1391 doi:10.1038/ncomms2422)
def GH(m):
	return max(eigvals(adjac(array(m))))
 





###Create graphs from original matrix and packed matrix

def show_mat(m):
	R=len(m)
	C=len(m[0])
	if R<500 and C<500:	
		IH=500
		IW=500
		R_r=IH/R+1
		C_r=IW/C+1
		M=zeros((IH,IW),dtype=int)
		for i in range(IH):
			for j in range(IW):
				M[i][j]=-(m[i/R_r][j/C_r]-1)
	else:
		IH=R
		IW=C
		M=abs(array(m)-1)	
	im_letters=["a","b","c","d","e","f","g","h","i","j"]	
	shuffle(im_letters)
	im_name=str()
	for i in im_letters:
		im_name=im_name+i
	im_NAME=("static/graphics/"+im_name+".png")		
	f = open(im_NAME, 'wb')
	w = png.Writer(IH,IW, greyscale=True, bitdepth=1)
	w.write(f, M)
	f.close()
	return ("/static/graphics/"+im_name+".png")




def show_mat_old(m):	#this requires the Python Image module: since the installation of this module in Windows is not straightforward, I have replaced this function with the one above.
	image=Image.new("L",(len(m[0]),len(m)))
	for i in range(len(m[0])):
		for j in range(len(m)):
			if m[j][i]==0:
				image.putpixel((i,j),255)
	image=image.resize((400, 400), Image.NEAREST) 	
	im_letters=["a","b","c","d","e","f","g","h","i","j"]	
	shuffle(im_letters)
	im_name=str()
	for i in im_letters:
		im_name=im_name+i
	image.save("static/graphics/"+im_name+".gif")		
	return ("/static/graphics/"+im_name+".gif")

 
###Erase graph files from static/graphic directory, on the basis of creation time
def erase_graphs():
	names=listdir("static/graphics/")
	for i in names:
		a=getmtime("static/graphics/"+i)
		b=time()
		if b-a>30:
			remove("static/graphics/"+i)



#############################################################################
####MAIN FUNCTION TO COMPUTE NESTEDNESS ACCORDING TO USER DEFINED PARAMETERS; it takes parameters from input page ('index.html') and pass the results to output page ('out.html')
def nested(request):
	erase_graphs()
	BATCH=[]
	try:	
		BATCH = request.POST["batch"]		#perform batch analysis?
	except:
		pass
	batch_dir=str()
	for i in BATCH:
		batch_dir=batch_dir+i
	if len(batch_dir)>0:
		try:
			batch=listdir(batch_dir)
		except:
			batch="WRONG"
	else:
		batch="NO"
	try:	
		m = request.POST["matrix"]
	except:
		pass
	#try:	
	#	Pack=request.POST["PACK"]		#Ignore empty rows and columns?			
	#except:
	#	Pack='no'		
	Pack='yes'	
	try:	
		ERA=request.POST["ERA"]		#Ignore empty rows and columns?		
	except:
		ERA='no'	
	I=[]	#metric selection
	try:	
		index=request.POST["NODF"]	
		I.append("NODF")
		ERA='ERA_ok'
	except:
		pass
	try:	
		index=request.POST["T"]	
		I.append("T")
	except:
		pass
	try:	
		index=request.POST["BR"]	
		I.append("BR")
	except:
		pass
	try:	
		index=request.POST["GH"]	
		I.append("GH")
	except:
		pass
	try:	
		NMy=request.POST["NMy"]	#Perform null model analysis?	
	except:
		pass	
	try:	
		NM=request.POST["NM"]
	except:
		pass
	try:	
		input=request.POST["input"]
		if input=='ram':		#Create a sample random matrix
			r_size=request.POST["r_size"]		#size of the random matrix
			r_nest=request.POST["r_nest"]		#nestedness degree of the random matrix
	except:
		return render_to_response('no_input.html',context_instance=RequestContext(request))
	try:	
		SimN=request.POST["SimN"]	#number of simulated matrix used to compute Z values and Relative Nestedness values
	except:
		pass
	try:
		if request.method == 'POST':
			form=UploadFileForm(request.POST, request.FILES)
			f=(request.FILES['file'])
			f_mat=[]
			for i in f:
				f_mat.append(i)
			FM,FRN,FCN=auto_format(f_mat)
	except:
		pass
	if input!='bat':
	####################################pasted matrix
		if input=='pas':	
			M,RN,CN=auto_format(m.split("\n"))
			file_name="Pasted Matrix"
	########################################end pasted matrix
		elif input=='fil':
			form=UploadFileForm(request.POST, request.FILES)		
			for filename, file in request.FILES.iteritems():
				file_name = request.FILES[filename].name
			M=FM
			RN=FRN
			CN=FCN
		elif input=='ram':
			M,RN,CN=RMAT(r_size,r_nest)
			file_name="Random Matrix"
	####################################erase empty rows and cols
		if ERA=='ERA_ok':
			M=NO_EMPTY(M)
	####Check matrix size (not present in static version)
		R=len(M)
		C=len(M[0])
		#if R*C>22500:
		#	return render_to_response('big_mat.html',locals()) 
########	##matrix definition M#######
		if RN==[]:
			RN=range(len(M))		###if row names are not present, they are defined as the range of integers between 0 and the total number of rows.
		if CN==[]:
			CN=range(len(M[0]))		###if column names are not present, they are defined as the range of integers between 0 and the total number of columns.
		nm1_pool=[]
		for i in M:
			for j in i:
				if j==1 or j==0:
					nm1_pool.append(j)
		Occ=sum(nm1_pool)
		Fill=app(float(Occ)/(R*C))
		MR=[]
		for i in M:
			row=[]
			for j in i:
				row.append(j)
			MR.append(row)
		p_M,PRN,PCN=pack(M,RN,CN,Pack)	
		if "NODF" in I:
			N,Nr,Nc=map(float,map(app,NODF(p_M)))
		else:
			N="_"
			Nr="_"
			Nc="_"		
		if "T" in I:
			T=float(app(TEMP(p_M)))
		else:
			T="_"		
		if "BR" in I:
			B=float(app(BR(p_M)))
		else:
			B="_"
		if "GH" in I:
			G=float(app(GH(p_M)))
		else:
			G="_"
		if "NODF" in I:
			SR_nodf=[]
			SR_nodf_r=[]
			SR_nodf_c=[]
		if "T" in I: 
			SR_t=[]
		if "BR" in I: 
			SR_br=[]
		if "GH" in I: 
			SR_gh=[]	
		index=[["<strong>METRIC   </strong>","<strong>INDEX   </strong>","<strong>Z-SCORE   </strong>", "<strong>RN   </strong>", "<strong>NESTED?   </strong>"]]	
		NM_index=[["<strong>METRIC   </strong>","<strong>MEAN   </strong>","<strong>ST.DEV.   </strong>","<strong>MIN   </strong>","<strong>MAX   </strong>"]]	
		NM_name="_"
		NM_names=['Equiprobable row and column totals (EE)','Proportional column and row totals (CE)','Equiprobable row totals, fixed column totals (EF)','Fixed row totals, equiprobable column totals (FE)','Fixed column and row totals (FF)','Babe Ruth Algorithm']	
		if "NMy" in locals():
			NM_name=NM_names[int(NM)-1]
			if SimN=='':
				SimN=50
			if NM=="6":
				r_hp=find_presences(MR)
			for i in range(int(SimN)):		
				if NM=="1":
					m=NM1(MR,nm1_pool)
				elif NM=="2":
					m=NM2(MR)
				elif NM=="3":
					m=NM3(MR)
				elif NM=="4":
					m=NM4(MR)
				elif NM=="5":
					m=NM5(MR)
				elif NM=="6":
					m=NM6(MR,r_hp)
				if ERA=='ERA_ok':
					m=NO_EMPTY(m)
				m,mPRN,mPCN=pack(m,PACK=pack)
				if "NODF" in I:
					sr_nodf,sr_nodf_r,sr_nodf_c=NODF(m)
					SR_nodf.append(sr_nodf)
					SR_nodf_r.append(sr_nodf_r)
					SR_nodf_c.append(sr_nodf_c)
				if "T" in I: 
					SR_t.append(TEMP(m))
				if "BR" in I: 
					SR_br.append(BR(m))
				if "GH" in I: 
					SR_gh.append(GH(m))
			#null model statistics
			if "NODF" in I:
				SR_nodf=array(SR_nodf)
				SR_nodf=SR_nodf[~isnan(SR_nodf)]
				min_NM=minimum(SR_nodf)
				max_NM=maximum(SR_nodf)
				mean_NM=mean(SR_nodf)
				std_NM=std(SR_nodf)
				NM_index.append(["NODF",app(mean_NM),app(std_NM),app(min_NM),app(max_NM)])
				SR_nodf_r=array(SR_nodf_r)
				SR_nodf_r=SR_nodf_r[~isnan(SR_nodf_r)]				
				min_NM=minimum(SR_nodf_r)
				max_NM=maximum(SR_nodf_r)
				mean_NM=mean(SR_nodf_r)
				std_NM=std(SR_nodf_r)
				NM_index.append(["NODF_row",app(mean_NM),app(std_NM),app(min_NM),app(max_NM)])
				SR_nodf_c=array(SR_nodf_c)
				SR_nodf_c=SR_nodf_c[~isnan(SR_nodf_c)]				
				min_NM=minimum(SR_nodf_c)
				max_NM=maximum(SR_nodf_c)
				mean_NM=mean(SR_nodf_c)
				std_NM=std(SR_nodf_c)
				NM_index.append(["NODF_col",app(mean_NM),app(std_NM),app(min_NM),app(max_NM)])
			if "T" in I: 
				SR_t=array(SR_t)
				SR_t=SR_t[~isnan(SR_t)]				
				min_NM=minimum(SR_t)
				max_NM=maximum(SR_t)
				mean_NM=mean(SR_t)
				std_NM=std(SR_t)
				NM_index.append(["T",app(mean_NM),app(std_NM),app(min_NM),app(max_NM)])
			if "BR" in I:
				SR_br=array(SR_br)
				SR_br=SR_br[~isnan(SR_br)]
				min_NM=minimum(SR_br)
				max_NM=maximum(SR_br)
				mean_NM=mean(SR_br)
				std_NM=std(SR_br)
				NM_index.append(["BR",app(mean_NM),app(std_NM),app(min_NM),app(max_NM)])
			if "GH" in I: 
				SR_gh=array(SR_gh)
				SR_gh=SR_gh[~isnan(SR_gh)]
				min_NM=minimum(SR_gh)
				max_NM=maximum(SR_gh)
				mean_NM=mean(SR_gh)
				std_NM=std(SR_gh)
				NM_index.append(["GH",app(mean_NM),app(std_NM),app(min_NM),app(max_NM)])
			if "NODF" in I:
				if mean(SR_nodf)!=0:
					RN_n=(N-mean(SR_nodf))/mean(SR_nodf)
				else:
					RN_n="N/A (mean = 0)"
				if std(SR_nodf)!=0:
					Z_n=(N-mean(SR_nodf))/std(SR_nodf)
					if Z_n>=3.09:
						N_sig="Yes (p<0.001)"
					elif 3.09>Z_n>=2.330:
						N_sig="Yes (p<0.01)"
					elif 2.330>Z_n>=1.640:
						N_sig="Yes (p<0.05)"
					elif Z_n<1.640:
						N_sig="No (p>0.05)"
					else:
						N_sig="_"
					index.append(["NODF",N,float(app(Z_n)),(app(RN_n)),N_sig])
				else:
					Z_n="N/A (std = 0)"
					N_sig="N/A (std = 0)"
					index.append(["NODF",N,Z_n,(app(RN_n)),N_sig])
				if mean(SR_nodf_r)!=0:
					RN_n=(Nr-mean(SR_nodf_r))/mean(SR_nodf_r)
				else:
					RN_n="N/A (mean = 0)"	
				if std(SR_nodf_r)!=0:
					Z_n=(Nr-mean(SR_nodf_r))/std(SR_nodf_r)
					if Z_n>=3.09:
						N_sig="Yes (p<0.001)"
					elif 3.09>Z_n>=2.330:
						N_sig="Yes (p<0.01)"
					elif 2.330>Z_n>=1.640:
						N_sig="Yes (p<0.05)"
					elif Z_n<1.640:
						N_sig="No (p>0.05)"
					else:
						N_sig="_"
					index.append(["NODF_row",Nr,float(app(Z_n)),(app(RN_n)),N_sig])
				else:
					Z_n="N/A (std = 0)"
					N_sig="N/A (std = 0)"
					index.append(["NODF_row",N,Z_n,(app(RN_n)),N_sig])
				if mean(SR_nodf_c)!=0:
					RN_n=(Nc-mean(SR_nodf_c))/mean(SR_nodf_c)
				else:
					RN_n="N/A (mean = 0)"	
				if std(SR_nodf_c)!=0:
					Z_n=(Nc-mean(SR_nodf_c))/std(SR_nodf_c)
					if Z_n>=3.09:
						N_sig="Yes (p<0.001)"
					elif 3.09>Z_n>=2.330:
						N_sig="Yes (p<0.01)"
					elif 2.330>Z_n>=1.640:
						N_sig="Yes (p<0.05)"
					elif Z_n<1.640:
						N_sig="No (p>0.05)"
					else:
						N_sig="_"
					index.append(["NODF_col",Nc,float(app(Z_n)),(app(RN_n)),N_sig])
				else:
					Z_n="N/A (std = 0)"
					N_sig="N/A (std = 0)"
					index.append(["NODF_col",N,Z_n,(app(RN_n)),N_sig])
			else:
				Z_n="_"			
			if "T" in I:
				if mean(SR_t)!=0:	
					RN_t=(T-mean(SR_t))/mean(SR_t)
				else:
					RN_t="N/A (mean = 0)"	
				if std(SR_t)!=0: 
					Z_t=(T-mean(SR_t))/std(SR_t)
					if Z_t<=-3.09:
						T_sig="Yes (p<0.001)"
					elif -3.09<Z_t<=-2.330:
						T_sig="Yes (p<0.01)"
					elif -2.330<Z_t<=-1.640:
						T_sig="Yes (p<0.05)"
					elif Z_t>-1.640:
						T_sig="No (p>0.05)"
					else:
						T_sig="_"	
					index.append(["T",T,float(app(Z_t)),(app(RN_t)),T_sig])
				else:
					Z_t="N/A (std = 0)"
					T_sig="N/A (std = 0)"
					index.append(["T",T,Z_t,(app(RN_t)),T_sig])
			else:
				Z_t="_"
			if "BR" in I:
				if mean(SR_br)!=0:
					RN_b=(B-mean(SR_br))/mean(SR_br)	
				else:
					RN_b="N/A (mean = 0)"
				if std(SR_br)!=0:
					Z_b=(B-mean(SR_br))/std(SR_br)
					if Z_b<=-3.09:
						B_sig="Yes (p<0.001)"
					elif -3.09<Z_b<=-2.330:
						B_sig="Yes (p<0.01)"
					elif -2.330<Z_b<=-1.640:
						B_sig="Yes (p<0.05)"
					elif Z_b>-1.640:
						B_sig="No (p>0.05)"
					else:
						B_sig="_"			
					index.append(["BR",B,float(app(Z_b)),(app(RN_b)),B_sig])
				else:
					Z_b="N/A (std = 0)"
					B_sig="N/A (std = 0)"
					index.append(["BR",B,Z_b,(app(RN_b)),B_sig])
			else:
				Z_b="_"
			if "GH" in I:
				if mean(SR_gh)!=0:
					RN_gh=(G-mean(SR_gh))/mean(SR_gh)	
				else:
					RN_gh="N/A (mean = 0)"
				if std(SR_gh)>0.0001:
					Z_gh=(G-mean(SR_gh))/std(SR_gh)
					if Z_gh>=3.09:
						G_sig="Yes (p<0.001)"
					elif 3.09>Z_gh>=2.330:
						G_sig="Yes (p<0.01)"
					elif 2.330>Z_gh>=1.640:
						G_sig="Yes (p<0.05)"
					elif Z_gh<1.640:
						G_sig="No (p>0.05)"
					else:
						G_sig="_"			
					index.append(["GH",G,float(app(Z_gh)),(app(RN_gh)),G_sig])
				else:
					Z_gh="N/A (std = 0)"
					G_sig="N/A (std = 0)"
					index.append(["GH",G,Z_gh,(app(RN_gh)),G_sig])
			else:
				Z_gh="_"
		else:
			index=[["<strong>METRIC</strong>","<strong>VALUE</strong>"]]
			if "NODF" in I:
				index.append(["NODF",N])
			if "T" in I: 
				index.append(["T",T])
			if "BR" in I: 
				index.append(["BR",B])
			if "GH" in I: 
				index.append(["GH",G])
			Z_n=Z_t=Z_b=Z_gh="_"	
		date=gettime()
		MAT_GRA=show_mat(M)	
		PMAT_GRA=show_mat(p_M)
		RN_form=str()
		for i in RN:
			RN_form=RN_form+str(i)+" - "
		RN_form=RN_form[:-3]
		PRN_form=str()
		for i in PRN:
			PRN_form=PRN_form+str(i)+" - "
		PRN_form=PRN_form[:-3]
		CN_form=str()
		for i in CN:
			CN_form=CN_form+str(i)+" - "
		CN_form=CN_form[:-3]
		PCN_form=str()
		for i in PCN:
			PCN_form=PCN_form+str(i)+" - "
		PCN_form=PCN_form[:-3]	
		return render_to_response('out.html',locals(),context_instance=RequestContext(request))
##########################################################################
##############################################PERFORM BATCH ANALYSIS
##########################################################################	
	elif batch not in ['','NO','WRONG']:
		index=[]	
		NM_name="_"
		NM_names=['Equiprobable row and column totals (EE)','Proportional column and row totals (CE)','Equiprobable row totals, fixed column totals (EF)','Fixed row totals, equiprobable column totals (FE)','Fixed column and row totals (FF)','Babe Ruth Algorithm']	
		if "NMy" in locals():
			NM_name=NM_names[int(NM)-1]
			if SimN=='':
				SimN=50
		for fff in batch:
			try:
				f=open(batch_dir+"/"+fff)
				f_mat=[]
				for i in f:
					f_mat.append(i)
				FM,FRN,FCN=auto_format(f_mat)
				M=FM
				RN=FRN
				CN=FCN				
####################################erase empty rows and cols
				if ERA=='ERA_ok':
					M=NO_EMPTY(M)
				####Check matrix size (not present in static version)
				R=len(M)
				C=len(M[0])
				if R<2 or C<2:
					raise Exception("Likely not a matrix")
				###matrix definition M#######
				if RN==[]:
					RN=range(len(M))		###if row names are not present, they are defined as the range of integrals between 0 and the total number of rows.
				if CN==[]:
					CN=range(len(M[0]))		###if column names are not present, they are defined as the range of integrals between 0 and the total number of columns.
				nm1_pool=[]
				for i in M:
					for j in i:
						if j==1 or j==0:
							nm1_pool.append(j)
				Occ=sum(nm1_pool)
				MR=[]
				for i in M:
					row=[]
					for j in i:
						row.append(j)
					MR.append(row)
				p_M,PRN,PCN=pack(M,RN,CN,Pack)	
				if "NODF" in I:
					N,Nr,Nc=map(float,map(app,NODF(p_M)))
				else:
					N="_"
					Nr="_"
					Nc="_"	
				if "T" in I:
					T=float(app(TEMP(p_M)))
				else:
					T="_"		
				if "BR" in I:
					B=float(app(BR(p_M)))
				else:
					B="_"
				if "GH" in I:
					G=float(app(GH(p_M)))
				else:
					G="_"
				if "NODF" in I:
					SR_nodf=[]
					SR_nodf_r=[]
					SR_nodf_c=[]
				if "T" in I: 
					SR_t=[]
				if "BR" in I: 
					SR_br=[]
				if "GH" in I: 
					SR_gh=[]	
				if "NMy" in locals():
					if NM=="6":
						r_hp=find_presences(MR)
					for i in range(int(SimN)):		
						if NM=="1":
							m=NM1(MR,nm1_pool)
						elif NM=="2":
							m=NM2(MR)
						elif NM=="3":
							m=NM3(MR)
						elif NM=="4":
							m=NM4(MR)
						elif NM=="5":
							m=NM5(MR)
						elif NM=="6":
							m=NM6(MR,r_hp)
						if ERA=='ERA_ok':
							m=NO_EMPTY(m)
						m,mPRN,mPCN=pack(m,PACK=Pack)
						if "NODF" in I:
							sr_nodf,sr_nodf_r,sr_nodf_c=NODF(m)
							SR_nodf.append(sr_nodf)
							SR_nodf_r.append(sr_nodf_r)
							SR_nodf_c.append(sr_nodf_c)
						if "T" in I: 
							SR_t.append(TEMP(m))
						if "BR" in I: 
							SR_br.append(BR(m))
						if "GH" in I: 
							SR_gh.append(GH(m))
					#null model statistics
					if "NODF" in I:
						SR_nodf=array(SR_nodf)
						SR_nodf=SR_nodf[~isnan(SR_nodf)]
						min_NM=minimum(SR_nodf)
						max_NM=maximum(SR_nodf)
						mean_NM=mean(SR_nodf)
						std_NM=std(SR_nodf)
						if mean(SR_nodf)!=0:
							RN_n=(N-mean(SR_nodf))/mean(SR_nodf)
						else:
							RN_n="N/A (mean = 0)"	
						if std(SR_nodf)!=0:
							Z_n=(N-mean(SR_nodf))/std(SR_nodf)
							if Z_n>=3.09:
								N_sig="Yes (p<0.001)"
							elif 3.09>Z_n>=2.330:
								N_sig="Yes (p<0.01)"
							elif 2.330>Z_n>=1.640:
								N_sig="Yes (p<0.05)"
							elif Z_n<1.640:
								N_sig="No  (p>0.05)"
							else:
								N_sig="_"
							index.append([fff,R,C,Occ,"NODF",N,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),float(app(Z_n)),(app(RN_n)),N_sig])
						else:
							Z_n="N/A (std = 0)"
							N_sig="N/A (std = 0)"
							index.append([fff,R,C,Occ,"NODF",N,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),Z_n,(app(RN_n)),N_sig])		
						SR_nodf_r=array(SR_nodf_r)
						SR_nodf_r=SR_nodf_r[~isnan(SR_nodf_r)]
						min_NM=minimum(SR_nodf_r)
						max_NM=maximum(SR_nodf_r)
						mean_NM=mean(SR_nodf_r)
						std_NM=std(SR_nodf_r)
						if mean(SR_nodf_r)!=0:
							RN_n=(Nr-mean(SR_nodf_r))/mean(SR_nodf_r)
						else:
							RN_n="N/A (mean = 0)"
						if std(SR_nodf_r)!=0:
							Z_n=(Nr-mean(SR_nodf_r))/std(SR_nodf_r)
							if Z_n>=3.09:
								N_sig="Yes (p<0.001)"
							elif 3.09>Z_n>=2.330:
								N_sig="Yes (p<0.01)"
							elif 2.330>Z_n>=1.640:
								N_sig="Yes (p<0.05)"
							elif Z_n<1.640:
								N_sig="No  (p>0.05)"
							else:
								N_sig="_"
							index.append([fff,R,C,Occ,"NODF_row",Nr,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),float(app(Z_n)),(app(RN_n)),N_sig])
						else:
							Z_n="N/A (std = 0)"
							N_sig="N/A (std = 0)"
							index.append([fff,R,C,Occ,"NODF_row",Nr,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),Z_n,(app(RN_n)),N_sig])		
						SR_nodf_c=array(SR_nodf_c)
						SR_nodf_c=SR_nodf_c[~isnan(SR_nodf_c)]
						min_NM=minimum(SR_nodf_c)
						max_NM=maximum(SR_nodf_c)
						mean_NM=mean(SR_nodf_c)
						std_NM=std(SR_nodf_c)
						if mean(SR_nodf_c)!=0:
							RN_n=(Nc-mean(SR_nodf_c))/mean(SR_nodf_c)
						else:
							RN_n="N/A (mean = 0)"
						if std(SR_nodf_c)!=0:
							Z_n=(Nc-mean(SR_nodf_c))/std(SR_nodf_c)
							if Z_n>=3.09:
								N_sig="Yes (p<0.001)"
							elif 3.09>Z_n>=2.330:
								N_sig="Yes (p<0.01)"
							elif 2.330>Z_n>=1.640:
								N_sig="Yes (p<0.05)"
							elif Z_n<1.640:
								N_sig="No  (p>0.05)"
							else:
								N_sig="_"
							index.append([fff,R,C,Occ,"NODF_col",Nc,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),float(app(Z_n)),(app(RN_n)),N_sig])
						else:
							Z_n="N/A (std = 0)"
							N_sig="N/A (std = 0)"
							index.append([fff,R,C,Occ,"NODF_col",Nc,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),Z_n,(app(RN_n)),N_sig])		
					else:
						Z_n="_"		
					if "T" in I:
						SR_t=array(SR_t)
						SR_t=SR_t[~isnan(SR_t)]
						min_NM=minimum(SR_t)
						max_NM=maximum(SR_t)
						mean_NM=mean(SR_t)
						std_NM=std(SR_t)
						if mean(SR_t)!=0:
							RN_t=(T-mean(SR_t))/mean(SR_t)
						else:
							RN_t="N/A (mean = 0)"
						if std(SR_t)!=0: 
							Z_t=(T-mean(SR_t))/std(SR_t)
							if Z_t<=-3.09:
								T_sig="Yes (p<0.001)"
							elif -3.09<Z_t<=-2.330:
								T_sig="Yes (p<0.01)"
							elif -2.330<Z_t<=-1.640:
								T_sig="Yes (p<0.05)"
							elif Z_t>-1.640:
								T_sig="No  (p>0.05)"
							else:
								T_sig="_"	
							index.append([fff,R,C,Occ,"T",T,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),float(app(Z_t)),(app(RN_t)),T_sig])
						else:
							Z_t="N/A (std = 0)"
							T_sig="N/A (std = 0)"
							index.append([fff,R,C,Occ,"T",T,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),Z_t,(app(RN_t)),T_sig])
					else:
						Z_t="_"	
					if "BR" in I:
						SR_br=array(SR_br)
						SR_br=SR_br[~isnan(SR_br)]
						min_NM=minimum(SR_br)
						max_NM=maximum(SR_br)
						mean_NM=mean(SR_br)
						std_NM=std(SR_br)
						if mean(SR_br)!=0:
							RN_b=(B-mean(SR_br))/mean(SR_br)
						else:
							RN_b="N/A (mean = 0)"	
						if std(SR_br)!=0: 
							Z_b=(B-mean(SR_br))/std(SR_br)
							if Z_b<=-3.09:
								B_sig="Yes (p<0.001)"
							elif -3.09<Z_b<=-2.330:
								B_sig="Yes (p<0.01)"
							elif -2.330<Z_b<=-1.640:
								B_sig="Yes (p<0.05)"
							elif Z_b>-1.640:
								B_sig="No  (p>0.05)"
							else:
								B_sig="_"			
							index.append([fff,R,C,Occ,"BR",B,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),float(app(Z_b)),(app(RN_b)),B_sig])
						else:
							Z_b="N/A (std = 0)"
							B_sig="N/A (std = 0)"
							index.append([fff,R,C,Occ,"BR",B,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),Z_b,(app(RN_b)),B_sig])
					else:
						Z_b="_"
					if "GH" in I:
						SR_gh=array(SR_gh)
						SR_gh=SR_gh[~isnan(SR_gh)]
						min_NM=minimum(SR_gh)
						max_NM=maximum(SR_gh)
						mean_NM=mean(SR_gh)
						std_NM=std(SR_gh)
						if mean(SR_gh)!=0:
							RN_gh=(G-mean(SR_gh))/mean(SR_gh)
						else:
							RN_gh="N/A (mean = 0)"	
						if std(SR_gh)!=0: 
							Z_gh=(G-mean(SR_gh))/std(SR_gh)
							if Z_gh>=3.09:
								G_sig="Yes (p<0.001)"
							elif 3.09>Z_gh>=2.330:
								G_sig="Yes (p<0.01)"
							elif 2.330>Z_gh>=1.640:
								G_sig="Yes (p<0.05)"
							elif Z_gh<1.640:
								G_sig="No  (p>0.05)"
							else:
								G_sig="_"			
							index.append([fff,R,C,Occ,"GH",G,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),float(app(Z_gh)),(app(RN_gh)),G_sig])
						else:
							Z_gh="N/A (std = 0)"
							G_sig="N/A (std = 0)"
							index.append([fff,R,C,Occ,"GH",G,app(mean_NM),app(std_NM),app(min_NM),app(max_NM),Z_gh,(app(RN_gh)),G_sig])
					else:
						Z_gh="_"		
				else:
					#index=[["<strong>METRIC</strong>","<strong>VALUE</strong>"]]
					if "NODF" in I:
						index.append([fff,R,C,Occ,"NODF",N])
					if "T" in I: 
						index.append([fff,R,C,Occ,"T",T])
					if "BR" in I: 
						index.append([fff,R,C,Occ,"BR",B])
					if "GH" in I: 
						index.append([fff,R,C,Occ,"GH",G])
					Z_n=Z_t=Z_b=Z_gh="_"	
				date=gettime()	
			except:
				pass			
	return render_to_response('out_batch.html',locals(),context_instance=RequestContext(request))
		
	
	





