--Wave Rebound
local s,id=GetID()
function s.initial_effect(c)
	--Activate(effect)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_ACTIVATE)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.target)
	e4:SetOperation(s.activate)
	c:RegisterEffect(e4)
end
function s.cfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_GRAVE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainNegatable(ev) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	if ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0 then
		local g=tg:Filter(s.cfilter,nil)
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject()
	if chk==0 then return g and #g>0 end
	Duel.SetTargetCard(g)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetSum(Card.GetAttack))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateActivation(ev)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local tg=Duel.GetTargetCards(e)
	if #tg>0 then
		Duel.Damage(p,tg:GetSum(Card.GetAttack),REASON_EFFECT)
	end
end
