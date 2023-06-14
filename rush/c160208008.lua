--ハーピィ・レジーナ
--Harpie Regina
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Draw 1 card and add 1 "Harpie Lady" or "Harpie Ladies" from the GY to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.drcond)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_HARPIE_LADY,160208002}
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WINGEDBEAST) and c:IsAttribute(ATTRIBUTE_WIND)
end
function s.drcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
end
function s.thfilter(c)
	return c:IsCode(CARD_HARPIE_LADY,160208002) and c:IsAbleToHand()
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	if #g>0 and Duel.SendtoGrave(g,REASON_COST)>0 then
		--Effect
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		if Duel.Draw(p,d,REASON_EFFECT)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local thg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			if #thg>0 then
				Duel.BreakEffect()
				Duel.SendtoHand(thg,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,thg)
			end
		end
	end
end