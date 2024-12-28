--森の聖騎士 ワンコ
--Wonko, Noble Knight of the Forest
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Fairy Tale Prologue: Journey's Dawn" from your Deck to your hand, or, if "Fairy Tale Prologue: Journey's Dawn" is on your field or in your GY, you can draw 1 card instead
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--While a card is in a Field Zone, your opponent's monsters cannot target monsters for attacks, except this one
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(function() return Duel.IsExistingMatchingCard(nil,0,LOCATION_FZONE,LOCATION_FZONE,1,nil) end)
	e3:SetValue(function(e,c) return c~=e:GetHandler() end)
	c:RegisterEffect(e3)
	--Make the monster that destroyed this card by battle lose 500 ATK
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetCondition(function(e) return e:GetHandler():GetReasonCard():IsRelateToBattle() end)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
s.listed_names={CARD_FAIRY_TALE_PROLOGUE}
function s.thfilter(c)
	return c:IsCode(CARD_FAIRY_TALE_PROLOGUE) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		or (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_FAIRY_TALE_PROLOGUE),tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1)) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local search_chk=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	local draw_chk=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_FAIRY_TALE_PROLOGUE),tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1)
	if search_chk and not (draw_chk and Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	else
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetReasonCard()
	if bc:IsRelateToBattle() then
		--It loses 500 ATK
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		bc:RegisterEffect(e1)
	end
end