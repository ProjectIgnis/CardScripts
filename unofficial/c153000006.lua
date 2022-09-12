--ブラック・マジシャン・ガール (Deck Master)
--Dark Magician Girl (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	dme1:SetCode(EVENT_FREE_CHAIN)
	dme1:SetCountLimit(1)
	dme1:SetCondition(s.con)
	dme1:SetOperation(s.op)
	DeckMaster.RegisterAbilities(c,dme1)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_DARK_MAGICIAN}
function s.val(e,c)
	return Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,30208479,CARD_DARK_MAGICIAN)*300
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
	return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and ct>0 and Duel.IsPlayerCanDraw(tp,ct) and Duel.IsDeckMaster(tp,id)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.Draw(tp,Duel.GetMatchingGroupCount(Card.IsMonster,tp,LOCATION_GRAVE,0,nil),REASON_EFFECT)
end