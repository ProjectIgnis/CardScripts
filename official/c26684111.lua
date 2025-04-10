--天空の聖水
--The Sacred Waters in the Sky
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 "The Sanctuary in the Sky" directly from your Deck, or add 1 monster that mentions "The Sanctuary in the Sky" from your Deck to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--If your monster that mentions "The Sanctuary in the Sky" would be destroyed by battle, you can banish this card from your GY instead
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.reptg)
	e2:SetValue(function(e,c) return s.repfilter(c,e:GetHandlerPlayer()) end)
	e2:SetOperation(function(e) Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT|REASON_REPLACE) end)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_SANCTUARY_SKY}
s.listed_series={SET_HYPERION,SET_THE_AGENT}
function s.actthfilter(c,tp)
	return (c:IsCode(CARD_SANCTUARY_SKY) and c:GetActivateEffect() and c:GetActivateEffect():IsActivatable(tp,true,true))
		or (c:ListsCode(CARD_SANCTUARY_SKY) and c:IsMonster() and c:IsAbleToHand())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.actthfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,1,tp,500)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local sc=Duel.SelectMatchingCard(tp,s.actthfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if not sc then return end
	local gainlp_chk=false
	if sc:IsCode(CARD_SANCTUARY_SKY) then
		gainlp_chk=Duel.ActivateFieldSpell(sc,e,tp,eg,ep,ev,re,r,rp)
	else
		gainlp_chk=Duel.SendtoHand(sc,nil,REASON_EFFECT)>0
		if gainlp_chk then Duel.ConfirmCards(1-tp,sc) end
	end
	if not (gainlp_chk and (Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_SANCTUARY_SKY),0,LOCATION_ONFIELD|LOCATION_GRAVE,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil)
		or Duel.IsEnvironment(CARD_SANCTUARY_SKY))) then return end
	local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,{SET_HYPERION,SET_THE_AGENT}),tp,LOCATION_MZONE,0,nil)
	if ct>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Recover(tp,ct*500,REASON_EFFECT)
	end
end
function s.repfilter(c,tp)
	return c:ListsCode(CARD_SANCTUARY_SKY) and c:IsReason(REASON_BATTLE) and c:IsControler(tp) and c:IsFaceup()
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
