--対生成
--Pair Production

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Targeted monster gains ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
	--Check for level 5 or lower cyberse monster
function s.filter1(c,tp)
	local lv=c:GetLevel()
	return lv>0 and c:IsAbleToGraveAsCost() and c:IsLevelBelow(5) and c:IsRace(RACE_CYBERSE)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_HAND,0,1,c,lv)
end
function s.filter2(c,lv)
	return c:IsLevel(lv) and c:IsAbleToGraveAsCost() and c:IsRace(RACE_CYBERSE)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
end
	--Targeted monster gains ATK equal to sent monster's level x 400
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc1=g1:GetFirst()
	local vc=tc1:GetLevel()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_HAND,0,1,1,tc1,tc1:GetLevel())
	g1:Merge(g2)
	local ct=Duel.SendtoGrave(g1,REASON_COST)
	if ct>0 then
		--Effect
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local dg=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
		if #dg>0 then
			Duel.HintSelection(dg)
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(400*vc)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			dg:GetFirst():RegisterEffectRush(e1)
		end
	end
end