-- ハイパー・ナリキング・レックス
-- Hyper Upstart King Rex
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160002029,160203010)
	--Special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UPSTART_GOBLIN}
function s.cfilter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.HintSelection(tg)
	local opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	if opt==0 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKTOP,REASON_EFFECT)
	elseif opt==1 then
		Duel.SendtoDeck(tg,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
	-- Effect
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		e1:SetValue(700)
		c:RegisterEffect(e1)
		local ct=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_GRAVE,0,nil,CARD_UPSTART_GOBLIN)
		if ct>0 and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
function s.thfilter(c)
	return c:IsSpell() and c:IsAbleToHand()
end