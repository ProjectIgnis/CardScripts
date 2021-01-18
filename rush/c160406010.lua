--古代の遠眼鏡
--Ancient Telescope (Rush)
local s,id=GetID()
function s.initial_effect(c)
	--confirm
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.cftg)
	e1:SetOperation(s.cfop)
	c:RegisterEffect(e1)
end
function s.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>4 end
	Duel.SetTargetPlayer(tp)
end
function s.cfop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.ConfirmDecktop(1-tp,5)
end