--Tongyo (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--ATK/DEF dOWN 500
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
e1:SetCode(EVENT_BATTLED)
e1:SetCondition(s.condition)
e1:SetOperation(s.operation)
c:RegisterEffect(e1)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local pos=c:GetBattlePosition()
return c==Duel.GetAttackTarget() and (pos==POS_FACEDOWN_DEFENSE or pos==POS_FACEDOWN_ATTACK) and c:IsLocation(LOCATION_MZONE)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local bc=c:GetBattleTarget()
if not bc:IsRelateToBattle() or bc:IsFacedown() then return end
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
e1:SetReset(RESET_EVENT+RESETS_STANDARD)
e1:SetValue(-500)
bc:RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EFFECT_UPDATE_DEFENSE)
bc:RegisterEffect(e2)
end
