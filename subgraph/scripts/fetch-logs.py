import json,urllib.request,time,sys
addr,out,to_block=sys.argv[1],sys.argv[2],int(sys.argv[3])
def get(u):
    for i in range(5):
        try:
            r=urllib.request.Request(u,headers={'user-agent':'curl/8','accept':'application/json'}); return json.load(urllib.request.urlopen(r,timeout=60))
        except Exception as e: err=e; time.sleep(3)
    raise err
logs=[]; frm=0
while True:
    d=get(f'https://celo.blockscout.com/api?module=logs&action=getLogs&address={addr}&fromBlock={frm}&toBlock={to_block}')
    r=d.get('result') or []
    if not isinstance(r,list) or not r: break
    logs+=r
    if len(r)<1000: break
    frm=int(r[-1]['blockNumber'],16)
seen=set(); u=[]
for l in logs:
    k=(l['transactionHash'],l['logIndex'])
    if k not in seen: seen.add(k); u.append(l)
u.sort(key=lambda l:(int(l['blockNumber'],16),int(l['logIndex'],16)))
json.dump(u,open(out,'w')); print(addr,'logs',len(u),'blocks',int(u[0]['blockNumber'],16),'..',int(u[-1]['blockNumber'],16))
