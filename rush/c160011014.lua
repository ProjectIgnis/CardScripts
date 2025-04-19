--アーツエンジェル・メタルポジション
--Arts Angel Metal Position
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Change monster to Defense position and inflict Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.GetLP(tp)<Duel.GetLP(1-tp) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FAIRY) and c:IsFaceup() and c:IsAbleToGraveAsCost()
end
function s.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0 and c:IsLevelBelow(8) and c:IsAttribute(ATTRIBUTE_EARTH)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	if Duel.SendtoGrave(tg,REASON_COST)>0 then
	--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
		local sc=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_MZONE,1,1,nil)
		if sc and Duel.ChangePosition(sc,POS_FACEUP_DEFENSE)>0 then
			local val=sc:GetFirst():GetBaseAttack()
			if val==0 then return end
			Duel.BreakEffect()
			Duel.Damage(1-tp,val,REASON_EFFECT)
		end
	end
end