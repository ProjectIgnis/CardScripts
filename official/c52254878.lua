--次元同異体ヴァリス
--Dimensional Allotrope Varis
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be destroyed by battle with a monster with the same Type/Attribute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(s.indval)
	c:RegisterEffect(e1)
	--Change its Type and Attribute
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.indval(e,c)
	local handler=e:GetHandler()
	return c:IsAttribute(handler:GetAttribute()) or c:IsRace(handler:GetRace())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local rc=Duel.AnnounceRace(tp,1,RACE_ALL)
	local att=c:IsDifferentRace(rc) and Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL) or c:AnnounceAnotherAttribute(tp)
	e:SetLabel(rc,att)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if (not c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	local rc,att=e:GetLabel()
	if c:IsDifferentRace(rc) then
		--Change monster type
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetValue(rc)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END,2)
		c:RegisterEffect(e1)
	end
	if c:IsAttributeExcept(att) then
		--Change Attribute
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e2:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e2:SetValue(att)
		e2:SetReset(RESETS_STANDARD_DISABLE_PHASE_END,2)
		c:RegisterEffect(e2)
	end
end