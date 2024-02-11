--アビスカイト・マッピング
--Abysskite Mapping
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--name change
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(160207049)
	c:RegisterEffect(e0)
	--Gain LP
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.tgfilter),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 end
end
function s.thfilter(c)
	return c:IsCode(160210053) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.tgfilter),tp,LOCATION_MZONE,0,nil)
	Duel.Recover(tp,ct*300,REASON_EFFECT)
	if Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if #g2>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(g2,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end