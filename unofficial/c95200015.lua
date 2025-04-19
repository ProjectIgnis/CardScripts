--Command Duel 15
local s,id=GetID()
function s.initial_effect(c)
	--recover
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
		Duel.SetTargetPlayer(tp)
	end
	if Duel.GetLP(tp)>Duel.GetLP(1-tp) then
		Duel.SetTargetPlayer(1-tp)
	end
	Duel.SetTargetParam(2000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local p=PLAYER_ALL
	if Duel.GetLP(tp)<Duel.GetLP(1-tp) then
		p=tp
	end
	if Duel.GetLP(tp)>Duel.GetLP(1-tp) then
		p=1-tp
	end
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	if p~=PLAYER_ALL then
		Duel.Recover(p,d,REASON_EFFECT)
	end
end