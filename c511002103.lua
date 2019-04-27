--Celestial Profit
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:GetControler()==tp and c:IsPreviousControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and rp~=tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(s.cfilter,nil,tp)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct*2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct*2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct*2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
