import pandas as pd 
import numpy as np 
import base64
import tempfile
import io 
import os
#from google.cloud import storage
import requests

def ot_scheduler(request):

  # Enable CORS
  headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST',
        'Access-Control-Allow-Headers': 'Content-Type'
    }

  if request.method == 'OPTIONS':
    return ('', 204, headers)

  # Decode the base64 string
  request_json = request.get_json()
  doc_data = request_json['doc']
  decoded_bytes = base64.b64decode(doc_data)

  # Write the decoded bytes to a temporary Excel file
  with tempfile.NamedTemporaryFile(suffix='.xlsx', delete=False) as tmp:
    tmp.write(decoded_bytes)
    tmp_path = tmp.name
  print('File Decoded Successfully')

  # Reading the Final Procedure file
  storage_client = storage.Client()
  bucket = storage_client.bucket('disease-classifier-model')
  blob = bucket.blob('Aug 2022-Dec 2023.xlsx') #dataset of previous surgery
  # Download the contents of the blob as bytes and then load into pandas
  data = blob.download_as_bytes()
  excel_data = io.BytesIO(data)
  print('Final Procedure Loaded')

  # Reading the Special Requirement file
  storage_client = storage.Client()
  bucket = storage_client.bucket('disease-classifier-model')
  blob = bucket.blob('Special Equipments.xlsx')
  # Download the contents of the blob as bytes and then load into pandas
  data = blob.download_as_bytes()
  special_equipment = io.BytesIO(data)
  print('Special Equipment Loaded')

  # Reading the nursing  file
  storage_client = storage.Client()
  bucket = storage_client.bucket('disease-classifier-model')
  blob = bucket.blob('Nurshing and Technician OT.xlsx')
  # Download the contents of the blob as bytes and then load into pandas
  data = blob.download_as_bytes()
  nursing_technician_tl = io.BytesIO(data)
  print('Nursing and Technician Loaded')

  # Reading the OT preferences
  storage_client = storage.Client()
  bucket = storage_client.bucket('disease-classifier-model')
  blob = bucket.blob('OT preferences(1).xlsx')
  # Download the contents of the blob as bytes and then load into pandas
  data = blob.download_as_bytes()
  ot_data = io.BytesIO(data)
  print('OT Preferences Loaded')


  # Preprocesing Input
  def preprocessed_surgeries(data):
    q = []
    for i in data:
      i = i.lower()
      i = i.strip()
      i = i.replace(' ','')
      q.append(i)
    return q

  df = pd.read_excel(excel_data)
  print('Final Procedures Read')
  inp = pd.read_excel(tmp_path)
  ### change date
  inp['DATE OF SURGERY'] = pd.to_datetime(inp['DATE OF SURGERY'])
  inp['DATE OF SURGERY'] = inp['DATE OF SURGERY'].dt.strftime('%m/%d/%Y')
  inp['DATE OF SURGERY'] = inp['DATE OF SURGERY'].astype(str)
  print('Input File Read')
  special_equipment = pd.read_excel(special_equipment)
  print('Special Equipment Read')
  nursing_technician_tl = pd.read_excel(nursing_technician_tl)
  print('Nursing File Read')
  ot = pd.read_excel(ot_data)

  # for special equipments
  def preprocess_equipments(data):
    q = []
    for i in data:
      a = ''.join(e for e in i if e.isalnum()).lower()
      q.append(a)
    return q

  # Sorting with the Priority
  def priority_surgery(knowledge_base,input_file,ot):
    input_file.columns = ['Date of Surgery','Age/Sex','Procedure','Surgeon','Department','Name of the Patient','Special Equipment','MRD']
    knowledge_base.columns = ['Procedure','Duration']
    knowledge_base['Processed_Procedures'] = preprocessed_surgeries(knowledge_base['Procedure'])
    input_file['Processed_Procedures'] = preprocessed_surgeries(input_file['Procedure'])

    ## we will use knowledge_base['Processed_Procedures'] to compare with input_file['Processed_Procedures'].from input file we get procedure name.We will map that name in knwoledge base and fecth the cporredsponding duration

    # for ot mapping
    input_file['Processed_Department'] = preprocessed_surgeries(input_file['Department'])
    ot['Processed_Department'] = preprocessed_surgeries(ot['Department'])


    ## map_input is dataframe (rows and coulmns)
    map_input = pd.merge(input_file,knowledge_base,how='inner',on='Processed_Procedures').drop_duplicates(['MRD'])
    map_input = pd.merge(map_input,ot,on='Processed_Department',how='inner')
    filter_map = map_input.drop(['Sr No','Procedure_y','Department_y','Processed_Department','Department_y'],axis=1)

    age = []
    for i in filter_map['Age/Sex']:
      i = i.split('Y')
      age.append(float(i[0]))

    filter_map['Age'] = age

    filter_a = filter_map[filter_map['Duration']>10.0].sort_values(by='Age',ascending=True)

    ## sorting based on duration >10 and sorting as per age 

    filter_b = filter_map[(filter_map['Duration']<10.0) & (filter_map['Age']<12.0)].sort_values(by='Age',ascending=True)
    filter_c = filter_map[(filter_map['Duration']<10.0)& (filter_map['Age']>12.0)].sort_values(by='Duration',ascending=False)

    filter = pd.concat([filter_a,filter_b,filter_c],axis=0)

    ot = []

