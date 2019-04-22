--Jump Guard
--ジャンプ・ガード
--  By Shad3

local scard=s
local s_id=id

function scard.initial_effect(c)
  --Activate
  local e1=Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCondition(scard.cd)
  e1:SetOperation(scard.op)
  c:RegisterEffect(e1)
  --Global check
  if not scard.gl_chk then
    scard.gl_chk=true
    local ge1=Effect.GlobalEffect()
    ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    ge1:SetCode(EVENT_LEAVE_FIELD)
    ge1:SetCondition(scard.reg_cd)
    ge1:SetOperation(scard.reg_op)
    Duel.RegisterEffect(ge1,0)
  end
end

function scard.reg_cd(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetFlagEffect(0,s_id)==0 and eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end

function scard.reg_op(e,tp,eg,ep,ev,re,r,rp)
  Duel.RegisterFlagEffect(0,s_id,RESET_PHASE+PHASE_END,0,1)
end

function scard.cd(e,tp,eg,ep,ev,re,r,rp)
  return Duel.GetFlagEffect(0,s_id)~=0
end

function scard.op(e,tp,eg,ep,ev,re,r,rp)
  local e1=Effect.CreateEffect(e:GetHandler())
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetTargetRange(1,0)
  e1:SetValue(1)
  e1:SetReset(RESET_PHASE+PHASE_END)
end
