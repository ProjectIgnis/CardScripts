--逆転する運命
--Reversal of Fate
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ARCANA_FORCE}
function s.filter(c)
	return c:IsSetCard(SET_ARCANA_FORCE) and c:GetFlagEffect(CARD_REVERSAL_OF_FATE)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and s.filter(tc) then
		local val=Arcana.GetCoinResult(tc)
		if val==COIN_HEADS then
			Arcana.SetCoinResult(tc,COIN_TAILS)
		elseif val==COIN_TAILS then
			Arcana.SetCoinResult(tc,COIN_HEADS)
		end
	end
end