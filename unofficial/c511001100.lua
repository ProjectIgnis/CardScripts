--竜皇の崩御
--Dragon King's Demise
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RELEASE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,#g,nil) end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,#g,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)
	if Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,ct,nil) then
		local g=Duel.GetMatchingGroup(Card.IsReleasableByEffect,tp,LOCATION_MZONE,0,nil)
		if Duel.Release(g,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup():Filter(Card.IsRace,nil,RACE_DRAGON)
			local sum=og:GetSum(Card.GetAttack)
			Duel.Damage(tp,sum,REASON_EFFECT,true)
			Duel.Damage(1-tp,sum,REASON_EFFECT,true)
			Duel.RDComplete()
		end
	end
end