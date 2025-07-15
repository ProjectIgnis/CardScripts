--焔魔の極馳
--Ultima Stallion of the Blaze Fiends
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Add to hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_GRAVE,0,3,nil,RACE_FIEND)
end
function s.thfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToHand() and (c:IsLevel(10) or c:IsType(TYPE_MAXIMUM))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(sg,1,tp,1,2,s.rescon,0,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	local tg=aux.SelectUnselectGroup(sg,1,tp,1,2,s.rescon,1,tp)
	local ct=Duel.SendtoHand(tg,nil,REASON_EFFECT)
	Duel.ConfirmCards(1-tp,tg)
end
function s.resfilter(c)
	return c:IsLevel(10) and not c:IsType(TYPE_MAXIMUM)
end
function s.resfilter2(c)
	return not c:IsLevel(10) and c:IsType(TYPE_MAXIMUM)
end
function s.rescon(sg,e,tp,mg)
	if sg:FilterCount(s.resfilter,nil)>0 then
		return #sg==1
	end
	if sg:FilterCount(s.resfilter2,nil)>0 then
		return #sg==2
	end
	return true
end