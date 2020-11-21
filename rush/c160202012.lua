--Yggdrago the Heavenly Emperor Dragon Tree (right)
local s,id=GetID()
function s.initial_effect(c)
	--Position change
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.maxCon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
end
function s.maxCon(e)
	--maximum mode check to do
	return e:GetHandler():IsMaximumModeCenter()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,3) end
	Duel.RegisterMaxIgnition(tp,id)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--requirement
	if Duel.DiscardDeck(tp,3,REASON_COST)>0 then
		--effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.SelectMatchingCard(tp,Card.IsDefensePos,tp,0,LOCATION_MZONE,1,1,nil)
			if #g>0 then
				Duel.ChangePosition(g,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
			end
		end
	end
end