--墓守の祈祷師
--Gravekeeper's Shaman
local s,id=GetID()
function s.initial_effect(c)
	--def up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.defval)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAIN_ACTIVATING)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--cannot activate
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.econ)
	e3:SetValue(s.efilter1)
	c:RegisterEffect(e3)
	--
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e4:SetCondition(s.econ)
	e4:SetTarget(s.etarget)
	e4:SetValue(s.efilter2)
	c:RegisterEffect(e4)
end
s.listed_series={SET_GRAVEKEEPERS}
s.listed_names={CARD_NECROVALLEY}
function s.filter(c)
	return c:IsSetCard(SET_GRAVEKEEPERS) and c:IsMonster()
end
function s.defval(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),LOCATION_GRAVE,0,nil)*200
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if re:IsMonsterEffect() and not re:GetHandler():IsSetCard(SET_GRAVEKEEPERS) and loc==LOCATION_GRAVE then
		Duel.NegateEffect(ev)
	end
end
function s.econ(e)
	return Duel.IsEnvironment(CARD_NECROVALLEY)
end
function s.efilter1(e,re,tp)
	return re:GetHandler():IsType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.etarget(e,c)
	return c:IsType(TYPE_FIELD)
end
function s.efilter2(e,re,tp)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer()
end