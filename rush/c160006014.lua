--セブンスロード・ウィズ
--Sevens Road Wiz
local s,id=GetID()
function s.initial_effect(c)
	-- atk change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_SEVENS_ROAD_MAGICIAN}
function s.cfilter(c,e,tp)
	return c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
end
function s.filter(c,atk)
	return c:IsFaceup() and c:GetAttack()==atk and c:GetBaseAttack()>0 and c:IsLevelBelow(8) and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--requirement
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local ct=Duel.SendtoGrave(g,REASON_COST)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local dg=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
		if #dg>0 then
			Duel.HintSelection(dg)
			--Original ATK becomes 0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(0)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			dg:GetFirst():RegisterEffect(e1)
			local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,CARD_SEVENS_ROAD_MAGICIAN)
			if ct>0 and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
				Duel.Draw(tp,1,REASON_EFFECT)
			end
		end
	end
end
