--剛鬼サンダー・オーガ
--Gouki Thunder Ogre
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0xfc),2)
	c:EnableReviveLimit()
	--extra summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e1:SetValue(s.sumval)
	c:RegisterEffect(e1)
	--atk
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetOperation(s.atkop)
	c:RegisterEffect(e3)
end
s.listed_series={0xfc}
function s.sumval(e,c)
	if c:IsControler(e:GetHandlerPlayer()) then
		local sumzone=e:GetHandler():GetLinkedZone()
		local relzone=-(1<<e:GetHandler():GetSequence())
		return 0,sumzone,relzone
	else
		local sumzone=e:GetHandler():GetLinkedZone(1-e:GetHandlerPlayer())
		local relzone=-(1<<e:GetHandler():GetSequence()+16)
		return 0,sumzone,relzone
	end
end
function s.cfilter(c,tp,zone)
	local seq=c:GetPreviousSequence()
	if not c:IsPreviousControler(tp) then seq=seq+16 end
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) 
		and c:IsPreviousLocation(LOCATION_MZONE) and bit.extract(zone,seq)~=0
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,e:GetHandler():GetLinkedZone())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetValue(400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
