--Hollow Giants
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.disable)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	--damage
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.damcon)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
local spfil=aux.FilterFaceupFunction(Card.IsSummonLocation,LOCATION_EXTRA)
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(spfil,tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(spfil,tp,0,LOCATION_MZONE,1,nil)
end
function s.disable(e,c)
	return (c:IsType(TYPE_EFFECT) or (c:GetOriginalType()&TYPE_EFFECT)==TYPE_EFFECT) and spfil(c)
end
function s.damfilter(c)
	return spfil(c) and spfil(c:GetBattleTarget())
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.damfilter,1,nil)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,0,1000)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_COST)~=0 then
		for i=0,1 do
			if eg:IsExists(Card.IsControler,1,nil,i) then Duel.Damage(i,1000,REASON_EFFECT) end
		end
	end
end
