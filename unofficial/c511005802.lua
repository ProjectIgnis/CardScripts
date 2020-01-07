--Hungry Burger (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
c:EnableReviveLimit()
--destroy warrior race before damage calc.
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_DESTROY)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
e1:SetCode(EVENT_BATTLE_START)
e1:SetTarget(s.destg)
e1:SetOperation(s.desop)
c:RegisterEffect(e1)
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
local bc=c:GetBattleTarget()
if chk==0 then return bc and bc:IsFaceup() and bc:IsRace(RACE_BEAST) end
Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local bc=c:GetBattleTarget()
if bc:IsRelateToBattle() then
Duel.Destroy(bc,REASON_EFFECT)
end
end
