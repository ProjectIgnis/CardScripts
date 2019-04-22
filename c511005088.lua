--Performapal Reborn Force
--復活のエンタメ－リボーン・フォース－
--  By Shad3
local s,id=GetID()
function s.initial_effect(c)
  --Activate
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCondition(s.cd)
  e1:SetOperation(s.op)
  c:RegisterEffect(e1)
  --Global check
  if not s.gl_chk then
    s.gl_chk=true
    s.sreg={}
    local ge1=Effect.GlobalEffect()
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_DESTROYED)
    ge1:SetOperation(s.reg_op)
    Duel.RegisterEffect(ge1,0)
    local ge2=Effect.GlobalEffect()
    ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge2:SetCode(EVENT_TURN_END)
    ge2:SetOperation(s.rst_op)
    Duel.RegisterEffect(ge2,0)
  end
end

function s.reg_op(e,tp,eg,ep,ev,re,r,rp)
  local tc=eg:GetFirst()
  while tc do
    if tc:IsType(TYPE_MONSTER) and tc:IsSetCard(0x9f) then s.sreg[tc:GetPreviousControler()]=true end
    tc=eg:GetNext()
  end
end

function s.rst_op()
  s.sreg[0]=false
  s.sreg[1]=false
end

function s.cd(e,tp,eg,ep,ev,re,r,rp)
  return s.sreg[tp]
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_REFLECT_DAMAGE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetTargetRange(1,0)
  e1:SetValue(s.ref_val)
  e1:SetReset(RESET_PHASE+PHASE_END)
  Duel.RegisterEffect(e1,tp)
  if (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE) then
    Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
  end
end

function s.ref_val(e,re,val,r,rp,rc)
  if (r&REASON_EFFECT)~=0 then
    e:Reset()
    return true
  end
  return false
end