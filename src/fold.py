#!/usr/bin/env python3

import os
import sys
from IPython.utils import io

with io.capture_output() as captured:
  sys.path.append('/src/RoseTTAFold/network')
  import predict_e2e
  from parsers import parse_a3m

import colabfold as cf
import subprocess
import numpy as np

def get_bfactor(pdb_filename):
  bfac = []
  for line in open(pdb_filename,"r"):
    if line[:4] == "ATOM":
      bfac.append(float(line[60:66]))
  return np.array(bfac)

def set_bfactor(pdb_filename, bfac):
  I = open(pdb_filename,"r").readlines()
  O = open(pdb_filename,"w")
  for line in I:
    if line[0:6] == "ATOM  ":
      seq_id = int(line[22:26].strip()) - 1
      O.write(f"{line[:60]}{bfac[seq_id]:6.2f}{line[66:]}")
  O.close()    

def do_scwrl(inputs, outputs, exe="./scwrl4/Scwrl4"):
  subprocess.run([exe,"-i",inputs,"-o",outputs,"-h"],
                  stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
  bfact = get_bfactor(inputs)
  set_bfactor(outputs, bfact)
  return bfact

# gather input
jobname = os.getenv('NAME')
sequence = os.getenv('SEQUENCE')
sequence = sequence.translate(str.maketrans('', '', ' \n\t')).upper()
jobname = jobname+"_"+cf.get_hash(sequence)[:5]

# set method
msa_method = "mmseqs2" #@param ["mmseqs2","single_sequence","custom_a3m"]
#@markdown - `mmseqs2` - FAST method
#@markdown - `single_sequence` - use single sequence input (not recommended, unless a *denovo* design and you dont expect to find any homologous sequences)
#@markdown - `custom_a3m` Upload custom MSA (a3m format)

# tmp directory
prefix = cf.get_hash(sequence)
os.makedirs('tmp', exist_ok=True)
prefix = os.path.join('tmp',prefix)

os.makedirs(jobname, exist_ok=True)

if msa_method == "mmseqs2":
  a3m_lines = cf.run_mmseqs2(sequence, prefix, filter=True)
  with open(f"{jobname}/msa.a3m","w") as a3m:
    a3m.write(a3m_lines)

elif msa_method == "single_sequence":
  with open(f"{jobname}/msa.a3m","w") as a3m:
    a3m.write(f">{jobname}\n{sequence}\n")

elif msa_method == "custom_a3m":
  print("upload custom a3m")
  msa_dict = files.upload()
  lines = msa_dict[list(msa_dict.keys())[0]].decode().splitlines()
  a3m_lines = []
  for line in lines:
    line = line.replace("\x00","")
    if len(line) > 0 and not line.startswith('#'):
      a3m_lines.append(line)

  with open(f"{jobname}/msa.a3m","w") as a3m:
    a3m.write("\n".join(a3m_lines))

msa_all = parse_a3m(f"{jobname}/msa.a3m")
msa_arr = np.unique(msa_all,axis=0)
total_msa_size = len(msa_arr)
if msa_method == "mmseqs2":
  print(f'\n{total_msa_size} Sequences Found in Total (after filtering)\n')
else:
  print(f'\n{total_msa_size} Sequences Found in Total\n')


#@title ## Run RoseTTAFold for mainchain and Scrwl4 for sidechain prediction

# load model
if "rosettafold" not in dir():
  rosettafold = predict_e2e.Predictor(model_dir="weights")

# make prediction using model
rosettafold.predict(f"{jobname}/msa.a3m",f"{jobname}/pred")

# pack sidechains using Scwrl4
plddt = do_scwrl(f"{jobname}/pred.pdb",f"{jobname}/pred.scwrl.pdb")

print(f"Predicted LDDT: {plddt.mean()}")
