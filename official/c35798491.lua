--ダークビショップデーモン
--Darkbishop Archfiend
local s,id=GetID()
function s.initial_effect(c)
	--Once per turn, during your Standby Phase, you must pay 500 LP (this is not optional), or this card is destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e1:SetOperation(s.mtop)
	c:RegisterEffect(e1)
	--Roll a six-sided die when resolving an opponent's card effect that targets an "Archfiend" monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_ARCHFIEND}
s.roll_dice=true
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.CheckLPCost(tp,500) then
		Duel.PayLPCost(tp,500)
	else
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
function s.filter(c,tp,re)
	return c:IsSetCard(SET_ARCHFIEND) and c:IsRelateToEffect(re) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsFaceup()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not (re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and ep==1-tp) then return false end
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not tg or not tg:IsExists(s.filter,1,nil,tp,re) or not Duel.IsChainDisablable(ev) then return false end
	local rc=re:GetHandler()
	Duel.Hint(HINT_CARD,1-tp,id)
	local dc=Duel.TossDice(tp,1)
	if dc==1 or dc==3 or dc==6 then
		if Duel.NegateEffect(ev) and rc:IsRelateToEffect(re) then
			Duel.Destroy(rc,REASON_EFFECT)
		end
	end
end