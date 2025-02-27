--エンシェント・アライズ・ドラゴン
--Ancient Arise Dragon
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Gains 600 ATK until the end of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160003022,160003023} --"Clear Ice Dragon", "Burning Blaze Dragon"
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.sfilter(c)
	return c:IsCode(160003022,160003023) and c:IsAbleToDeck()
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsCode,1,nil,160003022) and sg:IsExists(Card.IsCode,1,nil,160003023)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(600)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
	--Shuffle into the Deck 1 "Clear Ice Dragon" and 1 "Burning Blaze Dragon" in your GY
	local sg=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_GRAVE,0,nil)
	if aux.SelectUnselectGroup(sg,1,tp,2,2,s.rescon,0,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		local cg=aux.SelectUnselectGroup(sg,1,tp,2,2,s.rescon,1,tp)
		local sg2=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
		if Duel.SendtoDeck(cg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==2 and #sg2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			--Destroy 1 face-up monster with 1500 or less DEF on your opponent's field
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local tg=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,1,1,nil)
			if #tg>0 then
				tg=tg:AddMaximumCheck()
				Duel.Destroy(tg,REASON_EFFECT)
			end
		end
	end
end
function s.desfilter(c)
	return c:IsDefenseBelow(1500) and c:HasDefense() and c:IsFaceup()
end