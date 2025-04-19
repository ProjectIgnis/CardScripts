--トランザム・スクライド
--Transam Scride
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--ATK increase
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
function s.filter(c)
	return c:IsFaceup() and c:CanGetPiercingRush()
end
function s.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePositionRush()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.DiscardDeck(tp,1,REASON_EFFECT)
	local ct=Duel.GetOperatedGroup():GetFirst()
	if ct:IsMonster() and ct:IsRace(RACE_GALAXY) and ct:IsAttribute(ATTRIBUTE_LIGHT) and Duel.IsAbleToEnterBP()
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,3,nil)
		Duel.HintSelection(g2,true)
		local c=e:GetHandler()
		for tc in g2:Iter() do
			tc:AddPiercing(RESETS_STANDARD_PHASE_END,e:GetHandler())
		end
		local sg=g2:Filter(Card.IsCode,nil,CARD_TRANSAMU_RAINAC)
		local dg=Duel.GetMatchingGroup(s.posfilter,tp,0,LOCATION_MZONE,nil)
		if #sg>0 and #dg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.ChangePosition(dg,POS_FACEUP_DEFENSE)
		end
	end
end
