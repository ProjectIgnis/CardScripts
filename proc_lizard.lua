local CARD_CLOCK_LIZARD = 51476410
function Auxiliary.addLizardCheck(c)
	--lizard check
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(CARD_CLOCK_LIZARD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
function Auxiliary.addTempLizardCheck(c,filter,tRange,tRange2,reset)
	--lizard check with a reset
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(CARD_CLOCK_LIZARD)
	e1:SetTargetRange(tRange,tRange2)
	e1:SetReset(reset)
	e1:SetTarget(filter)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
end
--it was a prototype that never wanted to work for an unknown reason
function Auxiliary.addContinuousLizardCheck(c,filter,tRange,tRange2,location)
	--lizard check for cards like Yang Zing Creation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(CARD_CLOCK_LIZARD)
	e1:SetTargetRange(tRange,tRange2)
	e1:SetRange(location)
	e1:SetTarget(filter)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	
end
function Fusion.AddContactProc(c,group,op,sumcon,condition,sumtype,desc,cannotBeLizard)
	local mt=c.__index
	local t={}
	if mt.contactfus then
		t=mt.contactfus
	end
	t[c]=true
	mt.contactfus=t
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if not desc then
		e1:SetDescription(2)
	else
		e1:SetDescription(desc)
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	if sumtype then
		e1:SetValue(sumtype)
	end
	e1:SetCondition(Fusion.ContactCon(group,condition))
	e1:SetTarget(Fusion.ContactTg(group))
	e1:SetOperation(Fusion.ContactOp(op))
	c:RegisterEffect(e1)
	if sumcon then
		--spsummon condition
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e2:SetCode(EFFECT_SPSUMMON_CONDITION)
		if type(sumcon)=='function' then
			e2:SetValue(sumcon)
		end
		c:RegisterEffect(e2)
	end
	--lizard check
	if not cannotBeLizard then
		Auxiliary.addLizardCheck(c)
	end
end