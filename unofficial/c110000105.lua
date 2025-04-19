--トラップバスター・アーマー
--Trap Buster
local s,id=GetID()
function s.initial_effect(c)
	Armor.AddProcedure(c)
	--Negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_SZONE)
	e1:SetTarget(s.distg)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.discon)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_ARMOR) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.distg(e,c)
	return c:IsTrap() and c:GetCardTargetCount()>0
		and c:GetCardTarget():FilterCount(s.cfilter,nil,e:GetHandlerPlayer())==1
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsTrapEffect() then return false end
	local ok=false
	if re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		if g and g:FilterCount(s.cfilter,nil,tp)==1 then
			ok=true
		end
	end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	if ex and tg~=nil and tc+tg:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)-#tg>1 then
		ok=true
	end
	return ok
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end