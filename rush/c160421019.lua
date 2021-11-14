-- 大逆転の女神
-- Daigyakutenno Megami
local s,id=GetID()
function s.initial_effect(c)
	-- Draw and send card from hand to GY
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_DECKDES+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
s.listed_names={31122090}
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,31122090)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,d,REASON_EFFECT)<1 then return end
	if Duel.IsPlayerCanDiscardDeck(tp,1) then
		Duel.DiscardDeck(tp,1,REASON_EFFECT)
		local g=Duel.GetOperatedGroup()
		local ct=g:GetFirst()
		if ct then
			--If it was a monster, destroy 2
			if ct:IsType(TYPE_MONSTER) and  Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,2,nil,ct:GetRace()) and Duel.SelectYesNo(tp,aux.Stringid(id,0))  then
				local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,0,LOCATION_MZONE,2,2,nil)
				g=g:AddMaximumCheck()
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
function s.filter(c,race)
	return c:IsFaceup() and c:IsRace(race) and c:CanAttack() 
end
