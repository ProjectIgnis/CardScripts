--ジャンプ・ガード
--Jump Guard
--By Shad3
--fixed by ClaireStanfield
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
	local ge1=Effect.GlobalEffect()
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EVENT_LEAVE_FIELD)
	ge1:SetCondition(s.reg_cd)
	ge1:SetOperation(s.reg_op)
	Duel.RegisterEffect(ge1,0)
  end
end
function s.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp and c:IsReason(REASON_EFFECT)
end
function s.reg_cd(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetFlagEffect(0,id)==0 and eg:IsExists(s.filter,1,nil,tp) and #eg==1
end
function s.reg_op(e,tp,eg,ep,ev,re,r,rp)
  Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
end
function s.cd(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetFlagEffect(0,id)~=0
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetTargetRange(1,0)
  e1:SetValue(1)
  e1:SetReset(RESET_PHASE+PHASE_END)
  Duel.RegisterEffect(e1,tp)
end
