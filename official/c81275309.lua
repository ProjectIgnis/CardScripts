--氷結界の虎将 ライホウ
--General Raiho of the Ice Barrier
local s,id=GetID()
function s.initial_effect(c)
	--When your opponent's monster effect activated on the field resolves, they must discard 1 card or the effect is negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.handes)
	c:RegisterEffect(e1)
end
s[0]=0
function s.handes(e,tp,eg,ep,ev,re,r,rp)
	local trig_loc,chain_id=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_CHAIN_ID)
	if not (ep==1-tp and trig_loc==LOCATION_MZONE and chain_id~=s[0] and re:IsMonsterEffect()) then return end
	s[0]=chain_id
	if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
		Duel.DiscardHand(1-tp,nil,1,1,REASON_EFFECT|REASON_DISCARD,nil)
		Duel.BreakEffect()
	else Duel.NegateEffect(ev) end
end