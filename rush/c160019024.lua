--恵雷のワコ
--Lightning Bringer Wako
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change targeted monster's battle position
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160008026,160019060}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,160008026) and e:GetHandler():IsStatus(STATUS_SUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.setfilter(c)
	return c:IsCode(160019060) and c:IsSSetable()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,Card.IsCanChangePositionRush,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.HintSelection(g)
	if #g>0 then
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,nil)
		if #g2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g2:Select(tp,1,1,nil)
			Duel.HintSelection(sg)
			Duel.BreakEffect()
			Duel.SSet(tp,sg)
		end
	end
end