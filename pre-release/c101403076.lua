--百竜の交戦
--Reindsurm Encounter
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--When a Spell/Trap Card, or monster effect, is activated while you control a "Reindsurm" monster: Negate the activation, then you can add 1 "Reindsurm" monster from your Deck or GY to your hand, and if you do, send 1 Insect monster you control to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	--If a "Reindsurm" monster(s) you control would be destroyed by battle or card effect, you can place this card from your GY on the bottom of the Deck instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_REINDSURM}
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_REINDSURM),tp,LOCATION_MZONE,0,1,nil)
		and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Chain.IsNegatable(ev)
end
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_MZONE)
end
function s.thfilter(c)
	return c:IsSetCard(SET_REINDSURM) and c:IsMonster() and c:IsAbleToHand()
end
function s.tgfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsFaceup() and c:IsAbleToGrave()
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local thc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if not thc then return end
		if thc:IsLocation(LOCATION_GRAVE) then Duel.HintSelection(thc) end
		Duel.BreakEffect()
		if Duel.SendtoHand(thc,nil,REASON_EFFECT)>0 and thc:IsLocation(LOCATION_HAND) then
			if thc:IsPreviousLocation(LOCATION_DECK) then Duel.ConfirmCards(1-tp,thc) end
			Duel.ShuffleHand(tp)
			if thc:IsPreviousLocation(LOCATION_DECK) then Duel.ShuffleDeck(tp) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local tg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
			if #tg>0 then
				Duel.HintSelection(tg)
				Duel.SendtoGrave(tg,REASON_EFFECT)
			end
		end
	end
end
function s.repfilter(c,tp)
	return c:IsSetCard(SET_REINDSURM) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE|REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp) and c:IsAbleToDeck() and aux.nvfilter(c) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	Duel.HintSelection(c)
	Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT|REASON_REPLACE)
end