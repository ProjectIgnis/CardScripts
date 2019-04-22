--Life Exchange
--ライフ・エクスチェンジ
--  By Shad3

local scard=s

function scard.initial_effect(c)
  --Activate
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_CHAINING)
  e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
  e1:SetCondition(scard.cd)
  e1:SetOperation(scard.op)
  c:RegisterEffect(e1)
end

function scard.cd(e,tp,eg,ep,ev,re,r,rp)
  local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
  if ex and cp~=tp then return true end
  ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
  return ex and cp~=tp
end

function scard.op(e,tp,eg,ep,ev,re,r,rp)
  local c=e:GetHandler()
  local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_CHANGE_DAMAGE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetTargetRange(0,1)
  e1:SetValue(scard.dmgval)
  e1:SetReset(RESET_CHAIN)
  e1:SetLabel(cid)
  Duel.RegisterEffect(e1,tp)
  local e2=Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e2:SetCode(EVENT_RECOVER)
  e2:SetOperation(scard.recop)
  e2:SetReset(RESET_CHAIN)
  e2:SetLabel(cid)
  Duel.RegisterEffect(e2,tp)
  local e3=Effect.CreateEffect(c)
  e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
  e3:SetCode(EVENT_CHAIN_SOLVED)
  e3:SetOperation(scard.solvop)
  e3:SetReset(RESET_CHAIN)
  e3:SetLabelObject(e1)
  Duel.RegisterEffect(e3,tp)
  e1:SetLabelObject(e3)
  e2:SetLabelObject(e3)
end

function scard.dmgval(e,re,val,r,rp,rc)
  local cc=Duel.GetCurrentChain()
  if e:GetHandler()~=re:GetHandler() and cc~=0 and Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)==e:GetLabel() then
    e:GetLabelObject():SetLabel(val)
    return 0
  else
    return val
  end
end

function scard.recop(e,tp,eg,ep,ev,re,r,rp)
  local cc=Duel.GetCurrentChain()
  if ep~=tp and cc~=0 and Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)==e:GetLabel() then
    Duel.SetLP(ep,Duel.GetLP(ep)-ev)
    e:GetLabelObject():SetLabel(-ev)
    e:Reset()
  end
end

function scard.solvop(e,tp,eg,ep,ev,re,r,rp)
  Debug.Message("ping")
  local cc=Duel.GetCurrentChain()
  Debug.Message(cc)
  if cc==0 or Duel.GetChainInfo(cc,CHAININFO_CHAIN_ID)~=e:GetLabelObject():GetLabel() then return end
  local val=e:GetLabel()
  if val>0 then
    Duel.Damage(tp,val,REASON_EFFECT)
    Duel.Hint(HINT_SELECTMSG,tp,502)
    local tc=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
    if tc then Duel.Destroy(tc,REASON_EFFECT) end
  elseif val<0 then
    Duel.Recover(tp,-val,REASON_EFFECT)
    Duel.Damage(1-tp,1000,REASON_EFFECT)
  end
  e:Reset()
end