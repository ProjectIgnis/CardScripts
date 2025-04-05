--リプロドクス
--Reprodocus
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,nil,2,2)
	--change property
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then	return e:GetHandler():GetLinkedGroup():FilterCount(aux.FaceupFilter(Card.IsLocation,LOCATION_MZONE),nil)>0 end
	e:SetLabel(Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2)))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local lg=c:GetLinkedGroup():Filter(aux.FaceupFilter(Card.IsLocation,LOCATION_MZONE),nil)
	if #lg==0 then return end
	local eff=0
	local val=0
	if e:GetLabel()==0 then
		eff=EFFECT_CHANGE_RACE
		val=Duel.AnnounceAnotherRace(lg,tp)
	else
		eff=EFFECT_CHANGE_ATTRIBUTE
		val=Duel.AnnounceAnotherAttribute(lg,tp)
	end
	for tc in lg:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(eff)
		e1:SetValue(val)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end