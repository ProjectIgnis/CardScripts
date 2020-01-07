--おジャマ・デルタサンダー！！
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={8251996}
function s.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,12482652)
	 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,42941100)
	 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,79335209)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND+LOCATION_ONFIELD,0)*500
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.costfilter(c)
	return c:IsCode(8251996) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)	
	Duel.Damage(p,d,REASON_EFFECT)
	Duel.BreakEffect()
	local dg=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil)
	local dt=Duel.GetMatchingGroup(Card.IsDestructable,tp,0,LOCATION_ONFIELD,nil)
	if #dg>0 and #dt>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_HINTMSG_TOGRAVE)
		local des=dg:Select(tp,1,1,nil)
		Duel.SendtoGrave(des,REASON_EFFECT)
		Duel.BreakEffect()
		Duel.Destroy(dt,REASON_EFFECT)
	end
end
