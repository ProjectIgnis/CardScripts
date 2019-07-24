--Trap Buster
Duel.LoadScript("c419.lua")
local s,id=GetID()
function s.initial_effect(c)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_SZONE)
	e3:SetTarget(s.distg)
	c:RegisterEffect(e3)
	--disable effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
	--Double Snare
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(3682106)
	c:RegisterEffect(e2)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_ARMOR) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
function s.distg(e,c)
	return c:GetCardTargetCount()>0 and c:IsType(TYPE_TRAP) 
		and c:GetCardTarget():FilterCount(s.cfilter,nil,e:GetHandlerPlayer())==1
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_TRAP) then return end
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
	if ok then
		Duel.NegateEffect(ev)
	end
end
