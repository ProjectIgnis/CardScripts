--アニマジカ・シューター
--Animagica Shooter
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Summon with 1 tribute
	local e1=aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),s.otfilter)
	--Change monster's battle position
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.otfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN|STATUS_SPSUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,nil) end
end
function s.desfilter(c,lvl)
	return c:IsFaceup() and c:GetLevel()<lvl
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.HintSelection(g)
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 then
		local g2=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil,e:GetHandler():GetLevel())
		if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g2:Select(tp,1,1,nil)
			if #sg==0 then return end
			sg=sg:AddMaximumCheck()
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end