## ek aprticlur patient ke liye kitne OT's avaialble hai
    for i in filter['Preferred OT']:
      i = str(i)
      i = i.replace(' ','')
      j = list(map(int,i.split(',')))
      ot.append(j)

    filter['ot'] = ot
    filter['number ots'] = [len(i) for i in filter['ot']]
    filter_1 = pd.concat([filter[filter['number ots']==1],filter[filter['number ots']!=1]],axis=0)

    return filter_1

  '''### Removing the Knowledge Base
  def priority_surgery(input_file,ot):
    input_file.columns = ['Date of Surgery','Age/Sex','Procedure','Surgeon','Department','Name of the Patient','Special Equipment','MRD','Duration']
    #knowledge_base.columns = ['Procedure','Duration']
    #knowledge_base['Processed_Procedures'] = preprocessed_surgeries(knowledge_base['Procedure'])
    #input_file['Processed_Procedures'] = preprocessed_surgeries(input_file['Procedure'])

    # for ot mapping
    input_file['Processed_Department'] = preprocessed_surgeries(input_file['Department'])
    ot['Processed_Department'] = preprocessed_surgeries(ot['Department'])


    #map_input = pd.merge(input_file,knowledge_base,how='inner',on='Processed_Procedures').drop_duplicates(['Processed_Procedures','Surgeon','Age/Sex'])
    map_input = pd.merge(input_file,ot,on='Processed_Department',how='inner')
    filter_map = map_input.drop(['Sr No','Processed_Department','Department_y'],axis=1)

    age = []
    for i in filter_map['Age/Sex']:
      i = i.split('Y')
      age.append(float(i[0]))

    filter_map['Age'] = age

    filter_a = filter_map[filter_map['Duration']>10.0].sort_values(by='Age',ascending=True)
    filter_b = filter_map[(filter_map['Duration']<10.0) & (filter_map['Age']<12.0)].sort_values(by='Age',ascending=True)
    filter_c = filter_map[(filter_map['Duration']<10.0)& (filter_map['Age']>12.0)].sort_values(by='Duration',ascending=False)

    filter = pd.concat([filter_a,filter_b,filter_c],axis=0)

    ot = []

    for i in filter['Preferred OT']:
      i = str(i)
      i = i.replace(' ','')
      j = list(map(int,i.split(',')))
      ot.append(j)

    filter['ot'] = ot
    filter['number ots'] = [len(i) for i in filter['ot']]
    filter_1 = pd.concat([filter[filter['number ots']==1],filter[filter['number ots']!=1]],axis=0)

    return filter_1'''


  # Priority set up
  a = priority_surgery(df,inp,ot)
  ### for removal of knowledge base
  #a = priority_surgery(inp,ot)
  a['Special Equipment'] = a['Special Equipment'].astype(str)
  print(a['MRD'])
  print('Priority Set')

  def map_equipements (df,special_equipment):
    df['processed_equipment'] = preprocess_equipments(df['Special Equipment'].to_list())
    special_equipment['processed_equipment'] = preprocess_equipments(special_equipment['Equipment Name'].to_list()) 
    merge = pd.merge(a,special_equipment,on='processed_equipment',how='left')
    return merge

  mapped_equipments = map_equipements(a,special_equipment)
  mapped_equipments['Count'].fillna(0,inplace=True)
  mapped_equipments['Count'] = mapped_equipments['Count'].astype(int)


  # speacial Equipment map
  l = []
  m = {}
  for i,j in special_equipment[['Equipment Name','Count']].iterrows():
    l.append(j.to_list())

  for i in l:
    l1 = []
    for j in range(0,i[1]):
      a = []
      l1.append(a)
    m[i[0]] = l1


  #Scheduling Algorithm
  def scheduled_procedure(surgeries):
    filter_1 = surgeries

    surgery_duration = dict(zip(filter_1['MRD'],filter_1['Duration']))
    surgery_ot = dict(zip(filter_1['Procedure_x'],filter_1['ot']))
    surgery_doctor = dict(zip(filter_1['MRD'],filter_1['Surgeon']))
    mrd_equipment = dict(zip(filter_1['MRD'],filter_1['Equipment Name']))
    mrd_equipment_required = dict(zip(filter_1['MRD'],filter_1['Equipment Name'].notna()))

    #print([i*60 for i in filter_1['Duration']])
    #unscheduled_surgeries = list(filter_1['Procedure_x'])
    ##assumption -- one day only one specific surgery for a aptient but 2 different surgeries can be performed
    unscheduled_surgeries = [[filter_1['Procedure_x'].iloc[i],filter_1["MRD"].iloc[i]] for i in range(len(filter_1)) ]
    scheduled_surgeries = []
    OT_dict = {}
    doctors = {i:[] for i in filter_1['Surgeon']}

    # Function to check if two slots overlap
    def check_overlap(slot1, slot2):
      return slot1[0] < slot2[1] and slot2[0] < slot1[1]

    # Function to find if the new slot is free and add it to the occupied slots if it is free
    def book_slot(occupied_slots, new_slot):
      for slot in occupied_slots:
        if check_overlap(slot, new_slot):
          return False  # Slot is not free
      #print("time: ",int(new_slot[1]-new_slot[0]))
      ##if new_slot[1]>1080 and len(occupied_slots)!=0 and int(new_slot[1]-new_slot[0])<600:
      ##return False
      if new_slot[1]>1080 and len(occupied_slots)==0 and int(new_slot[1]-new_slot[0])<600:
        return False

      #occupied_slots.append(new_slot)  # Add the new slot as it's free
      return True  # Slot is successfully booked
    
    # Special equipment
    def book_slot_special(occupied_slots, new_slot):
      for slot in occupied_slots:
        if check_overlap(slot, new_slot):
          return False  # Slot is not free
      #print("time: ",int(new_slot[1]-new_slot[0]))

      #occupied_slots.append(new_slot)  # Add the new slot as it's free
      return True  # Slot is successfully booked


    for i in unscheduled_surgeries:
      ots = surgery_ot[i[0]]
      duration = surgery_duration[i[1]]
      doctor = surgery_doctor[i[1]]
      schedule_hua = False
      is_special = mrd_equipment_required[i[1]]

      for ot in ots:
        #print("surgery dekh le ",i," ot number ",ot)
        if schedule_hua:
          break
        for j in range(0,601):
          if ot in OT_dict:
            ot_duration = OT_dict[ot] + 30+j
            ot_duration_end = ot_duration+(duration*60)+j
            slots = book_slot(doctors[doctor],(ot_duration,ot_duration_end))
            slots_special=False
            slot_special_index=0
            if is_special:
              for k in range(0,len(m[mrd_equipment[i[1]]])):
                #print(m[mrd_equipment[i[1]]]," ",k)
                slots_special = book_slot_special(m[mrd_equipment[i[1]]][k],(ot_duration,ot_duration_end))
                if slots_special:
                  slot_special_index=k
                  break
            
            if not is_special:
              slots_special = True


            if ot_duration_end > 1080 and duration >10 and slots and slots_special:
              scheduled_surgeries.append({'surgery':i[0],'OT':ot,'Start_time':ot_duration,'End_time':ot_duration_end,'Doctor':doctor,'MRD':i[1],"Special Equipment":mrd_equipment[i[1]]})
              #print({'surgery':i[0],'OT':ot,'Start_time':ot_duration,'End_time':ot_duration_end,'Doctor':doctor,'MRD':i[1]})
              OT_dict[ot]=ot_duration_end
              doctors[doctor].append((ot_duration,ot_duration_end))
              if is_special:
                m[mrd_equipment[i[1]]][slot_special_index].append((ot_duration,ot_duration_end))
              schedule_hua = True
              #print(doctors)
              #print(OT_dict)
              print(m)
              break

            elif ot_duration_end <= 1080 and slots and slots_special:
              scheduled_surgeries.append({'surgery':i[0],'OT':ot,'Start_time':ot_duration,'End_time':ot_duration_end,'Doctor':doctor,'MRD':i[1],"Special Equipment":mrd_equipment[i[1]]})
              OT_dict[ot]=ot_duration_end
              doctors[doctor].append((ot_duration,ot_duration_end))
              if is_special:
                m[mrd_equipment[i[1]]][slot_special_index].append((ot_duration,ot_duration_end))
              schedule_hua = True
              #print(doctors)
              #print({'surgery':i[0],'OT':ot,'Start_time':ot_duration,'End_time':ot_duration_end,'Doctor':doctor,'MRD':i[1]})
              #print(OT_dict)
              print(m)
              break

          else:
            ot_duration = 480+j
            ot_duration_end = ot_duration+(duration*60)+j
            slots= book_slot(doctors[doctor],(ot_duration,ot_duration_end))
            slots_special=False
            slot_special_index = 0
            if is_special:
              for k in range(0,len(m[mrd_equipment[i[1]]])):
                slots_special = book_slot_special(m[mrd_equipment[i[1]]][k],(ot_duration,ot_duration_end))
                if slots_special:
                  slot_special_index= k
                  break
            if not is_special:
              slots_special = True
          
            if ot_duration_end > 1080 and duration >10.0 and slots and slots_special:
              scheduled_surgeries.append({'surgery':i[0],'OT':ot,'Start_time':ot_duration,'End_time':ot_duration_end,'Doctor':doctor,'MRD':i[1],"Special Equipment":mrd_equipment[i[1]]})
              OT_dict[ot]=ot_duration_end
              doctors[doctor].append((ot_duration,ot_duration_end))
              if is_special:
                m[mrd_equipment[i[1]]][slot_special_index].append((ot_duration,ot_duration_end))
              schedule_hua = True
              #print(doctors)
              #print({'surgery':i[0],'OT':ot,'Start_time':ot_duration,'End_time':ot_duration_end,'Doctor':doctor,'MRD':i[1]})
              #print(OT_dict)
              print(m)
              break

            elif ot_duration_end <= 1080 and slots and slots_special:
              scheduled_surgeries.append({'surgery':i[0],'OT':ot,'Start_time':ot_duration,'End_time':ot_duration_end,'Doctor':doctor,'MRD':i[1],"Special Equipment":mrd_equipment[i[1]]})
              OT_dict[ot]=ot_duration_end
              doctors[doctor].append((ot_duration,ot_duration_end))
              if is_special:
                m[mrd_equipment[i[1]]][slot_special_index].append((ot_duration,ot_duration_end))
              schedule_hua = True
              #print(doctors)
              #print({'surgery':i[0],'OT':ot,'Start_time':ot_duration,'End_time':ot_duration_end,'Doctor':doctor,'MRD':i[1]})
              #print(OT_dict)
              print(m)
              break

    return scheduled_surgeries

  final_schedule_surgeries = pd.DataFrame(scheduled_procedure(mapped_equipments))
  final_schedule_surgeries['Start_time'] = [f'{int(i//60)}:{str(int(i % 60)).zfill(2)}' for i in final_schedule_surgeries['Start_time']]
  final_schedule_surgeries['End_time'] = [f'{int(i//60)}:{str(int(i % 60)).zfill(2)}' for i in final_schedule_surgeries['End_time']]

  #print(final_schedule_surgeries['MRD'])
  print('Surgeries Scheduled')
  

  mapped_equipments.drop(['Duration','Preferred OT','Age','ot','number ots','processed_equipment', 'Equipment Name', 'Count','Processed_Procedures'],axis=1,inplace=True)
  mapped_equipments.columns = ['Date of Surgery','Age/Sex','surgery','Surgeon','Department','Name of the Patient','Special Equipment','MRD']

  #print(mapped_equipements['MRD'])
  print(mapped_equipments)

  ## Mapping nusre
  mapped_equipments['preprocess_dept'] = preprocess_equipments(mapped_equipments['Department'])
  nursing_technician_tl['preprocess_dept'] = preprocess_equipments(nursing_technician_tl['Department'])

  mapped_nurse = pd.merge(mapped_equipments,nursing_technician_tl,on='preprocess_dept',how='left')
  mapped_nurse.drop(['preprocess_dept','Department_y'],axis=1,inplace=True)
  mapped_nurse.rename({'Department_x':'Department'},inplace=True)

  print(mapped_nurse)

  result = pd.merge(mapped_nurse, final_schedule_surgeries, on='MRD', how='inner')
  print(result)
  
  result.drop_duplicates(['Age/Sex','surgery_x','Surgeon','Name of the Patient'],inplace=True)
  result.drop(['Doctor','surgery_y','Special Equipment_y'],axis=1,inplace=True)
  result.columns = ['Date of Surgery', 'Age/Sex', 'surgery', 'Surgeon', 'Department','Name of the Patient', 'Special Equipment', 'MRD','Nursing T/L','Technicial T/L', 'OT','Start_time', 'End_time']
  result.fillna('N/A',inplace=True)



  return (result.to_dict(),200,headers)






