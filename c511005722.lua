--Dark Elf (DOR)
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--attack cost
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_ATTACK_COST)
e1:SetCost(s.atcost)
e1:SetOperation(s.atop)
c:RegisterEffect(e1)
end

function s.atcost(e,c,tp)
return Duel.CheckLPCost(tp,50)
end

function s.atop(e,tp,eg,ep,ev,re,r,rp)
Duel.PayLPCost(tp,50)
end
