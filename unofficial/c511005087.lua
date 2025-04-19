----マジック・リバウンダー
--Magic Rebounder
--By Shad3
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetBattleDamage(tp)>0 and (Duel.GetAttacker():IsControler(1-tp) or (Duel.GetAttackTarget() and Duel.GetAttackTarget():IsControler(1-tp)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ac=Duel.GetAttacker()
    	local atc=Duel.GetAttackTarget()
	if ac:IsControler(1-tp) then 
        	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ac,1,0,0)
    	elseif atc and atc:IsControler(1-tp) then
        	Duel.SetOperationInfo(0,CATEGORY_DESTROY,atc,1,0,0)
    	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetAttacker()
    	local atc=Duel.GetAttackTarget()
    	if ac:IsControler(1-tp) and ac:IsRelateToBattle() then 
        	Duel.Destroy(ac,REASON_EFFECT)
    	elseif atc and atc:IsControler(1-tp) and atc:IsRelateToBattle() then
        	Duel.Destroy(atc,REASON_EFFECT)
    	end
end