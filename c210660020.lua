--Wicked Balance
--concept by Gideon
--scripted by Larry126
function c210660020.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1,210660020+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c210660020.condition)
	e1:SetTarget(c210660020.target)
	e1:SetOperation(c210660020.activate)
	c:RegisterEffect(e1)
end
function c210660020.filter(c)
	return not c:IsRace(RACE_FIEND) or not c:IsLevel(10) or c:IsFacedown()
end
function c210660020.condition(e,tp,eg,ep,ev,re,r,rp)
	local t=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	local s=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	local m=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	return t>s and m>0
		and not Duel.IsExistingMatchingCard(c210660020.filter,tp,LOCATION_MZONE,0,1,nil)
end
function c210660020.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local t=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	local s=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,t-s) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(t-s)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,t-s)
end
function c210660020.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local t=Duel.GetFieldGroupCount(p,0,LOCATION_ONFIELD)
	local s=Duel.GetFieldGroupCount(p,LOCATION_ONFIELD,0)
	if t>s then
		Duel.Draw(p,t-s,REASON_EFFECT)
	end
end